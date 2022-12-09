

import '../../../api/common/formatter/date_time_formatter.dart';
import '../../../api/common/map_reader.dart';
import '../database/database_ambiente.dart';

class ComodatoCab {
  int id;
  DateTime dataMovimento;
  DateTime dataVencimento;
  int idCliente;
  int status;
  bool cancelado;

  ComodatoCab(
      {required this.id,
      required this.dataMovimento,
      required this.dataVencimento,
      required this.idCliente,
      required this.status,
      required this.cancelado});

  factory ComodatoCab.fromMap(Map<String, dynamic> map) {
    dynamic value(String x) {
      return map[x];
    }

    double? douN(String x) {
      return double.tryParse(value(x).toString());
    }

    double dou(String x) {
      return douN(x) ?? 0;
    }

    DateTime getData(String x) {
      return DateTime.parse(value(x));
    }

    String format(String x) {
      return DateFormatter.normalData.format(getData(x));
    }


    MapReader mapReader = MapReader(map);

    return ComodatoCab(
      id: value('ID'),
      dataMovimento: getData('DATA_MOVIMENTO'),
      dataVencimento: getData('DATA_VENCIMENTO_COMODATO'),
      idCliente: value('ID_CLIENTE'),
      status: mapReader.integer('STATUS_COMODATO'),
      cancelado: mapReader.bo('CANCELADO'),
    );
  }

  Future<List<ComodatoDet>> getComodatoDet() async {
    // throw UnimplementedError();

    final maps = await DatabaseAmbiente.select('VW_COMODATOS',
        where: 'ID_CAB = ?', whereArgs: [id]);

    return List.generate(
        maps.length, (index) => ComodatoDet.fromMap(maps[index]));
  }
}

class ComodatoDet {
  int idCliente;
  int idDet;
  int idCab;
  int idProduto;
  double quantidade;
  String nome;

  ComodatoDet(
      {required this.idCliente,
      required this.idDet,
      required this.idCab,
      required this.idProduto,
      required this.quantidade,
      required this.nome});

  factory ComodatoDet.fromMap(Map<String, dynamic> map) {
    dynamic value(String x) {
      return map[x];
    }

    double? douN(String x) {
      return double.tryParse(value(x).toString());
    }

    double dou(String x) {
      return douN(x) ?? 0;
    }

    DateTime getData(String x) {
      return DateTime.parse(value(x));
    }

    String format(String x) {
      return DateFormatter.normalData.format(getData(x));
    }

    return ComodatoDet(
      idCliente: value('ID_CLIENTE'),
      idDet: value('ID'),
      idCab: value('ID_CAB'),
      idProduto: value('ID_PRODUTO'),
      quantidade: dou('QUANTIDADE'),
      nome: value('NOME') ?? '',
    );
  }


}

abstract class Comodato{
  static Future<List<ComodatoCab>> getComodatoCab(int? idPessoaSync, {bool mostrarFechados = false}) async {
    if (idPessoaSync == null) {
      return [];
    }

    final maps = await DatabaseAmbiente.select('TB_COMODATO_CAB',
        where: 'ID_CLIENTE = ? ${mostrarFechados? 'and STATUS_COMODATO != 1':''}',
        whereArgs: [idPessoaSync],
      orderBy: 'ID desc'
    );

    return List.generate(
        maps.length, (index) => ComodatoCab.fromMap(maps[index]));
  }

}

