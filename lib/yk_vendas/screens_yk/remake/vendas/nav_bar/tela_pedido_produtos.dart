import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../moddels/pedido.dart';
import '../tiles/tile_pedido_item.dart';

class TelaPedidoProduto extends StatefulWidget {
  const TelaPedidoProduto({Key? key, required this.pedido}) : super(key: key);

  final Pedido pedido;

  @override
  State<TelaPedidoProduto> createState() => _TelaPedidoProdutoState();
}

class _TelaPedidoProdutoState extends State<TelaPedidoProduto> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      children: [
        TextButton(
            onPressed: () {
              widget.pedido.createItem(idTabela: 0, idProduto: 1).then((value) {
                setState(() {});
              });
            },
            child: Text('Adicionar')),
        ListView.builder(
          shrinkWrap: true,
          itemCount: widget.pedido.itens.length,
          itemBuilder: (context, index) {
            return TilePedidoitem(item: widget.pedido.itens[index]);
          },
        ),
      ],
    );
  }
}
