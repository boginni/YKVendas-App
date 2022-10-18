import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forca_de_vendas/yukem_vendas/models/database_objects/produto.dart';

import '../../../../../api/common/components/list_scrollable.dart';
import '../../../../../api/common/custom_tiles/default_tiles/tile_spaced_text.dart';
import '../../../../../api/common/custom_tiles/default_tiles/tile_topico.dart';
import '../../../../../api/models/configuracao/app_system.dart';
import '../../../../models/configuracao/app_ambiente.dart';

class ContainerDetalhesCategoria extends StatelessWidget {
  final int idProduto;

  const ContainerDetalhesCategoria({Key? key, required this.idProduto})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appConfig = AppAmbiente.of(context);
    final appSystem = AppSystem.of(context);

    return FutureBuilder(
      future: ProdutoInfo.getData(idProduto),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {

        if (snapshot.data == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final ProdutoInfo item = snapshot.data!;

        return ListViewNested(children: [
          if (appConfig.mostrarDetalhesCategoria)
            ListViewNested(
              children: [
                const TileTopico('Categoria'),
                TileSpacedText('Grupo:', item.grupo),
                TileSpacedText('Subgrupo:', item.subGrupo),
                TileSpacedText('Departamento:', item.departamento),
              ],
            ),
          const TileTopico('Estoque'),
          TileSpacedText('Unidade de Medida:', item.unidade),
          if (item.estoque != null && appConfig.mostrarEstoque)
            TileSpacedText('Estoque Atual:', item.estoque.toStringAsFixed(0)),
          if (appConfig.mostrarQuantidadeReservada &&
              appConfig.mostrarEstoque &&
              item.estoque != null)
            TileSpacedText(
                'Quantidade Reservada:', item.estoque.toStringAsFixed(0)),
        ]);
      },
    );
  }
}
