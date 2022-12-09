import '../../../../models/objects/item.dart';

class Produto extends Item {
  final double estoque;
  final double preco;

  Produto(int id, String nome, this.estoque, this.preco) : super(id, nome);

}
