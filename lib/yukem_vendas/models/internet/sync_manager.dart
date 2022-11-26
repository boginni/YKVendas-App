import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:forca_de_vendas/yukem_vendas/models/internet/server_route.dart';
import 'package:forca_de_vendas/yukem_vendas/models/internet/sync_cliente.dart';
import 'package:forca_de_vendas/yukem_vendas/models/internet/sync_vendas.dart';
import 'package:forca_de_vendas/yukem_vendas/models/internet/sync_visitas.dart';

import '../../../api/common/components/barra_progresso.dart';
import 'internet.dart';

class SyncDesativada implements Exception {}

class SyncRunning implements Exception {}

class SyncHandler {
  static Future ping(BuildContext context) async {
    final res = await Internet.serverPost(ServerPath.PING,
            body: {'null': false},
            context: context,
            inputServer: true,
            ignoreFirbidden: true,
            timeout: 5000)
        .timeout(const Duration(seconds: 5));

    if (res.body == '1') {
      return null;
    }

    // printDebug(test);

    throw SyncDesativada();
  }

  static bool onSync = false;

  Object? error;

  String _getMsg() {
    late String msg;
    switch (error.runtimeType) {
      case SyncDesativada:
        msg = "Sincronização desativda pelo servidor";
        break;
      case TimeoutException:
        msg = 'Sem Resposta do servidor';
        break;
      case Forbidden:
        msg = 'Sessão inválida, precisa logar novamente';
        break;
      case SyncRunning:
        msg = 'Sincronização Já está Rodando';
        break;
      default:
        msg = "Erro na Sincronização";
        break;
    }
    return msg;
  }

  Future<Object?> syncronizeEverything(BuildContext context) async {
    print("onSync = ${onSync}");

    if (onSync) {
      error = SyncRunning();
      return error;
    }
    onSync = true;
    try {
      await SyncHandler.ping(context);
      await SyncClientes.syncClientes(context, toPing: false);
      await syncVendas(context);
      await syncVisitas(context);
      onSync = false;
      return null;
    } catch (e) {
      onSync = false;
      return e;
    }
  }

  static Future sincronizar(
      {bool show = false, required BuildContext context}) async {
    late final GlobalKey<BarraProgressoCircularState> key;

    if (show) {
      key = await mostrarBarraProgressoCircular(context);
    }

    final handler = SyncHandler();

    onSucces() {
      if (show && key.currentState != null) {
        key.currentState!.finish();
      }
    }

    onError() {
      if (show && key.currentState != null) {
        key.currentState!.setError('Sincronização Falhou', handler._getMsg());
      }
    }

    await handler.syncronizeEverything(context).then((value) {
      print(value);

      if (value == null) {
        return onSucces();
      }

      return onError();
    });
  }
}
