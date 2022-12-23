import '../../common/debugger.dart';

abstract class QueueAction {
  bool onTurn = false;

  Future<void> doTurn() async {}

  static List<QueueAction> listeners = [];

  static addListener(QueueAction realTimeSync) {
    if (!listeners.contains(realTimeSync)) {
      listeners.add(realTimeSync);
    }
  }

  static removeListener(QueueAction realTimeSync) {
    listeners.remove(realTimeSync);
  }

  static clearListeners() {
    listeners.clear();
  }

  static bool doingloop = false;

  static void doLoop() async {
    if (doingloop) {
      return;
    }


    doingloop = true;

    await Future.delayed(const Duration(milliseconds: 100));

    for (final obj in List.of(listeners)) {
      await Future.delayed(const Duration(milliseconds: 100));
      try {
        if(listeners.contains(obj)){
          await obj.doTurn();
        }
      } catch (e) {
        printDebug(e);
        printDebug('error type: ${e.runtimeType}');
      }
      removeListener(obj);
    }

    doingloop = false;
  }
}
