import '../../../api/common/formatter/date_time_formatter.dart';
import '../database/database_ambiente.dart';

class Comissao {
  int id;
  int? idSync;
  int idVendedor;
  int idCliente;
  DateTime dataEmissao;
  double comissao;
  double valorTotal;
  String nomeCliente;

  factory Comissao.fromMap(Map<String, dynamic> map) {
    int intValue(String x) {
      return map[x] as int;
    }

    double doubleValue(String x) {
      return map[x] as double;
    }

    String stringValue(String x) {
      return map[x] as String;
    }

    return Comissao(
      comissao: doubleValue('COMISSAO'),
      dataEmissao: DateFormatter.databaseDate.parse(stringValue('DATA_EMISSAO')),
      idCliente: intValue('ID_CLIENTE'),
      idSync: null,
      valorTotal: doubleValue('VALOR_TOTAL'),
      id: intValue('ID'),
      idVendedor: intValue('ID_VENDEDOR'),
      nomeCliente: stringValue('NOME'),
    );
  }

  Comissao({
    required this.id,
    required this.idSync,
    required this.idVendedor,
    required this.idCliente,
    required this.dataEmissao,
    required this.comissao,
    required this.valorTotal,
    required this.nomeCliente,
  });

  String getData() {
    return DateFormatter.normalData.format(dataEmissao);
  }
}

class ComissaoMes {
  final String mes;
  double valorTotal;
  double comissao = 0;

  factory ComissaoMes.fromMap(Map<String, dynamic> map) {
    return ComissaoMes(map['MES'], double.parse(map['COMISSAO'].toString()),
        double.parse(map['VALOR_TOTAL'].toString()));
  }

  ComissaoMes(this.mes, this.comissao, this.valorTotal);
}

Future<List<ComissaoMes>> getListComissaoMes(int idVendedor) async {
  final List<Map<String, dynamic>> maps = await DatabaseAmbiente.select(
      'VW_COMISSAO_MES',
      where: 'ID_VENDEDOR = ?',
      whereArgs: [idVendedor]);

  Map<String, ComissaoMes> lastMonths = {};

  var date = DateTime.now();

  for (int i = 5; i >= 0; i--) {
    var newDate = DateTime(date.year, date.month - i, date.day);

    final String month = DateFormatter.mes.format(newDate);

    lastMonths[month] = ComissaoMes(month, 0, 0);
  }

  List<ComissaoMes> list = [];

  for (final item in maps) {
    if (lastMonths[item['MES']] != null) {
      lastMonths[item['MES']] = ComissaoMes.fromMap(item);
    }
  }

  lastMonths.forEach((key, value) {
    list.add(value);
  });

  return list;
}

Future<List<Comissao>> getListComissao(int idVendedor,
    {ComissaoMes? mes}) async {
  late final List<Map<String, dynamic>> maps;
  if (mes == null) {
    maps = await DatabaseAmbiente.select('VW_COMISSAO',
        where: 'ID_VENDEDOR = ?', whereArgs: [idVendedor]);
  } else {
    // printDebug([idVendedor, "%${mes.mes}%"]);
    maps = await DatabaseAmbiente.select('VW_COMISSAO',
        where: 'ID_VENDEDOR = ? and MES = ?', whereArgs: [idVendedor, mes.mes]);
  }

  return List.generate(maps.length, (index) {
    return Comissao.fromMap(maps[index]);
  });
}
