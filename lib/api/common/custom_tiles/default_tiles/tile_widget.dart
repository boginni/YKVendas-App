// import 'package:flutter/material.dart';
//
// @Deprecated("Causa Muitos bugs")
//
// /// um Tile com título em String [title] e Widget customizado [child] class TileColumnWidget
//     extends StatelessWidget {
//   const TileColumnWidget({Key? key, required this.title, required this.child})
//       : super(key: key);
//
//   final Widget title;
//   final Widget child;
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Expanded(child: title),
//         Expanded(child: child),
//       ],
//     );
//   }
// }
//
//
// @Deprecated("Causa Muitos bugs")
// class TileRowWidget extends StatelessWidget {
//   const TileRowWidget({Key? key, required this.title, required this.child})
//       : super(key: key);
//
//   final Widget title;
//   final Widget child;
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Expanded(child: title),
//         Expanded(child: child)
//       ],
//     );
//   }
// }
