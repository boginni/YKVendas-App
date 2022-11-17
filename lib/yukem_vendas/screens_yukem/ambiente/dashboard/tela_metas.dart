import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forca_de_vendas/api/common/custom_tiles/default_tiles/tile_spaced_text.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/dashboard/components/container_loading.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/dashboard/tiles/tile_meta_item.dart';

import '../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../api/common/formatter/date_time_formatter.dart';
import '../../../models/configuracao/app_user.dart';
import '../../../models/internet/internet.dart';
import '../base/custom_drawer.dart';

class TelaMetas extends StatefulWidget {
  const TelaMetas({Key? key}) : super(key: key);

  @override
  State<TelaMetas> createState() => _TelaMetasState();
}

class _TelaMetasState extends State<TelaMetas> {
  bool onLoading = true;
  bool onEmpty = false;

  List<dynamic> itens = [];
  Map<String, dynamic> header = {};

  void getData() {
    final curTime = DateTime.now();
    final time = DateFormatter.databaseDate.format(curTime);

    final body = {
      "id_vendedor": AppUser.of(context).vendedorAtual,
      "data_inicio": time,
      "data_fim": time
    };

    Internet.serverPost('dash/meta/vendedor/', context: context, body: body)
        .then((value) {
      setState(() {
        onLoading = false;

        if (value.statusCode == 404) {
          onEmpty = true;
        }

        if (value.statusCode != 200) {
          return;
        }

        itens = const JsonDecoder().convert(value.body)['rows'];
        header = const JsonDecoder().convert(value.body)['header'];
      });
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      getData();
    });
  }

  final controllerScroll = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metas'),
      ),
      drawer: const CustomDrawer(),
      body: onLoading
          ? const ContainerLoading()
          : onEmpty
              ? Center(
                  child: Card(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          onLoading = true;
                          onEmpty = false;
                          getData();
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 26, vertical: 30),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextNormal('Não foi encontrado metas'),
                            Text('Atualizar')
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    getData();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    controller: controllerScroll,
                    child: Column(
                      children: [
                        if (header.isNotEmpty)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              child: Column(
                                children: [
                                  Center(
                                    child: Column(
                                      children: [
                                        TextTitle(
                                            header['NOME_META'].toString()),
                                        TextNormal(
                                            '${DateFormatter.normalData.format(DateTime.parse(header['DATA_INICIO']))} - ${DateFormatter.normalData.format(DateTime.parse(header['DATA_FIM']))}')
                                      ],
                                    ),
                                  ),
                                  TileSpacedText('Vendedor',
                                      header['NOME_VENDEDOR'].toString()),
                                  TileSpacedText('Dias Utieis',
                                      header['DIAS_UTEIS'].toString()),
                                  TileSpacedText('Dias Decorridos',
                                      header['DIAS_DECORRIDOS'].toString()),
                                  TileSpacedText('Dias Restantes',
                                      header['DIAS_RESTANTES'].toString()),
                                ],
                              ),
                            ),
                          ),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: itens.length,
                          physics: const ClampingScrollPhysics(),
                          itemBuilder: (context, index) {
                            final item = itens[index];
                            return TileMetaItem(item: item);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
