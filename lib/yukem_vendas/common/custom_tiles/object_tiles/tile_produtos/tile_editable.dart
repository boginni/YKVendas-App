import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forca_de_vendas/api/common/custom_tiles/default_tiles/tile_spaced_text.dart';
import 'package:forca_de_vendas/yukem_vendas/common/custom_tiles/object_tiles/tile_produtos/tile_visita_item.dart';
import 'package:forca_de_vendas/yukem_vendas/models/configuracao/app_ambiente.dart';
import 'package:forca_de_vendas/yukem_vendas/models/database_objects/visita_item_list.dart';

import '../../../../../api/common/custom_widgets/custom_icons.dart';
import '../../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../models/configuracao/app_user.dart';
import '../../../../models/database_objects/produtos_list_item.dart';
import '../../../../models/internet/internet.dart';
import '../../../../screens_yukem/ambiente/visita/tela_pedido/tela_item_do_pedido.dart';
import '../../../../screens_yukem/ambiente/visita/tela_visita/tela_pedido.dart';
import '../../../components/custom_cached_image.dart';

class TileVisitaItemEditable extends StatefulWidget {
  final Function(int id) onPressed;

  final Function(int id) onDelete;

  final Function() onAdd;

  const TileVisitaItemEditable(
      {Key? key,
      required this.item,
      this.viewOnly = false,
      required this.onPressed,
      required this.onDelete,
      required this.onAdd})
      : super(key: key);

  final bool viewOnly;

  final ProdutoListItem item;

  @override
  State<TileVisitaItemEditable> createState() => _TileVisitaItemEditableState();
}

class _TileVisitaItemEditableState extends State<TileVisitaItemEditable> {
  List<VisitaItemList> list = [];

  @override
  Widget build(BuildContext context) {
    final appAmbiente = AppAmbiente.of(context);

    String text =
        'Total Liquido ' + TextDinheiroReal.format(widget.item.totalLiq);

    // if (widget.item.brinde) {
    //   text = 'Brinde';
    // }

    toAdd() {
      if (widget.viewOnly) return;

      // if (widget.onPress != null) {
      //   widget.onPress!();
      //   return;
      // }

      // Navigator.of(context).pushNamed(TelaItemPedido.routeName, arguments: [
      //   widget.item.idVisita,
      //   widget.item.idProduto
      // ]).then((value) => refresh());
    }

    bool warnEstoque = widget.item.estoque != null &&
        widget.item.getQuantidade() > widget.item.estoque! &&
        appAmbiente.calcularEstoque;

    onPressed() {
      if (widget.viewOnly) {
        return;
      }

      Navigator.of(context).pushNamed(TelaItemPedido.routeName, arguments: [
        widget.item.idVisita,
        widget.item.idProduto
      ]).then((value) {
        TelaPedido.performHotReload(context);
      });
    }

    String total = widget.item.estoque != null
        ? 'Estoque: ${widget.item.estoque!.toStringAsFixed(0)}'
        : '';

    total = 'Total: ' + TextDinheiroReal.format(widget.item.totalLiq);

    final appUser = AppUser.of(context);

    final imageUrl =
        "${Internet.getHttpServer()}/image/${appUser.ambiente}/${widget.item.idProduto}-icon.png";

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.only(right: 12),
        title: TextButton(
          onPressed: widget.onAdd,
          child: Row(
            children: [
              Flexible(
                flex: 1,
                child: Stack(
                  fit: StackFit.loose,
                  children: <Widget>[
                    if (appAmbiente.mostrarFotoProduto)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: SizedBox(
                          height: 64,
                          width: 64,
                          child: CustomCachedImage(
                            link: imageUrl,
                            ambiente: appUser.ambiente,
                            name: '${widget.item.idProduto}-thumb.png',
                            failHorlder: const IconBig(CupertinoIcons.cube_box),
                            download: true,
                            waitTurn: false,
                          ),
                        ),
                      ),
                    if (!appAmbiente.mostrarFotoProduto)
                      const IconNormal(CupertinoIcons.cube_box),
                    if (warnEstoque && !widget.viewOnly)
                      const IconStatus(
                        statusIconType: StatusIconTypes.warning,
                      ),
                    if (!warnEstoque || widget.viewOnly)
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
                    TextTitle(
                      widget.item.nome,
                    ),
                    const Divider(
                      color: Colors.grey,
                    ),
                    Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: Row(
                            children: [
                              if (widget.item.valorTabela == null)
                                const Icon(
                                  Icons.monetization_on,
                                  size: 18,
                                  color: Colors.yellow,
                                ),
                              if (widget.item.valorOriginal == null)
                                const Icon(
                                  Icons.monetization_on,
                                  size: 18,
                                  color: Colors.red,
                                ),
                              Flexible(
                                child: Builder(builder: (x) {
                                  String preco = 'N/A';

                                  double? valor;

                                  if (widget.item.valorOriginal != null) {
                                    valor = widget.item.valorOriginal;
                                  }

                                  if (widget.item.valorTabela != null) {
                                    valor = widget.item.valorTabela;
                                  }

                                  if (valor != null) {
                                    preco = TextDinheiroReal.format(valor);
                                  }

                                  return TextNormal(
                                      'Quantidade: ${widget.item.getQuantidade()}');
                                }),
                              )
                            ],
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.topRight,
                            child: TextNormal(
                              total,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        initiallyExpanded: true,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                if (widget.item.estoque != null)
                  TileSpacedText(
                      'Estoque atual', widget.item.estoque!.toStringAsFixed(0)),
                TileSpacedText(
                    'Quantidade total', widget.item.getQuantidade().toString()),
                if (appAmbiente.usarBrinde)
                  TileSpacedText('Quantidade brinde',
                      widget.item.quantidadeBrinde.toString()),
                TileSpacedText('Valor Bruto',
                    TextDinheiroReal.format(widget.item.totalBruto)),
                TileSpacedText(
                    'Valor Descontos',
                    TextDinheiroReal.format(
                        widget.item.totalBruto - widget.item.totalLiq)),
                TileSpacedText('Valor Liquido',
                    TextDinheiroReal.format(widget.item.totalLiq)),
              ],
            ),
          ),
          FutureBuilder(
            future: VisitaItemList.getListItem(widget.item.idVisita,
                idProduto: widget.item.idProduto),
            builder: (BuildContext context,
                AsyncSnapshot<List<VisitaItemList>> snapshot) {
              if (snapshot.data != null) {
                list = snapshot.data!;
              }

              return ListView.builder(
                itemCount: list.length,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemBuilder: (context, index) {
                  return TileVisitaItem(
                    item: list[index],
                    viewOnly: widget.viewOnly,
                    onPressed: widget.onPressed,
                    onDelete: widget.onDelete,
                  );
                },
              );
            },
          )
        ],
      ),
    );
  }
}
