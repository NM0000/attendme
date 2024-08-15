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
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    await _initializeControllerFuture;

    setState(() {
      _isRecording = true;
    });

    _controller.startImageStream((CameraImage image) async {
      List<String> faces = await _recognizeFaces(image);
      setState(() {
        detectedFaces = faces;
      });
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

    // If no faces are detected, return an empty list
    if (detectedFaces.isEmpty) {
      return [];
    }

    // Otherwise, return the names or IDs of detected faces
    List<String> recognizedFaceNames = [];
    for (var face in detectedFaces) {
      // Add recognized face name or ID to the list
      //recognizedFaceNames.add(face.name); UNCOMMRNT LINE AFTER ML
    }

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

