import 'package:flutter/material.dart';
import 'package:forca_de_vendas/api/common/formatter/arredondamento.dart';
import 'package:provider/provider.dart';

import '../../../api/common/debugger.dart';
import '../../../yukem_vendas/models/database/database_ambiente.dart';
import '../../../yukem_vendas/models/database_objects/rota.dart';
import '../pdf/drawFotter.dart';

Future<void> setAmbienteConfig(int id, dynamic x) async {
  final db = await DatabaseAmbiente.getDatabase();

  final String value = x.toString();
  //TODO check no tamanho da string

  await db.update('CONF_USER', {'VALOR': value},
      where: 'ID = ?', whereArgs: [id]);
}

Future<String> getAmbienteConfig(int id) async {
  final List<Map<String, dynamic>> maps =
      await DatabaseAmbiente.select('TB_PRODUTO');

  return maps[0]["VALOR"];
}

Future<Rota> getUltimaRota() async {
  // final List<Map<String, dynamic>> maps = await select('VW_ULTIMA_ROTA');

  //TODO: Mudar para construtor ou createobject
  Rota r = Rota();

  r.nome = '';
  r.id = 0;

  // try{
  //   r.id = maps[0]['ID'];
  //   r.nome = maps[0]['NOME'];
  // } catch(e){
  //   r.nome = '';
  //   r.id = 0;
  // }

  return r;
}



class AppAmbiente {

  static Future<Map<String, dynamic>> getAppAmbiente(int idUser) async {
    final List<Map<String, dynamic>> list =
    await DatabaseAmbiente.select('VW_CONFIG_USER', where: '');

    Map<String, dynamic> maps = {};

    for (var row in list) {
      maps[row['NOME']] = int.parse(row['VALOR']);
    }

    // final config = AppConfig(maps);
    return maps;
  }

  late bool mostrarTabela;

  Color saveButtonColor = Colors.white;

  late int rotaPadrao;
  late bool usarRota;
  late int tabelaPadrao;
  late bool usarTabela;
  late int formaPagamentoPadrao;
  late bool usarFormaPagamento;
  late bool usarAssinatura;
  late bool usarCadastroCliente;
  late bool usarDescontoMax;
  late bool usarChegadaCliente;
  late bool usarDadosEntrega;
  late bool usarDescontoCima;
  late bool usarDescontoBaixo;
  late bool usarDescontoItem;
  late bool usarDescontoTotal;
  late bool mostrarVisitaConcluida;
  late bool mostrarVisitaCancelada;
  late bool mostrarVisitaExpirada;
  late bool usarFotoVisitaRealisada;
  late bool mostrarDetalhesCategoria;
  late bool mostrarQuantidadeReservada;
  late bool usarLimiteCredito;
  late bool mostrarFotoProduto;
  late bool usarDescontoVendedorItem;
  late bool alterarPrecoUndCima;
  late bool alterarPrecoUndBaixo;
  late bool mostrarEstoque;
  late bool calcularEstoque;
  late bool usarBrinde;

  late bool usarVendasTotais;
  late bool usarComissao;

  String? uuid;

  late bool importarValorUnt;

  late bool usarFiltroClienteVendedor;

  late bool limitarResultados;

  late bool mostrarIconeProduto;

  late bool descontoValor;

  late bool descontoPct;

  late bool ranquearFormaPg;

  AppAmbiente();

  factory AppAmbiente.of(BuildContext context) {
    return context.read<AppAmbiente>();
  }

  factory AppAmbiente.fromMap(Map<String, dynamic> maps) {
    // printDebug(maps);

    final app = AppAmbiente();

    app.update(maps);
    return app;
  }

