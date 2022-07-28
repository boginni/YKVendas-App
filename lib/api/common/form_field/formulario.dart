import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../custom_widgets/custom_text.dart';
import '../formatter/date_time_formatter.dart';

abstract class FormCampo extends StatelessWidget {
  //({Key? key, mandatoryField, title}) : super(key: key, mandatoryField: mandatoryField, title: title);
  const FormCampo({Key? key, required this.title, this.mandatoryField = false})
      : super(key: key);

  final String title;
  final bool mandatoryField;

  final double fontSize = 16;
  final double defaultBottonSpace = 32;
  final double defaultSideSpace = 8;

  Widget getTitleText() {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: fontSize),
        ),
        Text(mandatoryField ? " *" : "", style: TextStyle(fontSize: fontSize))
      ],
    );
  }

  Widget getCustomField();

  Widget getContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [getTitleText(), getCustomField()],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(
            left: defaultSideSpace,
            bottom: defaultBottonSpace,
            right: defaultSideSpace),
        child: getContent());
  }
}

class FormText extends FormCampo {
  FormText(
      {Key? key,
      required this.saveFunction(text)?,
      this.initialValue = "",
      mandatoryField = false,
      title})
      : super(key: key, mandatoryField: mandatoryField = false, title: title);

  String initialValue;
  Function(String?)? saveFunction;

  @override
  Widget getCustomField() {
    // TODO: implement getCustomField

    return TextFormField(
      maxLines: null,
      initialValue: initialValue,
      textAlignVertical: TextAlignVertical.bottom,
      style: TextStyle(fontSize: fontSize),
      autocorrect: false,
      validator: (text) {
        if (mandatoryField && text!.isEmpty) {
          return "Campo Obrigatório";
        }
        return null;
      },
      onSaved: saveFunction,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.all(10.0),
        // border: OutlineInputBorder(),
        hintText: '',
      ),
    );
  }
}

class FormPass extends FormCampo {
  final TextEditingController passController = TextEditingController();

  FormPass({Key? key, mandatoryField, title})
      : super(key: key, mandatoryField: mandatoryField = false, title: title);

  @override
  Widget getCustomField() {
    return TextFormField(
      controller: passController,
      // enabled: !UserManager.loading,
      decoration: const InputDecoration(hintText: 'Senha'),
      autocorrect: false,
      obscureText: true,
      validator: (pass) {
        if (pass!.isEmpty || pass.length < 6) return 'Senha inválida';
        return null;
      },
    );
  }
}

class FormDataNascimento extends FormCampo {
  const FormDataNascimento({Key? key, mandatoryField = false, title})
      : super(key: key, mandatoryField: mandatoryField, title: title);

  @override
  Widget getCustomField() {
    // TODO: implement getCustomField
    return const Text('Not Implemented');
  }
}

class FormSwitchButton extends StatefulWidget {
  final bool startValue;

  final String title;

  final MainAxisAlignment? mainAxisAlignment;

  final void Function(bool value) onChange;

  const FormSwitchButton({
    Key? key,
    required this.title,
    required this.onChange,
    this.startValue = false,
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FormSwitchButton();
}

class _FormSwitchButton extends State<FormSwitchButton> {
  bool isOn = false;

  @override
  void initState() {
    isOn = widget.startValue;
    super.initState();
  }

  bool first = true;

  @override
  Widget build(BuildContext context) {
    // if (first) {
    //   isOn = widget.startValue;
    // }
    // first = false;

    return Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: widget.mainAxisAlignment!,
        children: <Widget>[
          Flexible(
              child: TextTitle(
            widget.title,
          )),
          CupertinoSwitch(
              value: isOn,
              onChanged: (bool value) {
                widget.onChange(value);
                isOn = value;
                setState(() {});
              }),
        ]);
  }
}

class FormSwitch extends FormCampo {
  const FormSwitch({Key? key, mandatoryField = false, title})
      : super(key: key, mandatoryField: mandatoryField, title: title);

  final bool _switchValue = true;

  @override
  Widget getCustomField() {
    return CupertinoSwitch(
      value: _switchValue,
      onChanged: (value) {
        // setState(() {
        //   _switchValue = value;
        // });
      },
    );
  }

