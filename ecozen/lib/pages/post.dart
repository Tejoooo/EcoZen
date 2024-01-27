import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ImagePickerWidget extends StatefulWidget {
  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  XFile? _pickedImage;
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        // Process the picked file (display, upload, etc.)
        setState(() {
          _pickedImage = pickedFile;
        });
        print('Image picked: ${pickedFile.path}');
      } else {
        // User canceled the image picking
        print('Image picking canceled.');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _uploadImage(String filePath) async {
    final url = Uri.parse('http://172.20.10.7:8000/api/upload/');
    try {
      debugPrint("in");
      final request = http.MultipartRequest('POST', url); // Define the request
      debugPrint("hi1");

      request.files.add(await http.MultipartFile.fromPath('image', filePath));
      debugPrint("hi2");
      request.fields['description'] = 'firstimage';
      request.fields['user'] = '1';

      final response = await request.send();
      debugPrint("hi3");
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        print('API Response: $responseData');
        // Process the API response as needed
      } else {
        print('Failed to upload image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _pickedImage != null
              ? Image.file(File(_pickedImage!.path))
              : Text('No Image Selected'),
          if (_pickedImage != null)
            ElevatedButton(
              onPressed: () async {
                await _uploadImage(_pickedImage!.path);
              },
              child: Text('Upload'),
            ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Choose Image Source'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // Close the dialog
                            _pickImage(ImageSource.gallery);
                          },
                          child: Text('Gallery'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // Close the dialog
                            _pickImage(ImageSource.camera);
                          },
                          child: Text('Camera'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: Text('Pick Image'),
          ),
        ],
      ),
    );
  }
}
