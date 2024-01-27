// ignore_for_file: prefer_const_constructors, prefer_final_fields, unused_field

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 40,
            ),
            TextField(
              controller: _emailController,
              cursorColor: Colors.white,
              decoration: InputDecoration(labelText: "Enter Email"),
            ),
            SizedBox(
              height: 5,
            ),
            TextField(
              controller: _passwordController,
              cursorColor: Colors.white,
              decoration: InputDecoration(labelText: "Enter password"),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              onPressed: signInWithEmailAndPassword,
              icon: Icon(
                Icons.lock_open,
                size: 32,
              ),
              label: Text("Sign IN"),
            ),
          ],
        ),
      ),
    );
  }

  Future signInWithEmailAndPassword() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim());
  }
}
