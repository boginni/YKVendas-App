import 'package:flutter/material.dart';

import '../../custom_widgets/custom_text.dart';

/// Tópico que utiliza um divider
class TileTopico extends StatelessWidget {
  final String name;

  const TileTopico(this.name, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      child: Row(
        children: <Widget>[
          TextTitle(
            name,
          ),
          const Expanded(
            child: Divider(),
          ),
        ],
      ),
    );
  }
}
