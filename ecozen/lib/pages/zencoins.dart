// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:ecozen/constants.dart';
import 'package:ecozen/controllers/snackBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ZenCoins extends StatefulWidget {
  const ZenCoins({super.key});

  @override
  State<ZenCoins> createState() => _ZenCoinsState();
}

class _ZenCoinsState extends State<ZenCoins> {
  int zenCoins = 450;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    try {
      final response = await http.get(Uri.parse(backendURL +
          "/api/zencoin/${FirebaseAuth.instance.currentUser!.uid}"));
      print(jsonDecode(response.body));
      setState(() {
        zenCoins = jsonDecode(response.body)['balance'];
      });
    } catch (e) {
      ErrorSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      border: Border.all(
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 4, 5, 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.track_changes_rounded,
                            color: Colors.green,
                          ),
                          SizedBox(
                            width: 2,
                          ),
                          Text(zenCoins.toString()),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              ClipOval(
                child: Image.asset(
                  'assets/11.jpg', // Replace with the path to your image asset
                  width: 220, // Adjust the width as needed
                  height: 220, // Adjust the height as needed
                  fit: BoxFit
                      .cover, // This property ensures the image covers the oval shape
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  "Available Coupons",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              CouponCard(),
              CouponCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class CouponCard extends StatelessWidget {
  const CouponCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20, top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "STEAL DEAL",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "APPLY",
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.indigo[300]),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Text(
                "You need 50 more ZenCoins to get this Voucher",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.green[300],
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15))),
              child: Center(
                child: Text(
                  "Unlock This!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
