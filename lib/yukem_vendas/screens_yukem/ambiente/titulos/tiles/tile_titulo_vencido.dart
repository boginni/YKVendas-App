import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../api/common/custom_tiles/default_tiles/tile_spaced_text.dart';
import '../../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../../api/common/formatter/date_time_formatter.dart';
import '../../../../models/database_objects/titulos_aberto.dart';

class TileTituloVencido extends StatelessWidget {
  const TileTituloVencido({Key? key, required this.item}) : super(key: key);

  final TituloAberto item;

  @override
  Widget build(BuildContext context) {
    String status = 'Aberto';

    bool vencido = false;

    if (item.dataVencimento.compareTo(DateTime.now()) < 0) {
      status = 'Vencido';
      vencido = true;
    }

    return Card(
      child: Container(
        padding: const EdgeInsets.all(4),
        child: ExpansionTile(
          childrenPadding:
              const EdgeInsets.only(left: 12, right: 12, bottom: 8),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  TextTitle(
                    status,
                    color: vencido ? Colors.red : Colors.yellow,
                  ),
                  TextNormal('documento: ${item.documento}'),
                ],
              ),
              Column(
                children: [
                  TextTitle(TextDinheiroReal.format(item.valorRestante)),
                  TextNormal(
                      DateFormatter.normalData.format(item.dataVencimento)),
                ],
              ),
            ],
          ),
          children: [
            TileSpacedText('Id', item.id.toString()),
            TileSpacedText('Documento', item.documento),
            TileSpacedText('Vencimento',
                DateFormatter.normalData.format(item.dataVencimento)),
            const SizedBox(
              height: 8,
            ),
            TileSpacedText('Valor', TextDinheiroReal.format(item.valor)),
            TileSpacedText('Juros', TextDinheiroReal.format(item.valorJuros)),
            TileSpacedText('Multa', TextDinheiroReal.format(item.valorMulta)),
            TileSpacedText(
                'Restante', TextDinheiroReal.format(item.valorRestante)),
          ],
        ),
      ),
    );
  }
}
