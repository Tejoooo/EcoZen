// ignore_for_file: prefer_const_constructors, prefer_final_fields, prefer_collection_literals, unnecessary_null_comparison, use_build_context_synchronously, avoid_function_literals_in_foreach_calls, unnecessary_brace_in_string_interps, non_constant_identifier_names

import 'dart:convert';

import 'package:ecozen/constants.dart';
import 'package:ecozen/controllers/geoLocationGet.dart';
import 'package:ecozen/controllers/snackBar.dart';
import 'package:ecozen/models/problemModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  double zoom = 11.0;
  bool _isLoading = false;

  Set<Marker> markers = Set();
  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading = true;
    });
    FetchAllProblems();
    getCurrentLocation().then((value) {
      setState(() {
        _isLoading = false;
      });
      setState(() {
        zoom = 15.0;
        _center = LatLng(value.latitude, value.longitude);
      });
      mapController.animateCamera(CameraUpdate.newLatLng(_center));
    });
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
        markerId: MarkerId(problem.uid +
            position.longitude.toString() +
            position.latitude.toString() +
            problem.description),
        position: position,
        onTap: () async {
          setState(() {
            _isLoading = true;
          });
          String pid = problem.pid.toString();
          debugPrint(pid);
          String Url = backendURL + "/api/num_likes/";
          final result = await http.post(Uri.parse(Url), body: {
            "pid": pid,
            "uid": FirebaseAuth.instance.currentUser!.uid
          });
          setState(() {
            _isLoading = false;
          });

          Map<String, dynamic> response = json.decode(result.body);
          // Map<String, dynamic> response = {"userLiked": true};
          _onMarkerTapped(
              '${FirebaseAuth.instance.currentUser!.uid} reported with description ${problem.description} with ${pid}',
              problem.image,
              pid,
              response['userLiked'] ? true : false);
        },
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onMarkerTapped(
      String message, String image, String pid, bool voted) async {
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.network(backendURL + image),
                  SizedBox(height: 10),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () async {
                      int count = 1;
                      if (voted) {
                        count = -1;
                      }
                      final result = await http.post(
                          Uri.parse(backendURL + "/api/count_votes/"),
                          body: {
                            "uid": FirebaseAuth.instance.currentUser!.uid,
                            "pid": pid.toString(),
                            "count": count.toString()
                          });
                      if (result.statusCode == 200) {
                        setState(() {
                          voted = !voted;
                        });
                      }
                    },
                    icon: voted
                        ? Icon(Icons.volunteer_activism_sharp)
                        : Icon(Icons.volunteer_activism_outlined),
                    label: voted ? Text("Voted") : Text("Vote"),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                    ),
                  ),
                  Center(
                    child: Text(message + pid + pid),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: zoom,
            ),
            markers: Set.from(markers),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          _isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Container(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isLoading = true;
          });
          getCurrentLocation().then((value) {
            setState(() {
              _isLoading = false;
            });
            setState(() {
              zoom = 15.0;
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
