// //............

// import 'dart:async';
// import 'dart:convert';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class AttendancePage extends StatefulWidget {
//   final List<CameraDescription> cameras;
//   const AttendancePage({Key? key, required this.cameras}) : super(key: key);

//   @override
//   _AttendancePageState createState() => _AttendancePageState();
// }

// class _AttendancePageState extends State<AttendancePage> {
//   late CameraController _cameraController;
//   bool _isBackCamera = true;
//   bool _flashEnabled = false;
//   bool _isAutomaticCaptureInitialized = false;
//   bool _isProcessingImage = false;
//   List<String> recognized_name_recognizedStudents = [];
//   DateTime? _dateTime;
//   Timer? _captureTimer;
//   int _captureCount = 0;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   void _initializeCamera() {
//     _cameraController = CameraController(
//       _isBackCamera ? widget.cameras.first : widget.cameras.last,
//       ResolutionPreset.high,
//     );
//     _cameraController.initialize().then((_) {
//       if (!mounted) return;
//       setState(() {});
//     });
//   }

//   void _toggleCamera() {
//     setState(() {
//       _isBackCamera = !_isBackCamera;
//       _flashEnabled = _isBackCamera;
//       _initializeCamera();
//     });
//   }

//   void _toggleFlash() {
//     if (_isBackCamera) {
//       setState(() {
//         _flashEnabled = !_flashEnabled;
//         _cameraController.setFlashMode(
//           _flashEnabled ? FlashMode.torch : FlashMode.off,
//         );
//       });
//     }
//   }

//   void _startAutomaticCapture() {
//     if (_isAutomaticCaptureInitialized) return;
//     _isAutomaticCaptureInitialized = true;
//     _captureTimer = Timer.periodic(Duration(seconds: 4), (timer) async {
//       _captureCount += 2;
//       await _captureImage();
//       if (_captureCount >= 30) {
//         timer.cancel();
//         _showStudentListPopup();
//         _captureCount = 0;
//       }
//     });
//   }

//   Future<void> _captureImage() async {
//     if (!_cameraController.value.isInitialized || _isProcessingImage) return;
//     _isProcessingImage = true;

//     try {
//       final XFile image = await _cameraController.takePicture();

//       // Send the image file to the model
//       final response = await _sendImageToModel(image.path); // Use the file path

//       if (response != null) {
//         setState(() {
//           // Update recognized students list
//           final newStudents =
//               List<String>.from(response['recognized_name_recognizedStudents'] ?? []);
//           recognized_name_recognizedStudents =
//               {...recognized_name_recognizedStudents, ...newStudents}.toList();
//           _updateDateTime();
//           // Print recognized face count and names
//           int recognizedFaceCount = recognized_name_recognizedStudents.length;
//           print("Recognized face count: $recognizedFaceCount");
//           print("Recognized faces: ${recognized_name_recognizedStudents.join(', ')}");
//           // Optionally, show a message in the UI for recognized faces
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                   'Recognized face count: $recognizedFaceCount\nNames: ${recognized_name_recognizedStudents.join(', ')}'),
//             duration: Duration(seconds: 4),
//           ),
//         );
//         });
//       }
//     } catch (e) {
//       print("Error capturing image: $e");
//     } finally {
//       _isProcessingImage = false;
//     }
//   }

//   Future<Map<String, dynamic>?> _sendImageToModel(String filePath) async {
//     const String url = 'http://192.168.1.5:8000/api/auth/recognize-face/';
//     int retryCount = 3;

//     for (int attempt = 0; attempt < retryCount; attempt++) {
//       try {
//         var request = http.MultipartRequest('POST', Uri.parse(url));

//         // Attach the image file as multipart
//         request.files.add(
//           await http.MultipartFile.fromPath(
//             'attachment', 
//             filePath,
//           ),
//         );

//         // Send the request
//         var streamedResponse = await request.send();
//         var response = await http.Response.fromStream(streamedResponse);

//         if (response.statusCode == 200) {
//           return jsonDecode(
//               response.body); // Return the response as a JSON object
//         } else {
//           print(
//               'Failed to get response from model (Status: ${response.statusCode})');
//         }
//       } catch (e) {
//         print("Error sending image to model on attempt ${attempt + 1}: $e");
//       }
//     }
//     return null;
//   }

//   void _updateDateTime() {
//     setState(() {
//       _dateTime = DateTime.now();
//     });
//   }

//   void _showStudentListPopup() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text("Recognized Students"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children:
//               recognized_name_recognizedStudents.map((student) => Text(student)).toList(),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               _sendAttendanceReport();
//               Navigator.of(context).pop();
//             },
//             child: Text("Done"),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _sendAttendanceReport() async {
//     const String url = 'http://192.168.1.5:8000/api/auth/report';

//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'attachment': recognized_name_recognizedStudents}),
//       );

