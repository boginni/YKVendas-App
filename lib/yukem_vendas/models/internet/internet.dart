// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:forca_de_vendas/api/common/components/mostrar_confirmacao.dart';
import 'package:forca_de_vendas/yukem_vendas/models/internet/server_route.dart';
import 'package:http/http.dart';

import '../../../api/common/debugger.dart';
import '../configuracao/app_user.dart';

class Forbidden implements Exception {}

abstract class Internet {
  /// TODO: Rezetar ao padrão
  static String _hostName = 'app.comtecnologia.com';
  static String _portOut = '9032';
  static String _portIn = '';

  static int awaitTime = 15;

  static setPortIn(newPortIn) {
    _portIn = newPortIn;
  }

  static setURl(String server, String newPortOut, String newPortIn) {
    _hostName = server;
    _portOut = newPortOut;
    _portIn = newPortOut;
  }

  static String getDefaultHttpServer({bool input = false}) {
    String server = 'http://app.comtecnologia.com:9032';
    return server;
  }

  static String getHttpServer({bool input = false}) {
    final door = input ? _portIn : _portOut;
    String server = 'http://$_hostName:$door';
    return server;
  }

  static Uri getHttpUri(String path) {
    return Uri.parse('${getHttpServer()}/$path');
  }

  static String getWebSocketServer() {
    String server = 'ws://$_hostName:$_portOut';
    return server;
  }

  static String setDefault() {
    setURl('app.comtecnologia.com', '9032', '');
    return getHttpServer();
  }

  static Map<String, String> getDeafultHeaders(String body) {
    return {
      'Content-Type': 'application/json',
      'Content-Length': utf8.encode(body).length.toString(),
      'charset': 'utf-8',
      'Connection': 'keep-alive',
      'Accept-Encoding': 'gzip, deflate, br'
    };
  }

  static Future<Response> serverPost(
    String path, {
    dynamic body,
    Map<String, String>? headers,
    required BuildContext context,
    bool inputServer = false,
    bool ignoreFirbidden = false,
    int? timeout,
  }) async {
    /// converte para json se não for
    if (body is! String) {
      body = const JsonEncoder().convert(body);
    }

    headers ??= {};

    /// adiciona os headers padõres
    headers.addAll(getDeafultHeaders(body));

    if (context != null) {
      final appUser = AppUser.of(context);
      headers.addAll(appUser.toHeaders());
    }

    String urlRequest = '${getHttpServer(input: false)}/$path';

    try {
      late final Response res;

      if (timeout != null) {
        res = await post(Uri.parse(urlRequest), body: body, headers: headers)
            .timeout(Duration(milliseconds: timeout));
      } else {
        res = await post(Uri.parse(urlRequest), body: body, headers: headers);
      }

      if (res.statusCode == 403) {
        if (!ignoreFirbidden) {
          mostrarCaixaConfirmacao(
            context,
            mostrarCancelar: false,
            title: 'Sessão Inválida',
            content: 'Você precisa logar novamente para continuar sincronizado',
          );
        }
        throw Forbidden();
      }

      return res;
    } on TimeoutException {
      printDebug('Timeout');
      rethrow;
    } catch (e) {
      printDebug(e.runtimeType.toString());
      rethrow;
    }
  }

  static Future<Response> serverPost2(String path,
      {dynamic body, Map<String, String>? headers}) async {
    /// converte para json se não for
    if (body is! String) {
      body = const JsonEncoder().convert(body);
    }

    headers ??= {};

    /// adiciona os headers padõres
    headers.addAll({
      'Content-Type': 'application/json',
      'Content-Length': utf8.encode(body).length.toString(),
      'charset': 'utf-8',
      'Connection': 'keep-alive',
      'Accept-Encoding': 'gzip, deflate, br'
    });

    String urlRequest = '${getHttpServer()}/$path';

    try {
      final res =
          await post(Uri.parse(urlRequest), body: body, headers: headers);

      if (res.statusCode == 403) {
        // mostrarCaixaConfirmacao(context, mostrarCancelar: false, title: 'Sessão Inválida', content: 'Você precisa logar novamente para continuar sincronizado');
        throw Forbidden();
      }

      return res;
    } on TimeoutException {
      printDebug('Timeout');
      rethrow;
    } catch (e) {
      printDebug(e.runtimeType.toString());
      rethrow;
    }
  }

  static Future<Response?> serverLogin(String path,
      {dynamic body,
      Map<String, String>? headers,
      BuildContext? context}) async {
    /// converte para json se não for
    if (body is! String) {
      body = const JsonEncoder().convert(body);
    }

    headers ??= {};

    /// adiciona os headers padõres
    headers.addAll({
      'Content-Type': 'application/json',
      'Content-Length': body.length.toString(),
      'Accept-Encoding': 'gzip, deflate, br'
    });

    String urlRequest = '${getHttpServer()}/$path';

    return _getResponse(
        post(Uri.parse(urlRequest), body: body, headers: headers),
        sleepTime: 25);
  }

  static Future<Response?> getServers(String ambiente,
      {BuildContext? context}) async {
    /// converte para json se não for
    dynamic body = {};

    if (body is! String) {
      body = const JsonEncoder().convert(body);
    }

    /// adiciona os headers padõres
    final headers = {
      'Content-Type': 'application/json',
      'Content-Length': body.length.toString(),
      'ambiente': ambiente
    };

    String urlRequest = '${getDefaultHttpServer()}/${ServerPath.VIEW_SERVERS}';

    return _getResponse(
        post(Uri.parse(urlRequest), body: body, headers: headers),
        sleepTime: 2);
  }

  static Future<Response> serverGet(String path, dynamic body, Map? headers) {
    return get(Uri.parse('${getHttpServer()}/$path'),
        headers: {'Accept-Encoding': 'gzip, deflate, br'});
  }

  static Future<DateTime> serverDatetime() async {
    final url = '${getHttpServer()}/util/data';
    final res = await get(Uri.parse(url));

    try {
      return DateTime.parse(res.body);
    } catch (e) {
      throw Exception('Data retornada do servidor é inválida');
    }
  }

  static Future<Response?> _getResponse(Future<dynamic> request,
      {int? sleepTime}) async {
    sleepTime ??= awaitTime;
    try {
      Response response = await request.timeout(Duration(seconds: sleepTime));
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
