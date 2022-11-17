import 'package:flutter/material.dart';

import '../moddels/pedido_item.dart';

class TilePedidoitem extends StatelessWidget {
  const TilePedidoitem({Key? key, required this.item}) : super(key: key);

  final PedidoItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Text(item.id.toString()),
    );
  }
}
