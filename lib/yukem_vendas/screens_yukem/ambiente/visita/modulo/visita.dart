import 'package:forca_de_vendas/api/common/map_reader.dart';
import 'package:forca_de_vendas/yukem_vendas/models/database/database_ambiente.dart';

import '../../../../../api/common/debugger.dart';

class ModuloVisita {
  final int id;
  final int? idSync;
  final int idCliente;
  final int? idClienteSync;
  final int idVendedor;
  final int idRota;
  int idTabela;
  String? uuid;
  int situacao;
  final String? dataCriacao;
  final int tipo;
  bool status;
  bool sync;
  bool init;

  late final bool faturamento;

  ModuloVisita(
      {required this.id,
      required this.idSync,
      required this.idCliente,
      required this.idClienteSync,
      required this.idVendedor,
      required this.idRota,
      required this.idTabela,
      required this.uuid,
      required this.situacao,
      required this.dataCriacao,
      required this.tipo,
      required this.status,
      required this.sync,
      required this.init});

  factory ModuloVisita.fromMap(Map<String, dynamic> iMap) {
    final map = MapReader(iMap);

    final v = ModuloVisita(
        id: map.integer('ID'),
        idSync: map.intN('ID_SYNC'),
        idCliente: map.integer('ID_CLIENTE'),
        idClienteSync: map.intN('ID_CLIENTE_SYNC'),
        idVendedor: map.integer('ID_VENDEDOR'),
        idRota: map.integer('ID_ROTA'),
        idTabela: map.integer('ID_TABELA'),
        uuid: map.value('UUID'),
        situacao: map.integer('SITUACAO'),
        dataCriacao: map.value('CRIACAO'),
        tipo: map.integer('TIPO'),
        status: map.bo('STATUS'),
        sync: map.bo('SYNC'),
        init: map.bo('INIT'));

    v.faturamento = map.value('TIPO') == 0;

    return v;
  }

  Future<void> update(Map<String, dynamic> maps) async {
    await DatabaseAmbiente.update('TB_VISITA', maps,
        where: 'ID = ?', whereArgs: [id]);
    // printDebug('visita update : ${maps}');
  }

  static Future<ModuloVisita> fromId(int idVisita) async {
    final maps = await DatabaseAmbiente.select('TB_VISITA',
        where: 'ID = ?', whereArgs: [idVisita]);
    if (maps.length != 1) {
      throw Exception('Id visita inválido: ${idVisita}');
    }
    return ModuloVisita.fromMap(maps[0]);
  }

  Future abrirVisita() async {
    await update({'SITUACAO': 1});
  }

  void setInit(bool bool) async {
    init = bool;
    update({'INIT': bool ? 1 : 0});
  }

  void setTabela(int i) async {
    idTabela = i;
    update({'ID_TABELA': i});
  }
}
