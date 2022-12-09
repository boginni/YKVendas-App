import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../api/common/custom_widgets/custom_icons.dart';
import '../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../api/models/database_objects/query_filter.dart';
import '../../../app_foundation.dart';
import '../../../models/database/database_ambiente.dart';
import '../../../models/database_objects/produto.dart';
import '../../../models/internet/internet.dart';
import '../../../screens_yk/ambiente/produtos/tela_view_produto.dart';
import '../../components/custom_cached_image.dart';

/// Mostra um produto e ao clicar, abre a tela [TelaViewProduto]
class TileProduto extends StatefulWidget {
  final ProdutoListNormal produto;
  final bool mostrarIcone;
  final String ambiente;

  final Function() onUpdate;

  const TileProduto(
      {Key? key,
      required this.produto,
      required this.mostrarIcone,
      required this.ambiente,
      required this.onUpdate})
      : super(key: key);

  @override
  State<TileProduto> createState() => _TileProdutoState();
}

class _TileProdutoState extends State<TileProduto> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    viewProduto() {
      Application.navigate(
              context, TelaViewProduto(idProduto: widget.produto.id))
          .then((value) {
        widget.onUpdate();
      });
    }

    final imageUrl =
        "${Internet.getHttpServer()}/image/${widget.ambiente}/${widget.produto.id}-icon.png";

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 2),
        child: TextButton(
          onPressed: () {
            viewProduto();
          },
          child: Row(
            children: [
              if (widget.mostrarIcone)
                Flexible(
                  flex: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: SizedBox(
                      height: 64,
                      width: 64,
                      child: CustomCachedImage(
                        link: imageUrl,
                        ambiente: widget.ambiente,
                        name: '${widget.produto.id}-thumb.png',
                        failHorlder: const IconBig(CupertinoIcons.cube_box),
                        download: true,
                      ),
                    ),
                  ),
                ),
              if (!widget.mostrarIcone)
                const Flexible(
                    flex: 1, child: IconBig(CupertinoIcons.cube_box)),
              const SizedBox(
                width: 8,
              ),
              Flexible(
                  flex: 5,
                  child:
                      TextNormal('${widget.produto.id} ${widget.produto.nome}'))
            ],
          ),
        ),
      ),
    );
  }

  Future<List<ProdutoListNormal>> getProdutos(
      {QueryFilter? queryFilter, bool limit = false}) async {
    late final List<Map<String, dynamic>> maps;

    if (queryFilter != null) {
      maps = await DatabaseAmbiente.select('VW_PRODUTO_INFO',
          where: queryFilter.getWhere(),
          whereArgs: queryFilter.getArgs(),
          orderBy: 'NOME',
          limit: limit ? 100 : null);
    } else {
      maps = await DatabaseAmbiente.select('VW_PRODUTO_INFO', orderBy: 'NOME');
    }

    final list = List.generate(maps.length, (index) {
      final map = maps[index];
      return ProdutoListNormal(
          nome: map['NOME'].toString(),
          id: int.parse(map['ID_PRODUTO'].toString()));
    });

    return list;
  }
}
