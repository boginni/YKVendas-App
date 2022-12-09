
import '../../../api/common/map_reader.dart';
import '../database/database_ambiente.dart';

class ConfigCampo {
  final int id;
  final String nome;
  final bool obrigatorio;
  final bool validar;
  final bool mostrar;
  final bool especial;
  final bool editavel;
  final bool editavelVazio;

  ConfigCampo(
      {required this.id,
      required this.nome,
      required this.obrigatorio,
      required this.validar,
      required this.mostrar,
      required this.especial,
      required this.editavel,
      required this.editavelVazio});

  factory ConfigCampo.fromMap(Map<String, dynamic> map) {
    final m = MapReader(map, printError: true);

    // ID	NOME	OBRIGATORIO	VALIDAR	MOSTRAR	ESPECIAL	EDITAVEL	EDITAVEL_VAZIO

    return ConfigCampo(
      id: m.integer('ID'),
      nome: m.value('NOME'),
      obrigatorio: m.bo('OBRIGATORIO'),
      validar: m.bo('VALIDAR'),
      mostrar: m.bo('MOSTRAR'),
      especial: m.bo('ESPECIAL'),
      editavel: m.bo('EDITAVEL'),
      editavelVazio: m.bo('EDITAVEL_VAZIO'),
    );
  }

  static Future<Map<int, ConfigCampo>> getList() async {

    final maps = await DatabaseAmbiente.select('CONF_CAMPO_CADASTRO');

    final list =  List.generate(
        maps.length, (index) => ConfigCampo.fromMap(maps[index]));


    Map<int, ConfigCampo> map = {};

    for(final item in list){
      map[item.id] = item;
    }

    return map;


  }
}
