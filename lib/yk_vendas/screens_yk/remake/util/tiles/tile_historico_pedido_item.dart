import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../api/common/custom_widgets/custom_icons.dart';
import '../../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../models/database_objects/historico_pedido_det.dart';

class TileHistoricoPedidoItem extends StatelessWidget {
  final HistoricoPedidoDet item;

  const TileHistoricoPedidoItem({Key? key, required this.item})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String qtd = "Quantidade: ${item.quantidade.toStringAsFixed(0)}";
    String valorTot = "R\$ ${item.valorTotal.toStringAsFixed(2)}";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                  flex: 1,
                  child: IconNormal(
                    CupertinoIcons.cube_box,
                    color: (item.status && item.mobile)
                        ? Colors.green
                        : Colors.redAccent,
                  )),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextNormal(item.nome),
                    TextNormal(qtd),
                  ],
                ),
              ),
              Flexible(flex: 2, child: TextNormal(valorTot)),
            ],
          ),
        ],
      ),
    );
  }
}