  @override
  Widget getContent() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            getTitleText(),
            getCustomField(),
          ],
        ),
        const SizedBox(
          height: 32,
        )
      ],
    );
  }
}

// class FormTipoCliente extends FormDropDown {
//   FormTipoCliente({Key? key, mandatoryField = false, title = "Tipo de Cliente"})
//       : super(key: key, mandatoryField: mandatoryField, title: title) {
//     itens = ['Pessoa Física', 'Pessoa Jurídica'];
//     dropdownValue = itens[0];
//   }
// }
//
// class FormCidade extends FormDropDown {
//   FormCidade({Key? key, mandatoryField = false, title = "Cidade"})
//       : super(key: key, mandatoryField: mandatoryField, title: title) {
//     itens = ['Exemplo 1', 'Exemplo 2'];
//     dropdownValue = itens[0];
//   }
// }
//
// class FormRota extends FormDropDown {
//   FormRota({Key? key, mandatoryField = false, title = "Rota"})
//       : super(key: key, mandatoryField: mandatoryField, title: title) {
//     itens = ['Rota 1', 'Rota 2'];
//     dropdownValue = itens[0];
//   }
// }
//
// class FormIdioma extends FormDropDown {
//   FormIdioma({Key? key, mandatoryField = false, title = "Idioma"})
//       : super(key: key, mandatoryField: mandatoryField, title: title) {
//     itens = ['Nativo', 'Portugês', 'Inglês'];
//     dropdownValue = itens[0];
//   }
// }
//
// class FormTipoTeclado extends FormDropDown {
//   FormTipoTeclado({Key? key, mandatoryField = false, title = "Tipo de teclado"})
//       : super(key: key, mandatoryField: mandatoryField, title: title) {
//     itens = ['Numérico', 'Alfanumérico', 'Latim'];
//     dropdownValue = itens[0];
//   }
// }
//
// class FormOpcoesAdicionaisPesquisa extends FormDropDown {
//   FormOpcoesAdicionaisPesquisa({Key? key, mandatoryField = false, title = "Opções Adicionais de Pesquisa"}) : super(key: key, mandatoryField: mandatoryField, title: title)
//   {
//     itens = ['Nenhum', 'Opção 1'];
//     dropdownValue = itens[0];
//   }
// }

class FormImage extends FormCampo {
  FormImage({Key? key, mandatoryField, required title})
      : super(key: key, mandatoryField: mandatoryField = false, title: title);

  @override
  Widget getCustomField() {
    return Text(
      title,
      style: const TextStyle(fontSize: 16),
    );
  }
}

/// Widget para obter datas
///
/// Se for colocar dentro de um tipo de flex, coluna ou row
/// Utilize [Expanded]
class FormDatePicker extends StatefulWidget {
  final Function(DateTime? date) then;

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  DateFormat? formatter;

  String hint;
  final DateTime? startingDate;

  final InputDecoration? decoration;

  FormDatePicker(
      {Key? key,
      required this.then,
      required this.initialDate,
      required this.firstDate,
      required this.lastDate,
      this.formatter,
      this.hint = '',
      this.startingDate,
      this.decoration})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _FormDatePickerState();
}

class _FormDatePickerState extends State<FormDatePicker> {
  static DateFormat defaultFormatter = DateFormatter.normalData;

  DateTime? time;
  final controller = TextEditingController();

  bool localRebuild = false;

  late final DateFormat formatter;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    formatter = widget.formatter == null ? defaultFormatter : widget.formatter!;
    time = widget.initialDate;

    controller.text = time != null ? formatter.format(time!) : '';
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    if (!localRebuild) {
      time = widget.startingDate;
      controller.text = time != null ? formatter.format(time!) : '';
    }

    localRebuild = false;

    return TextFormField(
      controller: controller,
      focusNode: AlwaysDisabledFocusNode(),
      onTap: () {
        showDatePicker(
          context: context,
          initialDate: widget.initialDate,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
        ).then((value) {
          if (value != null) {
            setState(() {
              time = value;
              controller.text = time != null ? formatter.format(time!) : '';
              localRebuild = true;
            });
            widget.then(value);
          }
        });
      },
      decoration: widget.decoration == null
          ? InputDecoration(hintText: widget.hint)
          : widget.decoration!,
    );
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
