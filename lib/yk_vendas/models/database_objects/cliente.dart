// ignore_for_file: unused_import

import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';

import '../../../api/app/app_user.dart';
import '../../../api/common/debugger.dart';
import '../../../api/common/formatter/date_time_formatter.dart';
import '../../../api/models/database_objects/query_filter.dart';
import '../configuracao/app_user.dart';
import '../database/database_ambiente.dart';
import 'contato.dart';

class Cliente {
  Cliente();

  String? nomeOrcamento;

  String? getNomeOrcamento() {
    if (nomeOrcamento == null || nomeOrcamento!.isEmpty) {
      return null;
    }

    return nomeOrcamento;
  }

  List<Contato> contatos = [];

  int? id;
  int? idSync;

  late bool toSync;

  bool pessoaJuridica = false;
  late String tipoPessoa;

  String? nome;
  String? apelido;
  String? cpfcnpj;
  String? inscricaoEstadual;

  String? rg;

  String? dataNascimento;
  String? dddCelular;
  String? celular;
  String? dddTelefone;
  String? telefone;
  String? email;
  String? obs;
  String? cidade;
  String? municipio;
  String? cep;
  String? bairro;

  String? logradouro;
  String? numero;
  String? complementoLogadouro;
  String? uuid;

  String? whatsapp;

  /// Utilizado para inserir no banco de dados local
  Map<String, dynamic> toMap() {
    final maps = {
      'ID': id,
      'ID_SYNC': idSync,
      'TO_SYNC': toSync ? 1 : 0,
      'UUID': uuid,
      'TITULOS_VENCIDOS': null,
      'TITULOS_VENCER': null,
      'LIMITE_CREDITO': null,
      'NOME': nome,
      'APELIDO': apelido,
      'CPF_CNPJ': cpfcnpj,
      'RG': rg,
      'DATA_NASCIMENTO': dataNascimento,
      'INSCRICAO_ESTADUAL': inscricaoEstadual,
      'DDD_CELULAR': dddCelular,
      'CELULAR': celular,
      'DDD_TELEFONE': dddTelefone,
      'TELEFONE': telefone,
      'EMAIL': email,
      'WHATSAPP': whatsapp,
      'UF': null,
      'CIDADE': cidade,
      'LOGRADOURO': logradouro,
      'CEP': cep,
      'COMPLEMENTO': complementoLogadouro,
      'BAIRRO': bairro,
      'NUMERO': numero,
      'ID_CIDADE': idCidade,
      'OBSERVACAO': obs,
      'ID_TABELA_PRECO': idTabelaPrecos,
      'ID_USUARIO': idUsuario,
      'ID_FORMA_PG': idFormaPg,
      'ID_CLIENTE_TIPO': idClienteTipo,
      'ID_ROTA': idRota,
      'TIPO_PESSOA': pessoaJuridica ? 'J' : 'F',
    };

    return maps;
  }

  int? idTabelaPrecos;
  int idUsuario = 0;

  int? idFormaPg;
  int? idFormaPgTipo;

  int? idClienteTipo;
  String? clienteTipo;

  int? idCidade;
  int? idUf;
  int? idRota;

  /// Ulitlizado para fazer sincronização
  // @override
  Map<String, dynamic> toBody() {
    final String tipoPessoa = pessoaJuridica ? 'J' : 'F';
    late String? nascimento;

    try {
      DateTime date = DateFormatter.normalData.parse(dataNascimento.toString());
      nascimento = DateFormatter.normalData.format(date);
    } catch (e) {
      nascimento = '';
    }

    final maps = {
      /// CONFIGURAÇÕES
      'idsync': idSync,
      'tipopessoa': tipoPessoa,
      'idrota': idRota ?? 0,
      'idformapg': idFormaPg ?? 0,
      'formacad': 0,
      'idusuario': idUsuario,
      'idtabelapreco': idTabelaPrecos ?? 0,
      'idintegracao': uuid,

      /// Cadastro Básico
      'nome': apelido ?? '',
      'razao': nome ?? '',
      'cpfcnpj': cpfcnpj ?? '',
      'datanascimento': nascimento,
      'inscricaoestadual': inscricaoEstadual ?? '',
      'rg': rg ?? '',

      /// CONTATO
      'email': email ?? '',
      'dddtelefone': dddTelefone ?? '',
      'telefone': telefone ?? '',
      'dddcelular': dddCelular ?? '',
      'celular': celular ?? '',
      'whatsapp': whatsapp ?? '',

      /// ENDEREÇO
      'cep': cep ?? '',
      'cidade': '',
      'uf': '',
      'endereco': logradouro ?? '',
      'numero': numero ?? '',
      'bairro': bairro ?? '',
      'complemento': complementoLogadouro ?? '',
      'idCidade': idCidade ?? 0,

      'observacao': obs ?? '',
      'sexo': 'M',
      'idtipo': idClienteTipo,
    };

    return maps;
  }

