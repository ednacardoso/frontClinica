import 'package:flutter/material.dart';
import 'dart:convert'; // Para trabalhar com JSON
import 'package:http/http.dart' as http;

class AgendaScreen extends StatelessWidget {
  final String userType; // Tipo de usuário (cliente, funcionário, administrador)
  final String userName; // Nome do cliente ou funcionário

  const AgendaScreen({super.key, required this.userType, required this.userName});

  // Método para buscar agendamentos da API
  Future<List<Map<String, dynamic>>> fetchAgendamentos() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:5118/api/agenda')); // Use o IP correto

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Erro ao buscar agendamentos: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro de conexão: $e'); // Log para depuração
      throw Exception('Erro de conexão: Verifique se o servidor está rodando');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        backgroundColor: const Color.fromARGB(255, 18, 196, 187),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchAgendamentos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Erro: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum agendamento disponível.',
                style: TextStyle(fontSize: 16),
              ),
            );
          } else {
            final agendamentos = snapshot.data!;
            print('Agendamentos recebidos: $agendamentos'); // Log para depurar

            // Filtrar os agendamentos com base no tipo de usuário
            // Replace the existing filtering logic with this:
            final List<Map<String, dynamic>> agendamentosFiltrados =
                userType == 'administrador'
                    ? agendamentos
                    : userType == 'funcionario'
                        ? agendamentos
                            .where((agendamento) =>
                                agendamento['status'] == 'agendado')
                            .toList()
                        : agendamentos
                            .where((agendamento) =>
                                agendamento['cliente'] == userName)
                            .toList();


            if (agendamentosFiltrados.isEmpty) {
              return const Center(
                child: Text(
                  'Nenhum agendamento correspondente encontrado.',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              itemCount: agendamentosFiltrados.length,
              itemBuilder: (context, index) {
                final agendamento = agendamentosFiltrados[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      agendamento['cliente'] ?? 'Cliente não informado',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Funcionário: ${agendamento['funcionario'] ?? 'Não informado'}"),
                        Text("Data: ${agendamento['dataAgendamento'] ?? 'Sem data'}"),
                        Text("Status: ${agendamento['status'] ?? 'Desconhecido'}"),
                        Text("Observações: ${agendamento['observacoes'] ?? 'Sem observações'}"),
                      ],
                    ),
                    trailing: Icon(
                      agendamento['status'] == 'agendado'
                          ? Icons.event_available
                          : Icons.event_busy,
                      color: agendamento['status'] == 'agendado'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
