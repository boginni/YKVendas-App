import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forca_de_vendas/api/common/components/barra_progresso.dart';
import 'package:forca_de_vendas/api/common/custom_widgets/custom_text.dart';
import 'package:forca_de_vendas/yukem_vendas/models/database/database_ambiente.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/base/custom_drawer.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/base/moddel_screen.dart';

class TelaGerarVendas extends ModdelScreen {
  TelaGerarVendas({Key? key}) : super(key: key);

  final qtd = TextEditingController()..text = '10';
  final min = TextEditingController();
  final max = TextEditingController();

  @override
  Widget getCustomScreen(BuildContext context) {
    // TODO: implement getCustomScreen
    return Scaffold(
      appBar: AppBar(
        title: const Text('Testes'),
      ),
      drawer: const CustomDrawer(),
      body: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ListView(
              shrinkWrap: true,
              children: [
                const Center(child: Text('Quandidade de Pedidos')),
                TextField(controller: qtd),
                const SizedBox(
                  height: 12,
                ),
                const Center(child: Text('Produtos')),
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Column(
                        children: [
                          const Text('Min'),
                          TextField(
                            controller: min,
                          )
                        ],
                      ),
                    ),
                    // SizedBox(
                    //   width: 24,
                    // ),

                    Flexible(
                      flex: 1,
                      child: Column(
                        children: [
                          const Text('MaX'),
                          TextField(
                            controller: max,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    final key = mostrarBarraProgressoCircular(context);

                    Future.delayed(const Duration(milliseconds: 100)).then(
                      (value) async {
                        final rng = Random();

                        for (int i = 0; i < int.parse(qtd.text); i++) {
                          final db = await DatabaseAmbiente.getDatabase();

                          final id =
                              (await db.rawQuery(sqlIndex))[0]['ID'] ?? 0;

                          db.execute(sqlVi, [id, rng.nextDouble().toString()]);

                          db.execute(sqlChegada, [id]);

                          db.execute(sqlEntrega, [id]);

                          db.execute(sqlTot, [id]);

                          db.execute(sqlItem,
                              [10, (rng.nextDouble() > 0.8) ? 1 : 0, id, 9, 1]);

                          db.execute(sqlUp, [id]);
                        }

                        key.currentState!.finish();
                      },
                    );
                  },
                  child: const TextNormal('Gerar'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const sqlIndex = "SELECT max(ID) + 1 AS ID FROM TB_VISITA;";

const sqlVi =
    "INSERT INTO TB_VISITA ( ID, INIT, SYNC, STATUS, TIPO, CRIACAO, SITUACAO, UUID, ID_TABELA, ID_ROTA, ID_CLIENTE_SYNC, ID_VENDEDOR, ID_CLIENTE, ID_SYNC ) "
    "VALUES (?, 0, 0, 1, 0, '2022-07-31 02:49:49', 2, ?, 2, 0, null, 4502, (SELECT ID FROM TB_CLIENTE ORDER BY RANDOM() LIMIT 1), NULL )";

const sqlTot =
    "INSERT INTO TB_VISITA_TOTAIS ( COM_NOTA, VALOR_ENTRADA, ID_VENDEDOR, DESCONTO_VALOR, DESCONTO_PORCENTAGEM, DATA_ENVIO, ID_ASSINATURA, OBSERVACAO_NF, ID_FORMA_PAGAMENTO, ID_VISITA ) VALUES ( 0, 0, 4502, 0, 0, '2022-07-31 02:49:49', 0, '', 3, ? );";

const sqlItem = "INSERT INTO TB_VISITA_ITEM "
    "( DESCONTO_VALOR, ALTERACAO_VALOR, VALOR_UNITARIO, STATUS, QUANTIDADE, BRINDE, ID_PRODUTO, ID_VISITA )"
    "select 0 , 0, a.VALOR_VENDA, 1, (SELECT abs(random() % ?)), ?, a.ID, ? from TB_PRODUTO a inner join (SELECT ID FROM TB_PRODUTO ORDER BY RANDOM() LIMIT (SELECT abs(random() % ?) + ?)) b on b.ID = A.ID ;";

const sqlEntrega =
    "INSERT INTO TB_VISITA_ENTREGA ( DATA_ENVIO,  OBSERVACAO,  DETALHE,  RESTRICAO,  DATA,  ID_VISITA ) VALUES ( '2022-07-31 03:39:40',  '',  '',  0,  '2022-07-31 03:39:40',  ? )";

const sqlChegada =
    "INSERT INTO TB_VISITA_CHEGADA (DATA_ENVIO, DATA, ID_VISITA)VALUES ('2022-07-31 03:39:40', '2022-07-31 03:39:40', ?);";

const sqlUp = "UPDATE TB_VISITA SET SITUACAO = 2 WHERE ID = ?;";
