import 'package:flutter/material.dart';
import 'agenda.dart';
import 'realizar_agendamento.dart';

class FuncionarioDashboard extends StatefulWidget {
  final String userType; // Tipo de usuário (cliente ou funcionário)
  final String userName;

  const FuncionarioDashboard ({super.key, required this.userType, required this.userName});

  @override
  _FuncionarioDashboardState createState() => _FuncionarioDashboardState();
}

class _FuncionarioDashboardState extends State<FuncionarioDashboard > {
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