//       if (response.statusCode == 200) {
//         print('Attendance report sent successfully');
//       } else {
//         print('Failed to send attendance report: ${response.statusCode}');
//       }
//     } catch (e) {
//       print("Error sending attendance report: $e");
//     }
//   }

//   @override
//   void dispose() {
//     _cameraController.dispose();
//     _captureTimer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_cameraController.value.isInitialized) {
//       return Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Facial Recognition Attendance'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: CameraPreview(_cameraController),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               IconButton(
//                 icon: Icon(
//                   _flashEnabled ? Icons.flash_on : Icons.flash_off,
//                   color: _isBackCamera ? Colors.black : Colors.grey,
//                 ),
//                 onPressed: _toggleFlash,
//               ),
//               IconButton(
//                 icon: Icon(Icons.camera, color: Colors.black),
//                 onPressed: _startAutomaticCapture,
//               ),
//               IconButton(
//                 icon: Icon(Icons.switch_camera, color: Colors.black),
//                 onPressed: _toggleCamera,
//               ),
//             ],
//           ),
//           SizedBox(height: 20),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                     'Date: ${_dateTime != null ? _dateTime!.toLocal().toString().split(' ')[0] : ''}'),
//                 Text(
//                     'Time: ${_dateTime != null ? _dateTime!.toLocal().toString().split(' ')[1] : ''}'),
//                 Text('Total Number of Students: ${recognized_name_recognizedStudents.length}'),
//                 Text('Names of Students:'),
//                 SingleChildScrollView(
//                   child: Column(
//                     children: recognized_name_recognizedStudents
//                         .map((student) => Text(student))
//                         .toList(),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

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
          // Get recognized names from response and print each one
          final newStudents = List<String>.from(response['recognized_name'] ?? []);
          newStudents.forEach((name) => print('Recognized Name: $name'));
          
          // Update the recognized students list
          _recognizedStudents = {..._recognizedStudents, ...newStudents}.toList();
          _updateDateTime();
        });
      }
    } catch (e) {
      print("Error capturing image: $e");
    } finally {
      _isProcessingImage = false;
    }
  }

  Future<Map<String, dynamic>?> _sendImageToModel(String filePath) async {
    const String url = 'http://192.168.1.5:8000/api/auth/recognize-face/';
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
          return jsonDecode(response.body); // Return the response as a JSON object
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
    _dateTime = DateTime.now();
  }

  void _showStudentListPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Recognized Students"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _recognizedStudents.map((student) => Text(student)).toList(),
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
    const String url = 'http://192.168.1.5:8000/api/auth/attendance/';

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
                Text('Date: ${_dateTime != null ? _dateTime!.toLocal().toString().split(' ')[0] : ''}'),
                Text('Time: ${_dateTime != null ? _dateTime!.toLocal().toString().split(' ')[1].split('.')[0] : ''}'),
                Text('Total Number of Students: ${_recognizedStudents.length}'),
                Text('Names of Students:'),
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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

// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;

// class AttendancePage extends StatefulWidget {
//   @override
//   _AttendancePageState createState() => _AttendancePageState();
// }

// class _AttendancePageState extends State<AttendancePage> {
//   File? _image;
//   String _recognizedName = "Unknown";
//   String _processedImage = "";

//   Future<void> _pickImage() async {
//     final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//       });
//     }
//   }

//   Future<void> _sendImageToBackend() async {
//     if (_image == null) return;

//     // Read the image as bytes
//     List<int> imageBytes = await _image!.readAsBytes();
//     String base64Image = base64Encode(imageBytes);

//     try {
//       // Send a POST request to the backend
//       var response = await http.post(
//         Uri.parse("http://192.168.1.5:8000/api/auth/recognize-face/"),
//         body: {
//           'attachment': base64Image,
//         },
//       );

//       if (response.statusCode == 200) {
//         // Parse the response
//         var jsonResponse = jsonDecode(response.body);
//         setState(() {
//           _recognizedName = jsonResponse['recognized_name'];
//           _processedImage = jsonResponse['processed_frame'];
//         });
//       } else {
//         print("Failed to get response: ${response.body}");
//       }
//     } catch (e) {
//       print("Error: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Attendance System"),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (_image != null) Image.file(_image!),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _pickImage,
//               child: Text("Capture Image"),
//             ),
//             ElevatedButton(
//               onPressed: _sendImageToBackend,
//               child: Text("Send to Backend"),
//             ),
//             SizedBox(height: 20),
//             if (_recognizedName != "Unknown")
//               Column(
//                 children: [
//                   Text("Recognized Name: $_recognizedName"),
//                   SizedBox(height: 20),
//                   _processedImage.isNotEmpty
//                       ? Image.memory(
//                           base64Decode(_processedImage),
//                           height: 200,
//                           width: 200,
//                         )
//                       : Container(),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
