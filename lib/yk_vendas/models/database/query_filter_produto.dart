class FiltrosProdutos {
  final int idVisita;

  int limite = 10;
  String? pesquisa;

  int? departamento;
  int? grupo;
  int? subgrupo;

  FiltrosProdutos(this.idVisita);

  String getWhere() {
    String where = 'ID_VISITA = ?';

    if (departamento != null) {
      where += ' AND ID_DEPARTAMENTO = ?';
    }

    if (grupo != null) {
      where += ' AND ID_GRUPO = ?';
    }

    if (subgrupo != null) {
      where += ' AND ID_SUBGRUPO = ?';
    }

    if (pesquisa != null) {
      if (isNumeric(pesquisa)) {
        where += ' AND (ID_PRODUTO = ? OR GTIN = ?)';
      } else {
        where += ' AND NOME LIKE ?';
      }
    }

    return where;
  }

  bool isNumeric(String? s) {
    if (s == null) {
      return false;
    }
    try {
      return double.tryParse(s) != null;
    } catch (e) {
      return false;
    }
  }

  List<dynamic> getArgs() {
    List<dynamic> args = [];

    args.add(idVisita);

    if (departamento != null) {
      args.add(departamento);
    }

    if (grupo != null) {
      args.add(grupo);
    }

    if (subgrupo != null) {
      args.add(subgrupo);
    }

    if (pesquisa != null) {
      if (isNumeric(pesquisa)) {
        args.add('$pesquisa');
        args.add('$pesquisa');
      } else {
        args.add('%$pesquisa%');
      }
    }

    return args;
  }
}
