import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as img;
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
  bool _isDetecting = false;

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
      _startImageStream();
    });
  }

  void _startImageStream() {
    _cameraController?.startImageStream((CameraImage cameraImage) async {
      if (_isDetecting) return;
      _isDetecting = true;

      // Convert the camera image to a format compatible with the ML Kit
      final bytes = cameraImage.planes.fold<Uint8List>(
        Uint8List(0),
        (buffer, plane) => Uint8List.fromList(buffer + plane.bytes),
      );

      final image = InputImage.fromBytes(
        bytes: bytes,
        inputImageData: InputImageData(
          size: Size(cameraImage.width.toDouble(), cameraImage.height.toDouble()),
          imageRotation: InputImageRotation.Rotation_0deg,
          inputImageFormat: InputImageFormat.NV21,
          planeData: cameraImage.planes.map(
            (plane) {
              return InputImagePlaneMetadata(
                bytesPerRow: plane.bytesPerRow,
                height: cameraImage.height,
                width: cameraImage.width,
              );
            },
          ).toList(),
        ),
      );

      final faces = await _faceDetector.processImage(image);
      if (faces.isNotEmpty) {
        // If a face is detected, capture the image
        _captureImage();
      }

      _isDetecting = false;
    });
  }

  Future<void> _captureImage() async {
    try {
      final image = await _cameraController!.takePicture();
      _capturedImagePaths.add(image.path);
      setState(() {});

      // If you want to stop the stream after capturing enough images
      if (_capturedImagePaths.length >= 5) { // Adjust the count as needed
        _cameraController?.stopImageStream();
        Navigator.pop(context, _capturedImagePaths);
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
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Captured Images: ${_capturedImagePaths.length}',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
