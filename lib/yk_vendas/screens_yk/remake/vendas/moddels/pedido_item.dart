
import '../../../../../api/common/map_reader.dart';

class PedidoItem {
  final int id;
  final int idPedido;
  final int idProduto;
  final int idTabela;
  double quantidade;
  bool brinde;
  double valorUniario;
  double valorDesconto;

  PedidoItem(this.id, this.idPedido, this.idProduto, this.idTabela,
      this.quantidade, this.brinde, this.valorUniario, this.valorDesconto);

  factory PedidoItem.ofMap(Map<String, dynamic> map) {
    final r = MapReader(map);
    return PedidoItem(
      r.integer('ID'),
      r.integer('ID_PEDIDO'),
      r.integer('ID_PRODUTO'),
      r.integer('ID_TABELA'),
      r.dou('QUANTIDADE'),
      r.bo('STATUS_BRINDE'),
      r.dou('VALOR_UNITARIO'),
      r.dou('VALOR_DESCONTO'),
    );
  }
}
