// //changes done



// // import 'package:camera/camera.dart';
// // import 'package:flutter/material.dart';
// // import 'package:path_provider/path_provider.dart';

// // class FaceCaptureScreen extends StatefulWidget {
// //   const FaceCaptureScreen({Key? key}) : super(key: key);

// //   @override
// //   _FaceCaptureScreenState createState() => _FaceCaptureScreenState();
// // }

// // class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
// //   CameraController? _controller;
// //   late Future<void> _initializeControllerFuture;
// //   bool _isCapturing = false;
// //   List<String> _capturedImagePaths = [];
// //   final int _maxImages = 50;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _initializeControllerFuture = _initializeCamera();
// //   }

// //   Future<void> _initializeCamera() async {
// //     final cameras = await availableCameras();
// //     final frontCamera = cameras.firstWhere(
// //       (camera) => camera.lensDirection == CameraLensDirection.front,
// //       orElse: () => cameras.first,
// //     );

// //     _controller = CameraController(
// //       frontCamera,
// //       ResolutionPreset.high,
// //       enableAudio: false,
// //     );

// //     try {
// //       await _controller?.initialize();
// //       setState(() {});
// //     } catch (e) {
// //       print('Error initializing camera: $e');
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Camera initialization failed: $e')),
// //       );
// //     }
// //   }

// //   Future<void> _startCapturing() async {
// //     if (_controller?.value.isInitialized == true && !_isCapturing) {
// //       setState(() {
// //         _isCapturing = true;
// //       });

// //       final directory = await getTemporaryDirectory();
// //       List<String> capturedPaths = [];

// //       for (int i = 0; i < _maxImages; i++) {
// //         try {
// //           final XFile image = await _controller!.takePicture();
// //           final String imagePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
// //           await image.saveTo(imagePath);
// //           capturedPaths.add(imagePath);

// //           // Optional: Add a delay between captures to allow for face detection
// //           await Future.delayed(Duration(milliseconds: 500));
// //         } catch (e) {
// //           print('Error capturing image: $e');
// //         }
// //       }

// //       setState(() {
// //         _capturedImagePaths = capturedPaths;
// //         _isCapturing = false;
// //       });

// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Captured $_maxImages images.')),
// //       );

// //       // After capturing images, send them to the backend for training.
// //       await _sendImagesToBackend(_capturedImagePaths);

// //       // Log captured image paths for debugging
// //       _capturedImagePaths.forEach((path) => print('Captured image saved at: $path'));

// //       Navigator.pop(context, _capturedImagePaths);
// //     }
// //   }

// //   // Method to send images to the backend (you can implement this method)
// //   Future<void> _sendImagesToBackend(List<String> imagePaths) async {
// //     // Iterate over the image paths and send each one to the backend
// //     for (String path in imagePaths) {
// //       // Implement your logic to upload the image file to your backend here.
// //       // You can use HTTP requests (like POST) to send the image data.
// //       print('Sending image to backend: $path');
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _controller?.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Face Capture'),
// //         leading: IconButton(
// //           icon: Icon(Icons.arrow_back),
// //           onPressed: () {
// //             Navigator.pop(context);
// //           },
// //         ),
// //       ),
// //       body: FutureBuilder<void>(
// //         future: _initializeControllerFuture,
// //         builder: (context, snapshot) {
// //           if (snapshot.connectionState == ConnectionState.done) {
// //             if (_controller?.value.isInitialized == true) {
// //               return Stack(
// //                 children: [
// //                   CameraPreview(_controller!), // Full-screen camera preview
// //                   Positioned(
// //                     top: 50,
// //                     right: 20,
// //                     child: IconButton(
// //                       icon: Icon(
// //                         _isCapturing ? Icons.stop_circle : Icons.videocam,
// //                         color: Colors.red,
// //                         size: 40,
// //                       ),
// //                       onPressed: _isCapturing ? null : _startCapturing,
// //                     ),
// //                   ),
// //                   if (_isCapturing)
// //                     Positioned(
// //                       top: 50,
// //                       left: 20,
// //                       child: Text(
// //                         "Capturing...",
// //                         style: TextStyle(
// //                           color: Colors.red,
// //                           fontSize: 20,
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                       ),
// //                     ),
// //                   // Display captured image paths
// //                   if (!_isCapturing && _capturedImagePaths.isNotEmpty)
// //                     Positioned(
// //                       bottom: 20,
// //                       left: 20,
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: _capturedImagePaths.map((path) => Text('Image saved at: $path')).toList(),
// //                       ),
// //                     ),
// //                 ],
// //               );
// //             } else {
// //               return Center(child: Text('Failed to initialize the camera.'));
// //             }
// //           } else {
// //             return Center(child: CircularProgressIndicator());
// //           }
// //         },
// //       ),
// //     );
// //   }
// // }






