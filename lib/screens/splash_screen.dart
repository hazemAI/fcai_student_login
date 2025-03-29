import 'dart:async';

import 'package:fcai_student_login/providers/store_provider.dart';
import 'package:fcai_student_login/providers/user_provider.dart';
import 'package:fcai_student_login/screens/home_screen.dart';
import 'package:fcai_student_login/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate some loading time or initialization
    Timer(Duration(seconds: 1), () async {
      var userProvider = context.read<UserProvider>();
      await userProvider.defineUser();
      if (context.mounted && userProvider.isAuthenticated()) {
        await context.read<StoreProvider>().loadFavorites(context);
      }
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    userProvider.isAuthenticated()
                        ? HomeScreen()
                        : LoginScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // You can replace this with your app's logo or image
            FlutterLogo(size: 100),
            SizedBox(height: 20),
            Text(
              'Student App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Loading...', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
