import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forca_de_vendas/yukem_vendas/models/configuracao/app_ambiente.dart';
import 'package:forca_de_vendas/yukem_vendas/models/configuracao/app_user.dart';

import '../../../../../api/common/custom_widgets/custom_icons.dart';
import '../../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../models/database_objects/produtos_list_item.dart';
import '../../../../models/internet/internet.dart';
import '../../../components/custom_cached_image.dart';

class TileVisitaItemStandart extends StatefulWidget {
  final bool viewOnly;

  final ProdutoListItem item;

  const TileVisitaItemStandart(
      {Key? key,
      this.viewOnly = false,
      required this.item,
      required this.onAdd})
      : super(key: key);

  final Function() onAdd;

  @override
  State<TileVisitaItemStandart> createState() => _TileVisitaItemStandartState();
}

class _TileVisitaItemStandartState extends State<TileVisitaItemStandart> {
  @override
  Widget build(BuildContext context) {
    String estoque = widget.item.estoque != null
        ? 'Estoque: ${widget.item.estoque!.toStringAsFixed(0)}'
        : '';

    if (widget.item.editavel) {
      estoque = 'Quantidade: ${widget.item.getQuantidade()}';
    }

    // double preco;

    // String preco =
    //     'Preço ${TextDinheiroReal.format(widget.item.valor_tabela)}';

    final appAmbiente = AppAmbiente.of(context);

    final appUser = AppUser.of(context);

    final imageUrl =
        "${Internet.getHttpServer()}/image/${appUser.ambiente}/${widget.item.idProduto}-icon.png";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      color: Colors.white,
      child: TextButton(
        onPressed: widget.onAdd,
        child: Row(
          children: [
            if (appAmbiente.mostrarFotoProduto)
              Flexible(
                flex: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: SizedBox(
                    height: 64,
                    width: 64,
                    child: CustomCachedImage(
                      link: imageUrl,
                      ambiente: appUser.ambiente,
                      name: '${widget.item.idProduto}-thumb.png',
                      failHorlder: const IconBig(CupertinoIcons.cube_box),
                      download: true,
                    ),
                  ),
                ),
              ),
            if (!appAmbiente.mostrarFotoProduto)
              const Flexible(flex: 1, child: IconBig(CupertinoIcons.cube_box)),

            // const Flexible(
            //   flex: 1,
            //   child: IconNormal(
            //     CupertinoIcons.cube_box,
            //   ),
            // ),

            const SizedBox(
              width: 8,
            ),
            Flexible(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextTitle(
                    widget.item.nome,
                  ),
                  const Divider(
                    color: Colors.grey,
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: Row(
                          children: [
                            if (widget.item.valorTabela == null)
                              const Icon(
                                Icons.monetization_on,
                                size: 18,
                                color: Colors.yellow,
                              ),
                            if (widget.item.valorOriginal == null)
                              const Icon(
                                Icons.monetization_on,
                                size: 18,
                                color: Colors.red,
                              ),
                            Flexible(
                              child: Builder(builder: (x) {
                                String preco = 'N/A';

                                double? valor;

                                if (widget.item.valorOriginal != null) {
                                  valor = widget.item.valorOriginal;
                                }

                                if (widget.item.valorTabela != null) {
                                  valor = widget.item.valorTabela;
                                }

                                if (valor != null) {
                                  preco = TextDinheiroReal.format(valor);
                                }

                                return TextNormal('Preco: $preco');
                              }),
                            )
                          ],
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: TextNormal(
                            estoque,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
