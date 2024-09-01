import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:google_ml_kit/google_ml_kit.dart';

class FaceCaptureScreen extends StatefulWidget {
  final String studentId;

  FaceCaptureScreen({required this.studentId});

  @override
  _FaceCaptureScreenState createState() => _FaceCaptureScreenState();
}

class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  List<XFile>? _imageFiles = [];
  int _capturedImagesCount = 0;
  final FaceDetector _faceDetector = GoogleMlKit.vision.faceDetector(
    FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      enableClassification: true,
    ),
  );

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
      );

      await _cameraController!.initialize();
      setState(() {}); // Refresh the UI to reflect the camera initialization
    } catch (e) {
      print('Error initializing camera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera initialization failed: $e')),
      );
    }
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      print('Camera is not initialized.');
      return;
    }

    try {
      final image = await _cameraController!.takePicture();
      final imageFile = File(image.path);

      // Load image and get its dimensions
      final imageBytes = await imageFile.readAsBytes();
      final imageImage = img.decodeImage(Uint8List.fromList(imageBytes))!;
      final width = imageImage.width.toDouble();
      final height = imageImage.height.toDouble();

      final imageInput = InputImage.fromBytes(
        bytes: Uint8List.fromList(imageBytes),
        inputImageData: InputImageData(
          size: Size(width, height),
          imageRotation: InputImageRotation.Rotation_0deg,
          inputImageFormat: InputImageFormat.NV21,
          planeData: [],
        ),
      );

      // Detect faces in the image
      final faces = await _faceDetector.processImage(imageInput);

      if (faces.isNotEmpty) {
        // If faces are detected, process the image
        setState(() {
          _imageFiles?.add(image);
          _capturedImagesCount++;
        });
      } else {
        print('No faces detected in the image.');
      }
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  Future<void> _uploadImages() async {
    if (_imageFiles != null && _imageFiles!.isNotEmpty) {
      final studentDir = await _getStudentDirectory();

      for (var imageFile in _imageFiles!) {
        final fileName = path.basename(imageFile.path);
        final localFile = File(imageFile.path);
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('http://your-backend-url/upload'), // Update with your backend URL
        );

        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            localFile.readAsBytesSync(),
            filename: fileName,
          ),
        );

        request.fields['studentId'] = widget.studentId;
        request.fields['directory'] = studentDir;

        try {
          final response = await request.send();
          if (response.statusCode == 200) {
            print('Image uploaded successfully.');
          } else {
            print('Failed to upload image.');
          }
        } catch (e) {
          print('Error uploading image: $e');
        }
      }
    }
  }

  Future<String> _getStudentDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final studentDir = path.join(directory.path, widget.studentId);
    final dir = Directory(studentDir);

    if (!await dir.exists()) {
      await dir.create();
    }

    return studentDir;
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get the available dimensions
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Face Capture'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!_cameraController!.value.isInitialized) {
            return Center(child: Text('Failed to initialize the camera.'));
          }

          return Column(
            children: [
              // Camera preview
              Container(
                width: screenWidth,
                height: screenHeight * 0.6, // 60% of screen height
                child: CameraPreview(_cameraController!),
              ),
              // Controls and status
              Container(
                width: screenWidth,
                height: screenHeight * 0.4, // Remaining height for controls
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _captureImage,
                      child: Text('Capture Image'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(screenWidth * 0.8, 50),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _uploadImages,
                      child: Text('Upload Images'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(screenWidth * 0.8, 50),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Captured Images: $_capturedImagesCount',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
