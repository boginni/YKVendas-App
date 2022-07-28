import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forca_de_vendas/yukem_vendas/models/database_objects/visita_item_list.dart';

import '../../../../../api/common/custom_widgets/custom_icons.dart';
import '../../../../../api/common/custom_widgets/custom_text.dart';

class TileVisitaItem extends StatefulWidget {
  final bool viewOnly;

  final Function(int id) onDelete;
  final Function(int id) onPressed;

  const TileVisitaItem(
      {Key? key,
      required this.item,
      required this.viewOnly,
      required this.onDelete,
      required this.onPressed})
      : super(key: key);

  final VisitaItemList item;

  @override
  State<TileVisitaItem> createState() => _TileVisitaItemState();
}

class _TileVisitaItemState extends State<TileVisitaItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: Row(
        children: [
          Flexible(
            flex: 5,
            child: TextButton(
              onPressed: () => widget.onPressed(widget.item.id),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                    flex: 1,
                    child: Stack(
                      children: <Widget>[
                        IconNormal(
                            widget.item.brinde
                                ? CupertinoIcons.gift
                                : CupertinoIcons.money_dollar_circle_fill,
                            color: Theme.of(context).primaryColor),
                        // if (warnEstoque && !widget.viewOnly)
                        const IconStatus(
                          statusIconType: StatusIconTypes.warning,
                        ),
                        // if (!warnEstoque || widget.viewOnly)
                        const IconStatus(
                          statusIconType: StatusIconTypes.ok,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Flexible(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: TextNormal('Quantidade: ' +
                                  widget.item.quantidade.toStringAsFixed(0)),
                            ),
                            if (!widget.item.brinde)
                              Flexible(
                                child: TextNormal(
                                  TextDinheiroReal.format(
                                      (widget.item.quantidade *
                                          widget.item.valorUnitario)),
                                ),
                              ),
                          ],
                        ),
                        const Divider(),
                        if (!widget.item.brinde)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const TextNormal(
                                '',
                              ),
                              TextNormal(
                                "Desconto: " +
                                    TextDinheiroReal.format(
                                        widget.item.descontoValor),
                              ),
                            ],
                          ),
                        if (widget.item.brinde)
                          const TextNormal('Entregue como brinde'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          //
          if (!widget.viewOnly)
            Flexible(
              flex: 1,
              child: TextButton(
                onPressed: () => widget.onDelete(widget.item.id),
                child: const IconSmall(
                  CupertinoIcons.trash,
                ),
              ),
            )
        ],
      ),
    );
  }
}
