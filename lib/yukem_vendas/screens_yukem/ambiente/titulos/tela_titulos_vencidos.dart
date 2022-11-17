import 'package:flutter/material.dart';
import 'package:forca_de_vendas/api/common/components/list_scrollable.dart';
import 'package:forca_de_vendas/yukem_vendas/models/database_objects/titulos_aberto.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/titulos/tiles/tile_titulo_vencido.dart';

class TelaTitulos extends StatefulWidget {
  const TelaTitulos({Key? key, required this.idPessoaSync}) : super(key: key);

  final int? idPessoaSync;

  @override
  State<TelaTitulos> createState() => _TelaTitulosState();
}

class _TelaTitulosState extends State<TelaTitulos> {
  final scrollController = ScrollController();
  List<TituloAberto> list = [];

  @override
  void initState() {
    super.initState();
    getTitulosAberto(widget.idPessoaSync).then((value) {
      setState(() {
        list = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Títulos em Aberto'),
      ),
      body: ListView(
        controller: scrollController,
        children: [
          ListViewScrollable(
            itemBuilder: (BuildContext context, int i) {
              return TileTituloVencido(item: list[i]);
            },
            maxCount: list.length,
            scrollController: scrollController,
          )
        ],
      ),
    );
  }
}
