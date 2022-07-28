import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forca_de_vendas/api/common/components/list_scrollable.dart';
import 'package:forca_de_vendas/api/common/custom_tiles/default_tiles/tile_spaced_text.dart';
import 'package:forca_de_vendas/api/common/custom_widgets/custom_icons.dart';
import 'package:forca_de_vendas/api/common/custom_widgets/custom_text.dart';
import 'package:forca_de_vendas/api/common/formatter/date_time_formatter.dart';
import 'package:forca_de_vendas/yukem_vendas/models/database_objects/comodato.dart';

class TelaComodato extends StatefulWidget {
  const TelaComodato({Key? key}) : super(key: key);

  static const String routeName = 'TelaComodato';

  @override
  State<TelaComodato> createState() => _TelaComodatoState();
}

class _TelaComodatoState extends State<TelaComodato> {
  final scrollController = ScrollController();

  bool mostrarFechados = true;

  @override
  Widget build(BuildContext context) {
    List<ComodatoCab> list = [];

    final idPessoaSync = ModalRoute.of(context)!.settings.arguments as int?;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Comodatos'),
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    mostrarFechados = !mostrarFechados;
                  });
                },
                icon: Icon(mostrarFechados
                    ? CupertinoIcons.eye_slash
                    : CupertinoIcons.eye))
          ],
        ),
        body: ListView(
          controller: scrollController,
          children: [
            FutureBuilder(
              future: Comodato.getComodatoCab(idPessoaSync,
                  mostrarFechados: mostrarFechados),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.data != null) {
                  list = snapshot.data;
                }

                Widget getTile(int i) {
                  final itemCab = list[i];

                  String statusCab = '';
                  Color? statusCor;

                  if (itemCab.status == 0) {
                    statusCab = 'Aberto';
                    statusCor = Colors.green;
                  }

                  if (itemCab.status == 1) {
                    statusCab = 'Fechado';
                    statusCor = Colors.red;
                  }

                  if (itemCab.status == 3) {
                    statusCab = 'Parcial';
                    statusCor = Colors.yellow;
                  }

                  List<ComodatoDet> listDet = [];

                  final format = DateFormatter.normalData;
                  return Card(
                      child: Container(
                          padding: const EdgeInsets.all(4),
                          child: ExpansionTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextTitle(
                                      statusCab,
                                      color: statusCor,
                                    ),
                                    TextNormal('ID ${itemCab.id}'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const IconSmall(CupertinoIcons.clock),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    TextTitle(
                                        format.format(itemCab.dataVencimento)),
                                  ],
                                )
                              ],
                            ),
                            childrenPadding: const EdgeInsets.only(
                                left: 12, right: 12, bottom: 8),
                            children: [
                              TileSpacedText('Movimento',
                                  format.format(itemCab.dataMovimento)),
                              TileSpacedText('Vencimento',
                                  format.format(itemCab.dataVencimento)),
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  TextTitle('Produto'),
                                  TextTitle('Quantidade')
                                ],
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              FutureBuilder(
                                future: itemCab.getComodatoDet(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<dynamic> snapshot) {
                                  if (snapshot.data != null) {
                                    listDet = snapshot.data;
                                  }

                                  return ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: listDet.length,
                                    physics: const ClampingScrollPhysics(),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final itemDet = listDet[index];

                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            flex: 6,
                                            child: Row(
                                              children: [
                                                const IconSmall(
                                                    CupertinoIcons.cube_box),
                                                const SizedBox(
                                                  width: 8,
                                                ),
                                                TextNormal(itemDet.nome),
                                              ],
                                            ),
                                          ),
                                          Flexible(
                                            flex: 1,
                                            child: TextNormal(itemDet.quantidade
                                                .toStringAsFixed(0)),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          )));
                }

                return ListViewScrollable(
                  itemBuilder: (BuildContext context, int i) {
                    return getTile(i);
                  },
                  maxCount: list.length,
                  scrollController: scrollController,
                );
              },
            )
          ],
        ));
  }
}
