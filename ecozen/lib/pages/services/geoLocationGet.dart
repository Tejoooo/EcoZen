// // ignore_for_file: file_names, unused_import

// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';

// Future<Position> getCurrentLocation() async {
//   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//   if (!serviceEnabled) {
//     return Future.error('Location Serices are disabled');
//   }
//   LocationPermission permission = await Geolocator.checkPermission();
//   if (permission == LocationPermission.denied) {
//     permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied) {
//       return Future.error("location permission are denied");
//     }
//   }

//   if (permission == LocationPermission.deniedForever) {
//     return Future.error(
//         "location Permissions are permentaly dissabled please enable");
//   }
//   return await Geolocator.getCurrentPosition();
// }

// // getCurrentLocation().then((value){
// //    lat = value.latitude;
// //    log = value.longitude;
// // })

// //  get in map{
// // String googleURL = 'https://www.google.com/maps/search/?api=1&query=$lat,&log';
// // await canLaunchUrlString(googleURL) ? await canLaunchUrlString(googleURL) : throw 'couldnot launch'
// //  add the url_launch to the pubspec.yaml or download the package
// // }
