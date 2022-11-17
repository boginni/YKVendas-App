import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/comodato/tiles/tile_comodato_item.dart';

import '../../../../../api/common/custom_tiles/default_tiles/tile_spaced_text.dart';
import '../../../../../api/common/custom_widgets/custom_icons.dart';
import '../../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../../api/common/formatter/date_time_formatter.dart';
import '../../../../models/database_objects/comodato.dart';

class TileComodato extends StatefulWidget {
  const TileComodato({Key? key, required this.itemCab}) : super(key: key);

  final ComodatoCab itemCab;

  @override
  State<TileComodato> createState() => _TileComodatoState();
}

class _TileComodatoState extends State<TileComodato> {
  List<ComodatoDet> listDet = [];

  getData() {
    lastItem = widget.itemCab.id;
    widget.itemCab.getComodatoDet().then((value) {
      setState(() {
        listDet = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  int? lastItem;

  @override
  void didUpdateWidget(dynamic oldWidget) {
    if (lastItem != widget.itemCab.id) {
      getData();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    String statusCab = '';
    Color? statusCor;

    if (widget.itemCab.status == 0) {
      statusCab = 'Aberto';
      statusCor = Colors.green;
    }

    if (widget.itemCab.status == 1) {
      statusCab = 'Fechado';
      statusCor = Colors.red;
    }

    if (widget.itemCab.status == 3) {
      statusCab = 'Parcial';
      statusCor = Colors.yellow;
    }

    final format = DateFormatter.normalData;
    return Card(
      child: Container(
        padding: const EdgeInsets.all(4),
        child: ExpansionTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextTitle(
                    statusCab,
                    color: statusCor,
                  ),
                  TextNormal('ID ${widget.itemCab.id}'),
                ],
              ),
              Row(
                children: [
                  const IconSmall(CupertinoIcons.clock),
                  const SizedBox(
                    width: 8,
                  ),
                  TextTitle(format.format(widget.itemCab.dataVencimento)),
                ],
              )
            ],
          ),
          childrenPadding:
              const EdgeInsets.only(left: 12, right: 12, bottom: 8),
          children: [
            TileSpacedText(
                'Movimento', format.format(widget.itemCab.dataMovimento)),
            TileSpacedText(
                'Vencimento', format.format(widget.itemCab.dataVencimento)),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [TextTitle('Produto'), TextTitle('Quantidade')],
            ),
            const SizedBox(
              height: 16,
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: listDet.length,
              physics: const ClampingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return TileComodatoItem(itemDet: listDet[index]);
              },
            ),
          ],
        ),
      ),
    );
  }
}
