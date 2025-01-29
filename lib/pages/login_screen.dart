import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cliente_dashboard.dart';
import 'funcionario_dashboard.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'admin_dashboard.dart';

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
  final _storage = FlutterSecureStorage(); // Para armazenar o token
  bool isLoggedIn = false;  // Add this line  

  // Função para autenticar o usuário
  Future<void> _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;    

    final url = Uri.parse('http://localhost:5118/api/auth/login'); // Coloque a URL da sua API de login

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'SenhaHash': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Salve o token JWT no armazenamento seguro
      await _storage.write(key: 'jwt_token', value: data['token']);

      // Determine o tipo de usuário e redirecione para o dashboard correto
      String userType = determineUserType(email);
      String userName = email.split('@')[0]; // Get username from email

      if (userType == 'cliente') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ClienteDashboard(
                userType: userType,
                userName: userName, 
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
              ),
            ),
          );
        }
        else {
        
        Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AdminDashboard(
            userType: userType,
            userName: userName,
            isLoggedIn: true,
          ),
        ),
      );
    }
    } else {     
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

  String determineUserType(String email) {
    if (email.toLowerCase().contains('@funcionario.com')) {
      return 'funcionario';
    } else if (email.toLowerCase().contains('@admin.com')) {
      return 'administrador';
    }
    return 'cliente';
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
                    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
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
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
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
