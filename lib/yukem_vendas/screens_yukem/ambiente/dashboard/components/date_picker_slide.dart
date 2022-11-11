import 'package:flutter/material.dart';

import '../../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../../api/common/formatter/date_time_formatter.dart';

class DatePickerSlide extends StatefulWidget {
  const DatePickerSlide({
    Key? key,
    required this.minDate,
    required this.maxDate,
    required this.startingDate,
    required this.onChange,
  }) : super(key: key);

  final DateTime minDate;
  final DateTime maxDate;
  final DateTime startingDate;

  final Function(DateTime newDate) onChange;

  @override
  State<DatePickerSlide> createState() => _DatePickerSlideState();
}

class _DatePickerSlideState extends State<DatePickerSlide> {
  late DateTime currentDate;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentDate = widget.startingDate;
  }

  @override
  Widget build(BuildContext context) {
    change(int days) {
      final dt = Duration(days: days);

      final newDate = currentDate.add(Duration(days: days));

      if (newDate.isAfter(widget.minDate) && newDate.isBefore(widget.maxDate)) {
        setState(() {
          currentDate = newDate;
          widget.onChange(newDate);
        });
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextButton(
                onPressed: () {
                  change(-1);
                },
                child: const TextTitle('Anterior')),
          ),
          Expanded(
            flex: 3,
            child: Align(
                alignment: Alignment.center,
                child: TextBigTitle(
                    DateFormatter.normalDataResumido.format(currentDate))),
          ),
          Expanded(
            flex: 2,
            child: TextButton(
                onPressed: () {
                  change(1);
                },
                child: const TextTitle('Próximo')),
          ),
        ],
      ),
    );
  }
}
