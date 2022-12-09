import 'package:flutter/cupertino.dart';

import '../../api/common/components/mostrar_confirmacao.dart';
import '../../api/common/custom_widgets/custom_text.dart';
import '../../api/common/debugger.dart';
import '../../api/models/system_database/system_database.dart';
import '../../api/screens/support/screen_loading.dart';
import '../app_foundation.dart';
import '../models/database/database_ambiente.dart';
import '../models/database/database_update.dart';

class DatabaseUpdateViwer extends StatefulWidget {
  const DatabaseUpdateViwer(
      {Key? key, required this.onFinish, required this.ambiente})
      : super(key: key);

  final Function(bool fullSync) onFinish;
  final String ambiente;

  @override
  State<DatabaseUpdateViwer> createState() => _DatabaseUpdateViwerState();
}

class _DatabaseUpdateViwerState extends State<DatabaseUpdateViwer> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      updateDatabase();
    });
  }

  updateDatabase() async {
    bool fullSync = false;

    try {
      await DatabaseAmbiente.reloadDatabase();

      await updateAmbienteDatabase(onSaveData: () async {
        bool value = await mostrarCaixaConfirmacao(context,
            title: 'AVISO IMPORTANTE',
            content:
                'Você possue pedidos não sincronizados, não é recomendado atualizar app com vendas em aberto. deseja mesmo continuar?');
        return value;
      }).then((value) async {
        if (value) {
          await DatabaseSystem.insert(
              'TB_AMBIENTES', {'TO_SYNC': 1, 'NOME': widget.ambiente});

          fullSync = true;
          return true;
        }

        return false;
      });

      widget.onFinish(fullSync);
    } catch (e) {
      if (e.runtimeType == OperacaoCancelada) {
        Application.logout(context);
        return;
      }

      printDebug(e.toString());
      throw Exception('Não foi possível iniciar o banco de dados');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const ScreenLoading(
      children: [
        TextTitle(
          'Iniciando Banco de Dados',
        ),
        Text('Isso não deve demorar'),
      ],
    );
  }
}
