import 'dart:convert';

import 'package:flutter/cupertino.dart';

import '../../../api/common/debugger.dart';
import '../../../api/common/formatter/date_time_formatter.dart';
import '../../../api/models/system_database/system_database.dart';
import '../configuracao/app_user.dart';
import '../database/database_ambiente.dart';
import 'internet.dart';
import 'server_route.dart';

// Future<int> ping(Map<String, dynamic> map, BuildContext context) async {
//   String body = const JsonEncoder().convert(map);
//   final response =
//       await serverPost(ServerPath.VIEW_INFO, body: body, context: context);
//
//   if (response == null) {
//     throw 'Sem resposta do servidor';
//   }
//
//   dynamic res = jsonDecode(response.body);
//
//   return res['QUANTIDADE'];
// }

Future<List<dynamic>?> load(
    Map<String, dynamic> map, BuildContext context) async {
  String body = const JsonEncoder().convert(map);

  final response = await Internet.serverPost(ServerPath.VIEW_DOWNLOAD,
      body: body, context: context);

  if (response == null) {
    return null;
  }

  List<dynamic> res = jsonDecode(response.body);

  final List<dynamic> dados = [];

  if (res.isEmpty) {
    return dados;
  }

  for (final item in res) {
    dados.add(item);
  }

  return dados;
}

Future insertData(List<dynamic> list, tabela) async {
  List<Map<String, dynamic>> maps = List.generate(list.length, (index) {
    final Map<String, dynamic> constCase = {};

    final onCliente = tabela == "TB_CLIENTE";

    (list[index] as Map<String, dynamic>).forEach((key, value) {
      if (onCliente) {
        if (key == "ID") {
          key = "ID_SYNC";
        }
      }

      if (key != 'DATA_LAST_UPDATE') constCase[key] = value;
    });

    return constCase;
  });

  /// insere os dados recebidos no banco
  await DatabaseAmbiente.insertAll(tabela, maps);
}

// int? impSize = 0;

Future<bool> download(SyncItem syncItem, BuildContext context, int limit,
    {required bool forcar,
    required Function(double x) tick,
    required bool retry}) async {
  // forcar = true;

  Map<String, dynamic> body = {
    "tb": syncItem.nomeArquivo,
    'data': forcar ? '' : syncItem.dataLastUpdate,
  };

  List<dynamic>? list = await load(body, context);

  if (list != null) {
    await insertData(list, syncItem.nomeTabela);

    await DatabaseAmbiente.update(
        'CONF_IMP_TABLES', {'IND_IMPORTACAO': list.length},
        where: 'NOME_TABELA = ?', whereArgs: [syncItem.nomeTabela]);

    return true;
  } else {
    return false;
  }

  // try {
  //   impSize = await ping(body, context);
  // } catch (e) {
  //   rethrow;
  // }

  // int ammount = impSize!;

  // int skipSize = limit + (ammount * 0.1).round();
  // int curAmmount = syncItem.indImportado;
  //
  // while (curAmmount < ammount) {
  //   // Atraso para evitar sobrecarregar o banco
  //   // await Future.delayed(const Duration(milliseconds: 100));
  //
  //   int curSize = curAmmount;
  //   body['limit'] = ammount < skipSize ? ammount : skipSize;
  //   body['skip'] = curSize;
  //
  //
  // }
}

Future importar(SyncItem syncItem,
    {required bool forcar,
    required BuildContext context,
    required bool parcial,
    required Function(double x) tick,
    required Function(String x) starting,
    required bool retry,
    required DateTime data}) async {
  // PREPARA O BODY

  starting(syncItem.apelido);

  bool downloaded = await download(syncItem, context, parcial ? 250 : 999999,
      forcar: forcar, retry: retry, tick: tick);

  if (downloaded) {
    await DatabaseAmbiente.update(
        'CONF_IMP_TABLES',
        {
          'DATA_LAST_UPDATE': DateFormatter.databaseDateTime.format(data),
          'IND_IMPORTACAO': 0,
          'IMPORTADO': 1,
        },
        where: 'NOME_TABELA = ?',
        whereArgs: [syncItem.nomeTabela]);
  } else {
    throw Exception();
  }
}

