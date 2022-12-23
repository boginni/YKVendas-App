import 'package:flutter/material.dart';

import '../../../yk_vendas/models/database/database_ambiente.dart';
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
  final int? value;
  final bool editable;
  final String? where;
  final List<dynamic>? whereArgs;

  final void Function(int? i) onChange;

  const DropdownSaved(
    this.table, {
    Key? key,
    this.value,
    required this.onChange,
    this.editable = true,
    this.hint = '',
    this.where,
    this.whereArgs,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => DropdownSavedState();
}

class DropdownSavedState extends State<DropdownSaved> {
  List<_DropdownSavedValue> _list = [];
  _DropdownSavedValue? currentSelected;

  int? lastValue;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadList();
    });
  }


  @override
  void didUpdateWidget(dynamic oldWidget) {
    super.didUpdateWidget(oldWidget);

    if(widget.value != lastValue){
      if(widget.value == null){
        currentSelected = null;
      }

      loadList();
    }

  }

  Future loadList() async {
    lastValue = widget.value;
    try {
      late final List<Map<String, dynamic>> maps;
      if (widget.where == null || widget.whereArgs == null) {
        maps = await DatabaseAmbiente.select(widget.table);
      } else {
        maps = await DatabaseAmbiente.select(
          widget.table,
          where: widget.where,
          whereArgs: widget.whereArgs,
        );
      }

      setState(() {
        _list = List.generate(maps.length, (i) {
          final item = _DropdownSavedValue(
            maps[i]['ID'],
            nome: maps[i]['NOME'],
          );

          if (maps[i]['ID'] == widget.value) {
            currentSelected = item;
          }

          return item;
        });
      });
    } catch (e) {
      printDebug(e.toString());
    }
  }

  update(final _DropdownSavedValue? item) {
    // setState(() {
    //   currentSelected = item;
    // });

    widget.onChange(item!.id);
  }

  @override
  Widget build(BuildContext context) {
    AppSystem appSystem = AppSystem.of(context);

    if (!widget.editable) {
      return TextField(
        readOnly: true,
        controller: TextEditingController(text: currentSelected.toString()),
        style: textTitlelStyle(appSystem),
        enabled: false,
        decoration: InputDecoration(
          label: Text(
            widget.hint,
            style: TextStyle(fontSize: 12),
          ),
          isDense: true,
          // contentPadding: EdgeInsets.all(8),
        ),
      );
    }

    return DropdownButton<_DropdownSavedValue>(
      value: currentSelected,
      items: _list.map((_DropdownSavedValue item) {
        return DropdownMenuItem<_DropdownSavedValue>(
          value: item,
          child: TextNormal(
            item.toString(),
          ),
        );
      }).toList(),
      onChanged: (item) {
        update(item);
      },
      hint: TextNormal(widget.hint),
      isExpanded: true,
    );
  }
}
