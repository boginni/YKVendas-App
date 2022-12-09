import '../../../api/common/debugger.dart';
import '../database/database_ambiente.dart';

class VisitaItemList {

  int id;
  int idVisita;
  int idProduto;
  bool brinde;
  double quantidade;
  double valorUnitario;
  double descontoValor;

  VisitaItemList(
      {required this.id,
      required this.idVisita,
      required this.idProduto,
      required this.brinde,
      required this.quantidade,
      required this.valorUnitario,
      required this.descontoValor});

  factory VisitaItemList.fromMap(Map<String, dynamic> map) {
    value(String x) {
      final y = map[x];
      if (y == null) {
        printDebug('null call for $x');

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
    // ID	ID_VISITA	ID_PRODUTO	BRINDE	QUANTIDADE	STATUS	VALOR_UNITARIO	ALTERACAO_VALOR	DESCONTO_VALOR

    return VisitaItemList(
        id: value('ID'),
        idVisita: value('ID_VISITA'),
        idProduto: value('ID_PRODUTO'),
        brinde: value('BRINDE') == 1,
        quantidade: dou('QUANTIDADE'),
        valorUnitario: dou('VALOR_UNITARIO'),
        descontoValor: dou('DESCONTO_VALOR'));
  }

  static Future<List<VisitaItemList>> getListItem(int idVisita,
      {int? idProduto}) async {
    String where = 'ID_VISITA = ? AND STATUS = 1';
    List<dynamic> param = [idVisita];

    if (idProduto != null) {
      where += ' AND ID_PRODUTO = ?';
      param.add(idProduto);
    }

    final maps = await DatabaseAmbiente.select('TB_VISITA_ITEM',
        where: where, whereArgs: param);

    return List.generate(
        maps.length, (index) => VisitaItemList.fromMap(maps[index]));
  }
}