  static const String _viewVendedor = 'VW_CLIENTE_VENDEDOR';
  static const String _viewNormal = 'VW_CLIENTE';

  static Future<List<Cliente>> getData(
    BuildContext context, {
    String busca = '',
    bool clienteVendedor = true,
    bool buscaIdCnpj = true,
    int limit = 20,
  }) async {
    String x = busca;

    int idVendedor = AppUser.of(context).vendedorAtual;

    final field = buscaIdCnpj ? 'ID_SYNC =' : 'CPF_CNPJ like';
    final filter = '(NOME like ? or APELIDO like ? or $field ?)';
    String args = 'STATUS = 1';

    List<dynamic> param = [];
    if (x.isNotEmpty) {
      args += ' and ${filter}';
      param.add('%$x%');
      param.add('%$x%');
      param.add(buscaIdCnpj ? x : '%$x%');
    }

    if (clienteVendedor) {
      args += ' and (ID_VENDEDOR = ? )';
      param.add(idVendedor);
    }

    // return await Cliente.getList(args, param, normal: !clienteVendedor);

    String view = clienteVendedor ? _viewVendedor : _viewNormal;

    final maps = await DatabaseAmbiente.select(
      view,
      where: args,
      whereArgs: param,
      orderBy: 'ID_SYNC',
      limit: limit,
    );

    return _getList(maps);
  }

  static Future<List<Cliente>> getList(String args, List<dynamic> param,
      {String order = 'ID_SYNC',
      bool normal = false,
      int? limit = null}) async {

    late final List<Map<String, dynamic>> maps;

    String view = normal ? _viewNormal : _viewVendedor;

    maps = await DatabaseAmbiente.select(view,
        where: args, whereArgs: param, orderBy: order, limit: limit);

    final list = _getList(maps);

    return list;
  }

  /// Insere o clinte
  static Future<void> insertCliente(Cliente cliente,
      {bool force = false,
      Function? onSucess,
      Function? onDuplicated,
      Function? onFail}) async {
    final ca = force ? ConflictAlgorithm.replace : ConflictAlgorithm.abort;

    await DatabaseAmbiente.insert('TB_CLIENTE', cliente.toMap(),
        conflictAlgorithm: ca, printStack: false, onFail: (e) {
      if (e is DatabaseException) {
        e.isUniqueConstraintError();
      }
      if (onDuplicated != null) {
        onDuplicated();
      }
    }, onSucces: () {
      if (onSucess != null) {
        onSucess();
      }
    });
  }

// Future<int?> getID(int idSync){
//   select()
// }

  /// retorna a lista de clientes da tabela [TB_CLIENTE]
  static Future<List<Cliente>> getClientes(
      {QueryFilter? queryFilter,
      String order = 'ID_SYNC',
      bool normal = false}) async {
    String view = normal ? _viewNormal : _viewVendedor;




    late final List<Map<String, dynamic>> maps;


    if (queryFilter == null) {
      maps = await DatabaseAmbiente.select(view, orderBy: order);
    } else {
      maps = await DatabaseAmbiente.select(view,
          where: queryFilter.getWhere(),
          whereArgs: queryFilter.getArgs(),
          orderBy: 'ID_SYNC');
    }


    final list = _getList(maps);
    return list;
  }

