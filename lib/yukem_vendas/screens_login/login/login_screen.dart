import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
                  CurrentServer.getServer().then((value) {
                    setState(() {
                      server = value;
                    });
                  });
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

                    getServer();
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


                    if (server == null || server!.error) {
                      getServer();
                    } else {
                      login();
                    }

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
                      server == null || server!.error
                          ? "Buscar Servidor"
                          : "Entrar",
                      style: const TextStyle(fontSize: 18),
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

              if (errorMsg != null || errorMsg2 != null)
                const SizedBox(
                  height: 24,
                ),

              if (errorMsg != null)
                Align(
                  alignment: Alignment.center,
                  child: TextTitle(errorMsg!),
                ),
              if (errorMsg2 != null)
                Center(
                  child: TextTitle('Login Offline : $errorMsg2'),
                )
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

  Future offline(Credenciais credenciais) async {
    credenciais.offline = true;

    final maps = await DatabaseSystem.select('TB_AMBIENTES',
        where: 'NOME = ?', whereArgs: [credenciais.ambiente]);

    try {
      if (maps[0]['TO_SYNC'] != 0) {
        setState(() {
          errorMsg2 = 'Precisa finalizar a sincronização';
        });
        return;
      }
    } catch (e) {
      setState(() {
        errorMsg2 = 'Precisa finalizar a sincronização';
      });
      return;
    }

    await offlineLogin(
      credenciais,
      onSucces: () => acessarAmbiente(context, credenciais),
      onFail: (error) {
        setState(() {
          if (error == 0) {
            errorMsg2 = "Ambiente inválido para login offline";
          } else {
            errorMsg2 = "Senha ou Usuário inválido para login offline";
          }
        });
      },
    );
  }

  Future getServer() async {
    if (server == null || !server!.error) {
      return;
    }

    setState(() {
      isLoading = true;
      serverMsg = "Buscando servidor";
      addServidores(ambienteController.text).then((value) async {
        server = await CurrentServer.getServer();

        setState(() {
          isLoading = false;
          if (server!.error) {
            if (errorMsg != null) {
              return;
            }
          }

          serverMsg = null;

          if (server!.error) {
            errorMsg =
                "Não foi possível localizar o servidor para \"${ambienteController.text}\"";
          }


        });
        //
      });
      //
    });
  }

  Future login() async {

    if (isLoading) {
      return;
    }

    Credenciais credenciais = Credenciais();

    setState(() {
      errorMsg = null;
      errorMsg2 = null;
      credenciais.user = usuarioController.text;
      credenciais.ambiente = ambienteController.text;
      credenciais.senha = passController.text;
      credenciais.offline = false;
    });

    showDialog(
        context: context,
        builder: (x) {
          bool onLog = true;

          return LoginPopup(
            onCancel: () {
              onLog = false;
              offline(credenciais);
            },
            onStart: (f) {
              off() {
                onLog = false;
                f();
                offline(credenciais);
              }

              onlineLogin(
                credenciais,
                sincronizarWifi: AppSystem.of(context).sincronizarWifi,
                onSucces: () {
                  isLoading = false;
                  acessarAmbiente(context, credenciais);
                },
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
                      off();
                      break;
                    case 301:
                      errorMsg =
                          "Conexão perdida, ou servidor offline tente novamente";
                      off();
                      break;
                    case 302:
                      errorMsg = "Sem Internet";
                      off();
                      break;
                    case 303:
                      errorMsg = "Ambiente ou servidor offline";
                      off();
                      break;
                    case 304:
                      errorMsg =
                          "Dificuldades ao estabelecer conexão com o servidor, tente novamente";
                      off();
                      break;
                    default:
                      printDebug(error.toString());
                  }
                },
              ).then(
                (value) {
                  if (onLog) {
                    f();
                  }
                },
              );
            },
          );
        });
  }
}

class LoginPopup extends StatefulWidget {
  const LoginPopup({Key? key, required this.onCancel, required this.onStart})
      : super(key: key);

  final Function onCancel;
  final Function(Function) onStart;

  @override
  State<LoginPopup> createState() => _LoginPopupState();
}

class _LoginPopupState extends State<LoginPopup> {
  bool canPop = false;

  Future<bool> toPop() async {
    return canPop;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      widget.onStart(() {
        Navigator.of(context).pop();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => toPop(),
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TextNormal('Fazendo Login'),
                const SizedBox(
                  height: 16,
                ),
                const CircularProgressIndicator(),
                const SizedBox(
                  height: 16,
                ),
                const TextNormal(
                    'Logar offline não garante que terá uma sessão válida'),
                OutlinedButton(
                  onPressed: () {
                    canPop = true;
                    Navigator.of(context).pop();
                    widget.onCancel();
                  },
                  child: const Text('Login Offline'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
