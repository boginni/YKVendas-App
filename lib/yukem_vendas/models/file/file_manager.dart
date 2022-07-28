import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class FileManager {
  static getDirectory(Directory dir) {
    return dir.path;
  }

  static writeFile(String filePath, data, {bool utfEncode = false}) {
    final file = File(filePath);

    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }

    if (utfEncode) {
      data = utf8.encode(data);
    }

    file.writeAsBytesSync(data);
  }

  static loadFile() {}

  static int Bytes = 8;
  static int KBytes = 1024;
  static int MBytes = 1048576;

  static double toMbSize(int size) {
    return size.toDouble() / MBytes.toDouble();
  }
}

class FilePath {

  static Future<String> getSyncFilePath(String ambiente) async {
    final dir = await getTemporaryDirectory();
    return '${dir.path}/${ambiente}/sync.gz';
  }

  static Future<String> getBackupPedidos(String ambiente) async {
    final dir = await getTemporaryDirectory();
    return '${dir.path}/${ambiente}/backup.json';
  }

  static Future<String> getLogoFilePath(String ambiente) async {
    final dir = await getTemporaryDirectory();
    return '${dir.path}/${ambiente}/logo.png';
  }

  static Future<String> getDatabase(String text) async {
    return  '${await getDatabasesPath()}/ambientes/$text.db';
  }

  static Future<String> getVendaBackupPath(String ambiente) async {


    // final dir = await getApplicationDocumentsDirectory();
    // final dir = await getExternalStorageDirectories();
    final dir = await getExternalStorageDirectory();
    print(dir);
    return  '${dir!.path}/backup/$ambiente/';
    // return  'aaa';
  }


}
