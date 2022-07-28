import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:forca_de_vendas/api/common/formatter/date_time_formatter.dart';
import 'package:forca_de_vendas/api/common/map_reader.dart';
import 'package:forca_de_vendas/yukem_vendas/models/internet/server_route.dart';
import 'package:uuid/uuid.dart';

import '../database/database_ambiente.dart';
import '../database_objects/vendas.dart';
import 'internet.dart';

Future<List<SyncCab>> getSyncCabList() async {
  List<Map<String, dynamic>> maps =
      await DatabaseAmbiente.select('VW_SYNC_CAB');

  return List.generate(maps.length, (index) {
    final mapI = Map.of(maps[index]);

    mapI['A_DATA'] =
        DateFormatter.databaseDateTime.format(DateTime.now()).toString();
    mapI['A_HORA'] =
        DateFormatter.databaseTime.format(DateTime.now()).toString();
    mapI['A_DATA_PREV_ENTREGA'] = DateFormatter.databaseDateTime.format(
        DateFormatter.databaseDataEstranho.parse(mapI['A_DATA_PREV_ENTREGA']));

    MapReader map = MapReader(mapI);

    return SyncCab(
        idCliente: map.integer('A_ID_CLIENTE'),
        idTabela: map.integer('A_ID_TABELA'),
        idFormaPagamento: map.intN('A_ID_CONDICAO_PAGAMENTO') ?? 0,
        idIntegracao: map.value('A_ID_INTEGRACAO'),
        totalPedido: map.dou('A_TOTAL_PEDIDO'),
        valorDesconto: map.dou('A_TOTAL_PEDIDO'),
        observacao: map.value('A_OBSERVACAO'),
        data: map.value('A_DATA'),
        hora: map.value('A_HORA'),
        observacaoEntrega: map.value('A_OBS_ENTREGA'),
        dataPrevEntrega: map.value('A_DATA_PREV_ENTREGA'),
        totalLiquido: map.dou('A_TOTAL_LIQUIDO'),
        valorEntrada: map.dou('A_VALOR_ENTRADA'),
        valorRestante: map.dou('A_VALOR_RESTANTE'),
        idVendedor: map.integer('ID_VENDEDOR'),
        map: mapI);
  });
}

Future<List<SyncDet>> getSyncDetList(int idVisita) async {
  List<Map<String, dynamic>> maps = await DatabaseAmbiente.select('VW_SYNC_DET',
      where: 'ID_VISITA = ?', whereArgs: [idVisita]);

  return List.generate(maps.length, (index) {
    final map = Map.of(maps[index]);
    return SyncDet.fromMap(map);
  });
}

Future<List<Map<String, dynamic>>> getSyncDet(int idVisita) async {
  final List<Map<String, dynamic>> maps = [];

  for (final det in await getSyncDetList(idVisita)) {
    final map = det.toMap();
    map['A_ID_EMPRESA'] = 1;
    maps.add(map);
  }

  return maps;
}

Future<bool> syncVendas(BuildContext context) async {
  List<Map<String, dynamic>> vendas = [];

  List<Map<String, dynamic>> vendasMap = [];

  for (final item in await getSyncCabList()) {
    final cab = item.toMap();
    int idVisita = item.map['ID_VISITA'];

    final det = await getSyncDet(idVisita);
    String uuid = item.idIntegracao ?? const Uuid().v1();

    // cab['idvendedor'] = AppUser.get(context).vendedorAtual;
    cab['uuid'] = uuid;

    vendasMap.add({'uuid': uuid, 'idVisita': idVisita});

    final Map<String, dynamic> venda = {"cab": cab, "det": det};
    vendas.add(venda);
  }

  if (vendas.isEmpty) {
    return true;
  }

  final body = const JsonEncoder().convert(vendas);

  final res = await Internet.serverPost(ServerPath.VENDA,
      body: body, context: context, inputServer: true);

  if (res != null) {
    final Map<String, dynamic> resMap = const JsonDecoder().convert(res.body);

    // final Map<String, dynamic> maps = {};

    // for (final item in resMap) {
    //   maps[item['uuid']] = item['idvenda'];
    // }

    for (final venda in vendasMap) {
      final uuid = venda['uuid'];
      final idVisita = venda['idVisita'];
      int? idSync = int.tryParse(resMap[uuid].toString());
      if (idSync != null && idSync != 0) {
        await DatabaseAmbiente.update('TB_VISITA', {'ID_SYNC': idSync},
            where: ' ID = ?', whereArgs: [idVisita]);
      }
      if (idSync == 0) {
        throw SincronizacaoDesativada;
      }
    }

    return true;
  }

  return false;
}

class SincronizacaoDesativada extends HttpException {
  SincronizacaoDesativada(
      {String message = "Sincronização Desativada Pelo servidor"})
      : super(message);
}
