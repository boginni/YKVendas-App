import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forca_de_vendas/api/common/custom_widgets/custom_icons.dart';
import 'package:forca_de_vendas/api/common/custom_widgets/custom_text.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/base/custom_drawer.dart';

import '../../../../api/common/formatter/date_time_formatter.dart';
import '../../../models/configuracao/app_user.dart';
import '../../../models/internet/internet.dart';
import '../base/moddel_screen.dart';

class TelaCritica extends ModdelScreen {
  //TODO: Implementação de ScreenID para configurar a exibição de telas
  final int screenId = 0;

  const TelaCritica({Key? key}) : super(key: key);

  @override
  Widget getCustomScreen(BuildContext context) {
    return const _Tela();
  }
}

class _Tela extends StatefulWidget {
  const _Tela({Key? key}) : super(key: key);

  @override
  State<_Tela> createState() => _TelaState();
}

class _TelaState extends State<_Tela> {
  bool isLoading = true;
  List<dynamic> itens = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      final curTime = DateTime.now();
      final time = DateFormatter.databaseDate.format(curTime);
      // final time = '2022-01-03';




    });
  }

  @override
  Widget build(BuildContext context) {
    final list = ListView.builder(
      shrinkWrap: true,
      itemCount: itens.length,
      itemBuilder: (context, index) {
        final item = itens[index];

        return TileCritia(item: item);
      },
    );

    final carregando = Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              TextNormal('Carregando Dados'),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Critica'),
      ),
      drawer: const CustomDrawer(),
      // backgroundColor: Colors.grey[200],
      body: isLoading ? carregando : list,
    );
  }
}

class TileCritia extends StatelessWidget {
  const TileCritia({Key? key, required this.item}) : super(key: key);

  final List<dynamic> item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        child: Row(
          children: [
            const IconNormal(
              CupertinoIcons.cube_box,
            ),
            const SizedBox(
              width: 4,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item[2],
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text('Quantidade: ${item[4].toStringAsFixed(0)}'),
                ],
              ),
            ),
            Column(
              children: [
                const TextNormal('Total'),
                TextDinheiroReal(
                  valor: double.parse(item[5].toString()),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
