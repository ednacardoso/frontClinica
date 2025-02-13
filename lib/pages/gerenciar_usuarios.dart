
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


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
    final response = await http.get(
      Uri.parse('http://localhost:5118/api/users'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Falha ao carregar usuários');
    }
  }

  void _navegarParaTelaAdicao(BuildContext context, String tipo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdicionarUsuarioScreen(tipo: tipo),
      ),
    );
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
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            await excluirUsuario(context, cliente['id']);
                            setState(() {
                              _usuarios = _carregarUsuarios();
                            });
                          },
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
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            await excluirUsuario(context, funcionario['id']);
                            setState(() {
                              _usuarios = _carregarUsuarios();
                            });
                          },
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
Future<void> excluirUsuario(BuildContext context, int id) async {
  final response = await http.delete(
    Uri.parse('http://localhost:5118/api/users/$id'),
  );

  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuário excluído com sucesso!')));
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir usuário')));
  }
}

class AdicionarUsuarioScreen extends StatefulWidget {
  final String tipo; // 'cliente' ou 'funcionario'

  const AdicionarUsuarioScreen({super.key, required this.tipo});

  @override
  _AdicionarUsuarioScreenState createState() => _AdicionarUsuarioScreenState();
}
  class _AdicionarUsuarioScreenState extends State<AdicionarUsuarioScreen> {
    final _formKey = GlobalKey<FormState>();
    final _nomeController = TextEditingController();
    final _emailController = TextEditingController();
    final _senhaController = TextEditingController();
    final _cpfController = TextEditingController();
    final _apelidoController = TextEditingController();
    final _telefoneController = TextEditingController();
    final _especialidadeController = TextEditingController();
    final _dataNascimentoController = TextEditingController();

    Future<void> criarUsuario() async {
      if (_formKey.currentState!.validate()) {
        try {

          final date = DateTime.parse(_dataNascimentoController.text).toUtc();
          final formattedDate = date.toIso8601String();

          final usuario = {
            'nome': _nomeController.text,
            'email': _emailController.text,
            'senha': _senhaController.text,
            'cpf': _cpfController.text,
            'apelido': _apelidoController.text,
            'telefone': _telefoneController.text,
            'especialidade': widget.tipo == 'funcionario' ? _especialidadeController.text : '',
            'dataNascimento': formattedDate,
            'tipo': widget.tipo,  // 'cliente' ou 'funcionario'
          };

          final response = await http.post(
            Uri.parse('http://localhost:5118/api/users'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(usuario),
          );

          if (response.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Usuário criado com sucesso!')));
            Navigator.pop(context); // Return to previous screen
          } else {
            throw Exception('Falha ao criar usuário');
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao criar usuário: $e')));
        }
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: Text('Adicionar ${widget.tipo}')),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _nomeController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira um nome';
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: 'Nome'),
                  ),
                  TextFormField(
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira um email';
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  TextFormField(
                    controller: _senhaController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira uma senha';
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: 'Senha'),
                  ),
                  TextFormField(
                    controller: _cpfController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira um CPF';
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: 'CPF'),
                  ),
                  TextFormField(
                    controller: _apelidoController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira um apelido';
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: 'Apelido'),
                  ),
                  TextFormField(
                    controller: _telefoneController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira um telefone';
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: 'Telefone'),
                  ),
                  if (widget.tipo == 'funcionario')
                    TextFormField(
                      controller: _especialidadeController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira uma especialidade';
                        }
                        return null;
                      },
                      decoration: InputDecoration(labelText: 'Especialidade'),
                    ),
                  TextFormField(
                    controller: _dataNascimentoController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira uma data de nascimento';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                    labelText: 'Data de Nascimento',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          _dataNascimentoController.text = 
                              "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                        }
                      },
                    ),
                  ),
                  readOnly: true,                
                ),
                 SizedBox(height: 20), // Adds some spacing
                  ElevatedButton(
                    onPressed: criarUsuario,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                    child: Text(
                      'Salvar ${widget.tipo}',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
