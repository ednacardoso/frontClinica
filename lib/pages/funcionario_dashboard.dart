import 'package:flutter/material.dart';
import 'agenda.dart';
import 'realizar_agendamento.dart';

class FuncionarioDashboard extends StatefulWidget {
  final String userType; // Tipo de usuário (cliente ou funcionário)
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
  int _selectedIndex = 0;
  late List<Widget> _pages; // Use 'late' para inicializar no initState

  @override
  void initState() {
    super.initState();
    // Inicialize _pages no initState para acessar os parâmetros do widget
    _pages = [
      RealizarAgendamentoScreen(
        userType: widget.userType,
        userId: widget.userId,
      ),
      AgendaScreen(
        userType: widget.userType,
        userName: widget.userName,
        userId: widget.userId,
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bem-vindo(a) ao app da Lótus! - Funcionário ${widget.userName}"),
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