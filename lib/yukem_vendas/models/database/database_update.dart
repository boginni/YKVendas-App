import 'package:forca_de_vendas/api/models/system_database/system_database.dart';
import 'package:forca_de_vendas/yukem_vendas/models/database/database_ambiente.dart';
import 'package:forca_de_vendas/yukem_vendas/models/database/db_backup.dart';
import 'package:sqflite/sqflite.dart';

import '../../../api/common/debugger.dart';

String appVersion = '0.4.38c';
String dbAmbiente = '0.4.38 - 003';
String dbSystem = '0.4.33 - 001';

class OperacaoCancelada implements Exception {}

Future<bool> updateAmbienteDatabase(
    {required Future<bool> Function() onSaveData}) async {
  String dbVersion = '';

  try {
    final maps = await DatabaseAmbiente.select('SYS_DB_INFO');
    dbVersion = maps[0]['VERSION'];
  } catch (e) {}

  bool check = (dbVersion == dbAmbiente);

  // printDebug("$dbVersion  $curVersion");
  // printDebug(check);

  if (!check) {
    bool hasVendas = (await DatabaseAmbiente.select('VW_SYNC_CAB')).isNotEmpty;

    if (hasVendas && !(await onSaveData())) {
      throw OperacaoCancelada();
    }

    printDebug('Update ambiente database version $dbVersion to $dbAmbiente');

    try {
      await DatabaseBackup.createBackup();
    } catch (e) {
      return false;
    }

    final db = await DatabaseAmbiente.getDatabase();
    await db.close();

    await databaseFactory.deleteDatabase(db.path);
    await DatabaseAmbiente.update('SYS_DB_INFO', {'VERSION': dbAmbiente});

    return true;
  }

  return false;
}

Future<bool> updateSysDatabase() async {
  String dbVersion = '';

  try {
    final maps = await DatabaseSystem.select('SYS_DB_INFO');
    dbVersion = maps[0]['VERSION'];
  } catch (e) {}

  bool check = (dbVersion == dbSystem);
  if (!check) {
    printDebug('Update system database version $dbVersion to $dbSystem');

    final db = await DatabaseSystem.getDatabase();
    await db.close();
    await databaseFactory.deleteDatabase(db.path);

    await DatabaseSystem.update('SYS_DB_INFO', {'VERSION': dbSystem});
  }

  return true;
}
