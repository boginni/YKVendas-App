import 'package:flutter/cupertino.dart';
import 'package:forca_de_vendas/api/common/map_reader.dart';
import 'package:forca_de_vendas/yukem_vendas/models/database/database_ambiente.dart';

import '../../../../models/database_objects/cliente.dart';
import 'pedido_item.dart';

class Pedido {
  List<PedidoItem> itens = [];

  final int id;
  int? idCliente;
  int? idClienteSync;

  // final int idCliente;
  // final int idVendedor;
  // final int idRota;

  Pedido(
      {required this.id, required this.idCliente, required this.idClienteSync});

  factory Pedido.ofMap(Map<String, dynamic> map) {
    final r = MapReader(map);
    return Pedido(
      id: r.integer('ID'),
      idCliente: r.integer('ID_CLIENTE'),
      idClienteSync: r.integer('ID_CLIENTE_SYNC'),
    );
  }

  static Future<List<Pedido>> loadData(BuildContext context) async {
    final resultSet = await DatabaseAmbiente.select('TB_PEDIDO');

    final list = <Pedido>[];
    for (final row in resultSet) {
      list.add(Pedido.ofMap(row));
    }

    return list;
  }

  static Future<Pedido> create(BuildContext context,
      {int idTipo = 1, int? idRota, required int idVendedor}) async {
    final map = {
      'DATA_CRIACAO': 'current_date',
      'ID_TIPO': idTipo,
      'ID_ROTA': idRota,
      'ID_VENDEDOR': idVendedor
    };

    final id = await DatabaseAmbiente.insert('TB_PEDIDO', map);

    final resultSet = await DatabaseAmbiente.select(
      'TB_PEDIDO',
      where: 'ID = ?',
      whereArgs: [id],
    );

    return Pedido.ofMap(resultSet[0]);
  }

  Future createItem({required int idTabela, required int idProduto}) async {
    final map = {
      'ID_TABELA': idTabela,
      'ID_PRODUTO': idProduto,
      'ID_PEDIDO': this.id
    };

    final id = await DatabaseAmbiente.insert('TB_PEDIDO_ITEM', map);

    final resultSet = await DatabaseAmbiente.select(
      'TB_PEDIDO_ITEM',
      where: 'ID = ?',
      whereArgs: [id],
    );

    itens.add(PedidoItem.ofMap(resultSet[0]));
  }

  Future loadItens() async {
    final resultSet = await DatabaseAmbiente.select('TB_PEDIDO_ITEM',
        where: 'ID_PEDIDO = ?', whereArgs: [id]);

    final list = <PedidoItem>[];
    for (final row in resultSet) {
      list.add(PedidoItem.ofMap(row));
    }

    itens = list;
  }

  update(Map<String, dynamic> map) async {
    await DatabaseAmbiente.update(
      'TB_PEDIDO',
      map,
      where: 'ID = ?',
      whereArgs: [id],
    );
  }

  setCliente(Cliente c) async {
    idCliente = c.id;
    idClienteSync = c.idSync;

    final map = {
      'ID_CLIENTE': c.id,
      'ID_CLIENTE_SYNC': c.idSync,
    };
    await update(map);
  }
}
