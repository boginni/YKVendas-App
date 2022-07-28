import 'package:flutter/material.dart';

/// Tile Com título em String [title] e texto em String [value]
class TileText extends StatelessWidget {
  const TileText({Key? key, required this.title, required this.value})
      : super(key: key);

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(title,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900])),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Text(value,
              style: TextStyle(fontSize: 18, color: Colors.grey[500])),
        ),
      ],
    );
  }
}
