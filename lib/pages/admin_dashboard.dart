import 'package:flutter/material.dart';
import 'agenda.dart';
import 'realizar_agendamento.dart';
import 'gerenciar_usuarios.dart';


class AdminDashboard extends StatefulWidget {
  final String userType;
  final String userName;
  final bool isLoggedIn;
  final int userId;  // Add this field

  const AdminDashboard({
    super.key,
    required this.userType,
    required this.userName,
    required this.isLoggedIn,
    required this.userId,  // Add this parameter
  });

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // Verifique se a lista de páginas está sendo configurada corretamente
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
      GerenciarUsuariosScreen(),  // Tela de gerenciamento de usuários
    ];

    // Depuração para garantir que a lista tenha 3 elementos
    debugPrint('Total de páginas: ${_pages.length}');
  }

  void _onItemTapped(int index) {
    if (index >= 0 && index < _pages.length) { // Verifique o índice antes de acessá-lo
      setState(() {
        _selectedIndex = index;
      });
    } else {
      debugPrint("Índice fora do alcance: $index");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bem-vindo, Administrador ${widget.userName}!"), 
        backgroundColor: const Color.fromARGB(255, 18, 196, 187),
      ),
      body: _pages.isNotEmpty ? _pages[_selectedIndex] : Center(child: CircularProgressIndicator()), // Verifique se a lista não está vazia
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
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Gerenciar Usuários',  
          ),
        ],
        selectedItemColor: const Color.fromARGB(255, 18, 196, 187),
      ),
    );
  }
}
