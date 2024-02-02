import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecozen/controllers/carousel.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> images = ['assets/2.jpg', 'assets/2.jpg', 'assets/9.png'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey[50],
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 25),
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Stack(
                    children: [
                      // Text for the border
                      Text(
                        'EcoZen',
                        style: TextStyle(
                          fontSize: 54.0,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 1.0
                            ..color = Colors.black,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      // Text for the fill
                      Text(
                        'EcoZen',
                        style: TextStyle(
                          fontSize: 54.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[300], // Fill color
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  )),
              Container(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30.0),
                  child: Image.asset('assets/12.png'),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                width: 350,
              ),
              // SizedBox(height: 10),
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Stack(
                    children: [
                      // Text for the border
                      Text(
                        'MISSION',
                        style: TextStyle(
                          fontSize: 54.0,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 1.0
                            ..color = Colors.black,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      // Text for the fill
                      Text(
                        'MISSION',
                        style: TextStyle(
                          fontSize: 54.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[300], // Fill color
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  )),
              Container(
                child: ClipRRect(
                  // borderRadius: BorderRadius.circular(30.0),
                  child: Image.asset('assets/1.png'),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                width: 450,
              ),

              SizedBox(height: 20.0),
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Stack(
                    children: [
                      // Text for the border
                      Text(
                        'GOALS',
                        style: TextStyle(
                          fontSize: 54.0,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 1.0
                            ..color = Colors.black,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      // Text for the fill
                      Text(
                        'GOALS',
                        style: TextStyle(
                          fontSize: 54.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[300], // Fill color
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  )),
              StepCarousel(),
              SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}