// // // // version 2
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';

// class FaceCaptureScreen extends StatefulWidget {
//   const FaceCaptureScreen({Key? key}) : super(key: key);

//   @override
//   _FaceCaptureScreenState createState() => _FaceCaptureScreenState();
// }

// class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
//   CameraController? _controller;
//   late Future<void> _initializeControllerFuture;
//   bool _isCapturing = false;
//   List<String> _capturedImagePaths = [];
//   final int _maxImages = 50;
//   double _captureProgress = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     _initializeControllerFuture = _initializeCamera();
//   }

//   Future<void> _initializeCamera() async {
//     final cameras = await availableCameras();
//     final frontCamera = cameras.firstWhere(
//       (camera) => camera.lensDirection == CameraLensDirection.front,
//       orElse: () => cameras.first,
//     );

//     _controller = CameraController(
//       frontCamera,
//       ResolutionPreset.high,
//       enableAudio: false,
//     );

//     try {
//       await _controller?.initialize();
//       setState(() {});
//     } catch (e) {
//       print('Error initializing camera: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Camera initialization failed: $e')),
//       );
//     }
//   }

//   Future<void> _startCapturing() async {
//     if (_controller?.value.isInitialized == true && !_isCapturing) {
//       setState(() {
//         _isCapturing = true;
//       });

//       final directory = await getTemporaryDirectory();
//       List<String> capturedPaths = [];

//       for (int i = 0; i < _maxImages; i++) {
//         try {
//           final XFile image = await _controller!.takePicture();
//           final String imagePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
//           await image.saveTo(imagePath);
//           capturedPaths.add(imagePath);

//           // Update progress
//           setState(() {
//             _captureProgress = (i + 1) / _maxImages;
//           });

//           // Optional: Add a delay between captures to allow for face detection
//           await Future.delayed(Duration(milliseconds: 500));
//         } catch (e) {
//           print('Error capturing image: $e');
//         }
//       }

//       setState(() {
//         _capturedImagePaths = capturedPaths;
//         _isCapturing = false;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Captured $_maxImages images.')),
//       );

//       // After capturing images, send them to the backend for training.
//       await _sendImagesToBackend(_capturedImagePaths);

//       // Log captured image paths for debugging
//       _capturedImagePaths.forEach((path) => print('Captured image saved at: $path'));

//       _showCompletionDialog();
//     }
//   }

//   Future<void> _sendImagesToBackend(List<String> imagePaths) async {
//     // Implement your logic to upload the image file to your backend here.
//     for (String path in imagePaths) {
//       print('Sending image to backend: $path');
//     }
//   }

