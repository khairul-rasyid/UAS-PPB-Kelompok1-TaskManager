import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/login.dart';
import 'package:flutter_application/main.dart';
import 'package:google_sign_in/google_sign_in.dart';

FirebaseAuth firebaseAuth = FirebaseAuth.instance;
GoogleSignIn googleSignIn = GoogleSignIn();

Future<User?> signIn() async {
  GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
  GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount!.authentication;

  AuthCredential authCredential = GoogleAuthProvider.credential(
    idToken: googleSignInAuthentication.idToken,
    accessToken: googleSignInAuthentication.accessToken,
  );

  UserCredential userCredential =
      await firebaseAuth.signInWithCredential(authCredential);
  User? user = userCredential.user;

  return user;
}

Future<void> signOut() async {
  await googleSignIn.signOut();
  FirebaseAuth.instance.signOut();
}

class CheckUser extends StatelessWidget {
  const CheckUser({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return MyBottomNavBar(user: snapshot.data!);
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
