// ignore_for_file: prefer_const_constructors, prefer_final_fields, prefer_collection_literals, unnecessary_null_comparison

import 'package:ecozen/pages/services/geoLocationGet.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';

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

    // Add some sample markers
    _addMarker('marker1', LatLng(37.7749, -122.4194));
    _addMarker('marker2', LatLng(40.7128, -74.0060));
    _addMarker('marker3', LatLng(34.0522, -118.2437));
    _addMarker('marker4', LatLng(41.8781, -87.6298));
    _addMarker('marker5', LatLng(51.5074, -0.1278));
  }

  void _addMarker(String markerId, LatLng position) {
    markers.add(
      Marker(
        markerId: MarkerId(markerId),
        position: position,
        onTap: () {
          _onMarkerTapped('Marker $markerId tapped');
        },
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onMarkerTapped(String message) {
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
                Image.asset("assets/download_1.jpg"),
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
          debugPrint("geting location");
          getCurrentLocation().then((value){
            debugPrint(value.latitude.toString());
            debugPrint(value.longitude.toString()); 
          });
        },
        child: Icon(Icons.my_location),
      ),
    );
  }
}
