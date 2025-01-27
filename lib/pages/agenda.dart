import 'package:flutter/material.dart';
import 'dart:convert'; // Para trabalhar com JSON
import 'package:http/http.dart' as http;

class AgendaScreen extends StatelessWidget {
  final String userType; // Tipo de usuário (cliente, funcionário, administrador)
  final String userName; // Nome do cliente ou funcionário

  AgendaScreen({required this.userType, required this.userName});

  // Método para buscar agendamentos da API
  Future<List<Map<String, String>>> fetchAgendamentos() async {
  final response = await http.get(Uri.parse('http://localhost:5118/api/agendamentos'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    // Certifique-se de que os valores dentro dos mapas são Strings
    return List<Map<String, String>>.from(data.map((item) => {
          'id': item['id'] as int,
          'descricao': item['descricao'] as String,
        }));
  } else {
    throw Exception('Erro ao buscar agendamentos');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        backgroundColor: const Color.fromARGB(255, 18, 196, 187),
      ),
      body: FutureBuilder<List<Map<String, String>>>(
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

            // Filtrar os agendamentos com base no tipo de usuário
            final List<Map<String, String>> agendamentosFiltrados =
                userType == 'administrador'
                    ? agendamentos
                    : userType == 'funcionario'
                        ? agendamentos
                            .where((agendamento) =>
                                agendamento['funcionario'] == userName)
                            .toList()
                        : agendamentos
                            .where((agendamento) =>
                                agendamento['cliente'] == userName)
                            .toList();

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
                      agendamento['cliente']!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Funcionário: ${agendamento['funcionario']}"),
                        Text("Data: ${agendamento['dataAgendamento']}"),
                        Text("Status: ${agendamento['Status']}"),
                        Text("Observações: ${agendamento['observacoes']}"),
                      ],
                    ),
                    trailing: Icon(
                      agendamento['Status'] == 'Agendado'
                          ? Icons.event_available
                          : Icons.event_busy,
                      color: agendamento['Status'] == 'Agendado'
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
