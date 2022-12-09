import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../api/common/components/list_scrollable.dart';
import '../../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../../api/common/form_field/custom_input_field.dart';
import '../../../../../api/helpers/custom_formatters.dart';
import '../../../../models/configuracao/app_ambiente.dart';
import '../../../../models/database_objects/cliente.dart';
import '../../../../models/database_objects/config_campo.dart';
import '../config_camp_adapter.dart';

class Contato extends StatelessWidget {
  final Cliente cliente;

  final bool expanded;

  final Function(bool b) onExpansionChanged;

  final bool editable;

  const Contato(
      {Key? key,
      required this.cliente,
      required this.expanded,
      required this.onExpansionChanged,
      required this.editable})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const defaultMargin = EdgeInsets.symmetric(vertical: 4, horizontal: 2);
    const defaultPadding = EdgeInsets.symmetric(vertical: 2, horizontal: 6);

    final formatter = CustomFormatters();
    final app = AppAmbiente.of(context);

    final list = Provider.of<Map<int, ConfigCampo>>(context);
    final ConfigCampo configCelular = list[11]!;

    return Card(
      margin: defaultMargin,
      child: Padding(
        padding: defaultPadding,
        child: ListViewNested2(
          // initiallyExpanded: expanded,
          // onExpansionChanged: onExpansionChanged,
          title: const TextTitle('Contato'),
          children: [
            const SizedBox(
              height: 12,
            ),
            Row(
              children: [
                Flexible(
                  flex: 2,
                  child: ConfigCampAdapter(
                    configId: 10,
                    value: cliente.dddCelular,
                    onSaved: (String? text, String? maskedText) {
                      cliente.dddCelular = text;
                    },
                    onChange: (String? text, String? maskedText) {
                      cliente.dddCelular = text;
                    },
                    validator: (String? text) {
                      text ??= '';

                      // if((cliente.dddTelefone ?? '').length == 2){
                      //   final list = Provider.of<Map<int, ConfigCampo>>(context);
                      //   final ConfigCampo configCampo = list[10]!;
                      //
                      //   if(configCampo.especial){
                      //     return null;
                      //   }
                      //
                      // }

                      if (text.length != 2) {
                        return 'Inválido';
                      }
                    },
                    label: 'DDD',
                    limit: 10,
                    editavel: editable,
                    formatter: formatter.mask_ddd_celular,
                    keyboardType: formatter.keyboard_numero,
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Flexible(
                  flex: 8,
                  child: ConfigCampAdapter(
                    configId: 11,
                    value: cliente.celular,
                    onSaved: (String? text, String? maskedText) {
                      cliente.celular = text;
                    },
                    onChange: (String? text, String? maskedText) {
                      cliente.celular = text;
                    },
                    validator: (String? text) {
                      text ??= '';

                      if ((cliente.telefone ?? '').isNotEmpty) {

                        // return 'telefone ${(cliente.telefone ?? '').length}';

                        if (configCelular.especial) {
                          return null;
                        }
                      }

                      if (text.length != 11) {
                        return 'Número Inválido';
                      }
                    },
                    label: 'Celular',
                    limit: 20,
                    editavel: editable,
                    formatter: formatter.mask_numero_celular,
                    keyboardType: formatter.keyboard_numero,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 4,
            ),
            Row(
              children: [
                Flexible(
                  flex: 2,
                  child: ConfigCampAdapter(
                    configId: 12,
                    value: cliente.dddTelefone,
                    onSaved: (String? text, String? maskedText) {
                      cliente.dddTelefone = text;
                    },
                    onChange: (String? text, String? maskedText) {
                      cliente.dddTelefone = text;
                    },
                    validator: (String? text) {
                      text ??= '';
                      if (text.length != 2) {
                        return 'Inválido';
                      }
                    },
                    label: 'DDD',
                    limit: 10,
                    formatter: formatter.mask_ddd,
                    keyboardType: formatter.keyboard_numero,
                    editavel: editable,
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Flexible(
                  flex: 8,
                  child: ConfigCampAdapter(
                    configId: 13,
                    value: cliente.telefone,
                    onSaved: (String? text, String? maskedText) {
                      cliente.telefone = text;
                    },
                    onChange: (String? text, String? maskedText) {
                      cliente.telefone = text;
                    },
                    validator: (String? text) {
                      text ??= '';

                      if (text.length != 11 && text.length > 0) {
                        return 'Número Inválido';
                      }
                    },
                    label: 'Telefone',
                    limit: 20,
                    formatter: formatter.mask_numero_telefone,
                    keyboardType: formatter.keyboard_numero,
                    editavel: editable,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            ConfigCampAdapter(
              configId: 14,
              value: cliente.email,
              onSaved: (String? text, String? maskedText) {
                cliente.email = text;
              },
              onChange: (String? text, String? maskedText) {
                cliente.email = text;
              },
              label: 'Email',
              limit: 300,
              editavel: editable,
            ),
            const SizedBox(
              height: 8,
            ),
            ConfigCampAdapter(
              configId: 15,
              value: cliente.whatsapp,
              onSaved: (String? text, String? maskedText) {
                cliente.whatsapp = text;
              },
              onChange: (String? text, String? maskedText) {
                cliente.whatsapp = text;
              },
              validator: (String? text) {
                text ??= '';
                if (text.length != 17) {
                  return 'Número Inválido';
                }
              },
              label: 'Whatsapp',
              limit: 300,
              editavel: editable,
              formatter: formatter.mask_numero_whatsapp,
              keyboardType: formatter.keyboard_numero,
            ),
          ],
        ),
      ),
    );
  }
}
