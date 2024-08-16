import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class FaceCaptureScreen extends StatefulWidget {
  @override
  _FaceCaptureScreenState createState() => _FaceCaptureScreenState();
}

class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isCapturing = false;
  String? capturedFaceData;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No cameras available');
      }

      final firstCamera = cameras.first;

      _controller = CameraController(
        firstCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      _initializeControllerFuture = _controller.initialize();
      setState(() {}); // Update the UI after initializing the camera
    } catch (e) {
      print('Error initializing camera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera initialization failed: $e')),
      );
      // Optionally navigate back if camera initialization fails
      Future.delayed(Duration.zero, () {
        Navigator.pop(context);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _captureFaceData() async {
    await _initializeControllerFuture;

    setState(() {
      _isCapturing = true;
    });

    try {
      final image = await _controller.takePicture();
      File imageFile = File(image.path);

      // Here you can process the image for facial recognition, e.g., extract features
      // For simplicity, we'll save the image path as captured data (replace this with actual facial data processing)
      setState(() {
        capturedFaceData = imageFile.path;
        _isCapturing = false;
      });

      // You can now save `capturedFaceData` to your database or storage for future use
      // Example: save it to a cloud service or local storage

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Face data captured successfully!')),
      );
    } catch (e) {
      print('Error capturing face data: $e');
      setState(() {
        _isCapturing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Capture Face Data'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              // Handle errors here
              return Center(child: Text('Failed to initialize camera: ${snapshot.error}'));
            }

            return Column(
              children: [
                _controller.value.isInitialized
                    ? Expanded(child: CameraPreview(_controller))
                    : Center(child: Text('Camera not available')),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isCapturing ? null : _captureFaceData,
                  child: Text(_isCapturing ? 'Capturing...' : 'Capture Face Data'),
                ),
                if (capturedFaceData != null) ...[
                  SizedBox(height: 20),
                  Text('Captured face data saved successfully!'),
                  // Optionally display the captured image
                  Image.file(File(capturedFaceData!)),
                ]
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
