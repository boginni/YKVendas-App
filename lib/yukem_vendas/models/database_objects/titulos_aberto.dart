import '../../../api/common/formatter/date_time_formatter.dart';
import '../database/database_ambiente.dart';

class TituloAberto {
  final int id;
  final int idEmpresa;
  final int idPessoa;
  final bool status;
  String documento;
  DateTime dataVencimento;
  double valor;
  double valorRestante;
  double valorJuros;
  double valorMulta;
  String? nota;

  TituloAberto(
      {required this.id,
      required this.idEmpresa,
      required this.idPessoa,
      required this.status,
      required this.documento,
      required this.dataVencimento,
      required this.valor,
      required this.valorRestante,
      required this.valorJuros,
      required this.valorMulta,
      required this.nota});

  factory TituloAberto.fromMap(Map<String, dynamic> map) {
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

    return TituloAberto(
        id: value('ID'),
        idEmpresa: value('ID_EMPRESA'),
        idPessoa: value('ID_PESSOA'),
        status: value('STATUS') == 1,
        documento: value('DOCUMENTO') ?? '',
        dataVencimento: getData('DATA_VENCIMENTO'),
        valor: dou('VALOR'),
        valorRestante: dou('VALOR_RESTANTE'),
        valorJuros: dou('VALOR_JUROS'),
        valorMulta: dou('VALOR_MULTA'),
        nota: value('NOTA') ?? '');
  }
}

Future<List<TituloAberto>> getTitulosAberto(int? idPessoaSync) async {
  if (idPessoaSync == null) {
    return [];
  }

  final maps = await DatabaseAmbiente.select('TB_TITULOS_ABERTO',
      where: 'ID_PESSOA = ?', whereArgs: [idPessoaSync]);

  return List.generate(
    maps.length,
    (index) => TituloAberto.fromMap(maps[index]),
  );
}
