import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../api/common/components/list_scrollable.dart';
import '../../../../api/common/components/mostrar_confirmacao.dart';
import '../../../../api/common/custom_widgets/custom_icons.dart';
import '../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../api/common/custom_widgets/icon_dynamic.dart';
import '../../../../api/helpers/brasil_formatter.dart';
import '../../../../api/models/configuracao/app_system.dart';
import '../../../app_foundation.dart';
import '../../../models/configuracao/app_ambiente.dart';
import '../../../models/configuracao/app_user.dart';
import '../../../models/database/database_ambiente.dart';
import '../../../models/database_objects/db_visita_agenda.dart';
import '../../../models/database_objects/rota.dart';
import '../../../models/database_objects/visita.dart';
import '../../../screens_yk/ambiente/comodato/tela_comodato.dart';
import '../../../screens_yk/ambiente/encerramento/tela_encerramento_dia.dart';
import '../../../screens_yk/ambiente/titulos/tela_titulos_vencidos.dart';
import '../../../screens_yk/ambiente/visita/tela_visita.dart';
import '../../../screens_yk/ambiente/visita/tela_visita/tela_pedido.dart';
import '../../../screens_yk/ambiente/visita/tela_visita/tela_visualizacao_visita.dart';

class TileVisita extends StatefulWidget {
  Visita visita;
  final String redirect;
  final Function(Visita visita)? afterUpdate;
  final Function()? afterRemove;
  final bool encerramentoDia;
  bool selected;
  final bool Function() onPressed;

  TileVisita(
      {Key? key,
      required this.visita,
      this.redirect = TelaVisita.routeName,
      this.afterUpdate,
      this.afterRemove,
      this.encerramentoDia = false,
      this.selected = false,
      required this.onPressed})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => TileVisitaState();
}

class TileVisitaState extends State<TileVisita> {
  /// Atualiza as informa????es da visita
  update() async {
    final idVisita = widget.visita.id;
    final newVisita = await Visita.getVisita(idVisita);

    setState(() {
      widget.visita = newVisita;
    });

    if (widget.afterUpdate != null) {
      widget.afterUpdate!(widget.visita);
    }
  }

