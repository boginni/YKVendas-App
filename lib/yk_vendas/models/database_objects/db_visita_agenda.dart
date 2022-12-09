import '../database/database_ambiente.dart';


Future<int> insertVisitaAgenda(int idCliente, idRota,
    {bool faturamento = false, required int idVendedor}) async {
  final db = await DatabaseAmbiente.getDatabase();

  final List<Map<String, dynamic>> maps =
      await db.rawQuery('select coalesce(max(id), 0) + 1 as ID from TB_VISITA');

  int id = maps[0]['ID'];

  final map = {
    'ID': id,
    'ID_CLIENTE': idCliente,
    'ID_ROTA': idRota,
    'ID_VENDEDOR' : idVendedor,
    'TIPO': faturamento ? 0 : 1
  };

  await DatabaseAmbiente.insert('TB_VISITA', map);

  return id;
}
