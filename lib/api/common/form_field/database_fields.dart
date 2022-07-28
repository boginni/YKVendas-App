import 'package:flutter/material.dart';

import '../../../yukem_vendas/models/database/database_ambiente.dart';
import '../../models/configuracao/app_system.dart';
import '../custom_widgets/custom_text.dart';
import '../debugger.dart';

class _DropdownSavedValue {
  final int id;
  late final String? nome;

  _DropdownSavedValue(this.id, {this.nome});

  @override
  String toString() {
    return "$id -> $nome";
  }

  @override
  bool operator ==(Object other) =>
      other is _DropdownSavedValue && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class DropdownSaved extends StatefulWidget {
  static const String tabelaPreco = 'VW_TABELA_PRECO';
  static const String formaPagamento = 'VW_FORMA_PAGAMENTO';
  static const String rotas = 'TB_ROTAS';
  static const String motivoCancelamento = 'TB_MOTIVO_CANCELAMENTO';
  static const String uf = 'VW_ESTADO';
  static const String cidade = 'VW_CIDADE';

  final String hint;
  final String table;
  final int? startValue;
  final bool editable;
  final String? where;
  final List<dynamic>? whereArgs;

  final void Function(int? i) onChange;

  const DropdownSaved(
    this.table, {
    Key? key,
    this.startValue,
    required this.onChange,
    this.editable = true,
    this.hint = '',
    this.where,
    this.whereArgs,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DropdownSavedState();
}

class _DropdownSavedState extends State<DropdownSaved> {
  List<_DropdownSavedValue> list = [];
  bool toSearch = true;

  int? currentValue;
  bool localRebuild = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    AppSystem appSystem = AppSystem.of(context);

    if (!localRebuild) {
      currentValue = widget.startValue;
    }
    localRebuild = false;

    bool test = currentValue == null || list.isEmpty;
    _DropdownSavedValue? value =
        test ? null : _DropdownSavedValue(currentValue!);

    Future<List<_DropdownSavedValue>> getList() async {
      try {
        late final List<Map<String, dynamic>> maps;

        if (widget.where == null || widget.whereArgs == null) {
          maps = await DatabaseAmbiente.select(widget.table);
        } else {
          maps = await DatabaseAmbiente.select(widget.table,
              where: widget.where, whereArgs: widget.whereArgs);
        }

        list = List.generate(maps.length, (i) {
          final tp = _DropdownSavedValue(maps[i]['ID'], nome: maps[i]['NOME']);
          if (maps[i]['ID'] == currentValue) {
            value = tp;
          }
          return tp;
        });
      } catch (e) {
        printDebug(e.toString());
      }

      return list;
    }

    update(final _DropdownSavedValue? item) {
      setState(() {
        localRebuild = true;
        currentValue = item!.id;
      });

      widget.onChange(item!.id);
    }

    return FutureBuilder(
      future: toSearch ? getList() : null,
      builder: (BuildContext context,
          AsyncSnapshot<List<_DropdownSavedValue>?> snapshot) {
        ///Causava Bugs
        // toSearch = false;

        if (snapshot.data != null) {
          list = snapshot.data!;
        }

        if (!widget.editable) {
          return TextFormField(
            controller: TextEditingController()..text = value.toString(),
            style: textTitlelStyle(appSystem),
            enabled: false,
            decoration: defaultInputDecoration(),
          );
        }

        return DropdownButton<_DropdownSavedValue>(
          value:
              snapshot.connectionState != ConnectionState.done ? null : value,
          items: list.map((_DropdownSavedValue item) {
            return DropdownMenuItem<_DropdownSavedValue>(
              value: item,
              child: TextNormal(item.toString()),
            );
          }).toList(),
          onChanged: (item) {
            if (widget.editable) update(item);
          },
          hint: TextNormal(widget.hint),
          isExpanded: true,
        );
      },
    );
  }
}
