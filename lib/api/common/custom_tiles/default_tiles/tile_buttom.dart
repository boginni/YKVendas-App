import 'package:flutter/material.dart';

import '../../custom_widgets/custom_icons.dart';
import '../../custom_widgets/custom_text.dart';

/// Tile com Título em String [title] e Botão
///
/// Para desabilitar o botão, use [isActive].
// @Deprecated("Recomendo utilizar TileWidget")
class TileButton extends StatelessWidget {
  const TileButton(
      {Key? key,
      this.icon,
      required this.title,
      this.onPressMethod,
      this.isActive = true,
      this.stack = const []})
      : super(key: key);

  final Function()? onPressMethod;
  final IconData? icon;
  final List<Widget> stack;
  final String title;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      // color: Colors.white,
      onPressed: !isActive ? null : onPressMethod!,
      child: Row(
        children: [
          if (icon != null)
            Stack(
              children: <Widget>[
                    IconNormal(icon),
                  ] +
                  stack,
            ),
          if (icon != null)
            const SizedBox(
              width: 4,
            ),
          Flexible(
            child: Align(alignment: Alignment.topLeft, child: TextTitle(title)),
          ),
        ],
      ),
    );
  }
}
