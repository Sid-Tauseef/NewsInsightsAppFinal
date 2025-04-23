import 'package:client/constants/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Add shared_preferences for token storage

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  _MyAccountScreenState createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  String? username;
  String? email;
  String? phone;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('email'); // Retrieve the email from shared preferences

    if (userEmail != null) {
      try {
        // Send a POST request to the backend with the user's email
        final response = await http.post(
          Uri.parse('${Config.getUserDetails}'), // Ensure you point to the right endpoint
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'email': userEmail, // Send the user's email
          }),
        );

        if (response.statusCode == 200) {
          print("Response body: ${response.body}");  // Add this
          // Decode the response and update the state
          final Map<String, dynamic> data = jsonDecode(response.body)['data'];
          setState(() {
            username = data['username'];
            email = data['email'];
            phone = data['phone'];
          });
        } else {
          throw Exception('Failed to load user data');
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    } else {
      print("No user email found in shared preferences");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1E1A3B),
              Color(0xFF4B2958),
              Color(0xFF2E135F),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20.0),
              const Text(
                'Account Information',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Match text color with the login page
                ),
              ),
              const SizedBox(height: 20.0),
              _buildListTile(Icons.person, 'Username', username, 20.0),
              const Divider(color: Colors.white54), // Updated divider color
              _buildListTile(Icons.email, 'Email', email, 20.0),
              const Divider(color: Colors.white54), // Updated divider color
              _buildListTile(Icons.phone, 'Phone Number', phone, 20.0),
              const Divider(color: Colors.white54), // Updated divider color
              const SizedBox(height: 40.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Logic for editing account information can be added here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'Edit Account',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ListTile _buildListTile(IconData icon, String title, String? subtitle, double fontSize) {
    return ListTile(
      leading: Icon(icon, color: Colors.white), // Updated icon color
      title: Text(
        title,
        style: TextStyle(fontSize: fontSize, color: Colors.white), // Match text color with the login page
      ),
      subtitle: Text(
        subtitle ?? 'Loading...', // Display data dynamically
        style: TextStyle(fontSize: fontSize, color: Colors.white), // Increased font size
      ),
    );
  }
}
