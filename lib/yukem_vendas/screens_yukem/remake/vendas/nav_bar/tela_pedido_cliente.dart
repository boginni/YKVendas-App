import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forca_de_vendas/yukem_vendas/app_foundation.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/dashboard/components/container_loading.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/titulos/tela_titulos_vencidos.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/remake/util/tela_importar_produtos.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/remake/cliente/tela_clientes.dart';

import '../../../../models/database_objects/cliente.dart';
import '../../../ambiente/comodato/tela_comodato.dart';
import '../moddels/pedido.dart';

class TelaPedidoCliente extends StatefulWidget {
  const TelaPedidoCliente({Key? key, required this.pedido}) : super(key: key);

  final Pedido pedido;

  @override
  State<TelaPedidoCliente> createState() => _TelaPedidoClienteState();
}

class _TelaPedidoClienteState extends State<TelaPedidoCliente> {
  bool onLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.pedido.idCliente != null) {
      Cliente.getCliente(widget.pedido.idCliente!).then((value) {
        setState(() {
          curCliente = value;
          onLoading = false;
        });
      });
    }
  }

  Cliente? curCliente;

  bool mostrarTodos = false;

  @override
  Widget build(BuildContext context) {
    return onLoading
        ? const ContainerLoading()
        : SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                TextButton(
                  onPressed: () {
                    Application.navigate(
                      context,
                      TelaBuscarCliente(mostrarTodos: mostrarTodos),
                    ).then((value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        curCliente = value;
                        widget.pedido.setCliente(curCliente!);
                      });
                    });
                  },
                  child: const Text('Selecionar Cliente'),
                ),
                Switch(
                  value: mostrarTodos,
                  onChanged: (value) {
                    setState(() {
                      mostrarTodos = value;
                    });
                  },
                ),
                Builder(
                  builder: (context) {
                    if (curCliente == null) {
                      return Container();
                    }

                    final cliente = curCliente!;
                    return ListView(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      children: [
                        Text(cliente.nome ?? ''),
                        TextButton(
                          child: Text('Títulos'),
                          onPressed: () {
                            Application.navigate(context,
                                TelaTitulos(idPessoaSync: cliente.idSync));
                          },
                        ),
                        TextButton(
                          child: Text('Comodatos'),
                          onPressed: () {
                            Application.navigate(context,
                                TelaComodato(idPessoaSync: cliente.idSync));
                          },
                        ),
                        TextButton(
                          child: Text('Histórico de pedidos'),
                          onPressed: () {
                            Application.navigate(
                              context,
                              TelaHistoricoPedidos(idPessoa: cliente.idSync, idVisita: null,),
                            );
                          },
                        ),
                      ],
                    );
                  },
                )
              ],
            ),
          );
  }
}
