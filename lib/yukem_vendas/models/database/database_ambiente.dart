import 'package:forca_de_vendas/api/common/formatter/date_time_formatter.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../../api/common/debugger.dart';
import '../../../api/models/database_objects/database_manager.dart';

abstract class DatabaseAmbiente {
  /// Usado para dizer qual é a vesão atual do banco de dados
  static const int version = 16;

  static String? dbPath;
  static String? dbName;

  static Database? _db;

  /// Abre a database
  static Future<Database> getDatabase() async {
    // dbName ??= 'banco.db';

    dbName ??= 'live5';
    dbPath ??= await getDatabasesPath() + '/ambientes/';

    if (checkDbExists(dbPath!, dbName! + '.db')) {
      await copyDatabase(join(dbPath!, dbName! + '.db'), 'database.db');
    }

    _db = await openDatabase(
      join(dbPath!, dbName! + '.db'),
      version: version,
      onCreate: (db, version) async {
        // await createDatabase(db);
      },
    );

    return _db!;
  }

  @deprecated
  static _dbUpdate() {}

  static Future<Database> createAmbiente(String nome) async {
    dbPath ??= await getDatabasesPath() + '/ambientes/';

    printDebug('test');

    return await openDatabase(
      join(dbPath!, nome),
      version: version,
      onCreate: (db, version) async {
        // await createDatabase(db);
      },
    );
  }

  static Future deleteAmbiente(String nome) async {
    dbPath ??= await getDatabasesPath() + '/ambientes/';
    await deleteDatabase(dbPath! + nome);
  }

  static Future<void> createDatabase(Database db) async {
    final queries = await getDatabaseCreationQueries('database');

    // printDebug(queries);

    final batch = db.batch();

    for (final object in queries) {
      final tableName = object["name"];
      final sql = object['ddl'];

      if (object["type"] == "view") {
        continue;
      }

      if (sql != null) {
        try {
          await db.execute(sql);
          //
          // if (object["type"] != "table") {
          //   continue;
          // }

          final bruteRow = object["rows"] as List<dynamic>;

          if (bruteRow.isEmpty) {
            continue;
          }

          final rows = List.generate(
              bruteRow.length, (index) => bruteRow[index] as List<dynamic>);

          final columnsUntreated = object["columns"] as List<dynamic>;

          final columns = List.generate(
              columnsUntreated.length, (index) => columnsUntreated[index]);

          // printDebug(columns);

          final List<String> columnNames = [];

          for (final column in columns) {
            columnNames.add(column["name"]);
          }

          final Map<String, dynamic> body = {};

          for (final row in rows) {
            int i = 0;
            for (final cell in row) {
              body[columnNames[i++]] = cell;
            }

            // printDebug("$tableName + $body");
            await db.insert(tableName, body);
          }
        } catch (e) {
          // printDebug(e);
          //
          // rethrow;
        }
      }
    }

    bool toTry = true;

    while (toTry) {
      toTry = false;
      for (final object in queries) {
        final tableName = object["name"];
        final sql = object['ddl'];

        // printDebug(sql);
        if (object["type"] != "view") {
          continue;
        }
        if (sql != null) {
          try {
            await db.execute(sql);
          } on DatabaseException catch (e) {
            // if(e.is)
            if (!toTry) {
              // printDebug('Error creating -> $tableName');
              toTry = e.isNoSuchTableError();
            }
            // toTry = true;
            // printDebug(e);
            //
            // rethrow;
          } catch (e) {
            rethrow;
          }
        }
      }
    }

    batch.commit();
  }

  static Future<Database> getSystemDatabase() async {
    dbName ??= 'banco.db';
    dbPath ??= await getDatabasesPath();

    return await openDatabase(
      join(dbPath!, dbName!),
      // onCreate: ,
      version: version,

      // onCreate: (db, version) {
      //   db.execute('CREATE TABLE TEST(id int);');
      // },
    );
  }

  static Future reloadDatabase() async {
    _db ??= await getDatabase();

    await _db!.close();
    await Future.delayed(const Duration(milliseconds: 100));
    _db = null;
    await getDatabase();
  }

