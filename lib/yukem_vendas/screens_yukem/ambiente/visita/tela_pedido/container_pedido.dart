import 'package:flutter/cupertino.dart';
import 'package:forca_de_vendas/api/common/components/list_scrollable.dart';
import 'package:forca_de_vendas/api/common/custom_tiles/default_tiles/tile_topico.dart';

import '../../../../../api/common/custom_tiles/default_tiles/tile_spaced_text.dart';
import '../../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../models/database_objects/item_visita.dart';

class ContainerPedido extends StatefulWidget {
  const ContainerPedido({Key? key, required this.item}) : super(key: key);

  final ProdutoItemVisita item;

  @override
  State<ContainerPedido> createState() => ContainerPedidoState();
}

class ContainerPedidoState extends State<ContainerPedido> {
  @override
  Widget build(BuildContext context) {
    String money(dynamic x) =>
        TextDinheiroReal.format(double.parse(x.toString()));

    return ListViewNested(
      children: [
        const TileTopico('Pedido'),
        TileSpacedText('Quantidade Atual',
            widget.item.getQuantidadeProdutoAtual().toStringAsFixed(0)),
        const SizedBox(
          height: 8,
        ),
        TileSpacedText('Total Bruto', money(widget.item.getTotalBrutoPedido())),
        TileSpacedText(
            'Descontos', money(widget.item.getTotalDescontoPedido())),
        // TileSpacedText('Brinde', money(widget.item.getTotalBrindePedido())),

        TileSpacedText(
            'Total Liquido', money(widget.item.getTotalLiquidoPedido())),
        TileSpacedText('Desconto em porcentagem',
            '${(100 * widget.item.getTotalDescontoPctPedido()).toStringAsFixed(2)}%'),
      ],
    );
  }
}
