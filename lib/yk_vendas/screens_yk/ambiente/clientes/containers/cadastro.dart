import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../api/common/components/list_scrollable.dart';
import '../../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../../api/common/form_field/database_fields.dart';
import '../../../../../api/common/form_field/formulario.dart';
import '../../../../models/configuracao/app_ambiente.dart';
import '../../../../models/configuracao/app_user.dart';
import '../../../../models/database_objects/cliente.dart';
import '../../../../models/database_objects/config_campo.dart';

class Cadastro extends StatelessWidget {
  final Cliente cliente;

  final bool expanded;

  final Function(bool b) onExpansionChanged;

  final bool editable;

  final bool pessoaJuridica;

  final Function update;

  const Cadastro(
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

    final appUser = AppUser.of(context);
    final appAmbiente = AppAmbiente.of(context);

    if (editable) {
      cliente.idUsuario = appUser.vendedorAtual;
    }

    final list = Provider.of<Map<int, ConfigCampo>>(context);

    final configRota = list[1]!;
    final configFormaPg = list[2]!;
    final configTabela = list[3]!;
    final configTipo = list[24]!;

    return Card(
      margin: defaultMargin,
      child: Padding(
        padding: defaultPadding,
        child: ListViewNested2(
          title: const TextTitle('Cadastro'),
          children: <Widget>[
            Card(
              margin: defaultMargin,
              child: Padding(
                padding: defaultPadding,
                child: ListViewNested(children: [
                  FormSwitchButton(
                      title: 'Pessoa Jurídica:',
                      startValue: cliente.pessoaJuridica,
                      onChange: (b) {
                        if (editable) {
                          cliente.pessoaJuridica = b;
                          // cliente.cpfcnpj = null;
                          update();
                        }
                      }),
                  // FormSwitchButton(title: 'Criar visita:', onChange: (b) {}),

                  if (configTipo.mostrar)
                    DropdownSaved(
                      'VW_CLIENTE_TIPO',
                      value: cliente.idClienteTipo,
                      // where: "",
                      // whereArgs: [],
                      onChange: (x) {
                        if (configTipo.editavel) {
                          cliente.idClienteTipo = x;
                        }
                      },
                      hint: 'Tipo de cliente',
                      editable: configTipo.editavel,
                    ),

                  if (editable && configRota.mostrar)
                    DropdownSaved(
                      'VW_ROTA',
                      value: cliente.idRota,
                      where: "ID_VENDEDOR = ?",
                      whereArgs: [appUser.vendedorAtual],
                      onChange: (x) {
                        if (editable) {
                          cliente.idRota = x;
                        }
                      },
                      hint: 'Rota',
                      editable: editable,
                    ),

                  if ((editable || configFormaPg.especial) &&
                      configFormaPg.mostrar)
                    Builder(
                      builder: (context) {


                        // cliente.idFormaPg

                        String args = 'USA_MOBILE = 1';
                        List<dynamic> param = [];





                        bool a = appAmbiente.mostrarFormaPgCliente &&
                            cliente.idFormaPg != null &&
                            !editable;

                        bool b = editable && configFormaPg.especial;

                        if(b){
                          cliente.idFormaPg = appAmbiente.padraoFormaPagCadastro;
                        }

                        if (a || b) {
                          args += ' OR ID = ${cliente.idFormaPg}';
                        }



                        return DropdownSaved(
                          DropdownSaved.formaPagamento,
                          where: args,
                          whereArgs: param,
                          value: cliente.idFormaPg,
                          onChange: (x) {
                            if (configFormaPg.editavel) {
                              cliente.idFormaPg = x;
                            }
                          },
                          hint: 'Forma Pag.',
                          editable: (editable || configFormaPg.editavel),
                        );
                      },
                    ),

                  if (editable && configTabela.mostrar)
                    DropdownSaved(
                      DropdownSaved.tabelaPreco,
                      value: cliente.idTabelaPrecos,
                      onChange: (x) {
                        if (editable) {
                          cliente.idTabelaPrecos = x;
                        }
                      },
                      hint: 'Tabela de Preços',
                      editable: editable,
                    )

                  // Dropdownsaved(
                  //   Dropdownsaved.cidade,
                  //   startValue: cliente.idCidade,
                  //   where: "ID_UF = ?",
                  //   whereArgs: [cliente.idUf ?? 0],
                  //   onChange: (x) {},
                  //   hint: 'CIDADE',
                  // )

                  /// teste de adição de clientes
                  // TextFormField(
                  //   controller: _idSyncController,
                  //   decoration:
                  //       const InputDecoration(hintText: "ID_CAB"),
                  // )
                ]),
              ),
            ),
          ],
          // initiallyExpanded: expanded,
          // onExpansionChanged: onExpansionChanged,
        ),
      ),
    );
  }
}
