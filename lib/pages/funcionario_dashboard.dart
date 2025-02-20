import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FuncionarioDashboard extends StatefulWidget {
  final String userType;
  final String userName;
  final bool isLoggedIn;
  final int userId;

  const FuncionarioDashboard({
    super.key,
    required this.userType,
    required this.userName,
    required this.isLoggedIn,
    required this.userId,
  });

  @override
  _FuncionarioDashboardState createState() => _FuncionarioDashboardState();
}

class _FuncionarioDashboardState extends State<FuncionarioDashboard> {
  List<dynamic> _funcionarios = [];

  @override
  void initState() {
    super.initState();
    _fetchFuncionarios();
  }

  Future<void> _fetchFuncionarios() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5118/api/funcionarios'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _funcionarios = jsonDecode(response.body);
        });
      } else {
        // Tratar erro
        final Map<String, dynamic> data = jsonDecode(response.body);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Erro'),
            content: Text(data['message']),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('Erro ao buscar funcionários: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bem-vindo, Funcionario ${widget.userName}!"), 
        backgroundColor: const Color.fromARGB(255, 18, 196, 187),      
        ),      
      bottomNavigationBar: BottomNavigationBar(        
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Realizar Agendamento',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Agenda',
          ),          
        ],
        selectedItemColor: const Color.fromARGB(255, 18, 196, 187),
      ),
    );
  }
}
