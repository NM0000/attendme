//............

import 'dart:async';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AttendancePage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const AttendancePage({Key? key, required this.cameras}) : super(key: key);

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  late CameraController _cameraController;
  bool _isBackCamera = true;
  bool _flashEnabled = false;
  bool _isAutomaticCaptureInitialized = false;
  bool _isProcessingImage = false;
  List<String> _recognizedStudents = [];
  DateTime? _dateTime;
  Timer? _captureTimer;
  int _captureCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() {
    _cameraController = CameraController(
      _isBackCamera ? widget.cameras.first : widget.cameras.last,
      ResolutionPreset.high,
    );
    _cameraController.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  void _toggleCamera() {
    setState(() {
      _isBackCamera = !_isBackCamera;
      _flashEnabled = _isBackCamera;
      _initializeCamera();
    });
  }

  void _toggleFlash() {
    if (_isBackCamera) {
      setState(() {
        _flashEnabled = !_flashEnabled;
        _cameraController.setFlashMode(
          _flashEnabled ? FlashMode.torch : FlashMode.off,
        );
      });
    }
  }

  void _startAutomaticCapture() {
    if (_isAutomaticCaptureInitialized) return;
    _isAutomaticCaptureInitialized = true;
    _captureTimer = Timer.periodic(Duration(seconds: 4), (timer) async {
      _captureCount += 2;
      await _captureImage();
      if (_captureCount >= 30) {
        timer.cancel();
        _showStudentListPopup();
        _captureCount = 0;
      }
    });
  }

  Future<void> _captureImage() async {
    if (!_cameraController.value.isInitialized || _isProcessingImage) return;
    _isProcessingImage = true;

    try {
      final XFile image = await _cameraController.takePicture();

      // Send the image file to the model
      final response = await _sendImageToModel(image.path); // Use the file path

      if (response != null) {
        setState(() {
          // Update recognized students list
          final newStudents =
              List<String>.from(response['recognized_name'] ?? []);
          _recognizedStudents =
              {..._recognizedStudents, ...newStudents}.toList();
          _updateDateTime();
          // Print recognized face count and names
          int recognizedFaceCount = _recognizedStudents.length;
          print("Recognized face count: $recognizedFaceCount");
          print("Recognized faces: ${_recognizedStudents.join(', ')}");
          // Optionally, show a message in the UI for recognized faces
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Recognized face count: $recognizedFaceCount\nNames: ${_recognizedStudents.join(', ')}'),
            duration: Duration(seconds: 4),
          ),
        );
        });
      }
    } catch (e) {
      print("Error capturing image: $e");
    } finally {
      _isProcessingImage = false;
    }
  }

  Future<Map<String, dynamic>?> _sendImageToModel(String filePath) async {
    const String url = 'http://192.168.1.7:8000/api/auth/recognize-face/';
    int retryCount = 3;

    for (int attempt = 0; attempt < retryCount; attempt++) {
      try {
        var request = http.MultipartRequest('POST', Uri.parse(url));

        // Attach the image file as multipart
        request.files.add(
          await http.MultipartFile.fromPath(
            'attachment', 
            filePath,
          ),
        );

        // Send the request
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          return jsonDecode(
              response.body); // Return the response as a JSON object
        } else {
          print(
              'Failed to get response from model (Status: ${response.statusCode})');
        }
      } catch (e) {
        print("Error sending image to model on attempt ${attempt + 1}: $e");
      }
    }
    return null;
  }

  void _updateDateTime() {
    setState(() {
      _dateTime = DateTime.now();
    });
  }

  void _showStudentListPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Recognized Students"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              _recognizedStudents.map((student) => Text(student)).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _sendAttendanceReport();
              Navigator.of(context).pop();
            },
            child: Text("Done"),
          ),
        ],
      ),
    );
  }

  Future<void> _sendAttendanceReport() async {
    const String url = 'http://192.168.1.7:8000/api/auth/report';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'attachment': _recognizedStudents}),
      );

      if (response.statusCode == 200) {
        print('Attendance report sent successfully');
      } else {
        print('Failed to send attendance report: ${response.statusCode}');
      }
    } catch (e) {
      print("Error sending attendance report: $e");
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _captureTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Facial Recognition Attendance'),
      ),
      body: Column(
        children: [
          Expanded(
            child: CameraPreview(_cameraController),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(
                  _flashEnabled ? Icons.flash_on : Icons.flash_off,
                  color: _isBackCamera ? Colors.black : Colors.grey,
                ),
                onPressed: _toggleFlash,
              ),
              IconButton(
                icon: Icon(Icons.camera, color: Colors.black),
                onPressed: _startAutomaticCapture,
              ),
              IconButton(
                icon: Icon(Icons.switch_camera, color: Colors.black),
                onPressed: _toggleCamera,
              ),
            ],
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Date: ${_dateTime != null ? _dateTime!.toLocal().toString().split(' ')[0] : ''}'),
                Text(
                    'Time: ${_dateTime != null ? _dateTime!.toLocal().toString().split(' ')[1] : ''}'),
                Text('Total Number of Students: ${_recognizedStudents.length}'),
                Text('Names of Students:'),
                SingleChildScrollView(
                  child: Column(
                    children: _recognizedStudents
                        .map((student) => Text(student))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
