import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../api/common/form_field/custom_input_field.dart';
import '../../../models/database_objects/config_campo.dart';

class ConfigCampAdapter extends StatelessWidget {
  final int configId;

  final String? value;

  final Function(String?, String?) onSaved;

  final Function(String?, String?)? onChange;

  final int limit;

  final String? label;

  final String? Function(String?)? validator;

  final List<TextInputFormatter>? formatter;

  final bool editavel;

  final TextInputType? keyboardType;

  const ConfigCampAdapter(
      {Key? key,
      required this.configId,
      required this.value,
      required this.onSaved,
      this.onChange,
      required this.limit,
      this.label,
      this.validator,
      this.formatter,
      required this.editavel,
      this.keyboardType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final list = Provider.of<Map<int, ConfigCampo>>(context);

    final ConfigCampo configCampo = list[configId]!;

    final initialValue = value ?? '';

    bool editVazio = (value ?? '').isEmpty && configCampo.editavelVazio;

    if (configCampo.mostrar) {
      return CustomInputField(
        enabled: editavel || configCampo.editavel || editVazio,
        initialValue: initialValue,
        onSaved: onSaved,
        onChange: onChange,
        obrigatorio: configCampo.obrigatorio,
        labelText: label ?? '',
        limit: limit,
        validator: (String? text) {
          String? result;

          if (validator != null && configCampo.validar) {
            result = validator!(text);
          }

          return result;
        },
        formatter: formatter,
        keyboardType: keyboardType,
      );
    }

    return Container();
  }
}
