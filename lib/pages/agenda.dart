import 'package:flutter/material.dart';
import 'dart:convert'; // Para trabalhar com JSON
import 'package:http/http.dart' as http;

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
  final url = 'http://localhost:5118/api/agenda/usuario'; // Nova rota unificada
  
  try {
    final response = await http.get(Uri.parse(url));
    print("Resposta da API: ${response.body}");

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
    print("Erro ao carregar agendamentos: $e");
    throw Exception('Falha ao carregar os agendamentos');
  }
}


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Agendamento>>(
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
                      'Agendamento com ${agendamento.clienteNome}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Profissional: ${agendamento.funcionarioNome}}'),
                    Text('Data: ${agendamento.dataFormatada}'), // Usando data formatada
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
  final int funcionarioId;
  final Cliente clienteNome;
  final String funcionarioNome;  

  const Agendamento({
    required this.id,
    required this.dataAgendamento,
    required this.status,
    required this.observacoes,
    this.motivoCancelamento,
    required this.clienteId,
    required this.funcionarioId,
    required this.clienteNome,
    required this.funcionarioNome,
  });

  factory Agendamento.fromJson(Map<String, dynamic> json) {
    return Agendamento(
      id: json['id'] ?? 0,
      dataAgendamento: DateTime.parse(json['dataAgendamento'] ?? '2023-01-01T00:00:00Z'),
      status: json['status'] ?? 'Ativo',
      observacoes: json['observacoes'] ?? 'sem observações',
      motivoCancelamento: json['motivoCancelamento'] ?? 'sem motivos',
      clienteId: json['clienteId'] ?? 0,
      funcionarioId: json['funcionarioId'] ?? 0,
      clienteNome: json['clienteNome'] ?? 'Nome não informado',
      funcionarioNome: json['funcionarioNome'] ?? 'Nome não informado',
    );
  }

  String get dataFormatada {
    return '${dataAgendamento.day}/${dataAgendamento.month}/${dataAgendamento.year} ${dataAgendamento.hour}:${dataAgendamento.minute.toString().padLeft(2, '0')}';
  }
}

class Cliente {
  final int id;
  final String nome;
  final int userId;
  final String cpf;
  final String? apelido;
  final String email;
  final String telefone;
  final DateTime dataCadastro;
  final DateTime? dataNascimento;
  final String descricao;

  Cliente({
    required this.id,
    required this.nome,
    required this.userId,
    required this.cpf,
    this.apelido,
    required this.email,
    required this.telefone,
    required this.dataCadastro,
    this.dataNascimento,
    required this.descricao,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'] ?? 0,
      nome: json['nome'],
      userId: json['userId'] ?? 0,
      cpf: json['cpf'] ?? 'CPF não disponível',
      apelido: json['apelido'],
      email: json['email'] ?? 'Email não disponível',
      telefone: json['telefone'] ?? 'Telefone não disponível',
      dataCadastro: DateTime.parse(json['dataCadastro'] ?? '2023-01-01T00:00:00Z'),
      dataNascimento: json['dataNascimento'] != null ? DateTime.parse(json['dataNascimento']) : null,
      descricao: json['descricao'] ?? 'Sem descrição',
    );
  }
}

class Funcionario {
  final int id;
  final String nome;
  final int userId;
  final String cpf;
  final String especialidade;
  final String? apelido;
  final String email;
  final String telefone;
  final DateTime dataCadastro;
  final DateTime? dataNascimento;
  final String descricao;

  Funcionario({
    required this.id,
    required this.nome,
    required this.userId,
    required this.cpf,
    required this.especialidade,
    this.apelido,
    required this.email,
    required this.telefone,
    required this.dataCadastro,
    this.dataNascimento,
    required this.descricao,
  });

  factory Funcionario.fromJson(Map<String, dynamic> json) {
    return Funcionario(
      id: json['id'] ?? 0,
      nome: json['nome'],
      userId: json['userId'] ?? 0,
      cpf: json['cpf'] ?? 'CPF não disponível',
      especialidade: json['especialidade'] ?? 'Especialidade não disponível',
      apelido: json['apelido'],
      email: json['email'] ?? 'Email não disponível',
      telefone: json['telefone'] ?? 'Telefone não disponível',
      dataCadastro: DateTime.parse(json['dataCadastro'] ?? '2023-01-01T00:00:00Z'),
      dataNascimento: json['dataNascimento'] != null ? DateTime.parse(json['dataNascimento']) : null,
      descricao: json['descricao'] ?? 'Sem descrição',
    );
  }
}