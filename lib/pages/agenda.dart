import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ClientNotRegisteredException implements Exception {
  final String message;
  ClientNotRegisteredException(this.message);
}

class AgendaScreen extends StatefulWidget {
  final String userType;
  final String userName;
  final int userId;

  const AgendaScreen({
    super.key,
    required this.userType,
    required this.userName,
    required this.userId,
  });

  @override
  _AgendaScreenState createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  late Future<List<Agendamento>> _agendamentos;

  @override
  void initState() {
    super.initState();
    _agendamentos = _getAgendamentos();
  }

  Future<List<Agendamento>> _getAgendamentos() async {
    final url = 'http://localhost:5118/api/agenda';
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Resposta: ${response.body}");

      if (response.statusCode == 404) {
        final errorData = json.decode(response.body);
        if (errorData['code'] == 'CLIENTE_NAO_CADASTRADO') {
          _redirectToCompleteProfile();
          throw ClientNotRegisteredException(errorData['message']);
        }
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey("\$values")) {
          return (data["\$values"] as List)
              .map((item) => Agendamento.fromJson(item))
              .toList();
        }
        return (data as List)
            .map((item) => Agendamento.fromJson(item))
            .toList();
      }
      throw Exception('Erro na API: ${response.statusCode}');
    } catch (e) {
      debugPrint("Erro ao carregar agendamentos: $e");
      if (e is ClientNotRegisteredException) {
        return [];
      }
      throw Exception('Falha ao carregar os agendamentos');
    }
  }

  void _redirectToCompleteProfile() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Cadastro Incompleto'),
          content: Text('Você precisa completar seu cadastro para agendar.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CompletaCadastroScreen(
                    userId: widget.userId,
                    tipoUsuario: widget.userType,
                  ),
                ),
              ),
              child: Text('Completar Cadastro'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agenda'),
      ),
      body: FutureBuilder<List<Agendamento>>(
        future: _agendamentos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar agendamentos: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final agendamentos = snapshot.data!;

            if (agendamentos.isEmpty) {
              return Center(child: Text('Nenhum agendamento encontrado.'));
            }

            return ListView.builder(
              itemCount: agendamentos.length,
              itemBuilder: (context, index) {
                final agendamento = agendamentos[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  elevation: 4.0,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.userType == 'cliente'
                              ? 'Agendamento com ${agendamento.funcionarioNome}'
                              : 'Agendamento de ${agendamento.clienteNome}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Data: ${agendamento.dataFormatada}'),
                        Text('Status: ${agendamento.status}'),
                        if (agendamento.observacoes.isNotEmpty)
                          Text('Observações: ${agendamento.observacoes}'),
                        if (agendamento.motivoCancelamento != null)
                          Text('Motivo Cancelamento: ${agendamento.motivoCancelamento}'),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('Nenhum agendamento encontrado.'));
          }
        },
      ),
    );
  }
}

class Agendamento {
  final int clienteId;
  final String clienteNome;
  final String funcionarioNome;
  final int funcionarioId;
  final DateTime dataAgendamento;
  final String status;
  final String? motivoCancelamento;
  final String observacoes;

  const Agendamento({
    required this.clienteId,
    required this.clienteNome,
    required this.funcionarioNome,
    required this.funcionarioId,
    required this.dataAgendamento,
    required this.status,
    this.motivoCancelamento,
    required this.observacoes,
  });

  String get dataFormatada {
    return '${dataAgendamento.day.toString().padLeft(2, '0')}/'
           '${dataAgendamento.month.toString().padLeft(2, '0')}/'
           '${dataAgendamento.year} '
           '${dataAgendamento.hour.toString().padLeft(2, '0')}:'
           '${dataAgendamento.minute.toString().padLeft(2, '0')}';
  }

  factory Agendamento.fromJson(Map<String, dynamic> json) {
    return Agendamento(
      clienteId: json['userId'] ?? 0,
      clienteNome: json['clienteNome'] ?? 'Cliente não informado',
      funcionarioNome: json['funcionarioNome'] ?? 'Funcionário não informado',
      funcionarioId: json['funcionarioId'] ?? 0,
      dataAgendamento: DateTime.parse(json['dataAgendamento']),
      status: json['status'] ?? 'ativo',
      motivoCancelamento: json['motivoCancelamento'],
      observacoes: json['observacoes'] ?? '',
    );
  }
}

class AuthResponse {
  final String token;
  final String refreshToken;
  final DateTime expires;
  final UserInfo user;

  AuthResponse({
    required this.token,
    required this.refreshToken,
    required this.expires,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      refreshToken: json['refreshToken'],
      expires: DateTime.parse(json['expires']),
      user: UserInfo.fromJson(json['user']),
    );
  }
}

class UserInfo {
  final int userId;
  final String nome;
  final String tipo;
  final String role;

  UserInfo({
    required this.userId,
    required this.nome,
    required this.tipo,
    required this.role,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      userId: json['userId'],
      nome: json['nome'],
      tipo: json['tipo'],
      role: json['role'],
    );
  }
}


class CompletaCadastroScreen extends StatefulWidget {
  final int userId;
  final String tipoUsuario;

  const CompletaCadastroScreen({
    Key? key,
    required this.userId,
    required this.tipoUsuario,
  }) : super(key: key);

  @override
  _CompletaCadastroScreenState createState() => _CompletaCadastroScreenState();
}

class _CompletaCadastroScreenState extends State<CompletaCadastroScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Completar Cadastro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Complete seu cadastro para continuar'),
            // Add your form fields here
          ],
        ),
      ),
    );
  }
}

