import 'package:flutter/material.dart';
import 'package:forca_de_vendas/yukem_vendas/models/database_objects/titulos_aberto.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/dashboard/components/container_loading.dart';
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
  bool onLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getData();
    });
  }

  getData() {
    getTitulosAberto(widget.idPessoaSync).then((value) {
      setState(() {
        list = value;
        onLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Títulos em Aberto'),
      ),
      body: onLoading
          ? const ContainerLoading()
          : RefreshIndicator(
              onRefresh: () async {
                getData();
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                itemCount: list.length,
                itemBuilder: (context, index) =>
                    TileTituloVencido(item: list[index]),
              ),
            ),
    );
  }
}
