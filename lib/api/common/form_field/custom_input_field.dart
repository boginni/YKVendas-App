import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CustomInputField extends StatelessWidget {
  final bool enabled;
  final String labelText;
  final String initialValue;
  final List<TextInputFormatter>? formatter;
  final Function(String? text, String? maskedText) onSaved;
  final TextInputType? keyboardType;
  final String? Function(String? text)? validator;
  final bool obrigatorio;
  final int? limit;

  final Function(String? text, String? maskedText)? onChange;

  const CustomInputField({
    Key? key,
    this.enabled = true,
    required this.labelText,
    required this.initialValue,
    required this.onSaved,
    this.formatter,
    this.keyboardType,
    this.validator,
    this.obrigatorio = false,
    this.onChange,
    this.limit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool unchanged = true;

    final controller = TextEditingController();
    final bool b = formatter != null && formatter![0] is MaskTextInputFormatter;

    getText(String? text) {
      if (b) {
        final masked =
            (formatter![0] as MaskTextInputFormatter).getUnmaskedText();
        if (unchanged) {
          return initialValue;
        }

        return masked;
      }
      return text;
    }

    final format = <TextInputFormatter>[];

    if (formatter != null) {
      format.add(formatter![0]);
    }

    if (limit != null) {
      format.add(LengthLimitingTextInputFormatter(limit));
    }

    getMaskedText(String? text) {
      if (b) {
        return (formatter![0] as MaskTextInputFormatter).maskText(text ?? '');
      }
      return text;
    }

    String? value = getMaskedText(initialValue);

    controller.text = value ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 2,
      ),
      child: TextFormField(
        enabled: enabled,
        controller: controller,
        inputFormatters: format,
        keyboardType: keyboardType,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onSaved: (String? text) {
          if (text == null || text.isEmpty) {
            onSaved(null, null);
          } else {
            onSaved(getText(text), getMaskedText(text));
          }
        },
        validator: (text) {
          String? result;

          if (validator != null) {
            result = validator!(text);
          }

          if (obrigatorio) {
            if (text == null || text.isEmpty) {
              return 'Campo obrigatorio';
            }
          }

          return result;
        },
        onChanged: (x) {
          unchanged = false;

          if (onChange != null) {
            onChange!(getText(x), getMaskedText(x));
          }
        },
        decoration: InputDecoration(
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            labelText: labelText,
            border: const OutlineInputBorder()),
      ),
    );
  }
}
