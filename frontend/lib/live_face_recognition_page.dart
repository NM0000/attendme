import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class LiveFaceRecognitionPage extends StatefulWidget {
  @override
  _LiveFaceRecognitionPageState createState() => _LiveFaceRecognitionPageState();
}

class _LiveFaceRecognitionPageState extends State<LiveFaceRecognitionPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isRecording = false;
  List<String> detectedFaces = [];

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
    } catch (e) {
      print('Error initializing camera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera initialization failed: $e')),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    await _initializeControllerFuture;

    if (!_controller.value.isInitialized || _isRecording) return;

    setState(() {
      _isRecording = true;
    });

    _controller.startImageStream((CameraImage image) async {
      List<String> faces = await _recognizeFaces(image);
      if (mounted) { // Check if the widget is still in the widget tree
        setState(() {
          detectedFaces = faces;
        });
      }
    });
  }

  Future<void> _stopRecording() async {
    if (_isRecording) {
      await _controller.stopImageStream();
      setState(() {
        _isRecording = false;
        detectedFaces = [];
      });
    }
  }

  Future<List<String>> _recognizeFaces(CameraImage image) async {
    // Integrate your ML model here
    // Convert CameraImage to an input format suitable for your ML model

    // Placeholder for ML model inference
    // Replace the following with your actual ML model inference
    //final detectedFaces = await yourMLModel.runInference(image);

    // Simulate detected faces for demonstration purposes
    await Future.delayed(Duration(milliseconds: 100)); // Simulate processing time

    // Placeholder for detected faces
    List<String> recognizedFaceNames = []; 
    // Add recognized face names or IDs to the list
    return recognizedFaceNames;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Face Recognition'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            _stopRecording();
            Navigator.pop(context);
          },
        ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _isRecording ? _stopRecording : _startRecording,
                      child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
                    ),
                  ],
                ),
                if (_isRecording) ...[
                  if (detectedFaces.isEmpty)
                    Text('No face detected')
                  else
                    ...[
                      Text('Number of students present: ${detectedFaces.length}'),
                      ...detectedFaces.map((name) => Text(name)).toList(),
                    ]
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
