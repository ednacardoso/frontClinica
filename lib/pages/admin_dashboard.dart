import 'package:flutter/material.dart';
import 'agenda.dart';
import 'realizar_agendamento.dart';

class AdminDashboard extends StatefulWidget {
  final String userType;
  final String userName;
  final bool isLoggedIn;
  final int userId;  // Add this field

  const AdminDashboard({
    Key? key,
    required this.userType,
    required this.userName,
    required this.isLoggedIn,
    required this.userId,  // Add this parameter
  }) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      RealizarAgendamentoScreen(
        userType: widget.userType,
        userId: widget.userId,
      ),
      AgendaScreen(userType: widget.userType, userName: widget.userName, userId: widget.userId),
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
        title: Text("Bem-vindo, Administrador ${widget.userName}!"), // Changed this line
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

