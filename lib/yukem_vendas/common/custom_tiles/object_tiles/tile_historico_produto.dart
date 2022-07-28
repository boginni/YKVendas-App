import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forca_de_vendas/api/common/components/mostrar_confirmacao.dart';
import 'package:forca_de_vendas/api/common/custom_widgets/custom_icons.dart';
import 'package:forca_de_vendas/api/common/formatter/date_time_formatter.dart';
import 'package:forca_de_vendas/yukem_vendas/models/database_objects/historico_pedido.dart';
import 'package:forca_de_vendas/yukem_vendas/models/database_objects/historico_pedido_det.dart';
import 'package:forca_de_vendas/yukem_vendas/models/database_objects/item_visita.dart';
import 'package:forca_de_vendas/yukem_vendas/models/database_objects/tabela_precos.dart';
import 'package:forca_de_vendas/yukem_vendas/models/database_objects/totais_pedido.dart';

import '../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../api/common/debugger.dart';
import '../../../models/configuracao/app_ambiente.dart';
import '../../../models/configuracao/app_user.dart';

class TileHistoricoProduto extends StatelessWidget {
  final HistoricoPedido item;
  final int idVisita;

  TileHistoricoProduto({Key? key, required this.item, required this.idVisita})
      : super(key: key);

  List<HistoricoPedidoDet> list = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getHistoricoPeidoDetList(item.id),
      builder: (BuildContext context,
          AsyncSnapshot<List<HistoricoPedidoDet>> snapshot) {
        if (snapshot.data != null) {
          list = snapshot.data!;
        }

        if (snapshot.hasError) {
          printDebug(snapshot.error!.toString());
        }

        importar() async {
          if (!AppAmbiente.of(context).importarValorUnt) {
            await mostrarCaixaConfirmacao(context,
                title: 'Aviso',
                content:
                    'O app Vai tentar Recalcular o preço para o valor atual da tabela',
                mostrarCancelar: false);
          }

          final list = await getHistoricoPeidoDetList(item.id);

          int idTabela = await TabelaPreco.getIdTabela(idVisita);
          final appUser = AppUser.of(context);
          final appAmbiente = AppAmbiente.of(context);

          for (final item in list) {
            final produto = await getProdutoItemVisita(
                idVisita: idVisita,
                idProduto: item.idProduto,
                idVendedor: appUser.vendedorAtual,
                idTabela: idTabela,
                idItem: null);

            produto.quantidade = item.quantidade;

            if (appAmbiente.importarValorUnt) {
              printDebug('test 1');
              produto.valorUnitario = item.valorUnitario;
            } else {
              printDebug('test 2');
              produto.valorUnitario = produto.getPrecoTabela();
            }

            produto.descontoValor = item.valorDesconto;
            produto.brinde = item.brinde;
            produto.recalcDesconto();

            if (item.status && item.mobile) {
              produto.insertItem();
            } else {
              await mostrarCaixaConfirmacao(context,
                  content: '${item.nome} está desativado ou não é usado no app',
                  title: 'Produto inválido',
                  mostrarCancelar: false);
            }
          }

          TotaisPedido totaisPedido = TotaisPedido(idVisita,
              totalBruto: 0,
              totalLiquido: 0,
              totalDesconto: 0,
              quantidade: 0,
              itens: 0,
              idFormaPagamento: item.idFormaPagamento,
              comNota: false);

          totaisPedido.idVendedor = AppUser.of(context).vendedorAtual;
          totaisPedido.obsNF = item.obsNF ?? '';

          await totaisPedido.salvar();

          Navigator.of(context).pop();
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: ExpansionTile(
              title: TextButton(
                onPressed: () async {
                  mostrarCaixaConfirmacao(context,
                          title: 'Importar pedido?',
                          content:
                              'Os produtos desse item serão adicionados ao pedido atual')
                      .then((value) async {
                    if (value) {
                      importar();
                    }
                  });
                },
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Flexible(
                        flex: 1, child: IconNormal(CupertinoIcons.clock)),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      flex: 6,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Flexible(
                          //     child: TextTitle(item.nomeCliete)),

                          if (item.data != null)
                            Flexible(
                              child:
                                  TextNormal(DateFormatter.noramlDataHora.format(item.data!)),
                            )

                          // TextNormal(DateFormat('')
                          //     .(item.dataEmissao)),
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Column(
                        children: [
                          TextDinheiroReal(valor: item.valorTotal),
                        ],
                      ),
                    ),
                  ],
                ),
                // onPressed: () => importData(item.idVisita),
                // isActive: visita.tabelaConcluida
              ),
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: list.length,
                  physics: const ClampingScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return TileHistoricoPedidoDet(item: list[index]);
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class TileHistoricoPedidoDet extends StatelessWidget {
  final HistoricoPedidoDet item;

  const TileHistoricoPedidoDet({Key? key, required this.item})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String qtd = "Quantidade: ${item.quantidade.toStringAsFixed(0)}";
    String valorTot = "R\$ ${item.valorTotal.toStringAsFixed(2)}";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            // mainAxisAlignment:,
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                  flex: 1,
                  child: IconNormal(
                    CupertinoIcons.cube_box,
                    color: (item.status && item.mobile)
                        ? Colors.green
                        : Colors.redAccent,
                  )),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextNormal(item.nome),
                    TextNormal(qtd),
                  ],
                ),
              ),
              Flexible(flex: 2, child: TextNormal(valorTot)),
            ],
          ),
        ],
      ),
    );
  }
}