//   void _showCompletionDialog() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Capture Complete'),
//           content: Text('Successfully captured $_maxImages images.'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 Navigator.pop(context, _capturedImagePaths);
//               },
//               child: Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Face Capture'),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: FutureBuilder<void>(
//         future: _initializeControllerFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             if (_controller?.value.isInitialized == true) {
//               return Stack(
//                 children: [
//                   CameraPreview(_controller!), // Full-screen camera preview
//                   Positioned(
//                     top: 50,
//                     right: 20,
//                     child: IconButton(
//                       icon: Icon(
//                         _isCapturing ? Icons.stop_circle : Icons.camera_alt,
//                         color: Colors.red,
//                         size: 40,
//                       ),
//                       onPressed: _isCapturing ? null : _startCapturing,
//                     ),
//                   ),
//                   if (_isCapturing)
//                     Positioned(
//                       bottom: 20,
//                       left: 20,
//                       right: 20,
//                       child: Column(
//                         children: [
//                           LinearProgressIndicator(value: _captureProgress),
//                           SizedBox(height: 10),
//                           Text(
//                             "Capturing... ${(_captureProgress * 100).toStringAsFixed(0)}%",
//                             style: TextStyle(
//                               color: Colors.red,
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           'Please center your face in the frame.',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 22,
//                             fontWeight: FontWeight.w600,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                         SizedBox(height: 20),
//                         ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blueAccent,
//                             padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           onPressed: _isCapturing ? null : _startCapturing,
//                           child: Text(
//                             'Start Capture',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               );
//             } else {
//               return Center(child: Text('Failed to initialize the camera.'));
//             }
//           } else {
//             return Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//     );
//   }
// }

//version 3
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class FaceCaptureScreen extends StatefulWidget {
  final String studentId; // Added student ID as a parameter

  const FaceCaptureScreen({Key? key, required this.studentId}) : super(key: key);

  @override
  _FaceCaptureScreenState createState() => _FaceCaptureScreenState();
}

class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;
  bool _isCapturing = false;
  List<String> _capturedImagePaths = [];
  final int _maxImages = 50;
  double _captureProgress = 0.0;

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
      final studentFolder = Directory('${directory.path}/${widget.studentId}');

      if (!await studentFolder.exists()) {
        await studentFolder.create(recursive: true);
      }

      List<String> capturedPaths = [];

      for (int i = 0; i < _maxImages; i++) {
        try {
          final XFile image = await _controller!.takePicture();
          final String imagePath = '${studentFolder.path}/${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
          await image.saveTo(imagePath);
          capturedPaths.add(imagePath);

          // Update progress
          setState(() {
            _captureProgress = (i + 1) / _maxImages;
          });

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
      await _sendImagesToBackend(widget.studentId, _capturedImagePaths);

      // Log captured image paths for debugging
      _capturedImagePaths.forEach((path) => print('Captured image saved at: $path'));

      _showCompletionDialog();
    }
  }

  Future<void> _sendImagesToBackend(String studentId, List<String> imagePaths) async {
    final Uri url = Uri.parse('http://192.168.1.5:8000/api/auth/upload_photo/');
    final request = http.MultipartRequest('POST', url);

    for (String path in imagePaths) {
      final File file = File(path);
      request.files.add(await http.MultipartFile.fromPath('photo', file.path));
    }

    // Include student ID in the request
    request.fields['student_id'] = studentId;

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        print('All images uploaded successfully.');
      } else {
        print('Failed to upload images: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending images to backend: $e');
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Capture Complete'),
          content: Text('Successfully captured $_maxImages images.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, _capturedImagePaths);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
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
                        _isCapturing ? Icons.stop_circle : Icons.camera_alt,
                        color: Colors.red,
                        size: 40,
                      ),
                      onPressed: _isCapturing ? null : _startCapturing,
                    ),
                  ),
                  if (_isCapturing)
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        children: [
                          LinearProgressIndicator(value: _captureProgress),
                          SizedBox(height: 10),
                          Text(
                            "Capturing... ${(_captureProgress * 100).toStringAsFixed(0)}%",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Please center your face in the frame.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isCapturing ? null : _startCapturing,
                          child: Text(_isCapturing ? 'Capturing...' : 'Start Capture'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return Center(child: Text('Camera not initialized'));
            }
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
