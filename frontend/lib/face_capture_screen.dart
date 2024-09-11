import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:camera/camera.dart';

class FaceCaptureScreen extends StatefulWidget {
  final String studentId;

  const FaceCaptureScreen({Key? key, required this.studentId}) : super(key: key);

  @override
  _FaceCaptureScreenState createState() => _FaceCaptureScreenState();
}

class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
  CameraController? _cameraController;
  late Future<void> _initializeControllerFuture;
  final FaceDetector _faceDetector = GoogleMlKit.vision.faceDetector(
    FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      enableClassification: true,
      mode: FaceDetectorMode.accurate,
    ),
  );
  List<String> _capturedImagePaths = [];
  bool _isPreviewVisible = false; // To control visibility of preview

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _cameraController!.initialize().then((_) {
      setState(() {});
    });
  }

  Future<void> _captureImage() async {
    try {
      final image = await _cameraController!.takePicture();
      _capturedImagePaths.add(image.path);
      setState(() {});

      // If you want to stop the stream after capturing enough images
      if (_capturedImagePaths.length >= 10) { // Adjust the count as needed
        _cameraController?.dispose();
        setState(() {
          _isPreviewVisible = true; // Show preview after capturing images
        });
      }
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Face Capture'),
        backgroundColor: const Color.fromARGB(255, 167, 131, 118),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(8.0),
              child: _cameraController == null || !_cameraController!.value.isInitialized
                  ? Center(child: CircularProgressIndicator())
                  : CameraPreview(_cameraController!),
            ),
          ),
          if (_isPreviewVisible) // Show preview if images are captured
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _capturedImagePaths.length,
                        itemBuilder: (context, index) {
                          final imagePath = _capturedImagePaths[index];
                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 5.0),
                            child: Image.file(
                              File(imagePath),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 100,
                            ),
                          );
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, _capturedImagePaths);
                      },
                      child: Text('Confirm'),
                    ),
                  ],
                ),
              ),
            ),
          if (!_isPreviewVisible) // Show capture button if preview is not visible
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _captureImage,
                      child: Text('Capture Image'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}