  @override
  Widget build(BuildContext context) {
    Visita visita = widget.visita;
    final appSystem = AppSystem.of(context);

    onPressed() {
      if (widget.encerramentoDia) {
        widget.selected = widget.onPressed();
        setState(() {});
        return;
      }

      final idVisita = widget.visita.id;
      if (visita.getStatus() == VisitaStatus.aberto ||
          visita.getStatus() == VisitaStatus.edicao ||
          visita.viewOnly()) {
        Navigator.of(context)
            .pushNamed(
                visita.viewOnly()
                    ? TelaVisualizacaoVisita.routeName
                    : widget.redirect,
                arguments: idVisita)
            .then((value) => update());
      }
    }

    onLongPressed() {
      if (widget.encerramentoDia) {
        return;
      }
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              // title: const Text('Selecione o formato'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Application.navigate(
                              context,
                              TelaComodato(
                                idPessoaSync: visita.idPessoaSync,
                              ),
                            );
                          },
                          child: const TextNormal('Ver Comodatos'),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            if (visita.idPessoaSync != null) {
                              Application.navigate(
                                context,
                                TelaTitulos(
                                  idPessoaSync: visita.idPessoaSync!,
                                ),
                              );
                            }
                          },
                          child: const TextNormal('Ver T??tulos'),
                        ),
                      ),
                    ],
                  ),
                  if (visita.faturamento &&
                      visita.getStatus() == VisitaStatus.edicao)
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              remover() {
                                DatabaseAmbiente.update(
                                    'TB_VISITA', {'STATUS': 0},
                                    where: 'ID = ?',
                                    whereArgs: [visita.id]).then((value) {
                                  Navigator.pop(context, true);
                                  widget.afterRemove!();
                                });
                              }

                              mostrarCaixaConfirmacao(context,
                                      content:
                                          'Deseja mesmo REMOVER esse Faturamento?')
                                  .then((value) {
                                if (value) {
                                  remover();
                                }
                              });
                            },
                            child: const TextNormal('Remover Faturamento'),
                          ),
                        ),
                      ],
                    ),
                  if (visita.faturamento &&
                      visita.getStatus() == VisitaStatus.edicao &&
                      visita.idPessoa != 0 &&
                      AppAmbiente.of(context).usarCancelamentoFaturamento)
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed(
                                    TelaEncarramentoDia.routeName,
                                    arguments: {
                                      widget.visita.id: widget.visita
                                    }).then((value) {
                                  if (value == true) {
                                    if (widget.afterRemove != null) {
                                      Navigator.pop(context, true);
                                      widget.afterRemove!();
                                    }
                                  }
                                });
                              },
                              child: const TextNormal('Cancelar e Justificar')),
                        ),
                      ],
                    ),
                  if (widget.visita.idPessoaSync != null)
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              final appAmbiente = AppAmbiente.of(context);
                              String getRedirectRouteName() {
                                String r = appAmbiente.usarChegadaCliente &&
                                        !visita.faturamento
                                    ? TelaVisita.routeName
                                    : TelaPedido.routeName;
                                return r;
                              }

                              final rota = context.read<Rota>();

                              insertVisitaAgenda(
                                widget.visita.idPessoaSync!,
                                rota.id,
                                idVendedor: AppUser.of(context).vendedorAtual,
                                faturamento: visita.faturamento,
                              ).then((value) {
                                Navigator.of(context)
                                    .pushNamed(
                                  getRedirectRouteName(),
                                  arguments: value,
                                )
                                    .then((value) {
                                  Navigator.pop(context, true);
                                  widget.afterRemove!();
                                });
                              });
                            },
                            child: const TextNormal('Nova Venda'),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          });
    }

    Widget? getStatusIcon() {
      switch (visita.getStatus()) {
        case VisitaStatus.aberto:
          return null;
        case VisitaStatus.edicao:
          return const IconStatus(statusIconType: StatusIconTypes.warning);
        case VisitaStatus.concluida:
          return const IconStatus(statusIconType: StatusIconTypes.ok);
        case VisitaStatus.cancelada:
          return const IconStatus(statusIconType: StatusIconTypes.closed);
        case VisitaStatus.expirada:
          return const IconStatus(statusIconType: StatusIconTypes.expired);
      }
    }

    StatusIconTypes type =
        (visita.isSync) ? StatusIconTypes.ok : StatusIconTypes.warning;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: TextButton(
        onPressed: onPressed,
        onLongPress: onLongPressed,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.encerramentoDia)
              Stack(
                children: <Widget>[
                  /// Mostra o ??cone
                  IconDynamic(
                    primary: CupertinoIcons.person_alt_circle,
                    secondary: CupertinoIcons.person_alt_circle_fill,
                    size: (40 + appSystem.getIconScale()),
                  ),

                  /// Mostra o status
                  Flex(
                    direction: Axis.horizontal,
                    children: <Widget>[
                      if (getStatusIcon() != null) getStatusIcon()!,
                    ],
                  )
                ],
              ),
            if (widget.encerramentoDia)
              IconNormal(
                widget.selected
                    ? CupertinoIcons.circle_fill
                    : CupertinoIcons.circle,
                color: widget.selected ? Colors.greenAccent : Colors.grey,
              ),
            const SizedBox(
              width: 4,
            ),
            Flexible(
              child: ListViewNested(
                children: [
                  if (visita.nome.isNotEmpty)
                    // Nome do cliente
                    Align(
                      alignment: Alignment.topLeft,
                      child: TextTitle(
                        '${visita.idPessoaSync ?? '-'} ${visita.nome}',
                      ),
                    ),

                  /// Apelido em caso de empresa
                  Align(
                    alignment: Alignment.topLeft,
                    child: TextNormal(visita.apelido),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: TextNormal(formatCpfCnpj(visita.cpf_cnpj)),
                  ),

                  /// Endere??o
                  Align(
                    alignment: Alignment.topLeft,
                    child: TextNormal(
                      visita.getEndereco(),
                    ),
                  ),

                  if (visita.titulosVencendo != null &&
                      visita.titulosVencendo! > 0)
                    Align(
                      alignment: Alignment.topLeft,
                      child: TextSpamable(
                        textList: [
                          const TextNormal('T??tulos vencendo: '),
                          TextTitle(
                            TextDinheiroReal.format(visita.titulosVencendo!),
                            color: Colors.yellow,
                          )
                        ],
                      ),
                    ),

                  if (visita.titulosVencido != null &&
                      visita.titulosVencido! > 0)
                    Align(
                      alignment: Alignment.topLeft,
                      child: TextSpamable(
                        textList: [
                          const TextNormal('T??tulos vencidos: '),
                          TextTitle(
                            TextDinheiroReal.format(visita.titulosVencido!),
                            color: Colors.red,
                          )
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (widget.visita.idPessoaSync == null)
              const IconStatus(statusIconType: StatusIconTypes.sync),
            if (visita.getStatus() == VisitaStatus.concluida)
              IconStatus(
                statusIconType: type,
              ),
          ],
        ),
      ),
    );
  }
}
