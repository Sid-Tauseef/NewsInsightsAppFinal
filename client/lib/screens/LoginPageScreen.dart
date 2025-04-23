import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:http/http.dart' as http;
import 'package:client/constants/config.dart';
import 'package:client/screens/RegisterScreen.dart';
import 'package:client/widgets/applogo.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isNotValidate = false;
  bool _isLoading = false;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _initSharedPref();
  }

  Future<void> _initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> _loginUser() async {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        var reqBody = {
          "email": emailController.text,
          "password": passwordController.text,
        };
        var response = await http.post(
          Uri.parse(Config.login),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(reqBody),
        );
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status']) {
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('email', emailController.text);
          Navigator.pushReplacementNamed(context, 'home/', arguments: {
            "email": emailController.text,
          });
        } else {
          _showSnackbar("Invalid credentials. Please try again.");
        }
      } catch (e) {
        _showSnackbar("Connection error. Please try again.");
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isNotValidate = true);
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade900,
              Colors.deepPurple.shade800,
              Colors.deepPurple.shade700,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background elements
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            
            Column(
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.only(top: 80, bottom: 40),
                  child: Column(
                    children: [
                      const CommonLogo().p8(),
                      "Welcome Back".text.white.xl4.bold.make().pOnly(top: 20),
                      "Sign in to continue".text.gray300.make(),
                    ],
                  ),
                ).px24(),

                // Form Container
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            // Email Field
                            _buildTextField(
                              controller: emailController,
                              hintText: "Email Address",
                              icon: Icons.email_rounded,
                            ).pOnly(bottom: 20),

                            // Password Field
                            _buildTextField(
                              controller: passwordController,
                              hintText: "Password",
                              icon: Icons.lock_rounded,
                              obscureText: true,
                            ).pOnly(bottom: 30),

                            // Login Button
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.deepPurple.shade600,
                                    Colors.purple.shade400,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.purple.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: MaterialButton(
                                minWidth: double.infinity,
                                height: 56,
                                onPressed: _loginUser,
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        "Sign In",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ).pOnly(bottom: 25),

                            // Sign Up Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                "Don't have an account?".text.gray600.make(),
                                TextButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const MyRegisterPage(),
                                    ),
                                  ),
                                  child: "Sign Up".text.purple600.bold.make(),
                                ),
                              ],
                            ),

                            // Forgot Password
                            TextButton(
                              onPressed: () {},
                              child: "Forgot Password?".text.purple500.make(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.grey.shade800),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade500),
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorText: _isNotValidate && controller.text.isEmpty
            ? "This field is required"
            : null,
        errorStyle: TextStyle(color: Colors.red.shade400),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
    );
  }
}