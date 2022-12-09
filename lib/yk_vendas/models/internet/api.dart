import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import '../../../api/common/debugger.dart';

_getCepLink(int cep) {
  return 'https://viacep.com.br/ws/$cep/json/';
}

Future<dynamic> buscaCep(int cep) async {
  if (cep.toString().length < 8) {
    return;
  }

  Response response = await http.get(Uri.parse(_getCepLink(cep)));

  try {
    return const JsonDecoder().convert(response.body);
  } catch (e) {
    printDebug('invalid cep');
  }
}
