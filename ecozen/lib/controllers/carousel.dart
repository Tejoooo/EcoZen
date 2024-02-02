import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class StepCarousel extends StatelessWidget {
  final List<Widget> carouselItems = [
    // Item 1
    Container(
      width: 400.0,
      height: 300.0,
      decoration: BoxDecoration(
        color: Colors.blue[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'CLICK',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'Open your camera and capture the waste and send it to the nearest muncipal corporation and be a good citizen and help country to develop',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ),
    // Item 2
    Container(
      width: 400.0,
      height: 300.0,
      decoration: BoxDecoration(
        color: Colors.green[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'POST',
            style: TextStyle(
              fontSize: 30,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'Post your surroundings waste and help your community to be clean and green. Be kind and post only waste problems.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ),
    // Item 3
    Container(
      width: 400.0,
      height: 300.0,
      decoration: BoxDecoration(
        color: Colors.deepPurple[100],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'EARN',
            style: TextStyle(
              fontSize: 30,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'Earn the ZENCOINS by posting the posts and use them to get multiple discounts on your favourite brands and enjoy cleaning the country',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ),
    // Add more items as needed
  ];

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 300.0,
        aspectRatio: 1.0,
        enlargeCenterPage: true,
      ),
      items: carouselItems,
    );
  }
}
