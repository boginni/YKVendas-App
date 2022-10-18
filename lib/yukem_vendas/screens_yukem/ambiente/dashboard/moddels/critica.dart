import 'dart:convert';

import 'package:flutter/cupertino.dart';

import '../../../../models/configuracao/app_user.dart';
import '../../../../models/internet/internet.dart';

class Critica {
  Future<List<Critica>> getData(BuildContext context, DateTime time) async {
    final body = {
      "id_vendedor": AppUser.of(context).vendedorAtual,
      "data_inicio": time,
      "data_fim": time
    };

    await Internet.serverPost('dash/critica/', context: context, body: body)
        .then((value) {
      return const JsonDecoder().convert(value.body)['rows'];
    });

    return [];
  }
}
