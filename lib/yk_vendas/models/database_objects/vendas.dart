import 'package:flutter/material.dart';

import '../../../api/common/debugger.dart';
import '../../../api/common/formatter/date_time_formatter.dart';
import '../../../api/models/database_objects/query_filter.dart';
import '../database/database_ambiente.dart';

class Venda {
  static const dbIdVisita = "ID_VISITA";
  static const dbIdPessoa = "ID_PESSOA";
  static const dbIdRota = "ID_ROTA";
  static const dbNome = "NOME";
  static const dbNomeRota = "NOME_ROTA";
  static const dbTotalLiq = "TOTAL_LIQ";
  static const dbTotalBruto = "TOTAL_BRUTO";
  static const dbData = "DATA";

  static createObject(Map<String, dynamic> maps) {
    try {
      final x = Venda(maps[dbIdVisita],
          data: parseStringToDateTime(maps[dbData]),
          nomeCliete: maps[dbNome],
          totalLiq: maps[dbTotalLiq].toDouble(),
          totalBruto: maps[dbTotalBruto].toDouble(),
          idpessoa: maps[dbIdPessoa],
          idRota: maps[dbIdRota],
          nomeRota: maps[dbNomeRota]);

      return x;
    } catch (e) {
      printDebug(e.toString());
      return null;
    }
  }

  String getData() {
    return DateFormatter.normalData.format(data);
  }

  String getHorario() {
    return DateFormatter.normalHoraMinuto.format(data);
  }

  final int idVisita;
  final int idRota;
  final int idpessoa;

  const Venda(
    this.idVisita, {
    required this.idRota,
    required this.idpessoa,
    required this.nomeCliete,
    required this.totalLiq,
    required this.data,
    required this.totalBruto,
    required this.nomeRota,
  });

  final String nomeCliete;
  final double totalLiq;
  final double totalBruto;
  final DateTime data;
  final String nomeRota;
}

/// Pega a lista de [VW_VENDAS] do banco
Future<List<Venda>> getListVendas({QueryFilter? queryFilter}) async {
  List<Venda> x = [];

  try {
    late final List<Map<String, dynamic>> maps;

    if (queryFilter == null) {
      maps = await DatabaseAmbiente.select('VW_VENDAS');
    } else {
      maps = await DatabaseAmbiente.select('VW_VENDAS',
          where: queryFilter.getWhere(), whereArgs: queryFilter.getArgs());
    }

    x = List.generate(maps.length, (i) {
      return Venda.createObject(maps[i]);
    });
  } catch (e) {
    printDebug(e.toString());

  }

  return x;
}

// bool _bool(int b) {
//   return b == 1 ? true : false;
// }

class SyncCab {
  final int idCliente;
  final int idTabela;
  final int idFormaPagamento;
  final int idVendedor;

  final String? idIntegracao;

  final double totalPedido;
  final double valorDesconto;

  final String observacao;

  final String data;
  final String hora;

  final String observacaoEntrega;
  final String dataPrevEntrega;

  final double totalLiquido;
  final double valorEntrada;
  final double valorRestante;

  Map<String, dynamic> map;

  SyncCab({
    required this.idCliente,
    required this.idTabela,
    required this.idFormaPagamento,
    required this.idIntegracao,
    required this.totalPedido,
    required this.valorDesconto,
    required this.observacao,
    required this.data,
    required this.hora,
    required this.observacaoEntrega,
    required this.dataPrevEntrega,
    required this.totalLiquido,
    required this.valorEntrada,
    required this.valorRestante,
    required this.idVendedor,
    required this.map,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> maps = {
      'idempresa': 1,
      'idcliente': idCliente,
      'idvendedor': idVendedor, // A_ID_USUARIO
      'idtabela': idTabela,
      'idformaPagamento': idFormaPagamento,
      'idintegracao': idIntegracao,
      'totalpedido': totalPedido,
      'valordesconto': valorDesconto,
      'observacao': observacao,
      'data': data,
      'hora': hora,
      'observacaoentrega': observacaoEntrega,
      'datapreventrega': dataPrevEntrega,
      'totalliquido': totalLiquido,
      'valorentrada': valorEntrada,
      'valorrestante': valorRestante,
    };

    return maps;
  }
}

class SyncDet {
  int idVisita;
  String? idIntegracao;
  int idEmpresa;
  int idProduto;
  int idVendedor;
  double quantidade;
  double valorUnitario;
  double valorTotal;
  double valorDesconto;
  String obs;
  String brinde;

  SyncDet(
      {required this.idVisita,
      required this.idIntegracao,
      required this.idEmpresa,
      required this.idProduto,
      required this.idVendedor,
      required this.quantidade,
      required this.valorUnitario,
      required this.valorTotal,
      required this.valorDesconto,
      required this.obs,
      required this.brinde});

  factory SyncDet.fromMap(Map<String, dynamic> map) {
    dynamic value(String x) {
      final y = map[x];
      return y;
    }

    double dou(String x) {
      return double.parse(value(x).toString());
    }

    bool brinde = value('A_BRINDE') == 1;

    return SyncDet(
        idVisita: value('ID_VISITA'),
        idIntegracao: value('ID_INTEGRACAO'),
        idEmpresa: value('ID_EMPRESA'),
        idProduto: value('ID_PRODUTO'),
        idVendedor: value('ID_VENDEDOR'),
        quantidade: dou('QUANTIDADE'),
        valorUnitario: brinde ? 0 : dou('VALOR_UNITARIO'),
        valorTotal: brinde ? 0 : dou('VALOR_TOTAL'),
        valorDesconto: brinde ? 0 : dou('VALOR_DESCONTO'),
        obs: value('OBSERVACAO'),
        brinde: brinde ? 'T' : 'F');
  }

  Map<String, dynamic> toMap() {
    return {
      'ID_VISITA': idVisita,
      'ID_INTEGRACAO': idIntegracao,
      'ID_EMPRESA': idEmpresa,
      'ID_PRODUTO': idProduto,
      'ID_VENDEDOR': idVendedor,
      'QUANTIDADE': quantidade,
      'VALOR_UNITARIO': valorUnitario,
      'VALOR_TOTAL': valorTotal,
      'VALOR_DESCONTO': valorDesconto,
      'OBSERVACAO': obs,
      'A_BRINDE': brinde,
    };
  }
}
