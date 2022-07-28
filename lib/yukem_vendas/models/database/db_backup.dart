import 'dart:convert';
import 'dart:io';

import 'package:forca_de_vendas/yukem_vendas/models/database/database_ambiente.dart';
import 'package:forca_de_vendas/yukem_vendas/models/file/file_manager.dart';

class DatabaseBackup {
  // List<Map<String, dynamic>> tb_visita;
  // List<Map<String, dynamic>> tb_visita_cancelamento;
  // List<Map<String, dynamic>> tb_visita_chegada;
  // List<Map<String, dynamic>> tb_visita_entrega;
  // List<Map<String, dynamic>> tb_visita_item;
  // List<Map<String, dynamic>> tb_visita_totais;

  late Map<String, List<Map<String, dynamic>>> data = {};

  static String ambiente = 'live';

  static List<String> tables = [
    'TB_VISITA',
    'TB_VISITA_CANCELAMENTO',
    'TB_VISITA_CHEGADA',
    'TB_VISITA_ENTREGA',
    'TB_VISITA_ITEM',
    'TB_VISITA_TOTAIS'
  ];

  // TB_VISITA;
  // TB_VISITA_CANCELAMENTO;
  // TB_VISITA_CHEGADA;
  // TB_VISITA_ENTREGA;
  // TB_VISITA_ITEM;
  // TB_VISITA_TOTAIS;

  static createBackup() async {
    DatabaseBackup b = DatabaseBackup();

    const join = "INNER JOIN TB_VISITA VI ON X.ID_VISITA = VI.ID ";
    const where = " WHERE VI.ID_SYNC IS NULL AND VI.SITUACAO = 2 ";

    for (final table in tables) {
      String sql = "";
      if (table == 'TB_VISITA') {
        sql = "SELECT * FROM TB_VISITA VI $where";
      } else {
        sql = "SELECT X.* FROM $table X $join $where";
      }

      final db = await DatabaseAmbiente.getDatabase();

      b.data[table] = await db.rawQuery(sql);
    }

    final filePath = await FilePath.getBackupPedidos(ambiente);
    // final file = await File(filePath);
    // if (!file.existsSync()) {
    //   file.createSync(recursive: true);
    // }
    // await file.writeAsBytes());

    FileManager.writeFile(filePath, const JsonEncoder().convert(b.data),
        utfEncode: true);
  }

  static Future restoreBackup() async {
    final filePath = await FilePath.getBackupPedidos(ambiente);
    final file = File(filePath);

    if (await file.exists()) {
      final js = const JsonDecoder()
          .convert(utf8.decode(file.readAsBytesSync())) as Map<String, dynamic>;

      for (final table in tables) {
        final data = js[table] as List<dynamic>;

        for (Map<String, dynamic> row in data) {
          await DatabaseAmbiente.insert(table, row);
        }
      }

      await file.delete();
    }
  }
}
