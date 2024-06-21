import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/services/auth.dart';
import 'package:flutter_application/main.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 200, left: 20, right: 20),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/pic_login.png',
              scale: 1.3,
            ),
            const SizedBox(height: 40),
            const Text(
              "Dailoz.",
              style: TextStyle(
                fontSize: 32,
                color: Color(0xFF5B67CA),
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "Plan what you will do to be more organized for today, tomorrow and beyond",
              style: TextStyle(fontSize: 14, color: Color(0xFF2C406E)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 45,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  User? user = await signIn();
                  if (user != null) {
                    // ignore: use_build_context_synchronously
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MyBottomNavBar(user: user)),
                    );
                  }
                },
                icon: const Icon(Icons.login),
                label: const Text("Login With Google"),
                style: ElevatedButton.styleFrom(
                    foregroundColor: const Color(0xFFFFFFFF),
                    backgroundColor: const Color(0xFF5B67CA),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            )
          ],
        ),
      ),
    );
  }
}