  update(Map<String, dynamic> maps) {
    dynamic valueMap(String x) {
      dynamic value = maps[x];

      /// Verifica se eh nulo
      if (value == null) {
        printDebug('Config $x invalida');
        return null;
      }
      return value;
    }

    bool getBool(String fieldName, bool defaultValue) {
      try {
        int? value = int.tryParse(valueMap(fieldName).toString());

        if (value == null) {
          return defaultValue;
        }

        return value == 1;
      } catch (e) {
        return defaultValue;
      }
    }

    int getInt(String fieldName, int defaultValue) {
      try {
        int? value = int.tryParse(valueMap(fieldName).toString());

        if (value == null) {
          return defaultValue;
        }

        return value;
      } catch (e) {
        return defaultValue;
      }
    }

    int getStr(String fieldName, int defaultValue) {
      try {
        dynamic value = valueMap(fieldName);

        if (value == null) {
          return defaultValue;
        }

        return value;
      } catch (e) {
        return defaultValue;
      }
    }

    usarRota = getBool('USAR ROTA', false);
    usarTabela = getBool('USAR TABELA', false);
    tabelaPadrao = getInt('PADRAO TABELA', 0);
    usarAssinatura = getBool('USA ASSINATURA', false);
    rotaPadrao = getInt('PADRAO ROTA', 0);
    usarFormaPagamento = getBool('USAR FORMA PAGAMENTO', false);
    formaPagamentoPadrao = getInt('PADRAO FORMA PAGAMENTO', 1);
    usarCadastroCliente = getBool('USAR CADASTRO CLIENTE', false);
    usarChegadaCliente = getBool('USAR CHEGADA CLIENTE', false);

    usarDadosEntrega = getBool('USAR TELA ENTREGA', false);
    usarDescontoMax = getBool('USAR DESCONTO MAXIMO', false);

    usarDescontoCima = getBool('DESCONTO CIMA', false);
    usarDescontoBaixo = getBool('DESCONTO BAIXO', false);

    usarDescontoItem = getBool('DESCONTO ITEM', false);
    usarDescontoTotal = getBool('DESCONTO TOTAL', false);

    mostrarVisitaConcluida = getBool('EXIBIR VISITA CONCLUIDA', false);
    mostrarVisitaCancelada = getBool('EXIBIR VISITA CANCELADA', false);
    mostrarVisitaExpirada = getBool('EXIBIR VISITA EXPIRADA', false);

    usarFotoVisitaRealisada = getBool('USAR FOTO VISITA REALIZADA', false);
    mostrarDetalhesCategoria = getBool('EXIBIR DETALHES CATEGORIA', false);
    mostrarQuantidadeReservada = getBool('MOSTRAR QUANTIDADE RESERVADA', false);
    usarLimiteCredito = getBool('USAR LIMITE CREDITO', false);
    mostrarFotoProduto = getBool('MOSTRAR FOTO PRODUTO', false);
    mostrarEstoque = getBool('EXIBIR ESTOQUE', false);
    calcularEstoque = getBool('CALCULAR ESTOQUE', false);

    usarDescontoVendedorItem = getBool('USAR DESCONTO VENDEDOR NO ITEM', false);
    alterarPrecoUndCima = getBool('ALTERAR PRECO UND CIMA', false);
    alterarPrecoUndBaixo = getBool('ALTERAR PRECO UND BAIXO', false);

    usarFaturamento = getBool('USAR FATURAMENTO', false);

    usarEncerramentoDia = getBool('USAR ENCERRAMENTO DIA', false);
    usarConsultas = getBool('USAR CONSULTAS', false);
    usarBotaoComNota = getBool('USAR BOTAO DE COM NOTA', false);
    mostrarTabela = getBool('MOSTRAR TABELA', true);
    importarValorUnt = getBool('IMPORTAR VALOR UNITARIO', true);

    firma = getInt('FIRMA', 0);

    usarFirma = getBool('USAR FIRMA', false);
    usarBrinde = getBool('USAR BRINDE', false);

    usarComissao = getBool('USAR COMISSAO', false);
    usarVendasTotais = getBool('USAR VENDAS TOTAIS', false);

    usarFiltroClienteVendedor = getBool('USAR FILTRO CLIENTE VENDEDOR', true);
    usarFaturamentoComoOrcamento =
        getBool('NOME FATURAMENTO COMO ORCAMENTO', false);

    limitarResultados = getBool('LIMITAR RESULTADOS DE PESQUISA', false);

    idPessoaOrcamento = getInt('ID PESSOA ORCAMENTO', 0);

    mostrarIconeProduto = getBool('MOSTRAR ICONE DO PRODUTO', false);

    descontoValor = getBool('DESCONTO EM VALOR', false);
    descontoPct = getBool('DESCONTO EM PCT', false);

    valor = getInt('DECIMAL ARREDONDAMENTO', 0);

    ranquearFormaPg = getBool('RANQUEAR FORMA PG', false);
    buscaClientId = getBool('BUSCA POR ID/CNPJ', true);

    adicionarProdutoNegativoOrcamento =
        getBool('ADICIONAR PRODUTO NEGATIVO NA TELA DE ORCAMENTO', false);
    limparTrocarTabela = getBool('LIMPAR AO TROCAR TABELA', false);
    todosClientesFaturamento =
        getBool('TODOS OS CLIENTES EM FATURAMENTO', false);

    usarIncluirVisitaAgenda = getBool('USAR INCLUIR VISITA NA AGENDA', false);

    permitirFormaPgNula = getBool('USAR FORMA DE PAGAMENTO NULA', false);

    usarBloqueioFormaPg = getBool('USAR BLOQUEIO FORMA PG', false);

    padraoFormaPagCadastro = getInt('PADRAO FORMA PAG CADASTRO', 0);

    mostrarFormaPgCliente = getBool('MOSTRAR FORMA PG CLIENTE', false);

    usarCancelamentoFaturamento =
        getBool('USAR CANCELAMENTO NO FATURAMENTO', false);

    permitirDuplicarItens = getBool('PERMITIR DUPLICAR ITENS', false);

    diasValidadeOrcamento = getInt('DIAS VALIDADE ORCAMENTO', 7);

    diasValidos = diasValidadeOrcamento;

    //MOSTRAR TABELA
    // getBool('', false);
  }

  // NOME FATURAMENTO COMO ORCAMENTO

  late int diasValidadeOrcamento;
  late bool permitirDuplicarItens;

  late int idPessoaOrcamento;
  late bool usarFaturamento;
  late bool usarEncerramentoDia;
  late bool usarConsultas;
  late bool usarBotaoComNota;
  late int firma;
  late bool usarFirma;
  late bool usarFaturamentoComoOrcamento;
  late bool buscaClientId;

  late bool adicionarProdutoNegativoOrcamento;
  late bool limparTrocarTabela;
  late bool todosClientesFaturamento;

  late bool usarIncluirVisitaAgenda;

  late bool permitirFormaPgNula;

  late bool usarBloqueioFormaPg;

  late int padraoFormaPagCadastro;

  late bool mostrarFormaPgCliente;

  late bool usarCancelamentoFaturamento;

  Map<String, Color> myColors = {
    '1': const Color.fromARGB(255, 4, 125, 141),
    '2': const Color.fromARGB(255, 220, 20, 60),
    '3': const Color.fromARGB(255, 215, 215, 215),
    '4': Colors.blueAccent,
    '5': const Color.fromARGB(255, 100, 100, 100),
    '6': const Color.fromARGB(255, 215, 215, 215),
  };
}
