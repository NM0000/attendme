//changes done



import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FaceCaptureScreen extends StatefulWidget {
  const FaceCaptureScreen({Key? key}) : super(key: key);

  @override
  _FaceCaptureScreenState createState() => _FaceCaptureScreenState();
}

class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;
  bool _isCapturing = false;
  List<String> _capturedImagePaths = [];
  final int _maxImages = 50;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller?.initialize();
      setState(() {});
    } catch (e) {
      print('Error initializing camera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera initialization failed: $e')),
      );
    }
  }

  Future<void> _startCapturing() async {
    if (_controller?.value.isInitialized == true && !_isCapturing) {
      setState(() {
        _isCapturing = true;
      });

      final directory = await getTemporaryDirectory();
      List<String> capturedPaths = [];

      for (int i = 0; i < _maxImages; i++) {
        try {
          final XFile image = await _controller!.takePicture();
          final String imagePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
          await image.saveTo(imagePath);
          capturedPaths.add(imagePath);

          // Optional: Add a delay between captures to allow for face detection
          await Future.delayed(Duration(milliseconds: 500));
        } catch (e) {
          print('Error capturing image: $e');
        }
      }

      setState(() {
        _capturedImagePaths = capturedPaths;
        _isCapturing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Captured $_maxImages images.')),
      );

      // After capturing images, send them to the backend for training.
      await _sendImagesToBackend(_capturedImagePaths);

      // Log captured image paths for debugging
      _capturedImagePaths.forEach((path) => print('Captured image saved at: $path'));

      Navigator.pop(context, _capturedImagePaths);
    }
  }

  // Method to send images to the backend (you can implement this method)
  Future<void> _sendImagesToBackend(List<String> imagePaths) async {
    // Iterate over the image paths and send each one to the backend
    for (String path in imagePaths) {
      // Implement your logic to upload the image file to your backend here.
      // You can use HTTP requests (like POST) to send the image data.
      print('Sending image to backend: $path');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Face Capture'),
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
            if (_controller?.value.isInitialized == true) {
              return Stack(
                children: [
                  CameraPreview(_controller!), // Full-screen camera preview
                  Positioned(
                    top: 50,
                    right: 20,
                    child: IconButton(
                      icon: Icon(
                        _isCapturing ? Icons.stop_circle : Icons.videocam,
                        color: Colors.red,
                        size: 40,
                      ),
                      onPressed: _isCapturing ? null : _startCapturing,
                    ),
                  ),
                  if (_isCapturing)
                    Positioned(
                      top: 50,
                      left: 20,
                      child: Text(
                        "Capturing...",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  // Display captured image paths
                  if (!_isCapturing && _capturedImagePaths.isNotEmpty)
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _capturedImagePaths.map((path) => Text('Image saved at: $path')).toList(),
                      ),
                    ),
                ],
              );
            } else {
              return Center(child: Text('Failed to initialize the camera.'));
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}






// // // version 2

// import 'package:camera/camera.dart'; // Importing the camera package to access the device's camera.
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart'; // Importing Flutter's material design package for UI elements.
// import 'package:path_provider/path_provider.dart'; // For getting the directory paths on the device.
// import 'package:google_ml_kit/google_ml_kit.dart'; // Importing Google's ML Kit for face detection.

// class FaceCaptureScreen extends StatefulWidget { 
//   const FaceCaptureScreen({Key? key}) : super(key: key);

//   @override
//   _FaceCaptureScreenState createState() => _FaceCaptureScreenState();
// }

// class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
//   CameraController? _controller; // Controller to manage camera operations.
//   late Future<void> _initializeControllerFuture; // Future to handle camera initialization.
//   bool _isCapturing = false; // Boolean to track if the camera is currently capturing images.
//   bool _isFaceDetected = false; // Boolean to track if a face is detected.
//   FaceDetector? _faceDetector; // Object to handle face detection using ML Kit.
//   List<String> _capturedImagePaths = []; // List to store paths of captured images.
//   final int _maxImages = 5; // Number of images to capture.

//   @override
//   void initState() {
//     super.initState();
//     _initializeControllerFuture = _initializeCamera(); // Initialize the camera when the widget is created.
//     _faceDetector = GoogleMlKit.vision.faceDetector(FaceDetectorOptions(
//       enableContours: true, // Enable detection of facial contours (like eyes, nose, etc.).
//       enableClassification: true, // Enable face classification (like smiling or not).
//     ));
//   }

//   Future<void> _initializeCamera() async {
//     final cameras = await availableCameras(); // Get a list of available cameras on the device.
//     final frontCamera = cameras.firstWhere(
//       (camera) => camera.lensDirection == CameraLensDirection.front, // Prefer the front-facing camera.
//       orElse: () => cameras.first, // If no front camera, use the first available camera.
//     );

//     _controller = CameraController(
//       frontCamera,
//       ResolutionPreset.high, // Set camera resolution to high.
//       enableAudio: false, // Disable audio capture.
//     );

//     try {
//       await _controller?.initialize(); // Initialize the camera.
//       _controller?.startImageStream((CameraImage image) async {
//         if (_isCapturing) return; // If already capturing images, do nothing.
//         await _detectFaces(image); // Start face detection on the camera feed.
//       });
//       setState(() {});
//     } catch (e) {
//       print('Error initializing camera: $e'); // Print an error message if camera initialization fails.
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Camera initialization failed: $e')), // Show a notification if initialization fails.
//       );
//     }
//   }

//   Future<void> _detectFaces(CameraImage image) async {
//     final inputImage = _convertCameraImage(image); // Convert camera image to a format usable by ML Kit.
//     final List<Face> faces = await _faceDetector!.processImage(inputImage); // Process the image and detect faces.

//     if (faces.isNotEmpty) {
//       setState(() {
//         _isFaceDetected = true; // If faces are detected, update the state.
//       });
//     } else {
//       setState(() {
//         _isFaceDetected = false; // If no faces are detected, update the state.
//       });
//     }
//   }

//   InputImage _convertCameraImage(CameraImage image) {
//     final allBytes = WriteBuffer(); // Buffer to hold image bytes.
//     image.planes.forEach((plane) {
//       allBytes.putUint8List(plane.bytes); // Convert each plane of the image to bytes.
//     });
//     final bytes = allBytes.done().buffer.asUint8List(); // Get the final byte list.

//     final inputImageData = InputImageData(
//       size: Size(image.width.toDouble(), image.height.toDouble()), // Size of the image.
//       imageRotation: InputImageRotation.Rotation_0deg, // Rotation of the image (not rotated).
//       inputImageFormat: InputImageFormatMethods.fromRawValue(image.format.raw) ?? InputImageFormat.NV21, // Format of the image.
//       planeData: image.planes.map(
//         (plane) {
//           return InputImagePlaneMetadata(
//             bytesPerRow: plane.bytesPerRow, // Number of bytes per row in the image.
//             height: plane.height, // Height of the image plane.
//             width: plane.width, // Width of the image plane.
//           );
//         },
//       ).toList(),
//     );

//     return InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData); // Create an InputImage for ML Kit.
//   }

//   Future<void> _startCapturing() async {
//     if (_controller?.value.isInitialized == true && _isFaceDetected && !_isCapturing) {
//       setState(() {
//         _isCapturing = true; // Set capturing to true to indicate that capturing is in progress.
//       });

//       final directory = await getTemporaryDirectory(); // Get a temporary directory to save the images.
//       List<String> capturedPaths = []; // List to hold the paths of captured images.

//       for (int i = 0; i < _maxImages; i++) {
//         try {
//           final XFile image = await _controller!.takePicture(); // Capture an image.
//           final String imagePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}_$i.jpg'; // Create a unique path for the image.
//           await image.saveTo(imagePath); // Save the image to the path.
//           capturedPaths.add(imagePath); // Add the image path to the list.

//           // Optional: Add a delay between captures to allow for face detection
//           await Future.delayed(Duration(milliseconds: 500)); // Delay to stabilize the camera for the next capture.
//         } catch (e) {
//           print('Error capturing image: $e'); // Print an error message if image capture fails.
//         }
//       }

//       setState(() {
//         _capturedImagePaths = capturedPaths; // Update the state with the captured image paths.
//         _isCapturing = false; // Set capturing to false as capturing is complete.
//       });

//       ScaffoldMessenger.of (context).showSnackBar(
//         SnackBar(content: Text('Captured $_maxImages images.')), // Show a notification that images were captured.
//       );

//       // Log captured image paths for debugging
//       _capturedImagePaths.forEach((path) => print('Captured image saved at: $path')); // Print each captured image path.

//       // Return the captured paths to the previous screen
//       Navigator.pop(context, _capturedImagePaths); // Return the captured image paths to the previous screen.
//     }
//   }

//   @override
//   void dispose() {
//     _controller?.dispose(); // Dispose of the camera controller when the widget is destroyed.
//     _faceDetector?.close(); // Close the face detector when the widget is destroyed.
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Face Capture'), // Title of the screen.
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back), // Back arrow to navigate to the previous screen.
//           onPressed: () {
//             Navigator.pop(context); // Go back to the previous screen when the back arrow is pressed.
//           },
//         ),
//       ),
//       body: FutureBuilder<void>(
//         future: _initializeControllerFuture, // Wait for the camera to initialize.
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             if (_controller?.value.isInitialized == true) {
//               return Stack(
//                 children: [
//                   CameraPreview(_controller!), // Show the camera preview on the screen.
//                   if (_isFaceDetected)
//                     Positioned(
//                       top: 50,
//                       left: 20,
//                       child: Text(
//                         "Face Detected", // Display "Face Detected" if a face is detected.
//                         style: TextStyle(
//                           color: Colors.green,
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   Positioned(
//                     top: 50,
//                     right: 20,
//                     child: IconButton(
//                       icon: Icon(
//                         _isCapturing ? Icons.stop_circle : Icons.camera, // Show stop icon if capturing, camera icon otherwise.
//                         color: Colors.red,
//                         size: 40,
//                       ),
//                       onPressed: _isCapturing ? null : _startCapturing, // If not capturing, start capturing when the button is pressed.
//                     ),
//                   ),
//                 ],
//               );
//             } else {
//               return Center(child: Text('Failed to initialize the camera.')); // Show error if camera initialization fails.
//             }
//           } else {
//             return Center(child: CircularProgressIndicator()); // Show a loading spinner while the camera is initializing.
//           }
//         },
//       ),
//     );
//   }
// }


