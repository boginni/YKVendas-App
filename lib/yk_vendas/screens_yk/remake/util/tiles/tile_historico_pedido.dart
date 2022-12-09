import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../api/common/components/mostrar_confirmacao.dart';
import '../../../../../api/common/custom_tiles/default_tiles/tile_spaced_text.dart';
import '../../../../../api/common/custom_widgets/custom_icons.dart';
import '../../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../../api/common/debugger.dart';
import '../../../../../api/common/formatter/date_time_formatter.dart';
import '../../../../models/configuracao/app_ambiente.dart';
import '../../../../models/configuracao/app_user.dart';
import '../../../../models/database/database_ambiente.dart';
import '../../../../models/database_objects/historico_pedido.dart';
import '../../../../models/database_objects/historico_pedido_det.dart';
import '../../../../models/database_objects/item_visita.dart';
import '../../../../models/database_objects/tabela_precos.dart';
import '../../../../models/database_objects/totais_pedido.dart';
import 'tile_historico_pedido_item.dart';

class TileHistoricoPedido extends StatefulWidget {
  const TileHistoricoPedido({
    Key? key,
    required this.item,
    this.idVisita,
  }) : super(key: key);

  final HistoricoPedido item;
  final int? idVisita;

  @override
  State<TileHistoricoPedido> createState() => _TileHistoricoPedidoState();
}

class _TileHistoricoPedidoState extends State<TileHistoricoPedido> {
  List<HistoricoPedidoDet> list = [];
  late int lastId;

  Map<String, dynamic> totais = {};

  getData() async {
    lastId = widget.item.id;
    final value = await getHistoricoPeidoDetList(widget.item.id);

    final sql =
        'select a.NOME forma, b.NOME as vendedor from TB_FORMA_PAGAMENTO a left join TB_CLIENTE b on b.ID_SYNC = ? where a.ID = ?';

    final db = await DatabaseAmbiente.getDatabase();
    final raw = await db.rawQuery(
      sql,
      [widget.item.idVendedor, widget.item.idFormaPagamento],
    );

    setState(() {
      list = value;
      totais = raw[0];
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getData();
    });
  }

  @override
  void didUpdateWidget(dynamic oldWidget) {
    if (lastId != widget.item.id) {
      getData();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    importar() async {
      if (widget.idVisita == null) {
        return;
      }

      if (!AppAmbiente.of(context).importarValorUnt) {
        await mostrarCaixaConfirmacao(context,
            title: 'Aviso',
            content:
                'O app Vai tentar Recalcular o preço para o valor atual da tabela',
            mostrarCancelar: false);
      }

      final list = await getHistoricoPeidoDetList(widget.item.id);

      int idTabela = await TabelaPreco.getIdTabela(widget.idVisita!);

      final appUser = AppUser.of(context);
      final appAmbiente = AppAmbiente.of(context);

      for (final item in list) {
        final produto = await getProdutoItemVisita(
            idVisita: widget.idVisita!,
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

      TotaisPedido totaisPedido = TotaisPedido(
        widget.idVisita!,
        totalBruto: 0,
        totalLiquido: 0,
        totalDesconto: 0,
        quantidade: 0,
        itens: 0,
        idFormaPagamento: widget.item.idFormaPagamento,
        comNota: false,
      );

      totaisPedido.idVendedor = AppUser.of(context).vendedorAtual;
      totaisPedido.obsNF = widget.item.obsNF ?? '';

      await totaisPedido.salvar();

      Navigator.of(context).pop();
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        childrenPadding: const EdgeInsets.symmetric(horizontal: 8),
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
            mainAxisSize: MainAxisSize.max,
            children: [
              const Flexible(flex: 1, child: IconNormal(CupertinoIcons.clock)),
              const SizedBox(
                width: 8,
              ),
              if (widget.item.data != null)
                Expanded(
                  flex: 6,
                  child: TextNormal(
                    DateFormatter.noramlDataHora.format(widget.item.data!),
                  ),
                ),
              TextTitle(
                TextDinheiroReal.format(widget.item.valorTotal),
              ),
            ],
          ),
          // onPressed: () => importData(item.idVisita),
          // isActive: visita.tabelaConcluida
        ),
        children: [
          const TextNormal('Totais'),
          const SizedBox(
            height: 4,
          ),
          TileSpacedText(
              'Produtos', TextDinheiroReal.format(widget.item.valorProdutos)),
          TileSpacedText(
              'Descontos', TextDinheiroReal.format(widget.item.valorDesconto)),
          TileSpacedText(
              'Total', TextDinheiroReal.format(widget.item.valorTotal)),
          const SizedBox(
            height: 8,
          ),
          TileSpacedText('Forma de Pagamento', totais['forma'] ?? ''),
          if (widget.item.idVendedor != null)
            TileSpacedText('Vendedor', totais['vendedor'] ?? ''),
          const SizedBox(
            height: 8,
          ),
          const Divider(),
          ListView.builder(
            shrinkWrap: true,
            itemCount: list.length,
            physics: const ClampingScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return TileHistoricoPedidoItem(item: list[index]);
            },
          ),
          if ((widget.item.obsNF ?? '').isNotEmpty)
            const TextTitle('Observação da NF'),
          TextNormal(widget.item.obsNF ?? ''),
        ],
      ),
    );
  }
}
