import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart'; 

class FaceCaptureScreen extends StatefulWidget {
  const FaceCaptureScreen({Key? key}) : super(key: key);

  @override
  _FaceCaptureScreenState createState() => _FaceCaptureScreenState();
}

class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  List<File> _capturedImages = [];
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );

    try {
      await _controller.initialize();
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  Future<void> _captureImage() async {
    if (_controller.value.isInitialized && !_isCapturing) {
      setState(() {
        _isCapturing = true;
      });

      final directory = await getApplicationDocumentsDirectory();
      final imagePath =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png';

      try {
        await _controller.takePicture().then((XFile file) {
          setState(() {
            _capturedImages.add(File(file.path));
          });
        });
      } catch (e) {
        print(e);
      }

      setState(() {
        _isCapturing = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finishCapturing() {
    Navigator.pop(context, _capturedImages);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Capture Face'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                _controller.value.isInitialized
                    ? Expanded(child: CameraPreview(_controller))
                    : Center(child: Text('Camera not available')),
                if (_isCapturing) CircularProgressIndicator(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _captureImage,
                      child: Text('Capture Image'),
                    ),
                    ElevatedButton(
                      onPressed: _finishCapturing,
                      child: Text('Finish'),
                    ),
                  ],
                ),
                Wrap(
                  children: _capturedImages.map((image) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.file(image, width: 100, height: 100),
                    );
                  }).toList(),
                ),
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
