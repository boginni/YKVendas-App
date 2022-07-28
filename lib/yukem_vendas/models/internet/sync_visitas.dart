import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:forca_de_vendas/yukem_vendas/models/internet/server_route.dart';

import '../database/database_ambiente.dart';
import 'internet.dart';

Future<bool> syncVisitas(BuildContext context) async {

  List<Map<String, dynamic>> maps =
      await DatabaseAmbiente.select('VW_SYNC_VISITA');

  final body = const JsonEncoder().convert(maps);

  final res = await Internet.serverPost(ServerPath.VISITA, body: body, context: context, inputServer: true);

  for (var id in const JsonDecoder().convert(res.body)) {
    await DatabaseAmbiente.update('TB_VISITA', {'SYNC': 1},
        whereArgs: [id], where: 'UUID = ?');
  }

  return true;
}
