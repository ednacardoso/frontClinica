import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'realizar_agendamento.dart';
import 'agenda.dart';


class ClienteDashboard extends StatefulWidget {
  final String userType;
  final String userName;
  final int userId;

  const ClienteDashboard({
    super.key,
    required this.userType,
    required this.userName,
    required this.userId,
  });

  @override
  _ClienteDashboardState createState() => _ClienteDashboardState();
}
class _ClienteDashboardState extends State<ClienteDashboard> {
  int _selectedIndex = 0;
  List<dynamic> _clientes = [];

  @override
  void initState() {
    super.initState();
    _fetchClientes();
  }

  Future<void> _fetchClientes() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5118/api/clientes'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _clientes = jsonDecode(response.body);
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
      debugPrint('Erro ao buscar clientes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bem-vindo, Cliente ${widget.userName}!"),
        backgroundColor: const Color.fromARGB(255, 18, 196, 187),      
      ),
      body: _selectedIndex == 0
    ? RealizarAgendamentoScreen(
        userType: widget.userType,
        userId: widget.userId,
      )
    : AgendaScreen(
        userId: widget.userId,
        userType: widget.userType,
        userName: widget.userName,  // Added the userName parameter
      ),


      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
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
