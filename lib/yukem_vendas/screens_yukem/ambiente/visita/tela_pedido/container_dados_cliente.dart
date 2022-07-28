import 'package:flutter/material.dart';
import 'package:forca_de_vendas/api/common/components/list_scrollable.dart';
import 'package:forca_de_vendas/api/common/custom_tiles/default_tiles/tile_spaced_text.dart';
import 'package:forca_de_vendas/api/common/custom_widgets/custom_text.dart';
import 'package:forca_de_vendas/api/helpers/brasil_formatter.dart';
import 'package:forca_de_vendas/yukem_vendas/models/configuracao/app_ambiente.dart';
import 'package:forca_de_vendas/yukem_vendas/models/database_objects/cliente.dart';
import 'package:forca_de_vendas/yukem_vendas/models/database_objects/visita.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/clientes/tela_buscar_cliente.dart';

import '../../../../models/database/database_ambiente.dart';
import '../../../../models/database_objects/contato.dart';
import '../../../../models/database_objects/pedido.dart';

class ContainerDadosCliente extends StatelessWidget {
  final int idVisita;

  final Pedido pedido;

  ContainerDadosCliente({
    Key? key,
    required this.idVisita,
    required this.pedido,
    required this.update,
  }) : super(key: key);

  List<Contato> listContato = [];
  final Function update;

  @override
  Widget build(BuildContext context) {
    final appAmbiente = AppAmbiente.of(context);

    _getCliente() async {
      List<Map<String, dynamic>> maps = await DatabaseAmbiente.select(
          'TB_VISITA',
          where: 'ID = ?',
          whereArgs: [idVisita]);

      int? idPessoa = maps[0]['ID_CLIENTE'];

      if (idPessoa != null) {
        return await Cliente.getCliente(idPessoa);
      }

      return null;
    }

    return FutureBuilder(
      future: _getCliente(),
      builder: (BuildContext context, AsyncSnapshot<Cliente?> snapshot) {
        String title = 'Dados do cliente';

        Widget info = Column();

        if (snapshot.data != null) {
          Cliente cliente = snapshot.data!;
          title = cliente.nome ?? '';

          info = Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: ListViewNested(
              children: [
                const TextTitle('Informações básicas'),
                TileSpacedText('Apelido', cliente.apelido ?? ''),
                TileSpacedText('Nome', cliente.nome ?? ''),
                TileSpacedText('CPF/CNPJ', formatCpfCnpj(cliente.cpfcnpj)),

                // TextTitle('Contato'),

                // TextNormal(
                //     (cliente.dddTelefone ?? '') + ' ' + (cliente.telefone ?? '')),

                // TextNormal(
                //     (cliente.dddCelular ?? '') + ' ' + (cliente.celular ?? '')),

                // TextNormal(cliente.email ?? ''),

                // TextNormal(cliente.whatsapp ?? ''),

                const TextTitle('Endereço'),
                TileSpacedText('Logradouro', cliente.logradouro ?? ''),
                TileSpacedText(
                    'Complemento', cliente.complementoLogadouro ?? ''),
                TileSpacedText('Bairro', cliente.bairro ?? ''),
                TileSpacedText('Cidade', pedido.visita.cidade),
                const TextTitle('Contato'),
                FutureBuilder(
                  future: getContatos(pedido.visita.idPessoaSync),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Contato>?> snapshot) {
                    if (snapshot.data != null) {
                      listContato = snapshot.data!;
                    }

                    return ListView.builder(
                        physics: const ClampingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: listContato.length,
                        itemBuilder: (context, index) {
                          final item = listContato[index];
                          return TileSpacedText(item.tipo,
                              "${item.ddd.replaceAll(' ', '')} ${item.contato}");
                        });
                  },
                )
              ],
            ),
          );
        }

        return Card(
          child: ExpansionTile(
            title: TextButton(
              child: TextTitle(title),
              onPressed: () {
                if (pedido.visita.faturamento &&
                    !appAmbiente.usarFaturamentoComoOrcamento) {
                  Navigator.of(context).pushNamed(TelaBuscarCliente.routeName,
                      arguments: [
                        AppAmbiente.of(context).todosClientesFaturamento &&
                            pedido.visita.faturamento
                      ]).then((value) async {
                    if (value != null) {
                      final cli = (await Cliente.getCliente((value as int),
                          sync: false))!;

                      // printDebug('forma pg imp ${cli.idFormaPg}');

                      pedido.moduloTotais.setFormaPagamento(cli.idFormaPg);

                      await DatabaseAmbiente.update(
                          'TB_VISITA', {'ID_CLIENTE': value},
                          where: 'ID = ?', whereArgs: [pedido.visita.id]);

                      await DatabaseAmbiente.update('TB_VISITA_TOTAIS',
                          {'ID_FORMA_PAGAMENTO': cli.idFormaPg},
                          where: 'ID_VISITA = ?',
                          whereArgs: [pedido.visita.id]);

                      pedido.cliente = cli;

                      update();
                    }
                  });
                }
              },
            ),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 12),
                child: info,
              )
            ],
            expandedAlignment: Alignment.topLeft,
          ),
        );
      },
    );
  }
}

