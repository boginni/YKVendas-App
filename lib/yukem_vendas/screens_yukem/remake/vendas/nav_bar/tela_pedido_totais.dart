import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TelaPedidoTotais extends StatefulWidget {
  const TelaPedidoTotais({Key? key}) : super(key: key);

  @override
  State<TelaPedidoTotais> createState() => _TelaPedidoTotaisState();
}

class _TelaPedidoTotaisState extends State<TelaPedidoTotais> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      children: [
        TextButton(
          onPressed: () {},
          child: Text('cliente'),
        ),
      ],
    );
  }
}
