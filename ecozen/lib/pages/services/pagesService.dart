import 'package:ecozen/pages/account.dart';
import 'package:ecozen/pages/heatmaps.dart';
import 'package:ecozen/pages/homePage.dart';
import 'package:ecozen/pages/post.dart';
import 'package:ecozen/pages/zencoins.dart';
import 'package:flutter/material.dart';

import '../../controllers/bottomnavbar.dart';

class PagesService extends StatefulWidget {
  const PagesService({super.key});

  @override
  State<PagesService> createState() => _PagesServiceState();
}

class _PagesServiceState extends State<PagesService> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(),
      HeatMaps(),
      ImagePickerWidget(),
      ZenCoins(),
      Account()
    ];
  }

  void onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: MyBottomNavigationBar(
            currentIndex: _currentIndex, onItemTapped: onItemTapped));
  }
}
