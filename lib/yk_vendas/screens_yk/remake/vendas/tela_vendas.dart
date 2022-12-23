import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yk_vendas/api/common/debugger.dart';

import '../../../../api/app/app_theme.dart';
import '../../../app_foundation.dart';
import '../../../models/configuracao/app_user.dart';
import '../../ambiente/base/custom_drawer.dart';
import '../../ambiente/dashboard/components/selecionar_periodo.dart';
import 'moddels/pedido.dart';
import 'tela_pedido.dart';
import 'tiles/tile_pedido.dart';

class TelaVendas extends StatefulWidget {
  const TelaVendas({Key? key}) : super(key: key);

  @override
  State<TelaVendas> createState() => _TelaVendasState();
}

class _TelaVendasState extends State<TelaVendas> {
  bool onPesquisa = false;

  List<Pedido> pedidos = [];

  loadData() async {
    final value = await Pedido.loadData(context);
    setState(() {
      pedidos = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Vendas'),
        actions: [
          InkWell(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.sync),
            ),
            onTap: () {},
          )
        ],
      ),
      drawer: CustomDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          await loadData();
        },
        child: ListView(
          shrinkWrap: true,
          children: [
            Card(
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            onPesquisa = !onPesquisa;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Icon(Icons.search, size: 32),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            'R\$ 1000,00',
                            style: theme.textTheme.title(),
                          ),
                          Text(
                            'Total',
                            style: theme.textTheme.body(),
                          ),
                        ],
                      ),
                      InkWell(
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Icon(Icons.add, size: 32),
                        ),
                        onTap: () {
                          Pedido.create(
                            context,
                            idVendedor: AppUser.of(context).vendedorAtual,
                          ).then(
                            (value) {
                              Application.navigate(
                                context,
                                TelaPedido(
                                  pedido: value,
                                  init: true,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  if (onPesquisa)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(),
                        ),
                        InkWell(
                          onTap: () {
                            loadData();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Icon(Icons.search, size: 32),
                          ),
                        ),
                        InkWell(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Icon(Icons.calendar_month, size: 32),
                          ),
                          onTap: () {
                            SelecionarPeriodo.showPicker(context).then((value) {
                              printDebug(value);
                            });
                          },
                        ),
                      ],
                    )
                ],
              ),
            ),
            SizedBox(
              height: 12,
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: pedidos.length,
              itemBuilder: (context, index) {
                return TilePedido(
                  pedido: pedidos[index],
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
