import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forca_de_vendas/yukem_vendas/common/components/custom_cached_image.dart';
import 'package:forca_de_vendas/yukem_vendas/models/configuracao/app_ambiente.dart';
import 'package:forca_de_vendas/yukem_vendas/models/configuracao/app_user.dart';
import 'package:forca_de_vendas/yukem_vendas/models/database_objects/produto.dart';
import 'package:forca_de_vendas/yukem_vendas/models/database_objects/produto_preco.dart';
import 'package:forca_de_vendas/yukem_vendas/models/internet/internet.dart';

import '../../../../api/common/components/list_scrollable.dart';
import '../../../../api/common/custom_tiles/default_tiles/tile_spaced_text.dart';
import '../../../../api/common/custom_tiles/default_tiles/tile_topico.dart';
import '../../../../api/common/custom_widgets/custom_icons.dart';
import '../../../../api/common/custom_widgets/custom_text.dart';
import '../../../models/database_objects/tabela_precos.dart';

class TelaViewProduto extends StatefulWidget {
  static const routeName = '/telaViewProduto';

  const TelaViewProduto({Key? key, required this.idProduto}) : super(key: key);

  final int idProduto;

  @override
  State<StatefulWidget> createState() => _TelaViewProdutoState();
}

class _TelaViewProdutoState extends State<TelaViewProduto> {
  final _scrollCrontroller = ScrollController();
  TabelaPreco? tabela;

  late ProdutoInfo produto;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {

      getProdutoInfo(widget.idProduto).then((value) {
        setState(() {
          produto = value;
          isLoading = false;
        });
      });

    });
  }

  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    final appUser = AppUser.of(context);
    final appAmbiente = AppAmbiente.of(context);

    // setTabela(int? idTabela) async {
    //   if (idTabela == null) {
    //     return;
    //   }
    // }



    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualizar Produto'),
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body:

      isLoading? const Center(
        child: CircularProgressIndicator(),
      ) : Builder(
        builder: (context) {
          final imageUrl =
              "${Internet.getHttpServer()}/image/${appUser.ambiente}/${produto.id}.png";
          final iconUrl =
              "${Internet.getHttpServer()}/image/${appUser.ambiente}/${produto.id}-icon.png";

          return ListView(
            controller: _scrollCrontroller,
            children: <Widget>[
              Container(
                color: Colors.white,
                child: ListViewNested(
                  children: [
                    if (appAmbiente.mostrarFotoProduto)
                      CustomCachedImage(
                        link: imageUrl,
                        failHorlder: Container(),
                        placeHolder: Container(),
                        ambiente: appUser.ambiente,
                        name: '${produto.id}.png',
                        createThumb: false,
                        iconLink: iconUrl,
                        iconName: '${produto.id}-thumb.png',
                        waitTurn: false,
                      ),
                    Row(
                      children: [
                        const IconBig(CupertinoIcons.cube_box),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: TextTitle(produto.nome),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              TextSpamable(textList: [
                                const TextTitle('Estoque: '),
                                const SizedBox(
                                  width: 16,
                                ),
                                TextTitle(produto.estoque.toStringAsFixed(0))
                              ])
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListViewNested(
                    children: [
                      const TileTopico('Descrição'),
                      TileSpacedText('ID', produto.id.toString()),
                      TextNormal(produto.descricao),
                      const TileTopico('Categoria'),
                      TileSpacedText('Grupo:', produto.grupo),
                      TileSpacedText('Subgrupo:', produto.subGrupo),
                      TileSpacedText('Departamento:', produto.departamento),
                      // Row(
                      //   children: [
                      //     Flexible(
                      //       flex: 1,
                      //       child: DropdownSaved(
                      //           DropdownSaved.tabelaPreco,
                      //           startValue: tabela == null ? null : tabela!.id,
                      //         onChange: (i) => setTabela(i),
                      //         hint: 'Selecione uma Tabela',
                      //       )
                      //     )
                      //   ],
                      // ),

                      // TileSpacedText('Preço',produtso.preco.toStringAsFixed(0)),

                      // TileSpacedText('Unidade', produto.unidade),

                      //TileSpacedText('Estoque','$Estoque $Unidade') Alternativa (requer mexer no bd)
                      // ExpansionTile(
                      //   maintainState: true,
                      //   title: TextSpamable(
                      //     textList: [
                      //       const TextTitle('Preços por Tabela'),
                      //       TextNormal('(${x.toString()})')
                      //     ],
                      //   ),
                      //   children: const [
                      //     TextNormal('asd'),
                      //     TextNormal('qw'),
                      //   ],
                      // ),

                      // ExpansionTile(
                      //   maintainState: true,
                      //   title: TextSpamable(
                      //     textList: [
                      //       const TextTitle('Preços por Quantidade'),
                      //       TextNormal('(${x.toString()})')
                      //     ],
                      //   ),
                      //   children: const [
                      //     TextNormal('qws'),
                      //     TextNormal('asd'),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                  child: ListViewNested2(
                    title: const TextTitle('Preço por tabela'),
                    children: [
                      FutureBuilder(
                        future: getProdutoPrecoTabelaListFull(produto.id),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<ProdutoPrecoTabela>> snapshot) {
                          final List<ProdutoPrecoTabela> list =
                              snapshot.data ?? [];

                          return Card(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: list.length,
                                  physics: const ClampingScrollPhysics(),
                                  itemBuilder: (context, i) {
                                    final item = list[i];
                                    String preco = 'N/A';

                                    final usaTabela = appAmbiente.usarTabela ||
                                        item.idTabela ==
                                            appAmbiente.tabelaPadrao;

                                    if (item.valorTabela != null) {
                                      preco = TextDinheiroReal.format(
                                          item.valorTabela!);
                                    }

                                    if (!usaTabela) {
                                      return Container();
                                    } else {
                                      return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4, vertical: 2),
                                          child: TileSpacedText(
                                              item.nomeTabela, preco));
                                    }
                                  }),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        }
      )
    );
  }
}
