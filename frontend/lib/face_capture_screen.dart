// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:path_provider/path_provider.dart'; 

// class FaceCaptureScreen extends StatefulWidget {
//   final String studentId;

//   const FaceCaptureScreen({Key? key, required this.studentId}) : super(key: key);

//   @override
//   _FaceCaptureScreenState createState() => _FaceCaptureScreenState();
// }

// class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
//   CameraController? _cameraController;
//   List<String> _capturedImagePaths = [];
//   bool _isCameraInitialized = false;
//   bool _isCapturing = false; 

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   Future<void> _initializeCamera() async {
//     try {
//       final cameras = await availableCameras();
//       final frontCamera = cameras.firstWhere(
//         (camera) => camera.lensDirection == CameraLensDirection.front,
//         orElse: () => throw Exception('No front camera found'),
//       );

//       _cameraController = CameraController(
//         frontCamera,
//         ResolutionPreset.high,
//       );

//       await _cameraController!.initialize();
//       setState(() {
//         _isCameraInitialized = true;
//       });
//     } catch (e) {
//       print("Error initializing front camera: $e");
//     }
//   }

//   Future<void> _captureImage() async {
//     if (_cameraController == null || !_cameraController!.value.isInitialized) {
//       return;
//     }

//     setState(() {
//       _isCapturing = true;
//     });

//     const captureCount = 10;
//     const delay = Duration(milliseconds: 250); 

//     for (int i = 0; i < captureCount; i++) {
//       try {
//         final image = await _cameraController!.takePicture();
//         _saveImageToDirectory(image.path);
//         if (i < captureCount - 1) {
//           await Future.delayed(delay); 
//         }
//       } catch (e) {
//         print('Error capturing image: $e');
//       }
//     }

//     setState(() {
//       _isCapturing = false;
//     });

//     // After capturing 10 images, navigate back to the registration page
//     Navigator.pop(context, _capturedImagePaths);
//   }

//   void _saveImageToDirectory(String imagePath) async {
//     final directory = await getApplicationDocumentsDirectory();
//     final studentDirectory = Directory('${directory.path}/${widget.studentId}');

//     if (!studentDirectory.existsSync()) {
//       studentDirectory.createSync(recursive: true);
//     }

//     final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
//     final newPath = '${studentDirectory.path}/$fileName';
//     File(imagePath).copySync(newPath);

//     _capturedImagePaths.add(newPath);
//     setState(() {});

//     print('Image saved to $newPath');
//   }

//   @override
//   void dispose() {
//     _cameraController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Manual Face Capture'),
//         backgroundColor: const Color.fromARGB(255, 167, 131, 118),
//       ),
//       body: Column(
//         children: <Widget>[
//           if (_isCameraInitialized)
//             Expanded(
//               flex: 3,
//               child: CameraPreview(_cameraController!),
//             )
//           else
//             Expanded(
//               flex: 3,
//               child: Center(
//                 child: CircularProgressIndicator(),
//               ),
//             ),
//           Expanded(
//             flex: 1,
//             child: Container(
//               padding: EdgeInsets.all(8.0),
//               child: Column(
//                 children: [
//                   ElevatedButton(
//                     onPressed: _isCapturing ? null : () {
//                       showDialog(
//                         context: context,
//                         builder: (context) => AlertDialog(
//                           title: Text('Ensure Your Face is Visible'),
//                           content: Text('Please make sure your face is visible in the camera and press "Start Capturing" to begin.'),
//                           actions: [
//                             ElevatedButton(
//                               onPressed: () {
//                                 Navigator.of(context).pop();
//                                 _captureImage();
//                               },
//                               child: Text('Start Capturing'),
//                             ),
//                             ElevatedButton(
//                               onPressed: () => Navigator.of(context).pop(),
//                               child: Text('Cancel'),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                     child: Text('Capture Image'),
//                   ),
//                   SizedBox(height: 20),
//                   if (_isCapturing)
//                     Center(child: CircularProgressIndicator()),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart'; 
import 'package:http/http.dart' as http;  // For sending HTTP requests
import 'package:path/path.dart' as p;  // For handling file paths

class FaceCaptureScreen extends StatefulWidget {
  final String studentId;

  const FaceCaptureScreen({Key? key, required this.studentId}) : super(key: key);

  @override
  _FaceCaptureScreenState createState() => _FaceCaptureScreenState();
}

class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
  CameraController? _cameraController;
  List<String> _capturedImagePaths = [];
  bool _isCameraInitialized = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => throw Exception('No front camera found'),
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
      );

      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print("Error initializing front camera: $e");
    }
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    const captureCount = 10;
    const delay = Duration(milliseconds: 250); 

    for (int i = 0; i < captureCount; i++) {
      try {
        final image = await _cameraController!.takePicture();
        _saveImageToDirectory(image.path);
        if (i < captureCount - 1) {
          await Future.delayed(delay); 
        }
      } catch (e) {
        print('Error capturing image: $e');
      }
    }

    setState(() {
      _isCapturing = false;
    });

    // Upload the captured images to the backend after capturing
    await _uploadImagesToAPI();

    // After capturing 10 images, navigate back to the registration page
    Navigator.pop(context, _capturedImagePaths);
  }

  void _saveImageToDirectory(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final studentDirectory = Directory('${directory.path}/${widget.studentId}');

    if (!studentDirectory.existsSync()) {
      studentDirectory.createSync(recursive: true);
    }

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final newPath = p.join(studentDirectory.path, fileName);  // Using 'p' for path functions
    File(imagePath).copySync(newPath);

    _capturedImagePaths.add(newPath);
    setState(() {});

    print('Image saved to $newPath');
  }

  Future<void> _uploadImagesToAPI() async {
    // Define your Django backend URL for image upload
    var uri = Uri.parse('http://192.168.1.8:8000/auth/api/upload-image/');

    // For each captured image, send it to the server
    for (String path in _capturedImagePaths) {
      var imageFile = File(path);
      var imageName = p.basename(imageFile.path);

      // Create a multipart request
      var request = http.MultipartRequest('POST', uri);

      // Attach the image file to the request
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path, filename: imageName));

      // Send the request
      var response = await request.send();

      // Handle the response
      if (response.statusCode == 201) {
        print('Image $imageName uploaded successfully');
      } else {
        print('Failed to upload image $imageName');
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manual Face Capture'),
        backgroundColor: const Color.fromARGB(255, 167, 131, 118),
      ),
      body: Column(
        children: <Widget>[
          if (_isCameraInitialized)
            Expanded(
              flex: 3,
              child: CameraPreview(_cameraController!),
            )
          else
            Expanded(
              flex: 3,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _isCapturing ? null : () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Ensure Your Face is Visible'),
                          content: Text('Please make sure your face is visible in the camera and press "Start Capturing" to begin.'),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _captureImage();
                              },
                              child: Text('Start Capturing'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('Cancel'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text('Capture Image'),
                  ),
                  SizedBox(height: 20),
                  if (_isCapturing)
                    Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
