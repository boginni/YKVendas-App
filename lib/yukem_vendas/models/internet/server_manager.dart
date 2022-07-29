import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../../../api/common/custom_widgets/custom_text.dart';
import '../../../api/common/debugger.dart';
import '../../../api/models/system_database/system_database.dart';
import 'internet.dart';

Future<List<Map<String, dynamic>>> getServidoresInternet(
    String ambiente) async {
  try {
    final res = await Internet.getServers(ambiente);

    List<dynamic> list = const JsonDecoder().convert(res!.body);

    return List.generate(
        list.length, (index) => list[index] as Map<String, dynamic>);
  } on FormatException {
    rethrow;
  } catch (e) {
    printDebug(e.toString());
    return [];
  }
}

Future<bool> addServidores(String ambiente) async {
  try {
    for (final item in await getServidoresInternet(ambiente)) {
      await DatabaseSystem.insert('TB_SERVIDOR', item,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    final list = await getServidoresDatabase();

    if (list.isNotEmpty) {
      final item = Map.of(list[0]);
      item['LAST_SERVER'] = 1;
      await DatabaseSystem.insert('TB_SERVIDOR', item,
          conflictAlgorithm: ConflictAlgorithm.replace);

      Internet.setURl(item['SERVIDOR'], item['PORTA']);
    }

    return true;
  } catch (e) {
    return false;
  }
}

Future<List<Map<String, dynamic>>> getServidoresDatabase() async {
  try {
    final db = await DatabaseSystem.getDatabase();
    final list = await db.query('TB_SERVIDOR',
        where: 'TIPO = ?', whereArgs: ['E'], limit: 1);
    return list;
  } catch (e) {
    printDebug(e.toString());
    return [];
  }
}

class CurrentServer {
  static Future<String> getServerApelido() async {
    List<Map<String, dynamic>> res = await DatabaseSystem.select('TB_SERVIDOR',
        where: 'LAST_SERVER = ?', whereArgs: [1]);
    if (res.isEmpty) {
      return '';
    }

    final item = res[0];

    Internet.setURl(item['SERVIDOR'], item['PORTA']);
    return item['APELIDO'] ?? '';
  }

  bool error = false;
  bool serverEmpty = false;
  bool isloading = true;

  static Future<CurrentServer> getServer() async {
    final currentServer = CurrentServer();

    currentServer.isloading = true;
    // 'Carregando';

    String srv = await getServerApelido();

    currentServer.isloading = false;
    currentServer.serverEmpty = srv.isEmpty;

    if (currentServer.serverEmpty) {
      srv = 'Servidor não selecionado';
      currentServer.error = true;
    }

    currentServer.apelido = srv;

    return currentServer;
  }

  String apelido = "";

  Widget getWidget() {
    Color? color = error ? Colors.red : null;

    return TextTitle(
      apelido,
      color: color,
    );
  }
}
