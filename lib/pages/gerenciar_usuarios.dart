import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'registro_usuario.dart';

class GerenciarUsuariosScreen extends StatefulWidget {
  const GerenciarUsuariosScreen({super.key});

  @override
  State<GerenciarUsuariosScreen> createState() => _GerenciarUsuariosScreenState();
}

class _GerenciarUsuariosScreenState extends State<GerenciarUsuariosScreen> {
  Future<List<dynamic>>? _usuarios;

  @override
  void initState() {
    super.initState();
    _usuarios = _carregarUsuarios();
  }

  Future<List<dynamic>> _carregarUsuarios() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';

    final response = await http.get(
      Uri.parse('http://localhost:5118/api/auth/admin-only'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey("values")) {
        return (data["values"] as List).map((usuario) {
          return {
            "id": usuario["userId"] ?? 0,
            "nome": usuario["nome"] ?? "Sem Nome",
            "email": usuario["email"] ?? "Sem Email",
            "tipo": usuario["tipo"] ?? "desconhecido",
          };
        }).toList();
      }
    }
    throw Exception('Falha ao carregar usuários');
  }

  Future<void> resetarSenha(BuildContext context, int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5118/api/auth/reset-password/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Senha resetada com sucesso!')),
        );
      } else {
        throw Exception('Falha ao resetar senha');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao resetar senha: $e')),
      );
    }
  }

  void _navegarParaTelaAdicao(BuildContext context, String tipo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterScreen(tipo: tipo),
      ),
    );
  }

  Future<void> excluirUsuario(BuildContext context, int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';

    final response = await http.delete(
      Uri.parse('http://localhost:5118/api/users/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuário excluído com sucesso!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir usuário')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gerenciar Usuários')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ElevatedButton(
              onPressed: () => _navegarParaTelaAdicao(context, 'cliente'),
              child: const Text('Adicionar Cliente'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ElevatedButton(
              onPressed: () => _navegarParaTelaAdicao(context, 'funcionario'),
              child: const Text('Adicionar Funcionário'),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _usuarios,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erro ao carregar usuários'));
                }

                final usuarios = snapshot.data!;
                final clientes = usuarios.where((u) => u['tipo'] == 'cliente').toList();
                final funcionarios = usuarios.where((u) => u['tipo'] == 'funcionario').toList();

                return ListView(
                  children: [
                    if (clientes.isNotEmpty) ...[
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Clientes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      ...clientes.map((cliente) => ListTile(
                        title: Text(cliente['nome']),
                        subtitle: Text(cliente['email']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.lock_reset),
                              onPressed: () async {
                                await resetarSenha(context, cliente['id']);
                                setState(() {
                                  _usuarios = _carregarUsuarios();
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                await excluirUsuario(context, cliente['id']);
                                setState(() {
                                  _usuarios = _carregarUsuarios();
                                });
                              },
                            ),
                          ],
                        ),
                      )),
                    ],
                    if (funcionarios.isNotEmpty) ...[
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Funcionários', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      ...funcionarios.map((funcionario) => ListTile(
                        title: Text(funcionario['nome']),
                        subtitle: Text('${funcionario['email']} - ${funcionario['especialidade']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.lock_reset),
                              onPressed: () async {
                                await resetarSenha(context, funcionario['id']);
                                setState(() {
                                  _usuarios = _carregarUsuarios();
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                await excluirUsuario(context, funcionario['id']);
                                setState(() {
                                  _usuarios = _carregarUsuarios();
                                });
                              },
                            ),
                          ],
                        ),
                      )),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
