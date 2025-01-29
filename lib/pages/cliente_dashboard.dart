import 'package:flutter/material.dart';
import 'realizar_agendamento.dart';
import 'agenda.dart';

class ClienteDashboard extends StatefulWidget {
  final String userType; // Tipo de usuário (cliente ou funcionário)
  final String userName;

  const ClienteDashboard({super.key, required this.userType, required this.userName});

  @override
  _ClienteDashboardState createState() => _ClienteDashboardState(); // Implementação do createState
}

class _ClienteDashboardState extends State<ClienteDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    RealizarAgendamentoScreen(),
    AgendaScreen(userType: '', userName: '',), // Passar os parâmetros corretos aqui
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
        title: Text("Bem-vindo, ${widget.userName}"), // Acessando os parâmetros passados
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
