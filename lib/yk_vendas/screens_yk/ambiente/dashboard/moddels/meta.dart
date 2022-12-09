import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../../../../../api/common/formatter/date_time_formatter.dart';
import '../../../../models/internet/internet.dart';

class Meta {
  static Future loadData(BuildContext context, int idVendedor, DateTime dataIni,
      DateTime dataFim) async {
    final body = {
      "id_vendedor": idVendedor,
      // "id_vendedor": 4502,
      // "id_vendedor": 7,
      "data_inicio": DateFormatter.databaseDate.format(dataIni),
      "data_fim": DateFormatter.databaseDate.format(dataFim)
    };

    final result = await Internet.serverPost('dash/status/pedido/',
        context: context, body: body);

    if (result.statusCode != 200) {
      throw Exception('Erro ao Coletar dados');
    }

    return const JsonDecoder().convert(result.body);
  }
}
