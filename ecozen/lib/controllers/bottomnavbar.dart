import 'package:flutter/material.dart';

class MyBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemTapped;

  MyBottomNavigationBar(
      {required this.currentIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onItemTapped,
      items: [
        BottomNavigationBarItem(
          backgroundColor: Colors.black,
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          backgroundColor: Colors.black,
          icon: Icon(Icons.assessment),
          label: 'Heatmaps',
        ),
        BottomNavigationBarItem(
          backgroundColor: Colors.black,
          icon: Icon(Icons.report_problem),
          label: 'Problem',
        ),
        BottomNavigationBarItem(
          backgroundColor: Colors.black,
          icon: Icon(Icons.monetization_on),
          label: 'Zen Coins',
        ),
        BottomNavigationBarItem(
          backgroundColor: Colors.black,
          icon: Icon(Icons.account_circle),
          label: 'Account',
        ),
      ],
    );
  }
}
