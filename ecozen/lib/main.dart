import 'package:ecozen/pages/account.dart';
import 'package:ecozen/pages/emailVerifyPage.dart';
import 'package:ecozen/pages/heatmaps.dart';
import 'package:ecozen/pages/homePage.dart';
import 'package:ecozen/pages/loginPage.dart';
import 'package:ecozen/pages/post.dart';
import 'package:ecozen/pages/services/splashScreen.dart';
import 'package:ecozen/pages/signUpPage.dart';
import 'package:ecozen/pages/zencoins.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: "/posts",
      routes: {
        "/": (context) => HomePage(),
        "/splash": (context) => SplashScreen(),
        "/login": (context) => LoginPage(),
        "/signup": (context) => SignUPPage(),
        "/emailverify": (context) => EmailVerifyPage(),
        "/posts": (context) => ImagePickerWidget(),
        "/heatmaps" : (context) => HeatMaps(),
        "/zencoins" : (context) => ZenCoins(),
        "/account" : (context) => Account(),
      },
    );
  }
}
