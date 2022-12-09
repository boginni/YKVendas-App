import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../api/common/custom_widgets/custom_icons.dart';
import '../../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../models/database_objects/comodato.dart';

class TileComodatoItem extends StatelessWidget {
  const TileComodatoItem({Key? key, required this.itemDet}) : super(key: key);

  final ComodatoDet itemDet;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: const [
            IconSmall(CupertinoIcons.cube_box),
            SizedBox(
              width: 8,
            )
          ],
        ),
        Expanded(
          child: TextNormal(itemDet.nome),
        ),
        TextNormal(
          itemDet.quantidade.toStringAsFixed(0),
        ),
      ],
    );
  }
}
