class QueryItem implements QueryAdapter{
  String campo;

  dynamic value;

  // TODO: Melhoria futuras necessárias
  String tipo;
  bool contem;

  QueryItem(
      {required this.campo,
      required this.value,
      this.tipo = 'like',
      this.contem = false});

  String getArg() {
    return '$campo $tipo ?';
  }

  dynamic getParam() {
    return contem ? '$value' : value;
  }
}

abstract class QueryAdapter {
  String getArg();

  dynamic getParam();
}
