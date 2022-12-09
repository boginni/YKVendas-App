import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

import '../../../api/common/debugger.dart';

class AppUser {
  late String vendedor;
  late int vendedorAtual;
  late String ambiente;
  late String uuid;
  bool offline = false;


  bool fullsync = false;

  AppUser();

  factory AppUser.fromMaps(Map<String, dynamic> maps) {
    final app = AppUser();
    app.update(maps);
    return app;
  }

  update(Map<String, dynamic> maps) {
    try {
      vendedorAtual = maps['idVendedor'];
      ambiente = maps['ambiente'];
      uuid = maps['uuid'];
      vendedor = maps['vendedor'] ?? '';
    } catch (e) {
      // secureCall(_b(maps['']));
      // secureCall(maps[''].toDouble());
      printDebug(e.toString());

    }
  }

  dynamic secureCall(dynamic value) {
    if (value == null) {
      printDebug('Chamada inválida');

    }

    return value;
  }

  // bool _b(int? i) {
  //   if (i == null) {
  //     return false;
  //   }
  //
  //   return i == 1;
  // }

  factory AppUser.of(BuildContext context) {
    return context.read<AppUser>();
  }

  Map<String, dynamic> toMap() {
    return {'idVendedor': vendedorAtual, 'ambiente': ambiente, 'uuid': uuid};
  }

  Map<String, String> toHeaders() {
    return {
      'idVendedor': vendedorAtual.toString(),
      'ambiente': ambiente,
      'uuid': uuid
    };
  }
}
