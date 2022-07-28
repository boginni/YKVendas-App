import 'package:flutter/material.dart';
import 'package:forca_de_vendas/api/common/custom_tiles/default_tiles/tile_spaced_text.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/clientes/config_camp_adapter.dart';

import '../../../../../api/common/components/list_scrollable.dart';
import '../../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../../api/common/form_field/custom_input_field.dart';
import '../../../../../api/common/formatter/date_time_formatter.dart';
import '../../../../../api/helpers/custom_formatters.dart';
import '../../../../models/database_objects/cliente.dart';

class CadastroBasico extends StatelessWidget {
  final Cliente cliente;

  final bool expanded;

  final Function(bool b) onExpansionChanged;

  final bool editable;

  final bool pessoaJuridica;

  final Null Function() update;

  const CadastroBasico(
      {Key? key,
      required this.cliente,
      required this.expanded,
      required this.onExpansionChanged,
      required this.editable,
      required this.pessoaJuridica,
      required this.update})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const defaultMargin = EdgeInsets.symmetric(vertical: 4, horizontal: 2);
    const defaultPadding = EdgeInsets.symmetric(vertical: 2, horizontal: 6);

    final formatter = CustomFormatters();

    return Card(
      margin: defaultMargin,
      child: Padding(
        padding: defaultPadding,
        child: ListViewNested2(
          title: const TextTitle('Cadastro Básico'),
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TileSpacedText('Id Cliente', cliente.idSync.toString())),
            const SizedBox(
              height: 12,
            ),
            ConfigCampAdapter(
              configId: 4,
              value: cliente.apelido,
              onSaved: (String? text, String? maskedText) {
                cliente.apelido = text;
              },
              onChange: (String? text, String? maskedText) {
                cliente.apelido = text;
              },
              label: pessoaJuridica ? 'Razão social' : 'Nome Completo',
              limit: 300,
              editavel: editable,
            ),
            ConfigCampAdapter(
              configId: 5,
              value: cliente.nome,
              onSaved: (String? text, String? maskedText) {
                cliente.nome = text;
              },
              onChange: (String? text, String? maskedText) {
                cliente.nome = text;
              },
              label: 'Apelido/Nome Fantasia',
              limit: 300,
              editavel: editable,
            ),
            const SizedBox(
              height: 4,
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              // direction: Axis.horizontal,
              children: [
                Flexible(
                  flex: 6,
                  child: ConfigCampAdapter(
                    configId: 6,
                    value: cliente.cpfcnpj,
                    onSaved: (String? text, String? maskedText) {
                      cliente.cpfcnpj = text;
                    },
                    onChange: (String? text, String? maskedText) {
                      cliente.cpfcnpj = text;
                    },
                    validator: (String? x) {
                      int correctLength = pessoaJuridica ? 14 : 11;
                      int curLength = (cliente.cpfcnpj ?? '').length;
                      bool isValid = curLength == correctLength;

                      if (!isValid) {
                        return 'Tamanho incorreto';
                      }

                      return null;
                    },
                    label: pessoaJuridica ? 'CNPJ' : 'CPF',
                    limit: 300,
                    editavel: editable,
                    formatter: pessoaJuridica
                        ? formatter.mask_cnpj
                        : formatter.mask_cpf,
                  ),
                ),
                const SizedBox(
                  width: 4,
                ),
                Flexible(
                  flex: 5,
                  child: ConfigCampAdapter(
                    configId: pessoaJuridica ? 8 : 7,
                    value: cliente.pessoaJuridica
                        ? cliente.inscricaoEstadual
                        : cliente.rg,
                    onSaved: (String? text, String? maskedText) {
                      if (cliente.pessoaJuridica) {
                        cliente.inscricaoEstadual = text;
                      } else {
                        cliente.rg = text;
                      }
                    },
                    onChange: (String? text, String? maskedText) {
                      if (cliente.pessoaJuridica) {
                        cliente.inscricaoEstadual = text;
                      } else {
                        cliente.rg = text;
                      }
                    },
                    label: pessoaJuridica ? 'Insc. Estadual' : 'RG',
                    limit: 20,
                    editavel: editable,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            if (!pessoaJuridica && false)
              CustomInputField(
                enabled: editable,
                initialValue: cliente.dataNascimento ?? '',
                formatter: formatter.mask_data,
                onSaved: (String? text, String? maskedText) {
                  late String dat;

                  try {
                    DateTime date =
                        DateFormatter.normalData.parse(maskedText ?? '');
                    dat = DateFormatter.normalData.format(date);
                  } catch (e) {
                    dat = '';
                  }

                  cliente.dataNascimento = dat;
                },
                labelText: 'Data de Nascimento',
                keyboardType: formatter.keyboard_numero,
              ),
          ],
          // initiallyExpanded: expanded,
          // onExpansionChanged: onExpansionChanged,
        ),
      ),
    );
  }
}
