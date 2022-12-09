import 'package:flutter/cupertino.dart';

import 'package:uuid/uuid.dart';

import '../../screens_yk/ambiente/visita/modulo/totais.dart';
import '../../screens_yk/ambiente/visita/modulo/visita.dart';
import '../configuracao/app_ambiente.dart';
import '../database/database_ambiente.dart';
import 'chegada_cliente.dart';
import 'cliente.dart';
import 'dados_entrega.dart';
import 'produtos_list_item.dart';
import 'totais_pedido.dart';
import 'visita.dart';

class Pedido {
  late ModuloVisita moduloVisita;
  late ModuloTotais moduloTotais;
  late Visita visita;
  late double descontoMax;

  DadosEntrega? dadosEntrega;

  late Function update;

  late Cliente cliente;

  //Inicia a tela de pedido
  setup(AppAmbiente appAmbiente) async {
    int idVisita = moduloVisita.id;

    if (moduloVisita.init) {
      ///Muda a situação para edição
      await moduloVisita.abrirVisita();

      /// Insere uma chegada no cliente em caso o módulo esteja desativadado
      if (!appAmbiente.usarChegadaCliente || moduloVisita.faturamento) {
        await ChegadaCliente(idVisita).salvar();
      }

      if (appAmbiente.usarClienteTabela) {
        if (cliente != null) {
          final value = await DatabaseAmbiente.select('TB_CLIENTE',
              where: 'ID_SYNC = ?', whereArgs: [cliente.idSync]);

          int tabela = value[0]['ID_TABELA_PRECO'] ?? appAmbiente.tabelaPadrao;

          moduloVisita.setTabela(tabela);
        }
      } else {
        moduloVisita.setTabela(appAmbiente.tabelaPadrao);
      }

      int? formaPg;

      if (cliente != null) {
        formaPg = cliente.idFormaPg;
      }

      final totaisPedido = TotaisPedido(idVisita,
          totalBruto: 0,
          totalLiquido: 0,
          totalDesconto: 0,
          quantidade: 0,
          itens: 0,
          idFormaPagamento: formaPg,
          comNota: false);

      totaisPedido.idVendedor = moduloVisita.idVendedor;
      totaisPedido.obsNF = '';

      await totaisPedido.salvar();

      final dadosEntregaDummy = await getDadosEntrega(idVisita);

      if (dadosEntregaDummy == null) {
        await insertDadosEntrega(DadosEntrega.dummy(idVisita));
        dadosEntrega = await getDadosEntrega(idVisita);
      }

      // getDadosEntrega(idVisita);

      moduloVisita.setInit(false);
    }
  }

  limparDados() async {
    DatabaseAmbiente.delete('TB_VISITA_CHEGADA',
        where: 'ID_VISITA = ?', whereArgs: [visita.id]);
  }

  Future<dynamic> salvarDados() async {
    abaterEstoque(visita.id);

    await DatabaseAmbiente.update(
        'TB_VISITA', {'SITUACAO': 2, 'UUID': const Uuid().v1()},
        where: 'ID = ?', whereArgs: [visita.id]);
  }

  updateVisita() async {
    //   if (dadosEntrega != null) {
    //     await insertDadosEntrega(dadosEntrega!);
    //   }
    //   // insertTotaisPedido(totai)
    //
    //   visita = await getVisita(visita!.id);
    //
    //   setState(() {});
  }

  static Future<Pedido> getPedido(int idVisita, BuildContext context) async {
    Pedido p = Pedido();

    p.moduloVisita = await ModuloVisita.fromId(idVisita);
    p.visita = await Visita.getVisita(idVisita);
    final appAmbiente = AppAmbiente.of(context);


    p.cliente = (await Cliente.getCliente(p.visita.idPessoa))!;

    await p.setup(appAmbiente);

    p.moduloTotais = await ModuloTotais.fromId(idVisita);

    p.moduloTotais.viewOnly = p.visita.viewOnly();

    if (p.cliente.idFormaPgTipo != null) {
      final bloqueio = await DatabaseAmbiente.select('TB_BLOQUEIO_PG_TIPO',
          where: 'TIPO = ?', whereArgs: [p.cliente.idFormaPgTipo]);
      p.moduloTotais.bloqueio = bloqueio;
    }

    final maps = await DatabaseAmbiente.select('TB_VENDEDOR',
        where: 'ID = ?', whereArgs: [p.moduloVisita.idVendedor]);

    if (maps.isNotEmpty) {
      p.descontoMax = maps[0]['DESCONTO_MAXIMO'];
    }

    return p;
  }
}
