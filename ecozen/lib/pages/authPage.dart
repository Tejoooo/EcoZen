// ignore_for_file: prefer_const_constructors, prefer_final_fields, unused_field, use_build_context_synchronously

import 'package:ecozen/pages/services/snackBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailLoginController = TextEditingController();
  TextEditingController _passwordLoginController = TextEditingController();
  TextEditingController _emailSignUpController = TextEditingController();
  TextEditingController _passwordSignUpController = TextEditingController();
  TextEditingController _confirmPasswordSignUpController =
      TextEditingController();

  bool isLogin = true;

  void changeState() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  void dispose() {
    _emailLoginController.dispose();
    _passwordLoginController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: isLogin
            ? Column(
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  TextField(
                    controller: _emailLoginController,
                    cursorColor: Colors.white,
                    decoration: InputDecoration(labelText: "Enter Email"),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  TextField(
                    controller: _passwordLoginController,
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
                    label: Text("Login"),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextButton(
                    onPressed: changeState,
                    child: Text("SignUP"),
                  ),
                ],
              )
            : Column(
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  TextField(
                    controller: _emailSignUpController,
                    cursorColor: Colors.white,
                    decoration: InputDecoration(labelText: "Enter Email"),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  TextField(
                    controller: _passwordSignUpController,
                    cursorColor: Colors.white,
                    decoration: InputDecoration(labelText: "Enter password"),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  TextField(
                    controller: _confirmPasswordSignUpController,
                    cursorColor: Colors.white,
                    decoration: InputDecoration(labelText: "Enter Email"),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton.icon(
                    onPressed: signUpWithEmailAndPassword,
                    icon: Icon(
                      Icons.lock_open_outlined,
                      size: 32,
                    ),
                    label: Text("Sign Up"),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextButton(
                    onPressed: changeState,
                    child: Text("Login"),
                  ),
                ],
              ),
      ),
    );
  }

  Future signInWithEmailAndPassword() async {
    if (_emailLoginController.text.isEmpty) {
      ErrorSnackBar(context, "Email Field is Required");
    } else if (_passwordLoginController.text.isEmpty) {
      ErrorSnackBar(context, "Password Field is Required");
    } else if (_passwordLoginController.text.length < 6) {
      ErrorSnackBar(context, "Password should contain atlease 6 characters");
    } else {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailLoginController.text.trim(),
            password: _passwordLoginController.text.trim());
      } on FirebaseAuthException catch (e) {
        ErrorSnackBar(context, e.toString());
      }
    }
  }

  Future signUpWithEmailAndPassword() async {
    if (_passwordSignUpController.text ==
        _confirmPasswordSignUpController.text) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailSignUpController.text.trim(),
            password: _passwordSignUpController.text.trim());
      } on FirebaseAuthException catch (e) {
        ErrorSnackBar(context, e.toString());
      }
    } else {
      ErrorSnackBar(context, "Both Passwords should be same");
    }
  }
}
