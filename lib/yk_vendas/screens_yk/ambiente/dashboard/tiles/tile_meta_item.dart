import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../api/common/custom_tiles/default_tiles/tile_spaced_text.dart';
import '../../../../../api/common/custom_widgets/custom_icons.dart';
import '../../../../../api/common/custom_widgets/custom_text.dart';

class TileMetaItem extends StatelessWidget {
  const TileMetaItem({Key? key, required this.item}) : super(key: key);

  final List<dynamic> item;

  @override
  Widget build(BuildContext context) {
    String round(dynamic x) {
      return double.parse(x.toString()).toStringAsFixed(2);
    }

    return Card(
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          child: Column(
            children: [
              Row(
                children: [
                  const IconNormal(
                    CupertinoIcons.cube_box,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextNormal("${item[5]}"),
                        TextNormal("${item[7]}/${item[6]}")
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  children: [
                    Divider(),
                    TileSpacedText('Média Diaria', item[9].toString()),
                    TileSpacedText('Tendencia Total', round(item[10])),
                    TileSpacedText('Tendencia Pct', '${round(item[11])}%'),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
