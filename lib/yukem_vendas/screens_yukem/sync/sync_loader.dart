import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:forca_de_vendas/api/common/formatter/date_time_formatter.dart';

import '../../../api/common/debugger.dart';
import '../../models/database/database_ambiente.dart';

class SyncLoader {
  static final _EmptyListener emptyListener = _EmptyListener();

  final String filePath;
  final SyncLoaderListener listener;

  SyncLoader(this.listener, this.filePath);

  bool unpacking = true;

  int _totalViews = 0;
  String data = '';

  Map<String, dynamic> _normalViews = {};
  Map<String, dynamic> _rotaViews = {};

  SyncLoader unPack() {
    final syncFile = File(filePath);

    if (!syncFile.existsSync()) {
      throw Exception('Arquivo de syncronização não existe');
    }

    List<int>? unpacked = GZipCodec().decode(syncFile.readAsBytesSync());

    final data = const JsonDecoder()
        .convert(utf8.decode(unpacked, allowMalformed: true));
    unpacked = null;

    this.data = data['time'];
    final rawViews = data['views'];

    _normalViews = rawViews['normal'] as Map<String, dynamic>;
    _rotaViews = rawViews['rota'] as Map<String, dynamic>;

    _totalViews = _normalViews.keys.length + _rotaViews.keys.length;

    unpacking = false;

    return this;
  }

  syncAll() async {
    if (kDebugMode) {
      printDebug('sincronizando');
    }

    int i = 0;

    final Map<String, List<String>> tables = {};

    for (var element in (await DatabaseAmbiente.select('CONF_TABLE_VIEW'))) {
      tables[element['VIEW']] = [element['TABLE'], element['APELIDO']];
    }

    String time =
        DateFormatter.databaseDateTime.format(DateTime.parse(data));

    for (final key in _normalViews.keys) {

      final view = _normalViews[key];


      listener.onProgress(tables[key]![1], i++, _totalViews);
      await _loadContent(tables[key]![0], view, filter: ['DATA_LAST_UPDATE']);
      await DatabaseAmbiente.update(
        'CONF_IMP_TABLES',
        {
          'DATA_LAST_UPDATE': time,
          'IND_IMPORTACAO': 0,
          'IMPORTADO': 1,
        },
        where: 'NOME_TABELA = ?',
        whereArgs: [tables[key]![0]],
      );
    }

    // await DatabaseAmbiente.execute(
    //     'UPDATE CONF_IMP_TABLES set IMPORTADO = REIMPORTAR * -1 + 1');

    for (final key in _rotaViews.keys) {

      final view = _rotaViews[key];
      listener.onProgress(tables[key]![1], i++, _totalViews);
      await _loadContent(tables[key]![0], view,
          clearTable: true,
          filter: ['ID_EMPRESA', 'RT_ROTA', 'RT_VENDEDOR', 'DATA_LAST_UPDATE']);
    }

      printDebug('finalizado');


    listener.onProgress('Finalizando...', _totalViews, _totalViews);

    final file = File(filePath);

    await file.delete();
  }

  _loadContent(table, view,
      {bool clearTable = false, List<String> filter = const []}) async {
    final columns = (view['columns'] as List<dynamic>);
    final rows = view['rows'] as List<dynamic>;

    final List<Map<String, dynamic>> maps = [];
    for (final row in rows) {
      final Map<String, dynamic> map = {};

      for (int i = 0; i < columns.length; i++) {
        final colum = columns[i];
        if (filter.where((element) => element == colum).isNotEmpty) {
          continue;
        }

        map[colum] = row[i];
      }

      maps.add(map);
    }

    if (clearTable) {
      DatabaseAmbiente.delete(table, where: '1 = ?', whereArgs: [1]);
    }

    await DatabaseAmbiente.insertAll(table, maps);
  }
}

abstract class SyncLoaderListener {
  onProgress(String table, int currentProgress, int total);

  onError(Object e);
}

class _EmptyListener implements SyncLoaderListener {
  @override
  onError(Object e) {}

  @override
  onProgress(String table, int currentProgress, int total) {}
}
