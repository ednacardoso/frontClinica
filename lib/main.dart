import 'package:flutter/material.dart';
import 'pages/login_screen.dart'; // Certifique-se de que o caminho está correto
import 'pages/cliente_dashboard.dart';

void main() {
  runApp(const AppLotus());
}

class AppLotus extends StatelessWidget {
  const AppLotus({super.key});

  
  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = false;
    return MaterialApp(
      title: 'My Project',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 18, 196, 187),
        ),
        useMaterial3: true,
      ),
      home: isLoggedIn ? ClienteDashboard(userType: '', userName: '',) : const LoginScreen(),
    );
  }

  }
