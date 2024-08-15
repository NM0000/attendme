import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
//import 'package:shared_preferences/shared_preferences.dart';

class TakeAttendancePage extends StatefulWidget {
  @override
  _TakeAttendancePageState createState() => _TakeAttendancePageState();
}

class _TakeAttendancePageState extends State<TakeAttendancePage> {
  CameraController? _cameraController;
  List<String> _recognizedStudents = [];
  bool _isCameraInitialized = false;
  int _totalRecognizedStudents = 0;
  List<File> _capturedImages = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      // Request permission for camera usage
      await _requestCameraPermission();

      // Initialize the camera
      final cameras = await availableCameras();
      _cameraController = CameraController(cameras[0], ResolutionPreset.high);

      await _cameraController?.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _requestCameraPermission() async {
    // Implement camera permission request here (for example, using permission_handler package)
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        final image = await _cameraController!.takePicture();
        setState(() {
          _capturedImages.add(File(image.path));
        });

        // Optionally process the image for facial recognition
        _recognizeStudentsFromImage(File(image.path));
      } catch (e) {
        print('Error capturing image: $e');
      }
    }
  }

  void _recognizeStudentsFromImage(File image) {
    // Implement your facial recognition logic here
    // For demo purposes, let's assume we recognize some students
    setState(() {
      _recognizedStudents.addAll([
        'John Doe',
        'Jane Smith',
        'Alice Johnson',
      ]);
      _totalRecognizedStudents = _recognizedStudents.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take Attendance'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Camera preview section
          Expanded(
            flex: 3,
            child: _isCameraInitialized
                ? CameraPreview(_cameraController!)
                : Center(child: CircularProgressIndicator()),
          ),
          // Recognition details section
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Number of students present: $_totalRecognizedStudents',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _recognizedStudents.length,
                      itemBuilder: (context, index) {
                        return Text(
                          _recognizedStudents[index],
                          style: TextStyle(fontSize: 18),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _captureImage,
        child: Icon(Icons.camera),
      ),
    );
  }
}
