import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forca_de_vendas/api/common/custom_widgets/custom_text.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/base/custom_drawer.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/dashboard/moddels/critica.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/dashboard/tiles/tile_critica.dart';

import '../../../../api/common/formatter/date_time_formatter.dart';
import '../../../models/configuracao/app_user.dart';

class TelaCritica extends StatefulWidget {
  const TelaCritica({Key? key}) : super(key: key);

  @override
  State<TelaCritica> createState() => _TelaCriticaState();
}

class _TelaCriticaState extends State<TelaCritica> {
  bool onLoading = true;
  List<dynamic> itens = [];

  @override
  void initState() {
    super.initState();
    final curTime = DateTime.now();
    final time = DateFormatter.databaseDate.format(curTime);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Critica.getData(context, AppUser.of(context).vendedorAtual, time, time)
          .then((value) {
        setState(() {
          itens = value;
          onLoading = false;
        });
      });
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
      body: onLoading ? carregando : list,
    );
  }
}
