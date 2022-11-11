import 'dart:convert';

import 'package:flutter/cupertino.dart';

import '../../../../models/internet/internet.dart';

class Critica {
  static Future<List<Critica>> getData(
    BuildContext context,
    int idVendedor,
    String dataInit,
    String dataFim,
  ) async {
    final body = {
      "id_vendedor": idVendedor,
      "data_inicio": dataInit,
      "data_fim": dataFim
    };

    await Internet.serverPost('dash/critica/', context: context, body: body)
        .then((value) {
      return const JsonDecoder().convert(value.body)['rows'];
    });

    return [];
  }
}
