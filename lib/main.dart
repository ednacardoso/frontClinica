import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/login_screen.dart'; // Certifique-se de que o caminho está correto
import 'pages/cliente_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isLoggedIn = await checkLoginStatus();
  runApp(AppLotus(isLoggedIn: isLoggedIn));
}

class AppLotus extends StatelessWidget {
  final bool isLoggedIn;

  const AppLotus({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Project',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 18, 196, 187),
        ),
        useMaterial3: true,
      ),
      home: isLoggedIn
          ? ClienteDashboard(userType: 'cliente', userName: 'Usuario') // Passar valores corretos para o nome e tipo
          : const LoginScreen(),
    );
  }
}

Future<bool> checkLoginStatus() async {
  // Verifica se o token JWT está armazenado
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('jwt_token'); // 'jwt_token' é a chave que você usará para armazenar o token
  return token != null; // Se o token estiver presente, o usuário está logado
}