  /// Executa uma query no banco dado a tabela [table] e os parametros.
  static Future<List<Map<String, dynamic>>> select(String table,
      {final String? where,
      final List<dynamic>? whereArgs,
      final String? orderBy,
      final int? limit,
      Function? onSucces,
      Function? onFail}) async {
    List<Map<String, dynamic>> maps = [];
    final db = await DatabaseAmbiente.getDatabase();

    try {
      if (where == null || whereArgs == null) {
        maps = await db.query(table, orderBy: orderBy, limit: limit);
      } else {
        maps = await db.query(table,
            where: where, whereArgs: whereArgs, orderBy: orderBy, limit: limit);
      }
      if (onSucces != null) {
        onSucces();
      }
    } catch (e) {
      printDebug(e.toString());

      if (onFail != null) {
        onFail();
      }
    }

    return maps;
  }

  static Future update(String table, Map<String, dynamic> map,
      {ConflictAlgorithm algorithm = ConflictAlgorithm.replace,
      final String? where,
      final List<dynamic>? whereArgs,
      Function? onSucces,
      Function? onFail}) async {
    final db = await DatabaseAmbiente.getDatabase();

    try {
      if (where == null || whereArgs == null) {
        await db.update(table, map);
      } else {
        await db.update(table, map, where: where, whereArgs: whereArgs);
      }

      if (onSucces != null) onSucces();
    } catch (e) {
      printDebug(e.toString());
      if (onFail != null) onFail();
    }
  }

  static Future delete(String table,
      {final String? where,
      final List<dynamic>? whereArgs,
      Function? onSucces,
      Function? onFail}) async {
    final db = await DatabaseAmbiente.getDatabase();
    try {
      if (where == null || whereArgs == null) {
        await db.delete(table);
      } else {
        await db.delete(table, where: where, whereArgs: whereArgs);
      }
      if (onSucces != null) {
        onSucces();
      }
    } catch (e) {
      printDebug(e.toString());

      if (onFail != null) {
        onFail();
      }
    }
  }

  static Future insert(String table, Map<String, dynamic> map,
      {ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace,
      Function? onSucces,
      Function(dynamic e)? onFail,
      bool printStack = true}) async {
    final db = await DatabaseAmbiente.getDatabase();

    try {
      final result = await db.insert(
        table,
        map,
        conflictAlgorithm: conflictAlgorithm,
      );

      if (onSucces != null) onSucces();

      return result;
    } catch (e) {
      if (printStack) {
        printDebug(e.toString());
      }
      if (onFail != null) onFail(e);
    }
  }

  static Future<Object?> insertAll(
      String table, List<Map<String, dynamic>> maps,
      {ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace}) async {
    final db = await DatabaseAmbiente.getDatabase();
    var batch = db.batch();

    try {
      for (Map<String, dynamic> map in maps) {
        batch.insert(
          table,
          map,
          conflictAlgorithm: conflictAlgorithm,
        );
      }
      await batch.commit();
      return null;
    } catch (e) {
      printDebug(e);
      printDebug(e.toString());

      return e;
    }
  }

  static Future execute(String sql,
      {final List<dynamic>? args,
      Function? onSucces,
      Function? onFail,
      bool errorLog = true}) async {
    final db = await DatabaseAmbiente.getDatabase();
    try {
      if (args == null) {
        await db.execute(sql);
      } else {
        await db.execute(sql, args);
      }
      if (onSucces != null) {
        onSucces();
      }
    } catch (e) {
      if (errorLog) {
        printDebug(e.toString());
      }

      if (onFail != null) {
        onFail();
      }
    }
  }

  @deprecated
  static Future<List<Map<String, dynamic>>> produtoInfoView() async {
    const sql =
        'SELECT a.*, b.MOBILE FROM VW_PRODUTO_INFO a INNER JOIN TB_PRODUTO b ON b.ID = a.id_produto order by a.nome';
    final db = await getDatabase();

    return db.rawQuery(sql);
  }
}

@Deprecated("Não funciona como esperado")
Future closeDatabase(Database db) async {
  // await db.close();
  return;
}

/// Formatação padrão sqlite de DateTime
final DateFormat dateTimeFormat = DateFormatter.databaseDateTime;

/// Retorna o tempo atual formatado para o campo DateTime
String getCurrentTime() {
  return dateTimeFormat.format(DateTime.now());
}

parseStringToDateTime(String x) {
  return dateTimeFormat.parse(x);
}

