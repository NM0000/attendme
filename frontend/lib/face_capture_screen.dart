import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart'; 

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
    final newPath = '${studentDirectory.path}/$fileName';
    File(imagePath).copySync(newPath);

    _capturedImagePaths.add(newPath);
    setState(() {});

    print('Image saved to $newPath');
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
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class FaceCaptureScreen extends StatefulWidget {
//   @override
//   _FaceCaptureScreenState createState() => _FaceCaptureScreenState();
// }

// class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
//   File? _image;  // To store the selected image
//   final ImagePicker _picker = ImagePicker();  // Image picker instance
//   bool _isUploading = false;  // Flag to track the uploading state

//   // Function to pick an image from the camera
//   Future<void> _pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.camera);

//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);  // Convert the picked file to a File object
//       });
//     }
//   }

//   // Function to upload the image to the Django backend
//   Future<void> _uploadImage() async {
//     if (_image == null) {
//       return;
//     }

//     setState(() {
//       _isUploading = true;
//     });

//     var url = Uri.parse('http://your-django-server-url/upload-image/');  // Update with your Django server URL

//     // Create multipart request to send image
//     var request = http.MultipartRequest('POST', url);
//     request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

//     try {
//       var response = await request.send();

//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image uploaded successfully!')));
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image upload failed!')));
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred while uploading the image!')));
//     } finally {
//       setState(() {
//         _isUploading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Capture Face'),
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           // Display the captured image or a placeholder
//           _image != null
//               ? Image.file(
//                   _image!,
//                   width: 300,
//                   height: 300,
//                   fit: BoxFit.cover,
//                 )
//               : Container(
//                   width: 300,
//                   height: 300,
//                   color: Colors.grey[200],
//                   child: Icon(
//                     Icons.camera_alt,
//                     size: 100,
//                     color: Colors.grey[500],
//                   ),
//                 ),
//           SizedBox(height: 20),
//           _isUploading
//               ? CircularProgressIndicator()  // Show loading spinner while uploading
//               : ElevatedButton(
//                   onPressed: _pickImage,
//                   child: Text('Capture Image'),
//                 ),
//           SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: _isUploading ? null : _uploadImage,
//             child: Text('Upload Image'),
//           ),
//         ],
//       ),
//     );
//   }
// }
