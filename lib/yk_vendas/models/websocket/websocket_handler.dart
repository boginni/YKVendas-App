import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../api/common/debugger.dart';
import '../internet/internet.dart';

class WebSocketHandler {
  String wsServer = Internet.getWebSocketServer();
  String wsRegEvent = const JsonEncoder().convert({"name": "register"});
  late final String ambiente;

  late bool autoReconnect;
  bool toFinish = false;

  WebSocket? _socket;

  WebSocketHandler();

  factory WebSocketHandler.of(BuildContext context) {
    return context.read<WebSocketHandler>();
  }

  wsFun(Function(WebSocket ws) f) {
    if (_socket != null) {
      f(_socket!);
    }
  }

  bool online() {
    return _socket != null;
  }

  sendMsg() {}

  void end() {
    toFinish = true;
    autoReconnect = false;
    wsFun((ws) => ws.close());
    WebsocketEventListener.postStatus(false);
  }

  init() {
    autoReconnect = true;
    webSocket(ambiente);
  }

  webSocket(String ambiente) async {
    printDebug('Conectando Websocket');

    if (_socket != null) {
      printDebug('socket já online');
    }

    reconect() {
      _socket = null;
      WebsocketEventListener.postStatus(false);
      if (autoReconnect) {
        webSocket(ambiente);
      }
    }

    try {
      await WebSocket.connect(wsServer)
          .timeout(const Duration(seconds: 20))
          .then((WebSocket ws) {
            
            
        printDebug('Websocket Pronto');

        _socket = ws;
        WebsocketEventListener.postStatus(false);
        toFinish = false;


        ws.listen((data) {
          print(data);

          try {
            final msg = const JsonDecoder().convert(data);


            if (msg['name'] == 'fbEventList') {
              final data = msg['data'][ambiente];

              if (data != null) {
                WebsocketEventListener.postEvent(data as List<dynamic>);
              }
            }
          } catch (e) {
            printDebug(e.toString());
          }
        }, onDone: () {
          printDebug('terminou');
          _socket = null;
          if (!toFinish) {
            printDebug('Não era pra ter finalizado');
            reconect();
          }
        }, onError: (e) {
          printDebug('terminou com erro');
          reconect();
        });

        ws.add(wsRegEvent);
      });
    } catch (e) {
      printDebug(e.runtimeType.toString());
      reconect();
    }
  }
}

abstract class WebsocketEventListener {
  static final List<WebsocketEventListener> _listeners = [];

  static addListener(WebsocketEventListener l) {
    _listeners.add(l);
  }

  static removeListener(WebsocketEventListener l) {
    _listeners.remove(l);
  }

  static _call(Function(WebsocketEventListener listener) f) {
    final listeners = List.of(_listeners);

    for (final listener in listeners) {
      try {
        f(listener);
      } catch (e) {
        removeListener(listener);
      }
    }
  }

  static postEvent(List<dynamic> event) {
    _call((listener) => listener.onGenericEvent(event));
  }

  static postStatus(bool newStatus) {
    _call((listener) => listener.onChangeStatus(newStatus));
  }

  void onGenericEvent(List<dynamic> event);

  void onChangeStatus(bool online);
}
