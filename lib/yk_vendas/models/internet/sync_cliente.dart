import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

import '../../../api/common/debugger.dart';
import '../../../api/models/database_objects/query_filter.dart';
import '../database/database_ambiente.dart';
import '../database_objects/cliente.dart';
import 'internet.dart';
import 'server_route.dart';
import 'sync_manager.dart';

class SyncClientes {
  static bool _sync = false;

  static Future<bool> syncClientes(BuildContext context,
      {bool toPing = true}) async {
    print('sync cliente ${_sync}' );

    if (_sync) {
      return false;
    }

    if (toPing) {
      try {
        await SyncHandler.ping(context);
      } catch (e) {
        return false;
      }
    }



    _sync = true;

    List<Cliente> clientes = await Cliente.getClientes(
        queryFilter: QueryFilter(args: {'TO_SYNC': 1}, allowNull: true), normal: true);

    if (clientes.isEmpty) {
      _sync = false;
      return true;
    }

    try {
      List<Map<String, dynamic>> body = List.generate(clientes.length, (index) {
        return clientes[index].toBody();
      });

      final Response res = await Internet.serverPost(ServerPath.CLIENTE,
          body: body, context: context, inputServer: true);

      final Map<String, dynamic> maps = const JsonDecoder().convert(res.body);

      // final Map<String, dynamic> maps = {};

      // for (final item in responseList) {
      //   maps[item['uuid']] = item['id'];
      // }

      for (final cliente in clientes) {
        final uuid = cliente.uuid;
        try {
          int? idSync = int.tryParse(maps[uuid].toString());

          if (idSync != null) {
            // printDebug(uuid);
            // if(maps)
            cliente.idSync = idSync;
            cliente.toSync = false;

            await DatabaseAmbiente.update(
                'TB_VISITA', {'ID_CLIENTE_SYNC': idSync},
                where: 'ID_CLIENTE = ?', whereArgs: [cliente.id]);

            await Cliente.insertCliente(cliente, force: true);

            final newCliente = await Cliente.getClienteSync(idSync);

            await DatabaseAmbiente.update(
                'TB_VISITA', {'ID_CLIENTE': newCliente.id},
                where: 'ID_CLIENTE_SYNC = ?', whereArgs: [idSync]);
          }
        } catch (e) {
          printDebug(e.toString());
        }
      }

      updateVisitaSync();

      _sync = false;
      return true;
    } catch (e) {
      printDebug(e);
      _sync = false;
      return false;
    }
  }

  static Future updateVisitaSync() async {
    await DatabaseAmbiente.execute(
        'update TB_VISITA SET ID_CLIENTE_SYNC = (select x.ID_SYNC from TB_CLIENTE as x where x.ID = TB_VISITA.ID_CLIENTE) where TB_VISITA.ID_CLIENTE_SYNC is null');
  }
}
