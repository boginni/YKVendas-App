
import '../../../api/common/map_reader.dart';
import '../database/database_ambiente.dart';

class HistoricoPedidoDet {
  final int idProduto;
  final int? idCliente;
  final int? idVenda;
  final String nome;
  final double quantidade;
  final bool brinde;
  final double valorUnitario;
  final double valorDesconto;
  final double valorTotal;
  final bool mobile;
  final bool status;

  HistoricoPedidoDet({
    required this.idProduto,
    required this.idCliente,
    required this.idVenda,
    required this.nome,
    required this.quantidade,
    required this.brinde,
    required this.valorDesconto,
    required this.valorTotal,
    required this.valorUnitario,
    required this.mobile,
    required this.status,
  });

  factory HistoricoPedidoDet.fromMap(Map<String, dynamic> map) {
    dynamic value(String x) {
      return map[x];
    }

    dou(String x) {
      return double.tryParse(map[x].toString()) ?? 0.0;
    }

    douN(String x) {
      return double.tryParse(map[x].toString());
    }

    final r = MapReader(map);

    return HistoricoPedidoDet(
        idProduto: value('ID_PRODUTO'),
        idCliente: value('ID_CLIENTE'),
        idVenda: value('ID_VENDA_CAB'),
        nome: value('NOME') ?? '',
        quantidade: dou('QUANTIDADE'),
        brinde: value('BRINDE') == 1,
        valorDesconto: dou('VALOR_DESCONTO'),
        valorTotal: dou('VALOR_TOTAL'),
        valorUnitario: dou('VALOR_UNITARIO'),
        status: r.bo('STATUS'),
        mobile: r.bo('MOBILE'));
  }
}

// getHistoricoPeidoDet(id) async {
//   final maps = await DatabaseAmbiente.select('VW_HISTORICO_PEDIDO_DET',
//       where: 'ID_CLIENTE = ?', whereArgs: [id]);
//
//   return HistoricoPedidoDet.fromMap(maps[0]);
// }

Future<List<HistoricoPedidoDet>> getHistoricoPeidoDetList(int idVenda) async {
  final maps = await DatabaseAmbiente.select('VW_HISTORICO_PEDIDO_DET',
      where: 'ID_VENDA_CAB = ?', whereArgs: [idVenda]);

  List<HistoricoPedidoDet> list = [];

  for (final map in maps) {
    list.add(HistoricoPedidoDet.fromMap(map));
  }

  return list;
}
