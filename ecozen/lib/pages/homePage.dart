import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> images = ['assets/1.jpg', 'assets/2.jpg', 'assets/3.jpg']; // Add more image paths

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.grey[50],
      ),
      body: Container(
      color:Colors.grey[50],
      child: SingleChildScrollView
      ( 
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: Image.asset(
              'assets/5.png',
              width: 550.0,
              height: 400.0,
            )
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Welcome to Our App',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          CarouselSlider(
            options: CarouselOptions(
              height: 300.0,
              autoPlay: true,
              aspectRatio: 16 / 9,
              enlargeCenterPage: true,
            ),
            items: images.map((imagePath) {
              return 
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Container(
                  width: 450.0,
                  height: 450.0,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 3.0,
                    ),
                    // borderRadius: BorderRadius.circular(100.0),
                  ),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
                );
            }).toList(),
          ),
          SizedBox(height: 20.0),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Solving Waste Management Issues',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Our mission is to create a sustainable future by addressing waste management challenges. Join us in making the world a cleaner place!',
              style: TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    ),
      ),
    );
  }
}