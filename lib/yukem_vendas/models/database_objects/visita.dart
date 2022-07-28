import 'package:brasil_fields/brasil_fields.dart';
import 'package:forca_de_vendas/api/common/formatter/date_time_formatter.dart';

import '../../../api/common/debugger.dart';
import '../../../api/models/database_objects/query_filter.dart';
import '../configuracao/app_ambiente.dart';
import '../database/database_ambiente.dart';

_parseStringToDateTime(String x) {
  return DateFormatter.databaseDate.parse(x);
}

class FiltrosVisitas {
  int? idRota;
  String? pesquisa;
  DateTime? criacao;

  FiltrosVisitas({this.idRota, this.criacao, this.pesquisa = ''});

  static bool isNumeric(String? s) {
    if (s == null) {
      return false;
    }
    try {
      return double.tryParse(s) != null;
    } catch (e) {
      return false;
    }
  }

  String getWhere() {
    String where = '';

    if (idRota != null) {
      where += 'ID_ROTA = ?';
    }

    if (criacao != null) {
      if (where.isNotEmpty) {
        where += ' AND ';
      }

      where += 'CRIACAO LIKE ?';
    }

    if (pesquisa != null) {
      if (where.isNotEmpty) {
        where += ' AND ';
      }

      if (isNumeric(pesquisa)) {
        where += 'ID_PESSOA LIKE ?';
      } else {
        where += 'NOME LIKE ?';
      }
    }

    return where;
  }

  List<dynamic> getArgs() {
    List<dynamic> args = [];

    if (idRota != null) {
      args.add(idRota);
    }

    if (criacao != null) {
      args.add("%${DateFormatter.databaseDate.format(criacao!)}%");
    }

    if (pesquisa != null) {
      if (isNumeric(pesquisa)) {
        args.add('$pesquisa');
      } else {
        args.add('%$pesquisa%');
      }
    }

    return args;
  }
}

enum VisitaStatus { aberto, edicao, concluida, cancelada, expirada }

class Visita {
  double? titulosVencendo;
  double? titulosVencido;
  double? limiteCredito;
  late int? idPessoaSync;

  late final bool isSync;

  late final String cpf_cnpj;

  late final bool faturamento;

  late bool orcamento;

  Visita();

  factory Visita.fromMap(Map<String, dynamic> map) {
    bool _bool(int b) {
      return b == 1 ? true : false;
    }

    double? _double(String x) {
      return map[x];
    }

    value(String x) {
      dynamic y = map[x];

      return y;
    }

    try {
      Visita v = Visita();

      v.id = value("ID_VISITA");
      v.idPessoa = value('ID_PESSOA');

      ///TODO: Trocar para id_pessoa_sync
      v.idPessoaSync = value('ID_PESSOA_SYNC');
      v.nome = value('NOME');
      v.apelido = value('APELIDO');

      v.logradouro = value('LOGRADOURO') ?? '';
      v.numero = value('NUMERO');
      v.cep = value('CEP');
      v.bairro = value('BAIRRO');
      v.cidade = value('CIDADE');
      v.uf = value('UF');
      v.estado = value('ESTADO');

      v.chegadaConcluida = _bool(value('CHEGADA_CONCLUIDA'));
      v.tabelaConcluida = _bool(value('TABELA_CONCLUIDA'));
      v.dadosEntregaConcluida = _bool(value('DADOS_ENTREGA_CONCLUIDA'));
      v.itensConcluida = _bool(value('ITENS_CONCLUIDA'));
      v.totaisConcluida = _bool(value('TOTAIS_CONCLUIDA'));
      v.situacao = value('SITUACAO');
      v.criacao = _parseStringToDateTime(value('CRIACAO'));
      v.isSync = _bool(value('SYNC'));

      v.cpf_cnpj = value('CPF_CNPJ') ?? '';

      v.faturamento = value('TIPO') == 0;
      v.orcamento = value('TIPO') == 2;

      v.titulosVencendo = _double('TITULOS_VENCER');
      v.titulosVencido = _double('TITULOS_VENCIDOS');
      v.limiteCredito = _double('LIMITE_CREDITO');
      return v;
    } catch (e) {
      printDebug(e.toString());
      rethrow;
    }
  }

  bool viewOnly() {
    return getStatus() == VisitaStatus.concluida;
  }

  int id = 0;
  int idPessoa = 0;
  String apelido = "";
  String nome = "";
  String logradouro = "";
  String numero = "";
  String cep = "";
  String bairro = "";
  String cidade = "";
  String uf = "";
  String estado = "";

  late DateTime criacao;

