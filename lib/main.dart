import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/login_screen.dart'; // Certifique-se de que o caminho está correto
import 'pages/cliente_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Map<String, dynamic> loginData = await checkLoginStatus();

  runApp(AppLotus(
    isLoggedIn: loginData['isLoggedIn'] ?? false,
    userId: loginData['userId'] ?? 0,
    userType: loginData['userType'] ?? 'cliente',
    userName: loginData['userName'] ?? 'Usuário',
  ));
}

class AppLotus extends StatelessWidget {
  final bool isLoggedIn;
  final int userId;
  final String userType;
  final String userName;

  const AppLotus({
    super.key,
    required this.isLoggedIn,
    required this.userId,
    required this.userType,
    required this.userName,
  });

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
          ? ClienteDashboard(
              userType: userType,
              userName: userName,
              userId: userId, // Agora `userId` é passado corretamente
            )
          : const LoginScreen(),
    );
  }
}


Future<Map<String, dynamic>> checkLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  
  String? token = prefs.getString('jwt_token');
  int? userId = prefs.getInt('user_id'); // Recuperando userId
  String? userType = prefs.getString('user_type'); // Recuperando tipo de usuário
  String? userName = prefs.getString('user_name'); // Recuperando nome do usuário

  if (token != null && userId != null && userType != null && userName != null) {
    return {
      'isLoggedIn': true,
      'userId': userId,
      'userType': userType,
      'userName': userName,
    };
  } else {
    return {'isLoggedIn': false};
  }
}
