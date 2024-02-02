// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'package:ecozen/pages/account.dart';
import 'package:ecozen/pages/heatmaps.dart';
import 'package:ecozen/pages/homePage.dart';
import 'package:ecozen/pages/post.dart';
import 'package:ecozen/controllers/snackBar.dart';
import 'package:ecozen/pages/zencoins.dart';
import 'package:ecozen/sercureStorage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../controllers/bottomnavbar.dart';

class PagesService extends StatefulWidget {
  const PagesService({super.key});

  @override
  State<PagesService> createState() => _PagesServiceState();
}

class _PagesServiceState extends State<PagesService> {
  int _currentIndex = 0;
  late final List<Widget> _pages;
  bool isEmailVerified = false;
  String backendURL = "";

  @override
  void initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    checkForUserInDB();
    if (!isEmailVerified) {
      SendVerificationMail();
    }
    _pages = [
      HomePage(),
      HeatMaps(),
      ImagePickerWidget(),
      ZenCoins(),
      Account()
    ];
  }

  void checkForUserInDB() async {
    final url = await secureStorage.read(key: "backendURL") ?? "";
    setState(() {
      backendURL = url;
    });
    final jsonResponse = await http.get(Uri.parse(backendURL +
        "/api/user_exists/" +
        FirebaseAuth.instance.currentUser!.uid.toString()));
    if (jsonResponse.statusCode != 200) {
      User user = FirebaseAuth.instance.currentUser!;
      final newJsonResponse = await http.post(
        Uri.parse("${backendURL}/api/user/"),
        body: {"user_id": user.uid.toString(), "email": user.email.toString()},
      );
      print(newJsonResponse.body);
      if (newJsonResponse.statusCode != 201) {
        ErrorSnackBar(context, "User Not Created in Postgre DB");
      }
    }
  }

  void SendVerificationMail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
    } catch (e) {
      ErrorSnackBar(context, e.toString());
    }
  }

  void checkVerificationOfEmail() async {
    try {
      await FirebaseAuth.instance.currentUser!.reload();
    } on FirebaseAuthException catch (e) {
      ErrorSnackBar(context, e.toString());
    }
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
  }

  void onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isEmailVerified
        ? Scaffold(
            body: _pages[_currentIndex],
            bottomNavigationBar: MyBottomNavigationBar(
                currentIndex: _currentIndex, onItemTapped: onItemTapped))
        : WillPopScope(
            onWillPop: () async {
              if (_currentIndex != 0) {
                setState(() {
                  _currentIndex = 0;
                });
                return Future(() => false);
              }
              bool res = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Warning'),
                  content: const Text('Do you really want to exit'),
                  actions: [
                    TextButton(
                      child: const Text('Yes'),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                    TextButton(
                      child: const Text('No'),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ],
                ),
              );
              return Future.value(res);
            },
            child: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: SendVerificationMail,
                      child: Text("Send Verification Mail"),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    ElevatedButton(
                      onPressed: checkVerificationOfEmail,
                      child: Text("Verify"),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text("SignOut"),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
