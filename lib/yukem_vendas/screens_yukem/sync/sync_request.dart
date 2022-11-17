import 'dart:convert';

import 'package:forca_de_vendas/yukem_vendas/models/internet/server_route.dart';
import 'package:http/http.dart';

import '../../models/configuracao/app_user.dart';
import '../../models/file/file_manager.dart';
import '../../models/internet/internet.dart';
import '../../models/internet/sync_dados.dart';

class SyncRequest {
  int? rota;
  int? vendedor;

  static final _EmptyListener emptyListener = _EmptyListener();

  final SyncRequestListener listener;

  SyncRequest(this.listener);

  List<String> rotaView = [];
  Map<String, String?> normalView = {};

  String toBody({bool force = false}) {
    if (vendedor == null && !force) {
      throw Exception(
          'sincronização pode não funcionar se o vendedor for nulo');
    }

    return const JsonEncoder().convert({
      "rota": rota,
      "vendedor": vendedor,
      "views": {"normal": normalView, "rota": rotaView}
    });
  }

  void addItem(String arquivo, String data) {
    normalView[arquivo] = data.isEmpty ? null : data;
  }

  fullSync() {
    fullViews();
    fullRotas();
  }

  fullViews() {
    normalView = _normalViews;
  }

  fullRotas() {
    rotaView = _rotaViews;
  }

  Request getRequest(AppUser app) {
    final request = Request('POST', Internet.getHttpUri(ServerPath.VIEW));
    vendedor = app.vendedorAtual;
    final body = toBody();
    request.body = body;
    request.headers.addAll(app.toHeaders());
    request.headers.addAll(Internet.getDeafultHeaders(body));

    return request;
  }

  updateListener(Function(SyncRequestListener l) list) {
    list(listener);
  }

  bool isDownloading = false;
  Request? request;
  Client? client;

  int totalSize = 1;
  int currentSize = 0;

  bool preparando = false;

  Future<void> download(AppUser app,
      {Function(Object? err)? onFinished, Duration? timeout}) async {
    if (isDownloading) {
      return;
    }

    final request = getRequest(app);

    updateListener((l) {
      isDownloading = false;
      preparando = true;
      totalSize = 1;
      currentSize = 0;
      l.onPreServerResponse();
    });

    try {
      client = Client();
      final StreamedResponse response = await client!
          .send(request)
          .timeout(timeout ?? const Duration(seconds: 20));


      if(response.statusCode == 403){
        throw Forbidden();
      }

      List<int> bytes = [];
      updateListener((l) {
        isDownloading = true;
        preparando = false;
        totalSize = response.contentLength ?? 1;
        l.onServerResponse();
      });

      response.stream.listen(
        (List<int> newBytes) {
          bytes.addAll(newBytes);

          updateListener((l) {
            currentSize = bytes.length;
            l.onProgress();
          });
        },
        onDone: () async {
          final filePath = await FilePath.getSyncFilePath(app.ambiente);

          updateListener((l) {
            FileManager.writeFile(filePath, bytes);
            isDownloading = false;
            l.onFinish(bytes);
          });
          if (onFinished != null) {
            onFinished(null);
          }
        },
        onError: (e) {
          updateListener((l) {
            isDownloading = false;

            l.onError(e);
          });
        },
        cancelOnError: true,
      );
    } catch (e) {

      updateListener((l) {
        isDownloading = false;
        preparando = false;
        l.onError(e);
      });

      if (onFinished != null) {
        onFinished(e);
      }
    }
  }

  double getProgress() {
    return currentSize / totalSize;
  }

  double getTotalSizeMb() {
    return FileManager.toMbSize(totalSize);
  }

  double getCurrentSizeMb() {
    return FileManager.toMbSize(currentSize);
  }

  lastUpdate() async {
    List<SyncItem> syncList = await SyncItem.getSyncList();

    for (final item in syncList) {
      addItem(item.nomeArquivo, item.dataLastUpdate);
    }
  }
}

abstract class SyncRequestListener {
  void onPreServerResponse();

  void onServerResponse();

  void onProgress();

  void onFinish(List<int> bytes);

  void onError(Object e);
}

const _normalViews = {
  "MOB_VW_CLIENTE": null,
  "MOB_VW_ROTA": null,
  "MOB_VW_CLIENTE_ROTA": null,
  "MOB_VW_GRUPO": null,
  "MOB_VW_DEPARTAMENTO": null,
  "MOB_VW_SUB_GRUPO": null,
  "MOB_VW_UNIDADE": null,
  "MOB_VW_PRODUTO": null,
  "MOB_VW_TABELA_PRECO": null,
  "MOB_VW_TABELA_PRECO_PRODUTO": null,
  "MOB_VW_TABELA_PRECO_QT": null,
  "MOB_VW_FORMA_PAGAMENTO_TIPO": null,
  "MOB_VW_FORMA_PAGAMENTO": null,
  "MOB_VW_VENDEDOR": null,
  "MOB_VW_COMISSAO_DIARIA": null,
  "MOB_VW_VENDEDOR_ROTA": null,
  "MOB_VW_CONF_AMBIENTE": null,
  "MOB_VW_CONF_AMBIENTE_USER": null,
  "MOB_VW_CIDADE_ROTA": null,
  "MOB_VW_CONTATO_TIPO": null,
  "MOB_VW_CONTATO": null,
  "MOB_VW_COMODATO_CAB": null,
  "MOB_VW_COMODATO_DET": null,
  "MOB_VW_CLIENTE_VENDEDOR": null,
  "MOB_VW_CONF_CADASTRO_CAMPO": null,
  "MOB_VW_MOTIVO_CANCELAMENTO": null,
  "MOB_VW_BLOQUEIO_PG_TIPO": null,
  "MOB_VW_CLIENTE_TIPO": null,
  "MOB_VW_VENDEDOR_TABELA" : null
};

const _rotaViews = [
  "MOB_VW_TITULO_ABERTO_ROTA",
  "MOB_VW_HISTORICO_CAB_ROTA",
  "MOB_VW_HISTORICO_DET_ROTA"
];

class _EmptyListener implements SyncRequestListener {
  @override
  void onError(Object e) {
    // TODO: implement onError
  }

  @override
  void onFinish(List<int> bytes) {}

  @override
  void onPreServerResponse() {}

  @override
  void onProgress() {}

  @override
  void onServerResponse() {}
}
