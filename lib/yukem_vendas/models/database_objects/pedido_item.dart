import 'package:forca_de_vendas/yukem_vendas/models/database/database_ambiente.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PedidoItem {
  int id;
  int idVisita;
  int idProduto;
  bool brinde;
  double quantidade;
  double valorUnitario;
  double descontoValor;

  String unidadeMedida;
  String nome;

  double peso;

  PedidoItem(
      {required this.id,
      required this.idVisita,
      required this.idProduto,
      required this.brinde,
      required this.quantidade,
      required this.valorUnitario,
      required this.descontoValor,
      required this.unidadeMedida,
      required this.nome,
      required this.peso});

  factory PedidoItem.fromMap(Map<String, dynamic> map) {
    value(String x) {
      final y = map[x];
      if (y == null) {
        // printDebug('null call for $x');
        //
      }
      return y;
    }

    double? douN(String x) {
      try {
        final y = double.tryParse(value(x).toString());
        return y;
      } catch (e) {
        // printDebug(x);
        // printDebug(e);
        return null;
      }
    }

    double dou(String x) {
      return douN(x) ?? 0;
    }

    return PedidoItem(
        id: value('ID'),
        idVisita: value('ID_VISITA'),
        idProduto: value('ID_PRODUTO'),
        brinde: value('BRINDE') == 1,
        quantidade: dou('QUANTIDADE'),
        valorUnitario: dou('VALOR_UNITARIO'),
        descontoValor: dou('DESCONTO_VALOR'),
        nome: value('NOME_PRODUTO'),
        unidadeMedida: value('SIGLA'),
        peso: douN('PESO_LIQUIDO') ?? 0);
  }

  render(PdfGrid grid) {
    final PdfGridRow row = grid.rows.add();
    int i = 0;

    add(dynamic value, {int d = 2}) {
      if (value.runtimeType != String) {
        value = value.toStringAsFixed(d);
      }
      row.cells[i++].value = value;
    }

    dynamic b = brinde ? "Brinde" : quantidade * valorUnitario - descontoValor;

    add(idProduto, d: 0);
    add(nome);
    add(valorUnitario);
    add(quantidade, d: 0);
    add(descontoValor);
    add(b);
  }

  static Future<List<PedidoItem>> getListPedidoItemList(int idVisita,
      {int? idProduto}) async {
    String where = 'ID_VISITA = ? AND STATUS = 1';
    List<dynamic> param = [idVisita];

    if (idProduto != null) {
      where += ' AND ID_PRODUTO = ?';
      param.add(idProduto);
    }

    final maps = await DatabaseAmbiente.select('VW_PEDIDO_ITEM',
        where: where, whereArgs: param);

    return List.generate(
        maps.length, (index) => PedidoItem.fromMap(maps[index]));
  }
}
