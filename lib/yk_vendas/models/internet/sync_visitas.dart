import 'dart:convert';

import 'package:flutter/cupertino.dart';

import '../database/database_ambiente.dart';
import 'internet.dart';
import 'server_route.dart';

Future<bool> syncVisitas(BuildContext context) async {
  List<Map<String, dynamic>> maps =
      await DatabaseAmbiente.select('VW_SYNC_VISITA');

  if (maps.isEmpty) {
    return true;
  }

  final body = const JsonEncoder().convert(maps);

  final res = await Internet.serverPost(ServerPath.VISITA,
      body: body, context: context);

  for (var id in const JsonDecoder().convert(res.body)) {
    await DatabaseAmbiente.update('TB_VISITA', {'SYNC': 1},
        whereArgs: [id], where: 'UUID = ?');
  }

  return true;
}
