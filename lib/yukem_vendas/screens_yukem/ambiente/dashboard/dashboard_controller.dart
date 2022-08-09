import 'dart:convert';

import 'package:flutter/cupertino.dart';

import '../../../../api/common/formatter/date_time_formatter.dart';
import '../../../models/internet/internet.dart';

abstract class DashBoardController {

  static Future getCritica(
    BuildContext context, {
    required int idVendedor,
    required DateTime start,
    DateTime? end,
  }) async {
    final body = {
      "id_vendedor": idVendedor,
      // "id_vendedor": 7,
      "data_inicio": DateFormatter.databaseDate.format(start),
      "data_fim": DateFormatter.databaseDate.format(end ?? start)
    };

    final response = await Internet.serverPost('dash/critica/',
        context: context, body: body);

    if (response.statusCode != 200) {
      return;
    }

    return const JsonDecoder().convert(response.body)['rows'];

  }



}
