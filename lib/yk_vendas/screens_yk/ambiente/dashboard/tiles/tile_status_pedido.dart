import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../api/common/custom_widgets/custom_text.dart';

class TileStatusPedido extends StatelessWidget {
  const TileStatusPedido({Key? key, required this.item}) : super(key: key);

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final cab = item['cab'];
    final det = item['det'] as List<dynamic>;

    bool salvo = cab[4] != 'SALVO';

    return Card(
      child: ExpansionTile(
        tilePadding: EdgeInsets.all(8.0),
        childrenPadding: EdgeInsets.zero,

        title: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            if (salvo)
              const Icon(
                Icons.monetization_on,
                size: 42,
              ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextTitle(cab[4]),
                  TextNormal(cab[3]),
                ],
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            if (salvo)
              Flexible(
                flex: 1,
                child: TextNormal(
                  TextDinheiroReal.format(
                    double.parse(
                      (cab[5]).toString(),
                    ),
                  ),
                ),
              ),

            //
          ],
        ),
        children: salvo
            ? [
                TextNormal(cab[6] ?? ''),
                const SizedBox(
                  height: 8,
                ),
                Container(
                  color: Theme.of(context).primaryColorLight,
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: det.length,
                      physics: const ClampingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return TileStatusPedidoItem(
                          item: det[index],
                        );
                      }),
                ),
              ]
            : [
                const TextNormal(
                    'Itens e outras informações só estarão disponíveis após entrar para faturamento')
              ],
      ),
    );
  }
}

class TileStatusPedidoItem extends StatelessWidget {
  const TileStatusPedidoItem({Key? key, required this.item}) : super(key: key);

  final List<dynamic> item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(
                CupertinoIcons.cube_box,
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextNormal(item[5]),
                    TextNormal(item[6].toString()),
                  ],
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Flexible(
                flex: 1,
                child: TextNormal(
                  TextDinheiroReal.format(
                    double.parse(
                      item[7].toString(),
                    ),
                  ),
                ),
              ),

              //
            ],
          ),
        ),
      ),
    );
  }
}
