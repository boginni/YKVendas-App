// import 'dart:async';
// import 'dart:io';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image_downloader/image_downloader.dart';
// import 'package:path_provider/path_provider.dart';
// // import 'package:share_plus/share_plus.dart';
//
// void main() => runApp(ImageDownloadExemple());
//
// class ImageDownloadExemple extends StatefulWidget {
//   const ImageDownloadExemple({Key? key}) : super(key: key);
//
//   @override
//   _ImageDownloadExempleState createState() => _ImageDownloadExempleState();
// }
//
// class _ImageDownloadExempleState extends State<ImageDownloadExemple> {
//   final String _message = "";
//   final String _path = "";
//   final String _size = "";
//   final String _mimeType = "";
//   int _progress = 0;
//   final List<File> _mulitpleFiles = [];
//
//   get http => null;
//
//   @override
//   void initState() {
//     super.initState();
//
//     ImageDownloader.callback(onProgressUpdate: (String? imageId, int progress) {
//       setState(() {
//         _progress = progress;
//       });
//     });
//   }
//
//   bool downloading = false;
//
//   Future<void> test(String url) async {
//     if (downloading) return;
//
//     try {
//       // showLoadingDialog(context);
//       // Saved with this method.
//       downloading = true;
//       var imageId = await ImageDownloader.downloadImage(url);
//
//       if (imageId == null) {
//         return;
//       }
//
//       // Below is a method of obtaining saved image information.
//       var fileName = await ImageDownloader.findName(imageId);
//       var path = await ImageDownloader.findPath(imageId);
//       var size = await ImageDownloader.findByteSize(imageId);
//       var mimeType = await ImageDownloader.findMimeType(imageId);
//
//       // printDebug(fileName);
//
//       // Navigator.pop(context);
//       // showToast('Image downloaded.');
//     } on PlatformException catch (error) {
//       // printDebug(error);
//     }
//
//     downloading = false;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Plugin example app'),
//         ),
//         body: Center(
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: <Widget>[
//                 // FutureBuilder(
//                 //   future: test(
//                 //       "https://raw.githubusercontent.com/wiki/ko2ic/image_downloader/images/bigsize.jpg"),
//                 //   builder:
//                 //       (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
//                 //     return CircularProgressIndicator();
//                 //
//                 //     if (snapshot.data != null) {
//                 //       return Image.file(snapshot.data!);
//                 //     } else {}
//                 //   },
//                 // ),
//
//                 Row(
//                   children: const [
//                     Icon(CupertinoIcons.cube_box, size: 32),
//                     SizedBox(
//                       width: 8,
//                     ),
//                     Text('Carregar Imagem como ícone')
//                   ],
//                 ),
//
//                 const SizedBox(
//                   height: 24,
//                 ),
//
//                 Row(
//                   children: const [
//                     Icon(CupertinoIcons.cube_box, size: 32),
//                     SizedBox(
//                       width: 8,
//                     ),
//                     Text('Carregar Imagem como ícone')
//                   ],
//                 ),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     minimumSize: const Size.fromHeight(52),
//                   ),
//                   child: const Text(
//                     'Share Text',
//                     style: TextStyle(fontSize: 28),
//                   ),
//                   onPressed: () async {
//                     const urlImage =
//                         'https://images.builderservices.io/s/cdn/v1.0/i/m?url=https%3A%2F%2Fstorage.googleapis.com%2Fproduction-hostgator-brasil-v1-0-2%2F922%2F875922%2F0jx3W04V%2F7f928ae8d16a4c5e9a9ed248dc6a1390&methods=resize%2C350%2C5000';
//
//                     final url = Uri.parse(urlImage);
//                     final response = await http.get(url);
//                     final bytes = response.bodyBytes;
//
//                     final temp = await getTemporaryDirectory();
//                     final path = '${temp.path}/image.jpg';
//                     File(path).writeAsBytesSync(bytes);
//
//                     // await Share.shareFiles([path], text: 'Logo da empresa');
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
