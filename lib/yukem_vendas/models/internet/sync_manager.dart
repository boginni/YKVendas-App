import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:forca_de_vendas/yukem_vendas/models/internet/server_route.dart';
import 'package:forca_de_vendas/yukem_vendas/models/internet/sync_cliente.dart';
import 'package:forca_de_vendas/yukem_vendas/models/internet/sync_vendas.dart';
import 'package:forca_de_vendas/yukem_vendas/models/internet/sync_visitas.dart';

import '../../../api/common/components/barra_progresso.dart';
import '../../../api/common/debugger.dart';
import 'internet.dart';

bool onSync = false;

Future syncronizeEverything(
    {Function? onSucess,
    Function(dynamic? e)? onFail,
    required BuildContext context}) async {
  callback(Function? f) {
    onSync = false;
    if (f != null) {
      f();
    }
  }

  if (onSync) {
    return;
  }

  onSync = true;

  try {
    await SyncHandler.ping(context);
    await SyncClientes.syncClientes(context, toPing: false);
    await syncVendas(context);
    await syncVisitas(context);
    callback(onSucess);
  } catch (e) {
    callback(() => onFail != null ? onFail(_getMsg(e)) : null);
  }
}

class SyncDesativada implements Exception {}

String _getMsg(Object e) {
  late String msg;
  switch (e.runtimeType) {
    case SyncDesativada:
      msg = "Sincronização desativda pelo servidor";
      break;
    case TimeoutException:
      msg = 'Sem Resposta do servidor';
      break;
    case Forbidden:
      msg = 'Sessão inválida, precisa logar novamente';
      break;
    default:
      msg = "Erro na Sincronização";
      break;
  }

  return msg;
}

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

  static Future sincronizar(
      {bool show = false, required BuildContext context}) async {
    late final GlobalKey<BarraProgressoCircularState> key;

    if (show) {
      key = mostrarBarraProgressoCircular(context);
    }

    callback(Function f) {
      if (show) {
        f();
      }
    }

    await Future.delayed(const Duration(milliseconds: 100)).then(
      (value) async {
        await syncronizeEverything(
                context: context,
                onSucess: () => callback(() {
                      key.currentState!.finish();
                    }),
                onFail: (e) => callback(() => key.currentState!
                    .setError('A Sincronização Falhou', e.toString())))
            .then((value) => {key.currentState!.finish()});
      },
    );
  }
}
