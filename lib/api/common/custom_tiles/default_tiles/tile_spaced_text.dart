import 'package:flutter/material.dart';

import '../../custom_widgets/custom_text.dart';

/// Texto título no lado esquerdo e valor no lado direito
class TileSpacedText extends StatelessWidget {
  const TileSpacedText(this.title, this.value, {Key? key}) : super(key: key);

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        TextNormal(
          title,
        ),
        const SizedBox(
          width: 8,
        ),
        Flexible(
          flex: 6,
          child: TextNormal(
            value,
          ),
        )
      ],
    );
  }
}

class TileSpacedWidget extends StatelessWidget {
  const TileSpacedWidget(this.title,
      {Key? key, required this.child, this.forcedSpace})
      : super(key: key);

  final double? forcedSpace;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
            child: TextNormal(
          title,
        )),
        if (forcedSpace != null)
          SizedBox(
            width: forcedSpace,
          ),
        child
      ],
    );
  }
}
