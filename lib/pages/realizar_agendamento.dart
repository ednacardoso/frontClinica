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

    // Se o usuário for um cliente, define o clienteSelecionado como o userId
    if (widget.userType == 'cliente') {
      clienteSelecionado = widget.userId;
    } else {
      // Se for administrador ou funcionário, carrega a lista de clientes
      carregarClientes();
    }
  }

  Future<void> _getUserRole() async {
    final prefs = await SharedPreferences.getInstance();    
    final role = prefs.getString('userRole');
    print("User Role from SharedPreferences: $role"); 
    
    setState(() {
      userRole = role;
    });
  }

 Future<void> carregarClientes() async {
  final response = await http.get(Uri.parse('http://localhost:5118/api/clientes'));
  print("Resposta da API de clientes: ${response.body}");

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);

    if (data.containsKey("\$values") && data["\$values"] is List) {
      setState(() {
        clients = List<Map<String, dynamic>>.from(data["\$values"]);
      });
    } else {
      throw Exception('Formato inesperado da resposta da API de clientes');
    }
  } else {
    throw Exception('Erro ao carregar clientes');
  }
}

  Future<void> carregarFuncionarios() async {
  final response = await http.get(Uri.parse('http://localhost:5118/api/funcionarios'));
  print("Resposta da API de funcionários: ${response.body}");

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);

    if (data.containsKey("\$values") && data["\$values"] is List) {
      setState(() {
        funcionarios = List<Map<String, dynamic>>.from(data["\$values"]);
      });
    } else {
      throw Exception('Formato inesperado da resposta da API de funcionários');
    }
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

  void enviarAgendamento() async {
  try {
    print("Cliente selecionado antes do envio: $clienteSelecionado");
    print("Função enviarAgendamento() foi chamada!");

    int clienteId;
    if (widget.userType == 'cliente') {
      // Se o usuário for um cliente, usa o userId como clienteId
      clienteId = widget.userId;
    } else {
      // Se for administrador ou funcionário, usa o cliente selecionado
      if (clienteSelecionado == null) {
        throw Exception('Por favor, selecione um cliente');
      }
      clienteId = clienteSelecionado!;
    }

    if (funcionarioSelecionado == null || dataAgendamento == null) {
      throw Exception("Preencha todos os campos obrigatórios!");
    }

    final agendamento = {
      "clienteId": clienteId,
      "funcionarioId": funcionarioSelecionado,
      "dataAgendamento": dataAgendamento?.toUtc().toIso8601String(),
      "status": statusSelecionado.toLowerCase(),
      "observacoes": observacoesController.text,
      "motivoCancelamento": statusSelecionado == "Cancelado" ? motivoCancelamentoController.text : null,      
    };

    print("Dados sendo enviados: ${jsonEncode(agendamento)}");

    final response = await http.post(
      Uri.parse('http://localhost:5118/api/agenda'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(agendamento),
    );

    print("Resposta da API: ${response.statusCode} - ${response.body}");

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Agendamento realizado com sucesso!")),
      );
    } else {
      throw Exception("Erro ao agendar: ${response.body}");
    }
  } catch (e) {
    print("Erro no envio do agendamento: $e");
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