  static Future<Cliente?> getCliente(int idPessoa, {bool sync = false}) async {
    final queryFilter = QueryFilter(args: {sync ? 'ID_SYNC' : 'ID': idPessoa});

    late final List<Map<String, dynamic>> maps;
    if (queryFilter == null) {
      maps = await DatabaseAmbiente.select(_viewNormal);
    } else {
      maps = await DatabaseAmbiente.select(_viewNormal,
          where: queryFilter.getWhere(), whereArgs: queryFilter.getArgs());
    }

    final list = _getList(maps);

    final cliente = list[0];

    if (cliente != null) {
      Future<String> getCidade(int id) async {
        final map = await DatabaseAmbiente.select('PRE_CIDADE',
            where: 'ID = ?', whereArgs: [id]);

        return map[0]['NOME']!;
      }

      cliente.contatos = await getContatos(cliente.idSync);
      if (cliente.idCidade != null) {
        cliente.cidade = await getCidade(cliente.idCidade!);
      }
    }

    return cliente;
  }

  static Future<Cliente> getClienteSync(int idPessoaSync) async {
    final queryFilter = QueryFilter(args: {'ID_SYNC': idPessoaSync});

    late final List<Map<String, dynamic>> maps;
    if (queryFilter == null) {
      maps = await DatabaseAmbiente.select(_viewNormal);
    } else {
      maps = await DatabaseAmbiente.select(_viewNormal,
          where: '${queryFilter.getWhere()} and ID != 0',
          whereArgs: queryFilter.getArgs());
    }

    final list = _getList(maps);

    if (list.length != 1) {
      throw Exception('Invalido idSync');
    }

    return list[0];
  }

  static List<Cliente> _getList(List<Map<String, dynamic>> maps) {
    final list = List.generate(maps.length, (i) {
      String? value(String x) {
        final y = maps[i][x];

        if (y == null) {
          return y;
        }
        return y.toString();
      }

      int? intValue(String x) {
        int? r = int.tryParse(value(x) ?? '');

        return r;
      }

      Cliente c = Cliente();

      // printDebug(maps[0]);
      try {
        c.id = intValue('ID');
        c.apelido = value('APELIDO');
        c.nome = value('NOME');
        c.cpfcnpj = value('CPF_CNPJ');
        c.rg = value('RG');
        c.bairro = value('BAIRRO');
        c.logradouro = value('LOGRADOURO');
        c.numero = value('NUMERO');
        c.cep = value('CEP');

        c.uuid = value("UUID");
        c.idSync = intValue("ID_SYNC");
        // c .null = value ("TITULOS_VENCIDOS");
        // c. null = value ("TITULOS_VENCER");
        // c. null = value ("LIMITE_CREDITO");
        c.nome = value("NOME");
        c.apelido = value("APELIDO");
        c.cpfcnpj = value("CPF_CNPJ") ?? '';
        c.rg = value("RG");
        c.dataNascimento = value("DATA_NASCIMENTO");
        c.inscricaoEstadual = value("INSCRICAO_ESTADUAL");
        c.dddCelular = value("DDD_CELULAR");
        c.celular = value("CELULAR");
        c.dddTelefone = value("DDD_TELEFONE");
        c.telefone = value("TELEFONE");
        c.email = value("EMAIL");
        c.whatsapp = value("WHATSAPP");
        c.cidade = value("CIDADE");

        c.logradouro = value("LOGRADOURO");
        c.cep = value("CEP");
        c.complementoLogadouro = value("COMPLEMENTO");
        c.bairro = value("BAIRRO");
        c.numero = value("NUMERO");
        c.obs = value("OBSERVACAO");

        c.idRota = intValue("ID_ROTA");
        c.idCidade = intValue("ID_CIDADE");
        c.idTabelaPrecos = intValue("ID_TABELA_PRECOS");
        c.idUsuario = intValue("ID_USUARIO") ?? 0;
        c.idFormaPg = intValue("ID_FORMA_PG");
        c.idFormaPgTipo = intValue("ID_FORMA_PG_TIPO");

        c.idClienteTipo = intValue("ID_CLIENTE_TIPO");
        c.clienteTipo = value('CLIENTE_TIPO');

        c.obs = value('OBSERVACAO');

        c.pessoaJuridica = c.cpfcnpj!.length >= 12;

        c.tipoPessoa =
            value("TIPO_PESSOA") == null ? 'F' : value("TIPO_PESSOA")!;

        c.toSync = value("TO_SYNC") == '1';

        return c;
      } catch (e) {
        printDebug(e.toString());
        rethrow;
      }
    });

    return list;
  }
}
