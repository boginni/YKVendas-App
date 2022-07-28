// import 'dart:convert';
// import 'package:http/http.dart';
//
// Future<Response?> serverPost(int id) async {
//   dynamic body = {};
//   Map<String, String>? headers;
//
//   /// converte para json se não for
//   if (body is! String) {
//     body = const JsonEncoder().convert(body);
//   }
//
//   headers ??= {};
//
//   /// adiciona os headers padõres
//   headers.addAll({
//     'Content-Type': 'application/json',
//     // 'Content-Length': body.length.toString(),
//     'charset': 'utf-8',
//     'ambiente': 'utf-8',
//     'id': '$id',
//   });
//
//   String urlRequest = 'http://boginni.net:11002/test';
//
//   try {
//     post(Uri.parse(urlRequest), headers: headers, body: body).then((value) {
//       // printDebug('succes at $id');
//       list[id] = true;
//       succes++;
//     }).timeout(const Duration(seconds: 1), onTimeout: (){
//       fail++;
//     });
//   } catch (e) {
//     // printDebug("fail at $id");
//   }
// }
//
// List<bool> list = [];
// int succes = 0;
// int fail = 0;
// int tot = 100;
//
//
//
//
// printRes(){
//   for(int i = 0; i < 10; i++){
//
//   }
//   // printDebug('total => $tot');
//   // printDebug('waiting => ${tot - succes + fail}');
//   // printDebug('succes => $succes');
//   // printDebug('fails => $fail');
// }
//
// showthread() async{
//   Future.delayed(const Duration(milliseconds:  1500)).then((value) {
//     printRes();
//     showthread();
//   });
// }
//
//
// main() async {
//
//
//   // for (int i = 0; i < tot; i++) {
//   //   list.insert(i, false);
//   //   printDebug('sending $i');
//   //   serverPost(i);
//   //   await Future.delayed(const Duration(milliseconds: 100));
//   // }
//   //
//   // for (int i = 0; i < 5; i++) {
//   //   printDebug('results in ${5 - i}');
//   //   await Future.delayed(const Duration(seconds: 1)).then((value) {});
//   // }
//   //
//   // for (int i = 0; i < 100; i++) {
//   //   printDebug('req[$i] => ${list[i]}');
//   // }
//   //
//   // fail = tot - succes;
//   // printRes();
//
//
//   showthread();
//   tot = 0;
//   while(true){
//     list.insert(tot, false);
//     serverPost(tot);
//     tot++;
//     await Future.delayed(const Duration(milliseconds: 100));
//   }
//
// }
