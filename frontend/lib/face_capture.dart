import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;


class FaceCaptureScreen extends StatefulWidget {
  @override
  _FaceCaptureScreenState createState() => _FaceCaptureScreenState();
}

class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  List<File> _capturedImages = [];

  Future<void> captureImage() async {
    if (_capturedImages.length < 10) {
      final pickedImage = await _picker.pickImage(source: ImageSource.camera);
      if (pickedImage != null) {
        setState(() {
          _capturedImages.add(File(pickedImage.path));
        });
      }
    }
  }

  Future<void> submitRegistration() async {
    if (_capturedImages.length == 10) {
      try {
        // Create a multipart request
        var uri = Uri.parse('http://192.168.1.8:8000/api/auth/upload_images/');
        var request = http.MultipartRequest('POST', uri);

        request.fields['student_id'] = 'your_student_id'; // Add student ID

        for (int i = 0; i < _capturedImages.length; i++) {
          var stream = http.ByteStream(_capturedImages[i].openRead());
          var length = await _capturedImages[i].length();
          var multipartFile = http.MultipartFile(
            'images',  // This should match the key used in the Django view
            stream,
            length,
            filename: _capturedImages[i].path.split('/').last,
          );
          request.files.add(multipartFile);
        }

        // Send the request
        var response = await request.send();


        if (response.statusCode == 200) {
          print('Images uploaded successfully!');
          // You can navigate to another screen or show a success message
        } else {
          print('Failed to upload images. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error uploading images: $e');
      }
    } else {
      print('Please capture exactly 10 images before submitting.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Capture Images'),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Text(
            'Captured ${_capturedImages.length} out of 10',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Show images in 2 columns
              ),
              itemCount: _capturedImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(_capturedImages[index]), // Display captured images
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: captureImage,
            child: Text('Capture Image'),
          ),
          ElevatedButton(
            onPressed: _capturedImages.length == 10 ? submitRegistration : null,
            child: Text('Submit Registration'),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
