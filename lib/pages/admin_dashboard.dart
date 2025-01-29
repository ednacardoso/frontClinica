import 'package:flutter/material.dart';
import 'agenda.dart';
import 'realizar_agendamento.dart';

class AdminDashboard extends StatefulWidget {
  final String userType; // Tipo de usuário (cliente ou funcionário)
  final String userName;
  final bool isLoggedIn;  // Add this line

  const AdminDashboard ({super.key, required this.userType, required this.userName, required this.isLoggedIn, });

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
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
        title: Text("Bem-vindo, ${widget.userName}!"), // Changed this line
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

