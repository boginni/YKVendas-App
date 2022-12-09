


import 'query_item.dart';

class QueryGroup implements QueryAdapter{


  List<QueryAdapter> args = [];
  List<String> agregation = [];


  void addItem(QueryAdapter item, String agregation){

  }

  @override
  String getArg() {
    // TODO: implement getArg
    throw UnimplementedError();
  }

  @override
  getParam() {
    // TODO: implement getParam
    throw UnimplementedError();
  }


}
