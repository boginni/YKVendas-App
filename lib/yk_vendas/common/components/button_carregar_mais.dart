// import 'package:flutter/material.dart';
//
// class ButtonCarregarMais extends StatelessWidget {
//   const ButtonCarregarMais({
//     Key? key,
//     required this.onLoading,
//     required this.onPressed,
//   }) : super(key: key);
//   final bool onLoading;
//   final void Function() onPressed;
//
//   @override
//   Widget build(BuildContext context) {
//     return onLoading
//         ? const Center(
//             child: Padding(
//               padding: EdgeInsets.symmetric(vertical: 12),
//               child: CircularProgressIndicator(),
//             ),
//           )
//         : TextButton(
//             onPressed: () {
//               Future.delayed(
//                 const Duration(milliseconds: 250),
//                 onPressed,
//               );
//             },
//             child: const Text('Carregar Mais'),
//           );
//   }
// }
