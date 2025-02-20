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
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    try {
      final response = await http.get(
        Uri.parse('http://localhost:5118/api/agendamentos/usuario'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data is Map && data.containsKey("values")) {
          return (data["values"] as List)
              .map((item) => Agendamento.fromJson(item))
              .toList();
        }

        if (data is List) {
          return data.map((item) => Agendamento.fromJson(item)).toList();
        }

        throw Exception('Formato de resposta inválido');
      }

      throw Exception('Erro na requisição: ${response.statusCode}');
    } catch (e) {
      debugPrint("Erro ao buscar agendamentos: $e");
      rethrow;
    }
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
  final int id;
  final DateTime dataAgendamento;
  final String status;
  final String observacoes;
  final String? motivoCancelamento;
  final int clienteId;
  final String clienteNome;
  final int funcionarioId;
  final String funcionarioNome;

  const Agendamento({
    required this.id,
    required this.dataAgendamento,
    required this.status,
    required this.observacoes,
    this.motivoCancelamento,
    required this.clienteId,
    required this.clienteNome,
    required this.funcionarioId,
    required this.funcionarioNome,
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
     id: json['id'],
      dataAgendamento: DateTime.parse(json['dataAgendamento']), // Convert string to DateTime
      status: json['status'],
      observacoes: json['observacoes'],
      motivoCancelamento: json['motivoCancelamento'],
      clienteId: json['clienteId'],
      clienteNome: json['clienteNome'],
      funcionarioId: json['funcionarioId'],
      funcionarioNome: json['funcionarioNome'],
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
    super.key,
    required this.userId,
    required this.tipoUsuario,
  });

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

