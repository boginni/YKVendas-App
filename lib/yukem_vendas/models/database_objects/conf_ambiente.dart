
import '../database/database_ambiente.dart';

class UserConfig {
  final int id;
  final String nome;
  final String? descricao;
  String valor;
  int tipo;

  UserConfig({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.valor,
    required this.tipo,
  });
}

// Future<List<UserConfig>> getUserConfig() async {
//   List<Map<String, dynamic>> maps = await DatabaseAmbiente.select('VW_CONFIG_USER');
//
//   final list = List.generate(maps.length, (i) {
//     return UserConfig(
//         id: maps[i]['ID'],
//         nome: maps[i]['NOME'],
//         descricao: maps[i]['DESCRICAO'],
//         valor: maps[i]['VALOR'],
//         tipo: maps[i]['TIPO']);
//   });
//
//   return list;
// }

Future updateConfig(UserConfig x) async {
  await DatabaseAmbiente.update('CONF_USER', {'VALOR': x.valor},
      where: 'ID = ?', whereArgs: [x.id]);
}