  bool chegadaConcluida = false;
  bool tabelaConcluida = false;
  bool dadosEntregaConcluida = false;
  bool itensConcluida = false;
  bool totaisConcluida = false;

  late final int situacao;

  String getEndereco() {
    String? cep;
    try {
      cep = UtilBrasilFields.obterCep(this.cep, ponto: false);
    } catch (e) {
      cep = this.cep;
    }
    return logradouro + " - " + bairro + " - " + cidade + " - " + cep;
  }

  VisitaStatus getStatus() {
    return VisitaStatus.values[situacao];
  }

  String getDataCriacao() {
    return DateFormatter.normalDataResumido.format(criacao);
  }

  bool podeSalvar(AppAmbiente app) {
    return (chegadaConcluida || !app.usarChegadaCliente) &&
        // tabelaConcluida &&
        // (dadosEntregaConcluida || !app.usarDadosEntrega) &&
        itensConcluida &&
        totaisConcluida;
  }

  Future abrirVisita() async {
    await DatabaseAmbiente.update('TB_VISITA', {'SITUACAO': 1},
        where: 'ID = ?', whereArgs: [id]);
  }

  /// Retorna a lista de visitas da tabela [VW_VISITA] para determinada Rota
  static Future<List<Visita>> getListVisitas(QueryFilter? queryFilter) async {
    late final List<Map<String, dynamic>> maps;

    if (queryFilter == null) {
      maps = await DatabaseAmbiente.select('VW_VISITA');
    } else {
      // printDebug('sql: ${queryFilter.getWhere()} \nparam ${queryFilter.getArgs()}');

      maps = await DatabaseAmbiente.select('VW_VISITA',
          where: queryFilter.getWhere(), whereArgs: queryFilter.getArgs());
    }

    final visitas = List.generate(maps.length, (i) {
      return Visita.fromMap(maps[i]);
    });

    return visitas;
  }

  static Future<List<Visita>> getListVisitas2(
      String args, List<dynamic> param) async {
    late final List<Map<String, dynamic>> maps;

    maps = await DatabaseAmbiente.select('VW_VISITA',
        where: args, whereArgs: param);

    final visitas = List.generate(maps.length, (i) {
      return Visita.fromMap(maps[i]);
    });

    return visitas;
  }

  /// Retorna uma única visita da [VW_VISITA] de acordo com o ID
  static Future<Visita> getVisita(int idVisita) async {
    final List<Map<String, dynamic>> maps = await DatabaseAmbiente.select(
        'VW_VISITA',
        where: "ID_VISITA = ?",
        whereArgs: [idVisita]);

    final visitas = List.generate(maps.length, (i) {
      return Visita.fromMap(maps[i]);
    });

    return visitas[0];
  }

  static Future criarNovasVisitas(
      DateTime time, int idRota, int idVendedor, AppAmbiente app) async {

    List<Map<String, dynamic>> maps = await DatabaseAmbiente.select(
        'VW_ROTA_CIDADE',
        where: 'ID_ROTA = ?',
        whereArgs: [idRota]);

    String cidades = '';

    if (maps.isNotEmpty) {
      String cidIds = '';

      for (final item in maps) {
        dynamic val = item['ID_CIDADE'];
        if (val != null) {
          cidIds += val.toString() + ',';
        }
      }

      cidIds = cidIds.substring(0, cidIds.length - 1);

      // bool blackList = false;

      // cidades = " and cli.ID_CIDADE in ($cidIds)";
    }

    String filtroVendedor = 'and x.ID_VENDEDOR = $idVendedor ';

    if (app.usarFirma && app.firma == idVendedor) {
      filtroVendedor = '';
    }

    String sql = "INSERT INTO TB_VISITA(ID_CLIENTE, ID_ROTA, ID_VENDEDOR) "
        " SELECT  "
        "X.ID_CLIENTE,"
        "X.ID_ROTA,  "
        "$idVendedor  "
        "FROM VW_ROTA_CLIENTE X  "
        "INNER JOIN TB_CLIENTE cli "
        "ON X.ID_CLIENTE = cli.ID and cli.STATUS = 1 "
        "LEFT JOIN TB_VISITA VI "
        "ON VI.ID_CLIENTE = X.ID_CLIENTE "
        "AND VI.ID_ROTA =X.ID_ROTA "
        "AND VI.CRIACAO LIKE '${DateFormatter.databaseDate.format(time)}%' "
        "WHERE VI.ID IS NULL"
        " and x.ID_ROTA = $idRota $filtroVendedor"
        "  $cidades ; ";

    await DatabaseAmbiente.execute(sql);
  }
}
