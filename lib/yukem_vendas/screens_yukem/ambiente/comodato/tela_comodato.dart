import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forca_de_vendas/yukem_vendas/models/database_objects/comodato.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/comodato/tiles/tile_comodato.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/dashboard/components/container_loading.dart';

class TelaComodato extends StatefulWidget {
  const TelaComodato({Key? key, required this.idPessoaSync}) : super(key: key);

  final int? idPessoaSync;

  @override
  State<TelaComodato> createState() => _TelaComodatoState();
}

class _TelaComodatoState extends State<TelaComodato> {
  final scrollController = ScrollController();
  bool mostrarFechados = true;
  List<ComodatoCab> list = [];

  bool onLoading = true;

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      getData();
    });
  }

  getData() {
    Comodato.getComodatoCab(
      widget.idPessoaSync,
      mostrarFechados: mostrarFechados,
    ).then((value) {
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
        title: const Text('Comodatos'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                mostrarFechados = !mostrarFechados;
                getData();
              });
            },
            icon: Icon(
              mostrarFechados ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
            ),
          )
        ],
      ),
      body: onLoading
          ? const ContainerLoading()
          : ListView.builder(
              controller: scrollController,
              shrinkWrap: true,
              itemCount: list.length,
              itemBuilder: (BuildContext context, int i) {
                return TileComodato(itemCab: list[i]);
              },
            ),
    );
  }
}
