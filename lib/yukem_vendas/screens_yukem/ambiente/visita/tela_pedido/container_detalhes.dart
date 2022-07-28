import 'package:flutter/cupertino.dart';
import 'package:forca_de_vendas/api/common/components/list_scrollable.dart';
import 'package:forca_de_vendas/yukem_vendas/models/database_objects/item_visita.dart';

import '../../../../../api/common/custom_tiles/default_tiles/tile_spaced_text.dart';
import '../../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../../api/models/configuracao/app_system.dart';
import '../../../../models/configuracao/app_ambiente.dart';


class ContainerDetalhesVisitaItem extends StatefulWidget {
  const ContainerDetalhesVisitaItem({Key? key, required this.item}) : super(key: key);

  final ProdutoItemVisita item;
  @override
  State<ContainerDetalhesVisitaItem> createState() => ContainerDetalhesVisitaItemState();
}

class ContainerDetalhesVisitaItemState extends State<ContainerDetalhesVisitaItem> {

  @override
  Widget build(BuildContext context) {
    final appConfig = AppAmbiente.of(context);
    final appSystem = AppSystem.of(context);
    final appAmbiente = AppAmbiente.of(context);

    late double descontoMax;

    if (appAmbiente.usarDescontoVendedorItem) {
      descontoMax = widget.item.descontoMaxVendedor;
    } else {
      descontoMax = widget.item.descontoMaxProduto;
    }

    return ListViewNested(children: [
      // if (widget.item.hasPrecoQtd)
      //   TileSpacedText('Valor Unitário Quantidade:',
      //       TextDinheiroReal.format(widget.item.getPrecoQuantidade()!)),
      if (widget.item.valorTabela != null)
        TileSpacedText('Valor Unitário Tabela:',
            TextDinheiroReal.format(widget.item.valorTabela!)),
      SizedBox(height: 8,),
      if ((appConfig.usarDescontoBaixo || appConfig.usarDescontoCima) &&
          appConfig.usarDescontoItem)
        ListViewNested(children: [
          // TileSpacedText('Valor Unitário Atual:', _getValorUndCalc()),
          TileSpacedText('Total Bruto:', _getTotalBruto()),
        ]),
      if (appConfig.usarDescontoBaixo && appConfig.usarDescontoItem)
        ListViewNested(children: [
          TileSpacedText('Desconto:', _getDesconto()),
          TileSpacedText('Total Líquido:', _getTotalLiq()),
          TileSpacedText(
              'Desconto Máximo:', (descontoMax * 100).toStringAsFixed(2) + '%'),
        ])
    ]);
  }

  String _getPrecoUnitario() {
    double calc = widget.item.valorUnitario ?? widget.item.valorTabela ?? widget.item.valorVenda;
    return TextDinheiroReal.format(calc);
  }

  String _getTotalBruto() {
    return TextDinheiroReal.format(widget.item.getTotalBruto());
  }

  String _getTotalLiq() {
    return TextDinheiroReal.format(widget.item.getTotalLiquido());
  }

  String _getDesconto() {
    return TextDinheiroReal.format(widget.item.descontoValor);
  }



}

