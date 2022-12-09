import 'package:flutter/material.dart';

import '../../../../api/common/custom_tiles/default_tiles/tile_buttom.dart';
import '../../../../api/common/custom_tiles/default_tiles/tile_collapsable.dart';
import '../../../models/database_objects/produtos_list_item.dart';
import 'tile_produtos/tile_produto_item.dart';

class TileAddProdutosButton extends StatefulWidget {
  final int idVisita;
  final bool concluida;
  final bool enabled;
  final Function? onPressed;
  final Function? afterClickItem;
  final bool viewOnly;

  const TileAddProdutosButton(this.idVisita,
      {Key? key,
      this.onPressed,
      required this.enabled,
      required this.concluida,
      this.viewOnly = false,
      this.afterClickItem})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TileAddProdutosButtonState();
}

class _TileAddProdutosButtonState extends State<TileAddProdutosButton> {
  List<ProdutoListItem> list = [];

  @override
  Widget build(BuildContext context) {
    final int idVisita = widget.idVisita;

    return FutureBuilder(
      future: getProdutoItensVisita(idVisita),
      builder: (BuildContext context,
          AsyncSnapshot<List<ProdutoListItem>> snapshot) {
        if (snapshot.data != null) {
          list = snapshot.data!;
        }

        return TileCollapsable(
          collapsable: list.isNotEmpty,
          alwaysExpanded: widget.viewOnly,
          initiallyExpanded: true,
          title: TileButton(
            stack: [
              if (widget.concluida)
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                )
            ],
            title: 'Itens do pedido',
            icon: Icons.shopping_cart,
            isActive: widget.enabled,
            onPressMethod: () => widget.onPressed == null || widget.viewOnly
                ? null
                : widget.onPressed!(),
            // isActive: visita.tabelaConcluida
          ),
          children: [
            ListView.builder(
              physics: const ClampingScrollPhysics(),
              shrinkWrap: true,
              itemCount: list.length,
              itemBuilder: (BuildContext context, int index) {
                return TileItemPedido(
                  list[index],
                  viewOnly: widget.viewOnly,
                  rebuildAfterTrash: false,
                  afterTrash: () {
                    if (widget.afterClickItem != null) {
                      widget.afterClickItem!();
                    }
                  },
                  afterClick: (x) {
                    if (widget.afterClickItem != null) {
                      widget.afterClickItem!();
                    }
                  },
                );
              },
            )
          ],
        );
      },
    );
  }
}

class TileMostrarProdutos extends StatefulWidget {
  final int idVisita;

  const TileMostrarProdutos({Key? key, required this.idVisita})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TileMostrarProdutosState();
}

class _TileMostrarProdutosState extends State<TileMostrarProdutos> {
  List<ProdutoListItem> list = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getProdutoItensVisita(widget.idVisita),
      builder: (BuildContext context,
          AsyncSnapshot<List<ProdutoListItem>> snapshot) {
        if (snapshot.hasData ||
            snapshot.connectionState == ConnectionState.done) {
          list = snapshot.data!;
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index) {
            return TileItemPedido(
              list[index],
              editable: false,
              viewOnly: true,
              rebuildAfterTrash: false,
              onPress: () {},
            );
          },
        );
      },
    );
  }
}
