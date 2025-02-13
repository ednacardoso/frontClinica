import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cliente_dashboard.dart';
import 'funcionario_dashboard.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'admin_dashboard.dart';
import 'dart:async';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  final _storage = FlutterSecureStorage();
  bool isLoggedIn = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Função para autenticar o usuário
  Future<void> _login() async {
  final email = _emailController.text;
  final password = _passwordController.text;

  final url = Uri.parse('http://localhost:5118/api/auth/login');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'email': email,
      'SenhaHash': password,
    }),
  );

  if (response.statusCode == 200) {
    if (!mounted) return; // Verifica se o widget ainda está montado

    final data = json.decode(response.body);

    // Depuração: Verifique a estrutura do JSON retornado
    print(data);

    // Extrair valores do JSON
    final user = data['user']; // Acesse o objeto 'user'
    String userType = user['tipo'] ?? 'cliente'; // Tipo de usuário
    String userName = user['nome'] ?? 'Usuário'; // Nome do usuário
    int userId = user['id'] ?? 0; // ID do usuário

    // Salvar JWT token
    await _storage.write(key: 'jwt_token', value: data['token'] ?? '');

    final token = data['token'];
    if (token is String) {
      await _storage.write(key: 'jwt_token', value: token);
    } else {
      print("Erro: Token não é uma String - $token");
    }


    // Salvar user role
    await _storage.write(key: 'userRole', value: userType);

    // Salvar user name
    await _storage.write(key: 'userName', value: userName);

    // Salvar userId
    await _storage.write(key: 'userId', value: userId.toString());

    // Redirecionar para o dashboard correto
    if (userType == 'cliente') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ClienteDashboard(
            userType: userType,
            userName: userName,
            userId: userId,
          ),
        ),
      );
    } else if (userType == 'funcionario') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FuncionarioDashboard(
            userType: userType,
            userName: userName,
            isLoggedIn: true,
            userId: userId,
          ),
        ),
      );
    } else if (userType == 'administrador') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AdminDashboard(
            userType: userType,
            userName: userName,
            isLoggedIn: true,
            userId: userId, // Add this parameter
          ),
        ),
      );
    }
  } else {
    if (!mounted) return; // Verifica se o widget ainda está montado

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Erro de login'),
        content: Text('Usuário ou senha incorretos'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 235, 240, 240),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 64.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Bem-vindo ao App da Clínica Lótus!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 18, 196, 187),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Faça login para continuar',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 48),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o e-mail.';
                    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Por favor, insira um e-mail válido.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a senha.';
                    } else if (value.length < 8) {
                      return 'A senha deve ter pelo menos 8 caracteres.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _login();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 18, 196, 187),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Entrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}