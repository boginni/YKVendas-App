import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../api/common/custom_widgets/custom_icons.dart';
import '../../../../../api/common/custom_widgets/custom_text.dart';

class TileCritia extends StatelessWidget {
  const TileCritia({Key? key, required this.item}) : super(key: key);

  final List<dynamic> item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        child: Row(
          children: [
            const IconNormal(
              CupertinoIcons.cube_box,
            ),
            const SizedBox(
              width: 4,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item[2],
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text('Quantidade: ${item[4].toStringAsFixed(0)}'),
                ],
              ),
            ),
            Column(
              children: [
                const TextNormal('Total'),
                TextDinheiroReal(
                  valor: double.parse(item[5].toString()),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
