import 'dart:convert';

import 'package:flutter/cupertino.dart';

import '../../../api/common/debugger.dart';
import '../../../api/models/database_objects/query_filter.dart';
import '../database/database_ambiente.dart';
import '../internet/internet.dart';
import '../internet/server_route.dart';

// ID	ID_CLIENTE	ID_VENDEDOR	DATA_EMISSAO	VALOR_PRODUTOS	VALOR_DESCONTO	VALOR_TOTAL

class HistoricoPedido {
  final int id;
  final int? idCliente;
  final int? idVendedor;
  final int? idFormaPagamento;
  final String dataEmissao;
  final double valorProdutos;
  final double valorDesconto;
  final double valorTotal;

  late final DateTime? data;

  String? obsNF;

  HistoricoPedido(
      {required this.id,
      required this.idCliente,
      required this.idVendedor,
      required this.idFormaPagamento,
      required this.obsNF,
      required this.dataEmissao,
      required this.valorProdutos,
      required this.valorDesconto,
      required this.valorTotal}) {
    try {
      data = DateTime.parse(dataEmissao);
    } catch (e) {
      data = null;
    }
  }

  factory HistoricoPedido.fromMap(Map<String, dynamic> map) {
    value(String x) {
      return map[x];
    }

    return HistoricoPedido(
        id: value('ID'),
        idCliente: value('ID_CLIENTE'),
        idVendedor: value('ID_VENDEDOR'),
        idFormaPagamento: value('ID_FORMA_PAGAMENTO'),
        obsNF: value('OBS_NF'),
        dataEmissao: value('DATA_EMISSAO') ?? '',
        valorProdutos: value('VALOR_PRODUTOS'),
        valorDesconto: value('VALOR_DESCONTO'),
        valorTotal: value('VALOR_TOTAL'));
  }
}

/// Pega a lista de [VW_VENDAS] do banco
Future<List<HistoricoPedido>> getHistPedidos({QueryFilter? queryFilter}) async {
  List<HistoricoPedido> x = [];

  try {
    late final List<Map<String, dynamic>> maps;

    if (queryFilter == null) {
      maps = await DatabaseAmbiente.select('TB_HISTORICO_PEDIDO',
          orderBy: 'ID DESC');
    } else {
      maps = await DatabaseAmbiente.select('TB_HISTORICO_PEDIDO',
          where: queryFilter.getWhere(),
          whereArgs: queryFilter.getArgs(),
          orderBy: 'ID DESC');
    }

    x = List.generate(maps.length, (i) {
      return HistoricoPedido.fromMap(maps[i]);
    });
  } catch (e) {
    printDebug(e.toString());

  }

  return x;
}

Future<bool> syncHostorico(List<int> pessoas, BuildContext context,
    {bool completo = true}) async {
  final body = {
    "pessoas": pessoas,
    "data": "01.01.2022",
    "filtrar_data": false,
    'completo': completo,
  };

  final value =
      await Internet.serverPost(ServerPath.HISTORICO, body: body, context: context);

  if (value != null) {
    final response = const JsonDecoder().convert(value.body);
    if (response['cab'] != null && response['det'] != null) {
      List<Map<String, dynamic>> mapsCab = [];
      List<Map<String, dynamic>> mapsDet = [];

      for (final map in response['cab']) {
        mapsCab.add(map);
      }

      for (final map in response['det']) {
        mapsDet.add(map);
      }

      await DatabaseAmbiente.insertAll('TB_HISTORICO_PEDIDO', mapsCab);

      await DatabaseAmbiente.insertAll('TB_HISTORICO_PEDIDO_DET', mapsDet);

      return true;
    }
  }

  return false;
}
