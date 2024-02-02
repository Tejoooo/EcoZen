// ignore_for_file: prefer_const_constructors, avoid_print, sort_child_properties_last, use_key_in_widget_constructors, library_private_types_in_public_api, use_build_context_synchronously, prefer_interpolation_to_compose_strings, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:io';
import 'package:ecozen/controllers/geoLocationGet.dart';
import 'package:ecozen/controllers/snackBar.dart';
import 'package:ecozen/sercureStorage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ImagePickerWidget extends StatefulWidget {
  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  XFile? _pickedImage;
  bool _isLoading = false;
  String backendURL = "";
  TextEditingController _descriptController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _init();
  }
  void _init() async{
    String url = await secureStorage.read(key: "backendURL") ?? "";
    setState(() {
      backendURL = url;
    });
    debugPrint(backendURL);
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _pickedImage = pickedFile;
        });
        print('Image picked: ${pickedFile.path}');
      } else {
        print('Image picking canceled.');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _uploadImage(String filePath) async {
    setState(() {
      _isLoading = true;
    });
    final url = Uri.parse(backendURL + '/api/upload/');
    try {
      final request = http.MultipartRequest('POST', url);
      request.files.add(await http.MultipartFile.fromPath('image', filePath));
      request.fields['description'] = _descriptController.text.toString();
      request.fields['user'] = FirebaseAuth.instance.currentUser!.uid;
      await getCurrentLocation().then((value) {
        request.fields['latitude'] = value.latitude.toString();
        request.fields['longitude'] = value.longitude.toString();
      });

      final response = await request.send();
      String responseBody = await response.stream.bytesToString();
      Map<String, dynamic> jsonResponse = json.decode(responseBody);
      if (response.statusCode == 201) {
        SuccessSnackBar(context, 'Image is successfully classified as Garbage');
        setState(() {
          _pickedImage = null;
          _descriptController.dispose();
        });
      } else {
        ErrorSnackBar(context,
            'Looks like Image is Not classified into Garbage change the image with statusCode${response.statusCode}');
      }
    } catch (e) {
      ErrorSnackBar(context, e.toString());
    }
    setState(() {
      _isLoading = false;
    });
  }

// void imagePickerOption() {
//     Get.bottomSheet(SingleChildScrollView(
//       child: ClipRRect(
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(20),
//           topRight: Radius.circular(20),
//         ),
//         // ignore: avoid_unnecessary_containers
//         child: Container(
//           color: Colors.white,
//           height: 200,
//           width: 400,
//           child: Container(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   child: Column(
//                     children: [
//                       Container(
//                         padding: EdgeInsets.only(
//                             top: 15, left: 120, right: 120, bottom: 15),
//                         child: Column(
//                           children: [
//                             InkWell(
//                                 onTap: () {
//                         Navigator.pop(context);
//                         _pickImage(ImageSource.camera);
//                                         },
//                                 child: Container(
//                                   padding: const EdgeInsets.all(30),
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(100),
//                                     color: Colors.green[200]
//                                   ),
//                                   child: Icon(
//                                     Icons.camera_alt,
//                                     size: 30,
//                                     color: Colors.black,
//                                   ),
//                                 )),
//                             const SizedBox(
//                               height: 10,
//                             ),
//                             Text(
//                               "Take Photo",
//                               style: TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.w300,
//                                   ),
//                             ),
//                           ],
//                         ),
//                         decoration: BoxDecoration(
//                             border:
//                                 Border.all(style: BorderStyle.solid, width: .2),
//                             borderRadius: BorderRadius.circular(10)),
//                       ),
//                       const SizedBox(
//                         height: 25,
//                       ),

//                     ],
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     ));
//   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Image Picker',
                  style: TextStyle(
                    fontSize: 54.0,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 1.0
                      ..color = Colors.black,
                  ),
                ),
                SizedBox(
                  height: 100,
                ),
                _pickedImage != null
                    ? Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipRRect(
                            child: Image.file(
                              File(_pickedImage!.path),
                              width: 300.0,
                              height: 200.0,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _pickedImage = null;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.all(8.0),
                              padding: EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green[200],
                              ),
                              child: Icon(Icons.close, color: Colors.black),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Container(
                          height: 200,
                          width: 300,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors.grey[50],
                          ),
                          child: Center(
                            child: Text(
                              'No Image Selected',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                SizedBox(height: 20),
                Container(
                  width: 300, // Set the desired width
                  height: 50, // Set the desired height
                  child: TextField(
                    controller: _descriptController,
                    decoration: InputDecoration(
                      hintText: 'Enter your description here',

                      // Customize other properties if needed
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue, // Set the border color
                          width: 2.0, // Set the border width
                        ),
                        borderRadius: BorderRadius.all(
                            Radius.circular(8.0)), // Set the border radius
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  width: 200.0, // Adjust the width as needed
                  height: 50.0, // Adjust the height as needed
                  decoration: BoxDecoration(
                    color: Colors.green[50], // Choose your desired color
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_pickedImage != null) {
                        await _uploadImage(_pickedImage!.path);
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.green[50],
                              title: Text(
                                'Select Image',
                                textAlign: TextAlign.center,
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'Ok',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    },
                    child: Text(
                      'Upload',
                      style: TextStyle(color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.green[300],
                      elevation: 0,
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
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
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Colors.green[50],
                title: Text(
                  'Choose Image',
                  textAlign: TextAlign.center,
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                      child: Text(
                        'Camera',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                      child: Text(
                        'Gallery',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: Icon(Icons.camera_alt_outlined),
        backgroundColor: Colors.green[300],
      ),
    );
  }
}
