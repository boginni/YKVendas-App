import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SelecionarPeriodo extends StatelessWidget {
  const SelecionarPeriodo({Key? key}) : super(key: key);

  static Future<DateTimeRange?> showPicker(BuildContext context) async {
    return await showDateRangePicker(
        context: context,
        firstDate: DateTime.now().add(Duration(days: -90)),
        lastDate: DateTime.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              //Header background color
              primaryColor: Colors.blue,
              //Background color
              scaffoldBackgroundColor: Colors.grey[50],
              //Divider color
              dividerColor: Colors.grey,
              //Non selected days of the month color
              textTheme: TextTheme(
                bodyText2: TextStyle(color: Colors.black),
              ),
              colorScheme: ColorScheme.fromSwatch().copyWith(
                //Selected dates background color
                primary: Colors.blue,
                //Month title and week days color
                onSurface: Colors.black,
                //Header elements and selected dates text color
                //onPrimary: Colors.white,
              ),
            ),
            child: child!,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