class ContainerDadosClienteOld extends StatelessWidget {
  final int idVisita;

  final Visita visita;

  ContainerDadosClienteOld({
    Key? key,
    required this.idVisita,
    required this.visita,
    required this.update,
  }) : super(key: key);

  List<Contato> listContato = [];
  final Function update;

  @override
  Widget build(BuildContext context) {
    final appAmbiente = AppAmbiente.of(context);

    _getCliente() async {
      List<Map<String, dynamic>> maps = await DatabaseAmbiente.select(
          'TB_VISITA',
          where: 'ID = ?',
          whereArgs: [idVisita]);

      int? idPessoa = maps[0]['ID_CLIENTE'];

      if (idPessoa != null) {
        return await Cliente.getCliente(idPessoa);
      }

      return null;
    }

    return FutureBuilder(
      future: _getCliente(),
      builder: (BuildContext context, AsyncSnapshot<Cliente?> snapshot) {
        String title = 'Dados do cliente';

        Widget info = Column();

        if (snapshot.data != null) {
          Cliente cliente = snapshot.data!;
          title = cliente.nome ?? '';

          info = Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: ListViewNested(
              children: [
                const TextTitle('Informações básicas'),
                TileSpacedText('Apelido', cliente.apelido ?? ''),
                TileSpacedText('Nome', cliente.nome ?? ''),
                TileSpacedText('CPF/CNPJ', formatCpfCnpj(cliente.cpfcnpj)),

                // TextTitle('Contato'),

                // TextNormal(
                //     (cliente.dddTelefone ?? '') + ' ' + (cliente.telefone ?? '')),

                // TextNormal(
                //     (cliente.dddCelular ?? '') + ' ' + (cliente.celular ?? '')),

                // TextNormal(cliente.email ?? ''),

                // TextNormal(cliente.whatsapp ?? ''),

                const TextTitle('Endereço'),
                TileSpacedText('Logradouro', cliente.logradouro ?? ''),
                TileSpacedText(
                    'Complemento', cliente.complementoLogadouro ?? ''),
                TileSpacedText('Bairro', cliente.bairro ?? ''),
                TileSpacedText('Cidade', visita.cidade),
                const TextTitle('Contato'),
                FutureBuilder(
                  future: getContatos(visita.idPessoaSync),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Contato>?> snapshot) {
                    if (snapshot.data != null) {
                      listContato = snapshot.data!;
                    }

                    return ListView.builder(
                        physics: const ClampingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: listContato.length,
                        itemBuilder: (context, index) {
                          final item = listContato[index];
                          return TileSpacedText(item.tipo,
                              "${item.ddd.replaceAll(' ', '')} ${item.contato}");
                        });
                  },
                )
              ],
            ),
          );
        }

        return Card(
          child: ExpansionTile(
            title: TextButton(
              child: TextTitle(title),
              onPressed: () {},
            ),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 12),
                child: info,
              )
            ],
            expandedAlignment: Alignment.topLeft,
          ),
        );
      },
    );
  }
}
