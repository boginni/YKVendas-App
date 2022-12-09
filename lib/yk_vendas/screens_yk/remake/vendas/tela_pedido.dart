import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../ambiente/dashboard/components/container_loading.dart';
import 'moddels/pedido.dart';
import 'nav_bar/tela_pedido_cliente.dart';
import 'nav_bar/tela_pedido_produtos.dart';
import 'nav_bar/tela_pedido_totais.dart';

class TelaPedido extends StatefulWidget {
  const TelaPedido({Key? key, required this.pedido, this.init = false})
      : super(key: key);

  final Pedido pedido;
  final bool init;

  @override
  State<TelaPedido> createState() => _TelaPedidoState();
}

class _TelaPedidoState extends State<TelaPedido> {
  @override
  void initState() {
    widget.pedido.loadItens().then((value) {
      setState(() {
        telaAtual = 0;
        onLoading = false;
      });
    });
  }

  bool onLoading = true;

  late int telaAtual = 0;

  @override
  Widget build(BuildContext context) {
    final telas = <Widget>[
      TelaPedidoCliente(pedido: widget.pedido),
      TelaPedidoProduto(pedido: widget.pedido),
      const TelaPedidoTotais(),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Pedido')),
      body: onLoading ? const ContainerLoading() : telas[telaAtual],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          setState(() {
            telaAtual = value;
          });
        },
        currentIndex: telaAtual,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Cliente',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.cube_box),
            label: 'Produtos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'Totais',
          ),
        ],
      ),
    );
  }
}
