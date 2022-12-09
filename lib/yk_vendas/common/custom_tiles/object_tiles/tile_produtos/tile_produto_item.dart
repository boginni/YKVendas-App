import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../api/common/components/mostrar_confirmacao.dart';
import '../../../../models/configuracao/app_ambiente.dart';
import '../../../../models/database_objects/item_visita.dart';
import '../../../../models/database_objects/produtos_list_item.dart';
import '../../../../screens_yk/ambiente/visita/tela_pedido/tela_item_do_pedido.dart';
import 'tile_editable.dart';
import 'tile_standart.dart';

class TileItemPedido extends StatefulWidget {
  @Deprecated('Nem sei mais pra q server')
  final bool rebuildAfterTrash;
  final Function(ProdutoListItem newItem)? afterClick;
  final bool editable;
  final bool viewOnly;
  final Function()? onPress;

  TileItemPedido(this.item,
      {Key? key,
      this.afterTrash,
      this.rebuildAfterTrash = true,
      this.afterClick,
      this.editable = true,
      this.onPress,
      this.viewOnly = false})
      : super(key: key);

  final Function? afterTrash;

  ProdutoListItem item;

  @override
  State<StatefulWidget> createState() => _TileItemPedidoState();
}

class _TileItemPedidoState extends State<TileItemPedido> {
  Future<void> refresh() async {
    final newItem =
        await getProduto(widget.item.idVisita, widget.item.idProduto);

    if (widget.afterClick != null) {
      widget.afterClick!(newItem);
    }

    setState(() {
      widget.item = newItem;
    });
  }

  @override
  Widget build(BuildContext context) {
    AppAmbiente appConfig = AppAmbiente.of(context);

    onPressed(int id) {
      if (widget.viewOnly) {
        return;
      }

      Navigator.of(context).pushNamed(TelaItemPedido.routeName, arguments: [
        widget.item.idVisita,
        widget.item.idProduto,
        id
      ]).then((value) {
        // TelaPedido.performHotReload(context);
        refresh();
      });
    }

    onDelete(int id) {
      if (widget.viewOnly) {
        return;
      }

      if (widget.afterTrash != null) {
        widget.afterTrash!();
      }

      if (widget.rebuildAfterTrash) {}

      mostrarCaixaConfirmacao(context,
              title: 'Remover Item?',
              content: 'Você pode adicionar novamete depois')
          .then((value) {
        if (value) {
          ProdutoItemVisita.deleteItem(id).then((value) {
            refresh();
          });
        }
      });
    }

    onAdd() {
      if (widget.viewOnly) {
        return;
      }

      if (widget.onPress != null) {
        widget.onPress!();
        return;
      }

      Navigator.of(context).pushNamed(TelaItemPedido.routeName, arguments: [
        widget.item.idVisita,
        widget.item.idProduto
      ]).then((value) {
        refresh();
      });
    }

    return widget.item.editavel
        ? TileVisitaItemEditable(
            item: widget.item,
            viewOnly: widget.viewOnly,
            onPressed: onPressed,
            onAdd: onAdd,
            onDelete: onDelete,
          )
        : TileVisitaItemStandart(item: widget.item, onAdd: onAdd);
  }
}
