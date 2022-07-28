import 'package:flutter/material.dart';
import 'package:forca_de_vendas/api/common/components/list_scrollable.dart';
import 'package:forca_de_vendas/api/common/custom_tiles/default_tiles/tile_spaced_text.dart';
import 'package:forca_de_vendas/api/common/custom_widgets/custom_text.dart';
import 'package:forca_de_vendas/yukem_vendas/models/database_objects/titulos_aberto.dart';

import '../../../../api/common/formatter/date_time_formatter.dart';

class TelaTitulos extends StatefulWidget {
  const TelaTitulos({Key? key}) : super(key: key);

  static const String routeName = 'TelaTituloAberto';

  @override
  State<TelaTitulos> createState() => _TelaTitulosState();
}

class _TelaTitulosState extends State<TelaTitulos> {
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final idPessoaSync = ModalRoute.of(context)!.settings.arguments as int?;

    List<TituloAberto> list = [];

    return Scaffold(
        appBar: AppBar(
          title: const Text('Títulos em Aberto'),
        ),
        body: ListView(
          controller: scrollController,
          children: [
            FutureBuilder(
              future: getTitulosAberto(idPessoaSync),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.data != null) {
                  list = snapshot.data;
                }

                Widget getTile(int i) {
                  final item = list[i];

                  String status = 'Aberto';

                  bool vencido = false;

                  if (item.dataVencimento.compareTo(DateTime.now()) < 0) {
                    status = 'Vencido';
                    vencido = true;
                  }

                  return Card(
                      child: Container(
                          padding: const EdgeInsets.all(4),
                          child: ExpansionTile(
                            childrenPadding: const EdgeInsets.only(
                                left: 12, right: 12, bottom: 8),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    TextTitle(
                                      status,
                                      color:
                                          vencido ? Colors.red : Colors.yellow,
                                    ),
                                    TextNormal('documento: ${item.documento}'),
                                  ],
                                ),
                                Column(
                                  children: [
                                    TextTitle(TextDinheiroReal.format(
                                        item.valorRestante)),
                                    TextNormal(
                                        DateFormatter.normalData.format(item.dataVencimento)),
                                  ],
                                ),
                              ],
                            ),
                            children: [
                              TileSpacedText('Id', item.id.toString()),
                              TileSpacedText('Documento', item.documento),
                              TileSpacedText('Vencimento',
                                  DateFormatter.normalData.format(item.dataVencimento)),
                              const SizedBox(
                                height: 8,
                              ),
                              TileSpacedText(
                                  'Valor', TextDinheiroReal.format(item.valor)),
                              TileSpacedText('Juros',
                                  TextDinheiroReal.format(item.valorJuros)),
                              TileSpacedText('Multa',
                                  TextDinheiroReal.format(item.valorMulta)),
                              TileSpacedText('Restante',
                                  TextDinheiroReal.format(item.valorRestante)),
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
