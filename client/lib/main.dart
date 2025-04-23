import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client/widgets/BottomNav.dart';
import 'package:client/screens/CategoryScreen.dart';
import 'package:client/screens/LoginPageScreen.dart';
import 'package:client/screens/RegisterScreen.dart';
import 'package:client/providers/likedArticleProvider.dart';
import 'package:client/widgets/theme.dart'; // Import your theme file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Retrieve email from SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final email = prefs.getString('email');
  if (email != null) {
    print("Email retrieved from *****MAIN.DART**** SharedPreferences: $email");
  } else {
    print("No email found in SharedPreferences.");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LikedArticlesProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'News App',
        theme: AppTheme.lightTheme, // Use the light theme
        darkTheme: AppTheme.darkTheme, // Use the dark theme
        themeMode: ThemeMode.system, // Allow the system to dictate the theme mode
        home: const SplashScreen(), // Show a splash screen to handle redirection
        routes: {
          'home/': (context) => const BottomNav(),
          'category/': (context) => const CategoryScreen(),
          'login/': (context) => const LoginPage(),
          'register/': (context) => const MyRegisterPage(),
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      // If the user is logged in, navigate to the home screen
      Navigator.pushReplacementNamed(context, 'home/');
    } else {
      // If the user is not logged in, navigate to the login page
      Navigator.pushReplacementNamed(context, 'login/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Display a loading indicator while checking login status
      ),
    );
  }
}