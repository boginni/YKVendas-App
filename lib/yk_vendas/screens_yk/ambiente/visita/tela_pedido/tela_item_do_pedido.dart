import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../api/common/components/list_scrollable.dart';
import '../../../../../api/common/components/mostrar_confirmacao.dart';
import '../../../../../api/common/custom_widgets/custom_buttons.dart';
import '../../../../../api/common/custom_widgets/floating_bar.dart';
import '../../../../../api/common/debugger.dart';
import '../../../../common/components/custom_cached_image.dart';
import '../../../../models/configuracao/app_ambiente.dart';
import '../../../../models/configuracao/app_user.dart';
import '../../../../models/database/database_ambiente.dart';
import '../../../../models/database_objects/item_visita.dart';
import '../../../../models/database_objects/tabela_precos.dart';
import '../../../../models/internet/internet.dart';
import 'container_detalhes_categoria.dart';
import 'container_visita_item.dart';

class TelaItemPedido extends StatefulWidget {
  static const routeName = '/telaItemPedido';

  const TelaItemPedido({Key? key}) : super(key: key);

  @override
  State<TelaItemPedido> createState() => _TelaItemPedidoState();
}

class _TelaItemPedidoState extends State<TelaItemPedido> {
  final _formKey = GlobalKey<FormState>();

  ProdutoItemVisita? item;

  Future<ProdutoItemVisita> setup(List<dynamic> args) async {
    double descontoMax = 0;
    final appAmbiente = AppAmbiente.of(context);
    final appUser = AppUser.of(context);

    int idVisita = args[0] as int;
    int idProduto = args[1] as int;
    int? idItem;

    try {
      idItem = args[2] as int?;
    } catch (e) {}

    try {
      int idTabela = await TabelaPreco.getIdTabela(idVisita);

      if (!appAmbiente.permitirDuplicarItens && idItem == null) {
        var maps = await DatabaseAmbiente.select('TB_VISITA_ITEM',
            where: 'ID_VISITA = ? and ID_PRODUTO = ? and STATUS = 1',
            whereArgs: [idVisita, idProduto]);

        if (maps.isNotEmpty) {
          idItem = maps[0]['ID'];
        }
      }

      return getProdutoItemVisita(
        idVisita: idVisita,
        idProduto: idProduto,
        idVendedor: appUser.vendedorAtual,
        idTabela: idTabela,
        idItem: idItem,
      ).catchError(
        (e) {
          printDebug(e);
        },

      );
    } catch (e) {
      printDebug(e);
      rethrow;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setup(ModalRoute.of(context)!.settings.arguments as List<dynamic>)
          .then((value) {
        setState(() {
          item = value;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    late final Widget child;
    if (item != null) {
      child = Form(
        key: _formKey,
        child: BodyFloatingBar(
          barChildrens: [
            ButtonLimpar(
                enabled: true,
                onPressed: () {
                  mostrarCaixaConfirmacao(context).then((value) {
                    if (value) {
                      ProdutoItemVisita.deleteItem(item!.idItem).then((value) {
                        Navigator.of(context).pop();
                      });
                    }
                  });
                }),
            ButtonSalvar(
                enabled: item != null,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    item!
                        .insertItem()
                        .then((value) => Navigator.of(context).pop());
                  }
                })
          ],
          child: ListView(
            children: [
              ContainerItemPedido(
                produtoItemVisita: item!,
              ),
            ],
          ),
        ),
      );
    } else {
      child = const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item do produto'),
      ),
      // backgroundColor: Colors.white,
      body: child,
    );
  }
}

class ContainerItemPedido extends StatefulWidget {
  final ProdutoItemVisita produtoItemVisita;

  const ContainerItemPedido({Key? key, required this.produtoItemVisita})
      : super(key: key);

  @override
  State<ContainerItemPedido> createState() => _ContainerItemPedidoState();
}

class _ContainerItemPedidoState extends State<ContainerItemPedido> {
  @override
  Widget build(BuildContext context) {
    final appAmbiente = AppAmbiente.of(context);
    final appUser = AppUser.of(context);

    final imageUrl =
        "${Internet.getHttpServer()}/image/${appUser.ambiente}/${widget.produtoItemVisita.idProduto}.png";

    return ListViewNested(children: [
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
                name: '${widget.produtoItemVisita.idProduto}.png',
                waitTurn: false,
              ),
          ],
        ),
      ),

      Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListViewNested(
            children: [
              ContainerDetalhesCategoria(
                idProduto: widget.produtoItemVisita.idProduto,
              ),
              ContainerVisitaItem(item: widget.produtoItemVisita),
            ],
          ),
        ),
      ),

      //
      //   Card(
      //     child: Padding(
      //       padding: const EdgeInsets.all(8.0),
      //       child: ContainerBrinde(
      //         item: widget.produtoItemVisita,
      //         callBack: () {
      //           setState(() {});
      //         },
      //       ),
      //     ),
      //   ),

      const SizedBox(
        height: 64,
      )
    ]);
  }
}
