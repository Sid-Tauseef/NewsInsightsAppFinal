import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client/constants/config.dart';
import 'package:client/widgets/Sizedbox.dart';
import 'package:shimmer/shimmer.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? username;
  String? email;
  String? phone;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    setState(() => isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('email');

    if (userEmail != null) {
      try {
        final response = await http.post(
          Uri.parse('${Config.getUserDetails}'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode({'email': userEmail}),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body)['data'];
          setState(() {
            username = data['username'];
            email = data['email'];
            phone = data['phone'];
            isLoading = false;
          });
        } else {
          throw Exception('Failed to fetch user data');
        }
      } catch (e) {
        print("Error fetching user data: $e");
        setState(() => isLoading = false);
      }
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 26,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 10,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F9FF), Color(0xFFE9EFFD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAccountSection(),
                    sizedH(context, 0.04),
                    _buildActionButtons(),
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                sizedH(context, 0.03),
                isLoading
                    ? _buildShimmerLoading()
                    : Column(
                        children: [
                          _buildInfoRow(Icons.person, 'Username', username),
                          const Divider(height: 30),
                          _buildInfoRow(Icons.email, 'Email', email),
                          const Divider(height: 30),
                          _buildInfoRow(Icons.phone, 'Phone', phone),
                        ],
                      ),
              ],
            ),
          ),
          _buildEditButton(),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          _buildInfoRow(Icons.person, 'Username', null),
          const Divider(height: 30),
          _buildInfoRow(Icons.email, 'Email', null),
          const Divider(height: 30),
          _buildInfoRow(Icons.phone, 'Phone', null),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String? value) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurpleAccent),
        sizedW(context, 0.04),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Text(
                value ?? (isLoading ? 'Loading...' : 'Not set'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: value == null && !isLoading
                      ? Colors.grey
                      : const Color(0xFF3D3D3D),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditButton() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurpleAccent,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildActionTile(Icons.help_center, 'Help Center', () {}),
        sizedH(context, 0.02),
        _buildActionTile(Icons.logout, 'Log Out',
            () => Navigator.pushReplacementNamed(context, 'login/')),
      ],
    );
  }

  Widget _buildActionTile(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.deepPurpleAccent),
            sizedW(context, 0.04),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3D3D3D),
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }
}