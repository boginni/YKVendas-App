import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:forca_de_vendas/yukem_vendas/models/file/file_manager.dart';
import 'package:forca_de_vendas/yukem_vendas/models/internet/server_route.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/sync/sync_loader.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/sync/sync_request.dart';
import 'package:sqflite/sqflite.dart';

import '../configuracao/app_user.dart';
import '../database/database_ambiente.dart';
import 'internet.dart';

final views = [
  {"vw": 'MOB_VW_TITULO_ABERTO_ROTA', "tb": 'TB_TITULOS_ABERTO'},
  {"vw": 'MOB_VW_HISTORICO_CAB_ROTA', "tb": 'TB_HISTORICO_PEDIDO'},
  {"vw": 'MOB_VW_HISTORICO_DET_ROTA', "tb": 'TB_HISTORICO_PEDIDO_DET'}
];

Future<void> syncRota(BuildContext context) async {
  final appUser = AppUser.of(context);

  final downloader = SyncRequest(SyncRequest.emptyListener);
  downloader.fullRotas();

  await downloader.download(appUser, onFinished: (err) async {
    if (err != null) {
      return;
    }

    final loader = SyncLoader(SyncLoader.emptyListener,
        await FilePath.getSyncFilePath(appUser.ambiente));

    loader.unPack();
    await loader.syncAll();

  });

  // for (final item in views) {
  //   final vw = item['vw'];
  //   final tb = item['tb'];
  //
  //   final body = {
  //     "tb": vw,
  //     "data": false,
  //     "rota": 0,
  //     "vendedor": appUser.vendedorAtual
  //   };
  //
  //   try {
  //     dynamic res = await getData(headers, body);
  //     if (res.runtimeType != List && res['error'] != null) {
  //       throw Exception('Erro ao coletar dados: ${res['error']}');
  //     }
  //     res = _toMaps(res);
  //     await save(tb!, res, 0);
  //   } catch (e) {
  //     printDebug(e);
  //     throw Exception('Erro ao coletar dados: ${e.runtimeType}');
  //   }
  // }
}

Future<void> save(
    String tb, List<Map<String, dynamic>> maps, int idRota) async {
  await DatabaseAmbiente.delete(tb);

  await DatabaseAmbiente.insertAll(tb, maps,
      conflictAlgorithm: ConflictAlgorithm.replace);
}

Future<dynamic> getData(
    Map<String, String> headers, Map<String, dynamic> body) async {
  final value = await Internet.serverPost2(ServerPath.VIEW_DOWNLOAD,
      body: body, headers: headers);

  if (value != null) {
    final response = const JsonDecoder().convert(value.body);
    return response;
  }
}

List<Map<String, dynamic>> _toMaps(List<dynamic> res) {
  return List.generate(res.length, (index) {
    final map = res[index] as Map<String, dynamic>;

    Map<String, dynamic> result = {};

    map.forEach((key, value) {
      if (key != 'RT_VENDEDOR' &&
          key != 'RT_ROTA' &&
          key != 'ID_EMPRESA' &&
          key != 'DATA_LAST_UPDATE') {
        result[key] = value;
      }
    });

    return result;
  });
}
