import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:client/constants/config.dart';
import 'loginPageScreen.dart';

class MyRegisterPage extends StatefulWidget {
  const MyRegisterPage({super.key});

  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<MyRegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _showValidationErrors = false;

  Future<void> _registerUser() async {
    if (!_validateFields()) return;

    setState(() => _isLoading = true);
    
    try {
      final response = await http.post(
        Uri.parse(Config.registrationUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _emailController.text,
          "password": _passwordController.text,
          "username": _usernameController.text,
          "phone": _phoneController.text
        }),
      );

      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status']) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', _emailController.text);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
      } else {
        _showSnackbar("Registration failed. Please try again.");
      }
    } catch (e) {
      _showSnackbar("Connection error. Please try again later.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _validateFields() {
    final isValid = _usernameController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty;
    setState(() => _showValidationErrors = !isValid);
    return isValid;
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
              left: -100,
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
                      "Create Account".text.white.xl4.bold.make(),
                      "Join our community".text.gray300.make(),
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
                            _buildTextField(
                              controller: _usernameController,
                              hintText: "Username",
                              icon: Icons.person_rounded,
                            ).pOnly(bottom: 20),

                            _buildTextField(
                              controller: _phoneController,
                              hintText: "Phone Number",
                              icon: Icons.phone_rounded,
                              keyboardType: TextInputType.phone,
                            ).pOnly(bottom: 20),

                            _buildTextField(
                              controller: _emailController,
                              hintText: "Email Address",
                              icon: Icons.email_rounded,
                              keyboardType: TextInputType.emailAddress,
                            ).pOnly(bottom: 20),

                            _buildPasswordField().pOnly(bottom: 30),

                            // Register Button
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
                                onPressed: _registerUser,
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
                                        "Sign Up",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600),
                                        ),
                              ),
                            ).pOnly(bottom: 25),

                            // Login Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                "Already have an account?".text.gray600.make(),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: "Log In".text.purple600.bold.make(),
                                ),
                              ],
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
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
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
        errorText: _showValidationErrors && controller.text.isEmpty
            ? "This field is required"
            : null,
        errorStyle: TextStyle(color: Colors.red.shade400),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: true,
      style: TextStyle(color: Colors.grey.shade800),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        hintText: "Password",
        hintStyle: TextStyle(color: Colors.grey.shade500),
        prefixIcon: Icon(Icons.lock_rounded, color: Colors.grey.shade600),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.copy, color: Colors.grey.shade600),
              onPressed: () => Clipboard.setData(ClipboardData(text: _passwordController.text)),
            ),
            IconButton(
              icon: Icon(Icons.casino_rounded, color: Colors.grey.shade600),
              onPressed: () => _passwordController.text = generateRandomPassword(),
            ),
          ],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorText: _showValidationErrors && _passwordController.text.isEmpty
            ? "This field is required"
            : null,
        errorStyle: TextStyle(color: Colors.red.shade400),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
    );
  }

  String generateRandomPassword() {
    const characters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    Random random = Random();
    return List.generate(12, (index) => characters[random.nextInt(characters.length)]).join();
  }
}