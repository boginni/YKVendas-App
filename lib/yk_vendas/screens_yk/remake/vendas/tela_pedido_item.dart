import 'package:flutter/material.dart';

import '../produto/moddels/produto.dart';
import 'moddels/pedido_item.dart';

class TelaPedidoItem extends StatefulWidget {
  const TelaPedidoItem({Key? key, required this.item}) : super(key: key);

  final PedidoItem item;

  @override
  State<TelaPedidoItem> createState() => _TelaPedidoItemState();
}

class _TelaPedidoItemState extends State<TelaPedidoItem> {


  Produto? produto;

  @override
  void initState() {
    widget.item;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('')),
      body: ListView(),
    );
  }


}

