import 'package:flutter/material.dart';
import 'package:forca_de_vendas/api/common/components/mostrar_confirmacao.dart';
import 'package:forca_de_vendas/yukem_vendas/models/database/database_ambiente.dart';
import 'package:forca_de_vendas/yukem_vendas/models/internet/api.dart';
import 'package:provider/provider.dart';

import '../../../../../api/common/components/list_scrollable.dart';
import '../../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../../api/common/form_field/database_fields.dart';
import '../../../../../api/helpers/custom_formatters.dart';
import '../../../../models/configuracao/app_ambiente.dart';
import '../../../../models/database_objects/cliente.dart';
import '../../../../models/database_objects/config_campo.dart';
import '../config_camp_adapter.dart';

class Endereco extends StatefulWidget {
  final Cliente cliente;

  final bool expanded;

  final Function(bool b) onExpansionChanged;

  final bool editable;

  const Endereco(
      {Key? key,
      required this.cliente,
      required this.expanded,
      required this.onExpansionChanged,
      required this.editable})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _EnderecoState();
}

class _EnderecoState extends State<Endereco> {
  @override
  Widget build(BuildContext context) {
    const defaultMargin = EdgeInsets.symmetric(vertical: 4, horizontal: 2);
    const defaultPadding = EdgeInsets.symmetric(vertical: 2, horizontal: 6);

    final formatter = CustomFormatters();
    final app = AppAmbiente.of(context);

    final list = Provider.of<Map<int, ConfigCampo>>(context);
    final configUF = list[16]!;
    final configCidade = list[17]!;

    final cidadeKey = GlobalKey<DropdownSavedState>();

    return Card(
      margin: defaultMargin,
      child: Padding(
        padding: defaultPadding,
        child: ListViewNested2(
          // initiallyExpanded: expanded,
          // onExpansionChanged: onExpansionChanged,
          title: const TextTitle('Endereço'),
          children: [
            Row(
              children: [
                Flexible(
                  flex: 1,
                  child: DropdownSaved(
                    DropdownSaved.uf,
                    value: widget.cliente.idUf,
                    onChange: (x) {
                      setState(() {});
                      if (x != null) {
                        widget.cliente.idUf = x;
                        widget.cliente.idCidade = null;
                      }

                      cidadeKey.currentState!.loadList();
                    },
                    hint: 'UF',
                    editable: widget.editable || configUF.editavel,
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Flexible(
                  flex: 2,
                  child: DropdownSaved(
                    DropdownSaved.cidade,
                    key: cidadeKey,
                    value: widget.cliente.idCidade,
                    where:
                        widget.cliente.idUf != null ? "ID_UF = ?" : "ID_UF = 0",
                    whereArgs: widget.cliente.idUf != null
                        ? [widget.cliente.idUf]
                        : [],
                    onChange: (x) {
                      if (x != null) {
                        widget.cliente.idCidade = x;
                      }
                    },
                    hint: 'Cidade',
                    editable: widget.editable ||
                        configCidade.editavel ||
                        configUF.editavel,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 6,
            ),

            Row(
              children: [
                ///
                Flexible(
                  flex: 4,
                  child: ConfigCampAdapter(
                    configId: 18,
                    value: widget.cliente.logradouro,
                    onSaved: (String? text, String? maskedText) {
                      widget.cliente.logradouro = text;
                    },
                    onChange: (String? text, String? maskedText) {
                      widget.cliente.logradouro = text;
                    },
                    label: 'Logradouro',
                    limit: 300,
                    editavel: widget.editable,
                  ),
                ),

                const SizedBox(
                  width: 8,
                ),

                ///
                Flexible(
                  flex: 2,
                  child: ConfigCampAdapter(
                    configId: 19,
                    value: widget.cliente.cep,
                    onSaved: (String? text, String? maskedText) {
                      widget.cliente.cep = text;
                    },
                    onChange: (String? text, String? maskedText) {
                      widget.cliente.cep = text;
                      int? cep = int.tryParse(text ?? '');

                      if (lastSearch != cep && cep.toString().length == 8) {
                        buscaCep(cep!).then((value) {
                          final map = value as Map<String, dynamic>;

                          if (map['erro'] == null) {
                            mostrarCaixaConfirmacao(context,
                                    title:
                                        'Gostaria de auto preencher a partir do cep?')
                                .then((value) async {
                              if (!value) {
                                return;
                              }

                              widget.cliente.logradouro = map['logradouro'];
                              widget.cliente.complementoLogadouro =
                                  map['complemento'];
                              widget.cliente.bairro = map['bairro'];
                              widget.cliente.idCidade =
                                  await getIdCidade(int.parse(map['ibge']));
                              widget.cliente.idUf =
                                  await getIdUF(widget.cliente.idCidade!);
                              widget.cliente.cep = cep.toString();

                              setState(() {});
                            });
                          }
                        });
                      }

                      lastSearch = cep;
                    },
                    validator: (String? text) {},
                    label: 'CEP',
                    limit: 20,
                    keyboardType: formatter.keyboard_numero,
                    formatter: formatter.mask_cep,
                    editavel: widget.editable,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 6,
            ),

            ConfigCampAdapter(
              configId: 20,
              value: widget.cliente.complementoLogadouro,
              onSaved: (String? text, String? maskedText) {
                widget.cliente.complementoLogadouro = text;
              },
              onChange: (String? text, String? maskedText) {
                widget.cliente.complementoLogadouro = text;
              },
              validator: (String? text) {},
              label: 'Complemento Logradouro',
              limit: 300,
              editavel: widget.editable,
            ),

            ///
            const SizedBox(
              height: 6,
            ),
            Row(
              children: [
                ///
                Flexible(
                  flex: 4,
                  child: ConfigCampAdapter(
                    configId: 21,
                    value: widget.cliente.bairro,
                    onSaved: (String? text, String? maskedText) {
                      widget.cliente.bairro = text;
                    },
                    onChange: (String? text, String? maskedText) {
                      widget.cliente.bairro = text;
                    },
                    validator: (String? text) {},
                    label: 'Bairro',
                    limit: 300,
                    editavel: widget.editable,
                  ),
                ),

                const SizedBox(
                  width: 8,
                ),

                Flexible(
                  flex: 2,
                  child: ConfigCampAdapter(
                    configId: 22,
                    value: widget.cliente.numero,
                    onSaved: (String? text, String? maskedText) {
                      widget.cliente.numero = text;
                    },
                    onChange: (String? text, String? maskedText) {
                      widget.cliente.numero = text;
                    },
                    validator: (String? text) {},
                    label: 'Número',
                    limit: 10,
                    editavel: widget.editable,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

int? lastSearch;

Future<int> getIdCidade(int ibge) async {
  final maps = await DatabaseAmbiente.select('PRE_CIDADE',
      where: 'CODIGO_IBGE = ?', whereArgs: [ibge]);

  try {
    int id = maps[0]['ID'];
    return id;
  } catch (e) {
    throw Exception('código ibge inválido');
  }
}

Future<int> getIdUF(int idCidade) async {
  final maps = await DatabaseAmbiente.select('PRE_CIDADE',
      where: 'ID = ?', whereArgs: [idCidade]);

  try {
    int id = maps[0]['ID_UF'];
    return id;
  } catch (e) {
    throw Exception('id cidade inválido');
  }
}