Future importarTudo(
    {bool forcar = false,
    Function(String curTable, double tot, double cur, bool b)? onTick,
    required Function() onSucces,
    required bool Function(Object e) onFail,
    required BuildContext context,
    bool parcial = true}) async {
  ///Pega a lista de tabelas e começa a importar

  bool toTry = true;
  bool succes = true;
  bool reTry = false;

  final appUser = AppUser.of(context);



  while (toTry) {
    toTry = false;
    succes = true;

    try {
      DateTime date = await Internet.serverDatetime();

      List<SyncItem> list = await SyncItem.getSyncList();

      int progress = 0;
      for (final item in list) {
        if (item.importado) {
          // if(onTick != null){
          //   onTick(item.apelido,x / y.length, 0);
          // }
          progress++;
          // printDebug(item.nomeTabela + ' ' + 'pulado');
          continue;
        }

        if (onTick != null) {
          onTick(item.apelido, progress / list.length, 0, false);
        }

        /// Imparta Cada tabela individualmente
        await importar(item,
            forcar: forcar,
            parcial: parcial,
            retry: reTry,
            context: context,
            starting: (String x) {}, tick: (double x) {
          if (onTick != null) {
            onTick(item.apelido, progress / list.length, x, true);
          }
        }, data: date);

        reTry = false;
        progress++;
      }
      toTry = false;
    } catch (e) {
      reTry = true;
      printDebug(e.toString());

      succes = false;
      toTry = onFail(e);

      await Future.delayed(const Duration(seconds: 250));
    }
  }

  if (succes) {
    await DatabaseSystem.update('TB_AMBIENTES', {'TO_SYNC': 0},
        where: 'NOME = ?', whereArgs: [appUser.ambiente]);

    // await DatabaseAmbiente.execute('UPDATE CONF_IMP_TABLES set IMPORTADO = 1');

    // await DatabaseAmbiente.execute('UPDATE CONF_IMP_TABLES set IMPORTADO = REIMPORTAR * -1 + 1');
    onSucces();
  }
}

importarApenas(int id,
    {bool forcar = false,
    Function(String curTable, double tot, double cur, bool b)? onTick,
    required BuildContext context,
    bool parcial = true}) async {
  final item = await SyncItem.getSyncItem(id);

  try {
    DateTime date = await Internet.serverDatetime();
    date.add(const Duration(hours: 0));
    await importar(item,
        forcar: forcar,
        context: context,
        parcial: parcial,
        tick: (x) {},
        starting: (x) {},
        retry: false,
        data: date);
  } catch (e) {
    printDebug(e.toString());
  }
}

class SyncItem {
  late final int id;
  late final String nomeArquivo;
  late final String nomeTabela;
  late final String dataLastUpdate;
  late final String apelido;
  late final bool reimportar;
  late final bool importado;
  late final int indImportado;

  // ORDEM	NOME_ARQUIVO	NOME_TABELA	DATA_LAST_UPDATE	APELIDO	REIMPORTAR	IMPORTADO	IND_IMPORTACAO

  SyncItem(Map<String, dynamic> map) {
    dynamic value(String x) {
      return map[x];
    }

    int intValue(dynamic x) {
      return int.parse(value(x).toString());
    }

    // String stringValue(dynamic x) {
    //   return x.toString();
    // }

    bool boolValue(dynamic x) {
      return (value(x) == 1);
    }

    id = intValue('ORDEM');
    nomeArquivo = value('NOME_ARQUIVO');
    nomeTabela = value('NOME_TABELA');
    dataLastUpdate = value('DATA_LAST_UPDATE') ?? '';
    apelido = value('APELIDO');
    reimportar = boolValue('REIMPORTAR');
    importado = boolValue('IMPORTADO');
    indImportado = intValue('IND_IMPORTACAO');
  }

  static Future<List<SyncItem>> getSyncList() async {
    List<Map<String, dynamic>> maps = await DatabaseAmbiente.select(
      'CONF_IMP_TABLES',
      where: 'REIMPORTAR = ?',
      whereArgs: [1],
    );

    return List.generate(maps.length, (i) {
      return SyncItem(maps[i]);
    });
  }

  static Future<SyncItem> getSyncItem(int id) async {
    List<Map<String, dynamic>> maps = await DatabaseAmbiente.select(
        'CONF_IMP_TABLES',
        where: 'ORDEM = ?',
        whereArgs: [id]); //  where: 'IMPORTADO = ?', whereArgs: [0]

    return List.generate(maps.length, (i) {
      return SyncItem(maps[i]);
    })[0];
  }
}
