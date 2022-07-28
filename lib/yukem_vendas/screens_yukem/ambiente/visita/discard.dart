// getQuery() {
//   String x = _pesquisaController.text;
//   bool y = isNumeric(x);
//
//   final qf = QueryFilter(args: {
//     'ID_ROTA': rota.id,
//     'CLIENTE_STATUS': 1,
//     'TIPO': 1,
//     'ID_VENDEDOR': appUser.vendedorAtual,
//     y ? 'CPF_CNPJ' : 'NOME': x,
//     'CRIACAO': dataVisita != null
//         ? DateFormatter.databaseDate.format(dataVisita!)
//         : '',
//     'SITUACAO': listSituacao,
//     'SYNC': listStatus
//   }, allowNull: true);
//
//   // printDebug(qf.getWhere() + " " + qf.getArgs().toString());
//
//   return qf;
// }
//
// Widget barraPesquisaAvancada = Card(
//   margin: const EdgeInsets.only(bottom: 6, right: 8, left: 8),
//   child: Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//     child: ListViewNested(children: [
//       /// Filtros
//       const SizedBox(
//         height: 16,
//       ),
//       const TextTitle('Data da Visita'),
//       Row(
//         children: [
//           Expanded(
//             child: FormDatePicker(
//                 initialDate: DateTime.now(),
//                 firstDate: DateTime.now().add(const Duration(days: -360)),
//                 lastDate: DateTime.now().add(const Duration(days: 360)),
//                 startingDate: dataVisita,
//                 then: (DateTime? date) {
//                   if (date != null) {
//                     dataVisita = date;
//                     if (appSystem.usarPesquisaDinamica) {
//                       setState(() {});
//                     }
//                   }
//                 },
//                 hint: 'Data da Visita'),
//           ),
//           ButtonIcon(
//             onPressed: () {
//               dataVisita = null;
//               if (appSystem.usarPesquisaDinamica) {
//                 setState(() {});
//               }
//             },
//             icon: CupertinoIcons.clear_circled_solid,
//           ),
//         ],
//       ),
//       const TextTitle('Pesquisar'),
//       TextFormField(
//         controller: _pesquisaController,
//         onChanged: (x) {
//           if (appSystem.usarPesquisaDinamica) {
//             setState(() {});
//           }
//         },
//         decoration:
//         const InputDecoration(hintText: 'CPF_CNPJ ou Nome Pessoa'),
//       ),
//       ExpansionTile(
//         title: const TextTitle('SITUAÇÃO'),
//         children: [
//           ListView.builder(
//             itemBuilder: (BuildContext context, int index) {
//               final item = listSituacao[index];
//               return CheckboxTile(
//                   item: item,
//                   onChange: () {
//                     if (appSystem.usarPesquisaDinamica) {
//                       setState(() {});
//                     }
//                   });
//             },
//             itemCount: listSituacao.length,
//             shrinkWrap: true,
//           ),
//         ],
//       ),
//       ExpansionTile(
//         title: const TextTitle('STATUS'),
//         children: [
//           ListView.builder(
//             itemBuilder: (BuildContext context, int index) {
//               final item = listStatus[index];
//               return CheckboxTile(
//                   item: item,
//                   onChange: () {
//                     if (appSystem.usarPesquisaDinamica) {
//                       setState(() {});
//                     }
//                   });
//             },
//             itemCount: listStatus.length,
//             shrinkWrap: true,
//           ),
//         ],
//       ),
//       ElevatedButton(
//           onPressed: () {
//             FocusManager.instance.primaryFocus?.unfocus();
//             mostrarPesquisa = false;
//             setState(() {});
//           },
//           child: const TextNormal("Pesquisar")),
//     ]),
//   ),
// );
//
// Widget barraPesquisaSimples = SearchBar(
//   controller: _pesquisaController,
//   onPrimary: () {
//     setState(() {});
//   },
//   onSecondary: () {
//     pesquisaSimples = false;
//     setState(() {});
//   },
//   onChanged: (s) {
//     if (appSystem.usarPesquisaDinamica) {
//       setState(() {});
//     }
//   },
// );