import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RealizarAgendamentoScreen extends StatefulWidget {
  final String userType; // Tipo de usuário (cliente, funcionário, administrador)
  final int userId; // ID do usuário logado
  

  const RealizarAgendamentoScreen({
    super.key,    
    required this.userType,
    required this.userId,
  });

  @override
  State<RealizarAgendamentoScreen> createState() => _RealizarAgendamentoScreenState();
}

class _RealizarAgendamentoScreenState extends State<RealizarAgendamentoScreen> {
  List<Map<String, dynamic>> funcionarios = [];
  int? funcionarioSelecionado;
  int? clienteSelecionado;
  DateTime? dataAgendamento;
  String statusSelecionado = "Ativo";
  TextEditingController observacoesController = TextEditingController();
  TextEditingController motivoCancelamentoController = TextEditingController();

  // Add role checking
  String? userRole; // Add this to track user role
  List<Map<String, dynamic>> clients = []; // Add this for admin to select clients 

 @override
void initState() {
  super.initState();
  _getUserRole();
  carregarFuncionarios();

  if (widget.userType == 'cliente') {
    getClienteId(widget.userId).then((clienteId) {
      setState(() {
        clienteSelecionado = clienteId;
      });
      debugPrint("Cliente logado (clienteId) atribuído: $clienteSelecionado");
    });
  } else {
    carregarClientes();
  }
}


  Future<void> _getUserRole() async {   

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', widget.userId);

    int? userId = prefs.getInt('userId');
    debugPrint("User ID recuperado: $userId");
      
    final role = prefs.getString('userRole');
    debugPrint("User Role from SharedPreferences: $role"); 
    
    setState(() {
      userRole = role;
    });
  }

 Future<void> carregarClientes() async {
  
  final response = await http.get(Uri.parse('http://localhost:5118/api/clientes'));
  debugPrint("Resposta da API de clientes: ${response.body}");

  if (response.statusCode == 200) {
    // Directly parse as List
    final List<dynamic> data = json.decode(response.body);
    setState(() {
      clients = List<Map<String, dynamic>>.from(data);
    });
  } else {
    throw Exception('Erro ao carregar clientes');
  }
}

Future<void> carregarFuncionarios() async {
  final response = await http.get(Uri.parse('http://localhost:5118/api/funcionarios'));
  print("Resposta da API de funcionários: ${response.body}");

  if (response.statusCode == 200) {
    // Directly parse as List
    final List<dynamic> data = json.decode(response.body);
    setState(() {
      funcionarios = List<Map<String, dynamic>>.from(data);
    });
  } else {
    throw Exception('Erro ao carregar funcionários');
  }
}



  Future<void> selecionarData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );

    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          dataAgendamento = DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<bool> verificarCliente(int clienteId) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5118/api/clientes/$clienteId')
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Erro ao verificar cliente: $e');
      return false;
    }
  }

  Future<int?> getClienteId(int userId) async {
    final response = await http.get(
      Uri.parse('http://localhost:5118/api/clientes/cliente/$userId')
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['id'];
    }
    return null;
  }

  void enviarAgendamento() async {
  try {
    if (clienteSelecionado == null) {
      throw Exception('Por favor selecione um cliente');
    }
    if (funcionarioSelecionado == null) {
      throw Exception('Por favor selecione um funcionário');
    }
    if (dataAgendamento == null) {
      throw Exception('Por favor selecione uma data e hora');
    }

    final agendamento = {  
      "clienteId": clienteSelecionado,
      "funcionarioId": funcionarioSelecionado,  
      "dataAgendamento": dataAgendamento?.toUtc().toIso8601String(),
      "status": statusSelecionado,
      "observacoes": observacoesController.text,
      "motivoCancelamento": null,  
    };

    debugPrint("Dados do agendamento: ${jsonEncode(agendamento)}");

    final response = await http.post(
      Uri.parse('http://localhost:5118/api/agendamentos'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(agendamento),
    );

    if (response.statusCode == 201) {
      if (!context.mounted) return;
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Agendamento realizado com sucesso!"),
          duration: Duration(seconds: 3),
        ),
      );

      // Add delay to show the message
      await Future.delayed(const Duration(seconds: 3));

      if (!context.mounted) return;
      // Simply pop the current screen
      Navigator.of(context).pop();
      
    } else {
      throw Exception("Erro ao agendar: ${response.body}");
    }
  } catch (e) {
    debugPrint("Erro no agendamento: $e");
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  }
}

  @override  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Realizar Agendamento')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Client selection for admin and funcionario
              if (widget.userType != 'cliente') ...[
                Text("Selecione um Cliente:", style: TextStyle(fontSize: 16)),
                DropdownButton<int>(
                  value: clienteSelecionado,
                  hint: Text("Escolha um cliente:"),
                  onChanged: (int? newValue) {
                    setState(() {
                      clienteSelecionado = newValue;
                    });
                  },
                  items: clients.map<DropdownMenuItem<int>>((cliente) {
                    return DropdownMenuItem<int>(
                      value: cliente["id"],
                      child: Text(cliente["nome"]),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
              ],

              // Professional selection
              Text("Selecione um Funcionário:", style: TextStyle(fontSize: 16)),
              DropdownButton<int>(
                value: funcionarioSelecionado,
                hint: Text("Escolha um funcionário:"),
                onChanged: (int? newValue) {
                  setState(() {
                    funcionarioSelecionado = newValue;
                  });
                },
                items: funcionarios.map<DropdownMenuItem<int>>((funcionario) {
                  return DropdownMenuItem<int>(
                    value: funcionario["id"],
                    child: Text(funcionario["nome"]),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),

              Text("Data e Hora do Agendamento:", style: TextStyle(fontSize: 16)),
              TextButton(
                onPressed: () => selecionarData(context),
                child: Text(dataAgendamento == null
                    ? "Escolher Data e Hora"
                    : "${dataAgendamento!.day}/${dataAgendamento!.month}/${dataAgendamento!.year} - ${dataAgendamento!.hour}:${dataAgendamento!.minute}"),
              ),
              SizedBox(height: 20),

              Text("Status do Agendamento:", style: TextStyle(fontSize: 16)),
              DropdownButton<String>(
                value: statusSelecionado,
                onChanged: (String? newValue) {
                  setState(() {
                    statusSelecionado = newValue!;
                  });
                },
                items: ["Ativo", "Cancelado"].map<DropdownMenuItem<String>>((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),

              Text("Observações:", style: TextStyle(fontSize: 16)),
              TextField(
                controller: observacoesController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Digite as observações:",
                ),
                maxLines: 2,
              ),
              SizedBox(height: 20),

              if (statusSelecionado == "Cancelado") 
                Column(
                  children: [
                    Text("Motivo do Cancelamento:", 
                        style: TextStyle(fontSize: 16, color: Colors.red)),
                    TextField(
                      controller: motivoCancelamentoController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Informe o motivo do cancelamento",
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: 20),
                  ],
                ),
          
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    print("Botão Agendar foi pressionado!"); // Debug
                    enviarAgendamento();
                  },
                  child: Text("Agendar"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}