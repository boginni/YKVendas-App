import 'package:flutter/material.dart';

import '../../../../api/common/components/list_scrollable.dart';
import '../../../../api/common/custom_widgets/custom_text.dart';
import '../../../models/database_objects/vendas.dart';
import '../../../screens_yk/ambiente/visita/tela_visita/tela_visualizacao_visita.dart';
// ignore: unused_import

/// Utilizado na Tela de vendas
class TileVenda extends StatelessWidget {
  const TileVenda(this.item, {Key? key}) : super(key: key);

  final Venda item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: TextButton(
          onPressed: () {
            Navigator.of(context).pushNamed(TelaVisualizacaoVisita.routeName,
                arguments: item.idVisita);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: ListViewNested(
                  children: [
                    TextNormal(
                      item.nomeCliete,
                    ),
                    TextNormal(item.getData() + ' ' + item.getHorario())
                  ],
                ),
              ),
              Flexible(
                  child: TextTitle(
                '\$' + item.totalLiq.toStringAsFixed(2),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
