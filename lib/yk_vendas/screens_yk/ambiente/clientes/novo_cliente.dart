import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../api/common/components/list_scrollable.dart';
import '../../../../api/common/components/mostrar_confirmacao.dart';
import '../../../../api/common/custom_widgets/custom_buttons.dart';
import '../../../../api/common/custom_widgets/custom_text.dart';
import '../../../models/configuracao/app_user.dart';
import '../../../models/database/database_ambiente.dart';
import '../../../models/database_objects/cliente.dart';
import '../../../models/database_objects/config_campo.dart';
import 'config_camp_adapter.dart';
import 'containers/cadastro.dart';
import 'containers/cadastro_basico.dart';
import 'containers/contato.dart';
import 'containers/endereco.dart';

class TelaNovoCliente extends StatefulWidget {
  static const routeName = '/telaNovoCliente';

  const TelaNovoCliente({Key? key, this.idPessoa}) : super(key: key);

  final int? idPessoa;

  @override
  State<StatefulWidget> createState() => TelaNovoClienteState();
}

class TelaNovoClienteState extends State<TelaNovoCliente> {
  updateScreen() {
    salvarCliente();
    setState(() {});
  }

  salvarCliente() {
    if (formKey.currentState != null) {
      formKey.currentState!.save();
    }
  }

  bool editable = true;
  bool toLoad = true;
  Cliente cliente = Cliente();
  Map<int, ConfigCampo> config = {};
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  setup() async {
    await Future.delayed(const Duration(milliseconds: 500));
    config = await ConfigCampo.getList();

    if (widget.idPessoa == null || !toLoad) {
      setState(() {
        onLoading = false;
      });
      return;
    }

    toLoad = false;


    Cliente? c = await Cliente.getCliente(widget.idPessoa!);

    if (c == null) {
      return;
    }

    if (c.idCidade != null) {
      final maps = await DatabaseAmbiente.select('PRE_CIDADE',
          where: 'ID = ?', whereArgs: [c.idCidade]);
      c.idUf = maps[0]['ID_UF'];
    }

    setState(() {
      cliente = c;
      onLoading = false;
    });
  }

  bool onLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setup();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.idPessoa != null) {
      editable = false;
    }

    salvar() async {
      formKey.currentState!.save();

      // cliente.idSync = int.tryParse(_idSyncController.text);
      // cliente.rota = appAmbiente.rotaPadrao;

      cliente.uuid = const Uuid().v1();
      cliente.toSync = true;
      cliente.idUsuario = AppUser.of(context).vendedorAtual;

      onSucess() async {
        Navigator.of(context).pop(true);
      }

      onDuplicated() {
        Cliente.insertCliente(cliente, force: true, onSucess: onSucess);
      }

      await Cliente.insertCliente(cliente,
          onDuplicated: onDuplicated, onSucess: onSucess);
    }

    onPressed() async {
      // updateScreen();
      if (formKey.currentState!.validate() || !editable) {
        final cpfList = await DatabaseAmbiente.select('TB_CLIENTE',
            where: 'CPF_CNPJ = ?', whereArgs: [cliente.cpfcnpj ?? 'x']);

        if (cpfList.isNotEmpty && editable) {
          mostrarCaixaConfirmacao(context,
              mostrarCancelar: false,
              title: "CPF ou CNPJ Duplicado!",
              content: "Já existe um cliente com esse CPF/CNPJ cadastrado");

          return;
        }

        /// TODO: Gambiarra temporária
        if (editable) {
          if (cliente.idRota == null && config[1]!.obrigatorio) {
            mostrarCaixaConfirmacao(context,
                title: 'Selecione uma rota',
                content: 'O campo de rota é obrigatório',
                mostrarCancelar: false);
            return;
          }

          if (cliente.idFormaPg == null && config[2]!.obrigatorio) {
            mostrarCaixaConfirmacao(context,
                title: 'Selecione uma Forma de Pagamento',
                content: 'O campo de Forma de Pagamento é obrigatório',
                mostrarCancelar: false);
            return;
          }

          if (cliente.idTabelaPrecos == null && config[3]!.obrigatorio) {
            mostrarCaixaConfirmacao(context,
                title: 'Selecione uma Tabela',
                content: 'O campo de Tabela é obrigatório',
                mostrarCancelar: false);
            return;
          }
        }

        if (cliente.idCidade == null && config[17]!.obrigatorio) {
          mostrarCaixaConfirmacao(context,
              title: 'Selecione uma cidade',
              content: 'O campo de cidade é obrigatório',
              mostrarCancelar: false);
          return;
        }

        //
        mostrarCaixaConfirmacao(context,
                title: 'Deseja Salvar?',
                content:
                    'O cliente será adicionado ao ERP na próxima sincronização')
            .then((value) {
          if (value) {
            salvar();
          }
        });
        //

      } else {
        mostrarCaixaConfirmacao(context,
                mostrarCancelar: false,
                content: 'Preencha os campos obrigatórios')
            .then(
          (value) {
            if (value) {}
          },
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cliente'),
        centerTitle: true,
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
      ),
      body: onLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: formKey,
              child: Provider<Map<int, ConfigCampo>>(
                create: (BuildContext context) {
                  return config;
                },
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: [
                    /// OPÇÕES
                    Cadastro(
                        cliente: cliente,
                        expanded: true,
                        onExpansionChanged: (b) {
                          // salvarCliente();
                        },
                        update: () {
                          formKey.currentState!.save();
                          setState(() {});
                        },
                        editable: editable,
                        pessoaJuridica: cliente.pessoaJuridica),

                    CadastroBasico(
                      cliente: cliente,
                      expanded: true,
                      onExpansionChanged: (b) {
                        // salvarCliente();
                        // cadastroBasicoExpanded = b;
                      },
                      update: () {
                        // widget.formKey.currentState!.save();
                        setState(() {});
                      },
                      editable: editable,
                      pessoaJuridica: cliente.pessoaJuridica,
                    ),

                    Contato(
                        cliente: cliente,
                        expanded: true,
                        onExpansionChanged: (b) {
                          // salvarCliente();
                          // contatoExpanded = b;
                        },
                        editable: editable),

                    Endereco(
                        cliente: cliente,
                        expanded: true,
                        onExpansionChanged: (b) {
                          // salvarCliente();
                          // enderecoExpanded = b;
                        },
                        editable: editable),

                    /// EXTRA
                    Card(
                      margin: const EdgeInsets.only(
                          left: 2, right: 2, top: 2, bottom: 64),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 6),
                        child: ListViewNested(
                          children: [
                            const SizedBox(
                              height: 16,
                            ),
                            const TextTitle('Observação'),
                            ConfigCampAdapter(
                              onSaved: (text, x) {
                                if (text != null) {
                                  cliente.obs = text;
                                }
                              },
                              limit: 300,
                              label: 'Obs',
                              configId: 23,
                              value: cliente.obs,
                              editavel: editable,
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: ButtonSalvar(
        enabled: true,
        onPressed: onPressed,
      ),
    );
  }
}