getBool(int x) {
  return x == 1;
}

/// Retorna
String dateTimeToString(final DateTime x) {
  return dateTimeFormat.format(x);
}

// /// Executa uma query no banco dado a tabela [table] e os parametros.
// Future<List<Map<String, dynamic>>> select(String table,
//     {final String? where,
//     final List<dynamic>? whereArgs,
//     final String? orderBy,
//     Function? onSucces,
//     Function? onFail}) async {
//   late final List<Map<String, dynamic>> maps;
//
//   final db = await DatabaseAmbiente.getDatabase();
//
//   try {
//     if (where == null || whereArgs == null) {
//       maps = await db.query(table, orderBy: orderBy);
//     } else {
//       maps = await db.query(table,
//           where: where, whereArgs: whereArgs, orderBy: orderBy);
//     }
//     if (onSucces != null) {
//       onSucces();
//     }
//   } catch (e) {
//     printDebug(e.toString());
//
//     if (onFail != null) {
//       onFail();
//     }
//   }
//
//   await closeDatabase(db);
//
//   return maps;
// }
//
// Future update(String table, Map<String, dynamic> map,
//     {ConflictAlgorithm algorithm = ConflictAlgorithm.replace,
//     final String? where,
//     final List<dynamic>? whereArgs,
//     Function? onSucces,
//     Function? onFail}) async {
//   final db = await DatabaseAmbiente.getDatabase();
//
//   try {
//     if (where == null || whereArgs == null) {
//       await db.update(table, map);
//     } else {
//       await db.update(table, map, where: where, whereArgs: whereArgs);
//     }
//
//     if (onSucces != null) onSucces();
//   } catch (e) {
//     printDebug(e.toString());
//
//     if (onFail != null) onFail();
//   }
//
//   await closeDatabase(db);
// }
//
// Future delete(String table,
//     {final String? where,
//     final List<dynamic>? whereArgs,
//     Function? onSucces,
//     Function? onFail}) async {
//   final db = await DatabaseAmbiente.getDatabase();
//   try {
//     if (where == null || whereArgs == null) {
//       await db.delete(table);
//     } else {
//       await db.delete(table, where: where, whereArgs: whereArgs);
//     }
//     if (onSucces != null) {
//       onSucces();
//     }
//   } catch (e) {
//     printDebug(e.toString());
//
//     if (onFail != null) {
//       onFail();
//     }
//   }
//
//   await closeDatabase(db);
// }
//
// Future insert(String table, Map<String, dynamic> map,
//     {ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace,
//     Function? onSucces,
//     Function(dynamic e)? onFail,
//     bool printStack = true}) async {
//   final db = await DatabaseAmbiente.getDatabase();
//
//   try {
//     await db.insert(
//       table,
//       map,
//       conflictAlgorithm: conflictAlgorithm,
//     );
//
//     if (onSucces != null) onSucces();
//   } catch (e) {
//     if (printStack) {
//       printDebug(e.toString());
//
//     }
//     if (onFail != null) onFail(e);
//   }
//
//   await closeDatabase(db);
// }
//
// Future insertAll(String table, List<Map<String, dynamic>> maps,
//     {ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace,
//     Function? onSucces,
//     Function? onFail}) async {
//   final db = await DatabaseAmbiente.getDatabase();
//   var batch = db.batch();
//
//   try {
//     for (Map<String, dynamic> map in maps) {
//       batch.insert(
//         table,
//         map,
//         conflictAlgorithm: conflictAlgorithm,
//       );
//     }
//     await batch.commit();
//     if (onSucces != null) onSucces();
//   } catch (e) {
//     printDebug(e.toString());
//
//     if (onFail != null) onFail();
//   }
//
//   await closeDatabase(db);
// }
//
// Future execute(String sql,
//     {final List<dynamic>? args, Function? onSucces, Function? onFail}) async {
//   final db = await DatabaseAmbiente.getDatabase();
//   try {
//     if (args == null) {
//       await db.execute(sql);
//     } else {
//       await db.execute(sql, args);
//     }
//     if (onSucces != null) {
//       onSucces();
//     }
//   } catch (e) {
//     printDebug(e.toString());
//
//     if (onFail != null) {
//       onFail();
//     }
//   }
//
//   await closeDatabase(db);
// }
