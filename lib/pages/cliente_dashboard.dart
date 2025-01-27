import 'package:flutter/material.dart';
import 'realizar_agendamento.dart';
import 'agenda.dart';
import '../models/usuario.dart';

class ClienteDashboard extends StatefulWidget {
  final String userType; // Tipo de usuário (cliente ou funcionário)
  final String userName;

  ClienteDashboard({required this.userType, required this.userName});

  @override
  _ClienteDashboardState createState() => _ClienteDashboardState();
}

class _ClienteDashboardState extends State<ClienteDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    RealizarAgendamentoScreen(),
    AgendaScreen(userType: '', userName: '',),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bem-vindo(a) ao app da Lótus!'),
        backgroundColor: const Color.fromARGB(255, 18, 196, 187),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
