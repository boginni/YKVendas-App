import 'package:flutter/material.dart';

@Deprecated("Recomendo utilizar TileWidget")
class TileTextButton extends StatelessWidget {
  final Function onPressed;

  const TileTextButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => onPressed,
      child: const Text(
        "Salvar",
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}
