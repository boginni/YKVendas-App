import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../api/common/components/list_scrollable.dart';
import '../../../api/common/custom_widgets/custom_icons.dart';
import '../../../api/common/custom_widgets/custom_text.dart';
import '../../../api/common/debugger.dart';
import '../../../api/models/configuracao/app_system.dart';
import '../../../api/models/system_database/system_database.dart';
import '../../app_foundation.dart';
import '../../models/database/database_update.dart';
import '../../models/internet/login_manager.dart';
import '../../models/internet/server_manager.dart';
import '../../screens_yukem/ambiente/configuracoes/tela_configuracao_sistema.dart';
import '../servidores/tela_servidores.dart';

class LoginScreen extends StatefulWidget {
  static String routeName = 'login';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController ambienteController = TextEditingController();
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  bool isLoading = false;
  String? errorMsg;
  String? errorMsg2;
  String? serverMsg;

  bool verSenha = false;
  CurrentServer? server;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      start().then((value) {
        CurrentServer.getServer().then((value) {
          setState(() {
            server = value;
          });
        });
      });
    });
  }

  Future start() async {
    final db = await DatabaseSystem.getDatabase();

    // final db = await DatabaseSystem.getDatabase();

    List<Map<String, dynamic>> res;
    res = await db.query('VW_ULTMO_USUARIO');
    ambienteController.text = res[0]['AMBIENTE'];
    usuarioController.text = res[0]['LOGIN'];
    final appSystem = AppSystem.of(context);
    passController.text = appSystem.salvarSenha ? res[0]['PASS'] : "";

    await db.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrar'),
        centerTitle: true,
        leading: InkWell(
          child: const Icon(Icons.settings),
          onTap: () {
            /**
             * Vai para tela de configuração
             */
            Application.navigate(
              context,
              const TelaConfiguracoesSistema(),
              callback: () {
                setState(() {});
              },
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: InkWell(
              onTap: () {
                Application.navigate(
                    context,
                    TelaServidores(
                      ambiente: ambienteController.text,
                    ), callback: () {
                  setState(() {});
                });
              },
              child: const Icon(Icons.wifi, size: 24),
            ),
          )
        ],
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shrinkWrap: true,
            // mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Builder(builder: (BuildContext context) {
                late Widget widget;

                if (server != null) {
                  widget = server!.getWidget();
                } else {
                  widget = TextTitle(
                    serverMsg ?? 'Carregando',
                    color: Colors.grey,
                  );
                }

                return Column(
                  children: [
                    const Center(child: TextNormal('Servidor')),
                    Center(
                      child: widget,
                    ),
                  ],
                );
              }),

              Focus(
                onFocusChange: (x) {
                  if (!x) {
                    ambienteController.text = ambienteController.text.trim();
                  }
                },
                child: TextFormField(
                  controller: ambienteController,
                  // enabled: !UserManager.loading,
                  decoration: const InputDecoration(
                    label: TextNormal('Ambiente'),
                    hintText: 'Ambiente',
                  ),
                  autocorrect: false,
                ),
              ),

              /**
               * USUÁRIO
               */

              const SizedBox(
                height: 16,
              ),
              Focus(
                onFocusChange: (x) {
                  if (!x) {
                    usuarioController.text = usuarioController.text.trim();
                  }
                },
                child: TextFormField(
                  controller: usuarioController,
                  // enabled: !UserManager.loading,
                  decoration: const InputDecoration(
                    label: TextNormal('Usuário'),
                    hintText: 'Usuário',
                  ),
                  autocorrect: false,
                  // validator: (email) {
                  //   if (!emailValid(email!)) return 'E-mail inválido';
                  //   return null;
                  // },
                ),
              ),

              /**
               * SENHA
               */

              const SizedBox(
                height: 16,
              ),

              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: TextFormField(
                      controller: passController,
                      // enabled: !UserManager.loading,
                      decoration: const InputDecoration(
                        label: TextNormal('Senha'),
                        hintText: 'Senha',
                      ),
                      autocorrect: false,
                      obscureText: !verSenha,
                      validator: (pass) {
                        if (pass!.isEmpty || pass.length < 6) {
                          return 'Senha inválida';
                        }
                        return null;
                      },
                    ),
                  ),
                  Expanded(
                      flex: 1,
                      child: InkWell(
                        child: const IconNormal(Icons.remove_red_eye_outlined),
                        onTap: () {
                          verSenha = !verSenha;
                          setState(() {});
                        },
                      )),
                ],
              ),

              const SizedBox(
                height: 4,
              ),

              // FormSwitchButton(title: "Salvar Senha", onChange: (b) {
              //
              // }),

              // Align(
              //   alignment: Alignment.centerRight,
              //   child: TextButton(
              //     onPressed: () {},
              //     child: const Text('Esqueci minha senha'),
              //   ),
              // ),

              /**
               * ENTRAR
               */

              const SizedBox(
                height: 16,
              ),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    // login();

                    login();

                    // mostrarBarraProgressoCircular(context);
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor),
                  child: Builder(builder: (context) {
                    if (isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return Text(
                      server == null ? "Buscar Servidor" : "Entrar",
                      style: TextStyle(fontSize: 18),
                    );
                  }),
                ),
              ),

              const SizedBox(
                height: 8,
              ),
              Text(
                appVersion,
                textAlign: TextAlign.center,
              ),

              if (errorMsg != null)
                ListViewNested(children: [
                  const SizedBox(
                    height: 24,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: TextTitle(errorMsg!),
                  ),
                  if (errorMsg2 != null)
                    Center(
                      child: TextTitle('Login Offline : $errorMsg2'),
                    )
                ]),
            ],
          ),
        ),
      ),
    );

    // return FutureBuilder(
    //     future: firstBuild ? start() : null,
    //     builder: (context, AsyncSnapshot<dynamic> snapshot) {
    //       if (snapshot.connectionState != ConnectionState.done && firstBuild) {
    //         return const ScreenLoading(children: [
    //           TextNormal('Inicializando tela de login'),
    //         ]);
    //       }
    //
    //       return ;
    //     });
  }

  offline(Credenciais credenciais) async {
    credenciais.offline = true;

    final maps = await DatabaseSystem.select('TB_AMBIENTES',
        where: 'NOME = ?', whereArgs: [credenciais.ambiente]);

    try {
      if (maps[0]['TO_SYNC'] != 0) {
        errorMsg2 = 'Precisa finalizar a sincronização';
        return;
      }
    } catch (e) {
      errorMsg2 = 'Precisa finalizar a sincronização';
      return;
    }

    showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: TextTitle('teste'),
          );
        }).then((value) => {
          if (value == true)
            {
              offlineLogin(
                credenciais,
                onSucces: () => acessarAmbiente(context, credenciais),
                onFail: (error) {
                  if (error == 0) {
                    errorMsg2 = "Ambiente inválido para login offline";
                  } else {
                    errorMsg2 = "Senha ou Usuário inválido para login offline";
                  }
                  setState(() {});
                },
              )
            }
        });
  }

  Future getServer() async {
    CurrentServer currentServer = server!;

    if (currentServer.error) {
      serverMsg = "Buscando servidor";

      setState(() {});

      await addServidores(ambienteController.text, () {
        errorMsg = "Servidor Indisponível";
        setState(() {});
      });

      if (errorMsg != null) {
        isLoading = false;
        setState(() {});
        return;
      }

      currentServer = await CurrentServer.getServer();
    }

    serverMsg = null;

    if (currentServer.error) {
      errorMsg =
          "Não foi possível localizar o servidor para \"${ambienteController.text}\"";
      isLoading = false;
      setState(() {});
      return;
    }
  }

  Future login() async {
    if (isLoading) {
      return;
    }

    isLoading = true;

    setState(() {});

    errorMsg = null;
    errorMsg2 = null;

    Credenciais credenciais = Credenciais();

    credenciais.user = usuarioController.text;
    credenciais.ambiente = ambienteController.text;
    credenciais.senha = passController.text;
    credenciais.offline = false;

    onlineLogin(credenciais,
        sincronizarWifi: AppSystem.of(context).sincronizarWifi,
        onSucces: () => acessarAmbiente(context, credenciais),
        onFail: (error) {
          switch (error) {
            case 101:
              errorMsg = "Evite Campos nulos";
              break;
            case 102:
              errorMsg = "Ambiente Inexistente!";
              break;
            case 103:
              errorMsg = "Senha ou Usuário inválidos!";
              break;
            case 104:
              errorMsg = "Login online somente em wifi";
              offline(credenciais);
              break;
            case 301:
              errorMsg = "Conexão perdida, ou servidor offline tente novamente";
              offline(credenciais);
              break;
            case 302:
              errorMsg = "Sem Internet";
              offline(credenciais);
              break;
            case 303:
              errorMsg = "Ambiente ou servidor offline";
              offline(credenciais);
              break;
            case 304:
              errorMsg =
                  "Dificuldades ao estabelecer conexão com o servidor, tente novamente";
              offline(credenciais);
              break;
            default:
              printDebug(error.toString());
          }
        }).then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }
}
