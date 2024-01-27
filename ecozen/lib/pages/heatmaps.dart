import 'package:ecozen/controllers/bottomnavbar.dart';
import 'package:ecozen/pages/account.dart';
import 'package:ecozen/pages/homePage.dart';
import 'package:ecozen/pages/post.dart';
import 'package:ecozen/pages/zencoins.dart';
import 'package:flutter/material.dart';

class HeatMaps extends StatefulWidget {
  const HeatMaps({super.key});

  @override
  State<HeatMaps> createState() => _HeatMapsState();
}

class _HeatMapsState extends State<HeatMaps> {
  @override
  int _currentIndex = 0;
  void onItemTapped(int index) {
    // Handle bottom navigation item tap
    setState(() {
      _currentIndex = index;
    });
    switch (_currentIndex) {
    case 0:
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
      break;
    case 1:
      Navigator.push(context, MaterialPageRoute(builder: (context) => HeatMaps()));
      break;
    case 2:
      Navigator.push(context, MaterialPageRoute(builder: (context) => ImagePickerWidget()));
      break;
    case 3:
      Navigator.push(context, MaterialPageRoute(builder: (context) => ZenCoins()));
      break;
    case 4:
      Navigator.push(context, MaterialPageRoute(builder: (context) => Account()));
      break;
  }
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
      ),
      bottomNavigationBar: MyBottomNavigationBar(currentIndex: _currentIndex, onItemTapped: onItemTapped)
    );
  }
}