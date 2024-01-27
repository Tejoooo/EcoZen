// ignore_for_file: prefer_const_constructors, prefer_final_fields, prefer_collection_literals, unnecessary_null_comparison

import 'dart:convert';

import 'package:ecozen/constants.dart';
import 'package:ecozen/controllers/geoLocationGet.dart';
import 'package:ecozen/controllers/snackBar.dart';
import 'package:ecozen/models/problemModel.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class HeatMaps extends StatefulWidget {
  const HeatMaps({super.key});

  @override
  State<HeatMaps> createState() => _HeatMapsState();
}

class _HeatMapsState extends State<HeatMaps> {
  late GoogleMapController mapController;

  LatLng _center = LatLng(-23.5557714, -46.6395571);

  Set<Marker> markers = Set();
  @override
  void initState() {
    super.initState();
    getCurrentLocation().then((value) {
      setState(() {
        _center = LatLng(value.latitude, value.longitude);
      });
      mapController.animateCamera(CameraUpdate.newLatLng(_center));
    });
    FetchAllProblems();
  }

  void FetchAllProblems() async {
    final response =
        await http.get(Uri.parse("${backendURL}/api/user-problems/"));
    if (response.statusCode == 200) {
      List<dynamic> jsonDataList = jsonDecode(response.body);
      List<ProblemModel> problemsList =
          jsonDataList.map((data) => ProblemModel.fromJSON(data)).toList();
      setState(() {
        problemsList.forEach((problem) =>
            _addMarker(problem, LatLng(problem.latitude, problem.longitude)));
      });
    } else {
      ErrorSnackBar(context, "coudn't able to fetch the markers");
    }
  }

  void _addMarker(ProblemModel problem, LatLng position) {
    markers.add(
      Marker(
        markerId: MarkerId(problem.uid),
        position: position,
        onTap: () {
          _onMarkerTapped(
              '${problem.uid} reported with description ${problem.description}',
              problem.image);
        },
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onMarkerTapped(String message, String image) {
    debugPrint(message);
    Get.bottomSheet(SingleChildScrollView(
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          color: Colors.white,
          height: 400,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              children: [
                Image.network(backendURL + image) ??
                    CircularProgressIndicator(),
                SizedBox(height: 10),
                Center(
                  child: Text(message),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _center == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
              markers: Set.from(markers),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getCurrentLocation().then((value) {
            setState(() {
              _center = LatLng(value.latitude, value.longitude);
            });
            mapController.animateCamera(CameraUpdate.newLatLng(_center));
          });
        },
        child: Icon(Icons.my_location),
      ),
    );
  }
}
