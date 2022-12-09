import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../../../api/common/components/barra_progresso.dart';
import '../../../../../api/common/custom_widgets/custom_icons.dart';
import '../../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../../api/common/debugger.dart';
import '../../../../common/custom_tiles/object_tiles/tile_add_produtos.dart';
import '../../../../models/database_objects/tabela_precos.dart';
import '../../../../models/database_objects/visita.dart';
import '../../../../models/pdf/pdf_pedido.dart';
import '../tela_pedido/container_totais.dart';

class TelaVisualizacaoVisita extends StatelessWidget {
  static const routeName = '/visualizacaoVisita';

  TelaVisualizacaoVisita({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int idVisita = ModalRoute.of(context)!.settings.arguments as int;

    ///Inicia a tela de pedido
    setup() async {
      return await Visita.getVisita(idVisita);
    }

    return FutureBuilder(
      future: setup(),
      builder: (BuildContext context, AsyncSnapshot<Visita> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          Visita visita = snapshot.data!;

          return Scaffold(
              appBar: AppBar(
                title: const Text("Visualização da Venda"),
                centerTitle: true,
                leading: BackButton(
                  onPressed: () {
                    Navigator.of(context).pop(context);
                  },
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Selecione o formato'),
                                content: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        final key =
                                            await mostrarBarraProgressoCircular(
                                                context);
                                        gerarRelatorio(idVisita, formato: true)
                                            .then((value) {
                                          key.currentState!.finish();
                                        }).catchError((value) {
                                          printDebug(value);
                                          key.currentState!
                                              .setError('Error', '');
                                        });
                                      },
                                      child:
                                          const IconBig(Icons.picture_as_pdf),
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        final key =
                                            await mostrarBarraProgressoCircular(
                                                context);

                                        gerarRelatorio(idVisita, formato: false)
                                            .then((value) {
                                          key.currentState!.finish();
                                        }).catchError((value) {
                                          printDebug(value);
                                          key.currentState!
                                              .setError('Error', '');
                                        });
                                      },
                                      child: const IconBig(Icons.image),
                                    )
                                  ],
                                ),
                              );
                            });
                      },
                      child: const Icon(Icons.share),
                    ),
                  )
                ],
              ),
              body: ListView(
                children: [
                  Column(
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              bottom: 24, top: 4, right: 8, left: 8),
                          child: FutureBuilder(
                            future: TabelaPreco.getTabelaPreco(idVisita),
                            builder: (BuildContext context,
                                AsyncSnapshot<TabelaPreco?> snapshot) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const TextNormal('Tabela de Preços:'),
                                  TextTitle(snapshot.data != null
                                      ? snapshot.data!.nome!
                                      : '')
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      TileAddProdutosButton(idVisita,
                          concluida: visita.itensConcluida,
                          enabled: visita.tabelaConcluida,
                          onPressed: () {},
                          viewOnly: true),
                      Card(
                        child: ContainerTotaisPedido(
                          visita: visita,
                          onUpdate: () => () {},
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 48,
                  )
                ],
              ));
        }
      },
    );
  }
}
