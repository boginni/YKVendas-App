import 'package:forca_de_vendas/yukem_vendas/models/database/database_ambiente.dart';

class Contato {
  int idPessoa;
  String tipo;
  String ddd;
  String contato;

  Contato(
      {required this.idPessoa,
      required this.tipo,
      required this.ddd,
      required this.contato});

  factory Contato.fromMap(Map<String, dynamic> map) {
    dynamic value(String x) {
      return map[x];
    }

    return Contato(
        idPessoa: value('ID_PESSOA'),
        tipo: value('TIPO'),
        ddd: value('DDD'),
        contato: value('CONTATO'));
  }
}

Future<List<Contato>> getContatos(int? idPessoa) async {
  if (idPessoa == null) {
    return [];
  }

  List<Map<String, dynamic>> maps = await DatabaseAmbiente.select('VW_CONTATO',
      where: 'ID_PESSOA = ?', whereArgs: [idPessoa]);

  return List.generate(maps.length, (index) => Contato.fromMap(maps[index]));
}
