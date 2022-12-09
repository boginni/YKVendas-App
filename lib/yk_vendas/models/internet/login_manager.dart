import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../../../api/common/debugger.dart';
import '../../../api/models/system_database/system_database.dart';
import '../../app_foundation.dart';
import 'internet.dart';
import 'server_route.dart';

class Credenciais {
  String ambiente = "";
  String user = "";
  String senha = "";
  String uuid = "";
  late final int idVendedor;
  bool offline = false;
}

acessarAmbiente(BuildContext context, Credenciais credenciais) async {
  await DatabaseSystem.insert('TB_USERS', {
    'LOGIN': credenciais.user,
    'PASS': credenciais.senha,
    'AMBIENTE': credenciais.ambiente,
    'UUID': credenciais.uuid,
    'ID_VENDEDOR': credenciais.idVendedor
  });

  await Application.logIn(context,
      uuid: credenciais.uuid,
      idVendedor: credenciais.idVendedor,
      ambiente: credenciais.ambiente,
      offline: credenciais.offline,
      vendedor: credenciais.user);
}

Future offlineLogin(Credenciais credenciais,
    {required Function onSucces, required Function(int error) onFail}) async {
  ///TODO remover chamada local
  final params = [credenciais.user, credenciais.senha, credenciais.ambiente];
  List<Map<String, dynamic>> res = await DatabaseSystem.select('TB_USERS',
      where: 'LOGIN = ? AND PASS = ? and AMBIENTE = ?', whereArgs: params);

  if (res.isNotEmpty) {
    // await acessarAmbiente(
    //     offline: true, uuid: , idVendedor: );

    credenciais.uuid = res[0]['UUID'];
    credenciais.idVendedor = res[0]['ID_VENDEDOR'];

    // await DatabaseSystem.update('TB_SERVIDOR', {'PORTA_IN': Internet.portIn},
    //     where: 'AMBIENTE = ?', whereArgs: [credenciais.ambiente]);
    //
    DatabaseSystem.select('TB_SERVIDOR',
        where: 'LAST_SERVER = ?', whereArgs: [1]).then((value) {
      Internet.setPortIn(value[0]['PORTA_IN'].toString());
    });

    onSucces();
  } else {
    List<Map<String, dynamic>> res = await DatabaseSystem.select('TB_USERS',
        where: 'AMBIENTE = ?', whereArgs: [credenciais.ambiente]);

    if (res.isEmpty) {
      onFail(0);
      return;
    }

    onFail(1);
  }
}

Future onlineLogin(Credenciais credenciais,
    {required Function onSucces,
    required Function(int error) onFail,
    bool sincronizarWifi = false}) async {
  try {
    // var connectivityResult = await (Connectivity().checkConnectivity());
    // if (connectivityResult == ConnectivityResult.mobile) {
    //
    // } else if (connectivityResult == ConnectivityResult.wifi) {
    //   // I am connected to a wifi network.
    // }

    final ConnectivityResult result = await Connectivity().checkConnectivity();

    if (result == ConnectivityResult.wifi) {
      // printDebug('Connected to a Wi-Fi network');
    } else if (result == ConnectivityResult.mobile) {
      if (sincronizarWifi) {
        onFail(104);
        return;
      }
    } else {
      printDebug('Not connected to any network');
    }

    Map<String, dynamic> body = {
      "usuario": credenciais.user,
      "pass": credenciais.senha,
    };

    Map<String, String> headers = {
      "ambiente": credenciais.ambiente,
    };

    var res = await Internet.serverLogin(ServerPath.LOGIN,
        body: body, headers: headers);

    if (res == null) {
      onFail(0);
      return;
    }

    final maps = const JsonDecoder().convert(res.body) as Map<String, dynamic>;

    if (maps['ID_VENDEDOR'] != null) {
      int idVendedor = maps['ID_VENDEDOR'];
      String uuid = maps['LAST_UUID'];

      credenciais.idVendedor = idVendedor;
      credenciais.uuid = uuid;

      Internet.setPortIn(maps['port'].toString());

      await DatabaseSystem.update(
          'TB_SERVIDOR', {'PORTA_IN': maps['port'].toString()},
          where: 'AMBIENTE = ?', whereArgs: [credenciais.ambiente]);

      onSucces();
    } else {
      int error = maps['error'];

      onFail(error);

      return;
    }
  } on TimeoutException catch (_) {
    // errorMsg = "Sem Resposta do Servidor";

    onFail(301);
  } on SocketException {
    // errorMsg = "Sem conexão";

    onFail(302);
  } on ArgumentError {
    // errorMsg = "Ambiente ou Servidor Inválido";

    onFail(303);
  } on ClientException {
    // printDebug(e.runtimeType.toString());
    // errorMsg = "Erro Desconhecido";
    // printDebug(e.toString());

    // Problemas para conectar com o servidor
    onFail(304);
  } catch (e) {
    printDebug(e.runtimeType.toString());
    printDebug(e.toString());
    onFail(8);
  }

  return;
}
