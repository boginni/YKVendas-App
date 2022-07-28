// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:image_picker/image_picker.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Foto App',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: const MyHomePage(),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key}) : super(key: key);
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   final picker = ImagePicker();
//   File? _selectedImage;
//   bool _inProcess = false;
//
//   getImage(ImageSource src) async {
//     setState(() {
//       _inProcess = true;
//     });
//     final pickedFile = await picker.getImage(source: src);
//     if (pickedFile != null) {
//       File? cropped = await ImageCropper().cropImage(
//         sourcePath: pickedFile.path,
//         aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
//         compressQuality: 100,
//         maxHeight: 700,
//         maxWidth: 700,
//         compressFormat: ImageCompressFormat.jpg,
//       );
//       setState(() {
//         _selectedImage = cropped!;
//         _inProcess = false;
//       });
//     } else {
//       setState(() {
//         _inProcess = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Camera'),
//       ),
//       body: (_inProcess)
//           ? Container(
//               color: Colors.white,
//               height: double.infinity,
//               width: double.infinity,
//               alignment: Alignment.center,
//               child: SizedBox(
//                 width: 70,
//                 height: 70,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 5.0,
//                   backgroundColor: Theme.of(context).primaryColor,
//                 ),
//               ),
//             )
//           : Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 _selectedImage != null
//                     ? Image.file(
//                         _selectedImage!,
//                         width: 250,
//                         height: 250,
//                         fit: BoxFit.cover,
//                       )
//                     : const SizedBox(
//                         width: 250,
//                         height: 250,
//                         child: Icon(
//                           Icons.camera_alt,
//                           size: 200,
//                           color: Colors.grey,
//                         ),
//                       ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: <Widget>[
//                     RaisedButton(
//                       onPressed: () {
//                         getImage(ImageSource.camera);
//                       },
//                       child: const Text('Camera'),
//                     ),
//                     RaisedButton(
//                       onPressed: () {
//                         getImage(ImageSource.gallery);
//                       },
//                       child: const Text('Galeria'),
//                     ),
//                   ],
//                 )
//               ],
//             ),
//     );
//   }
// }
