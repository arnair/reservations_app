


import 'package:flutter/material.dart';
import 'package:time_range_picker/time_range_picker.dart';

class MainTimeRange extends StatefulWidget {
  var reservationStart = TimeOfDay(hour: 2, minute: 0);
  var reservationEnd = TimeOfDay(hour: 3, minute: 0);

  MainTimeRange({super.key});

  @override
  State<MainTimeRange> createState() => _MainTimeRangeState();
}

class _MainTimeRangeState extends State<MainTimeRange> {

  @override
  Widget build(BuildContext context) {
    return TimeRangePicker(
      interval: const Duration(minutes: 15),
      hideButtons: true,
      onStartChange: (start) => setState(() {widget.reservationStart = start;}),
      onEndChange: (end) => setState(() {widget.reservationEnd = end;}),
      start: widget.reservationStart,
      end: widget.reservationEnd,
    );
  }
}

class DisabledTimeRange extends TimeRangePicker {
  DisabledTimeRange({Key? key, required TimeRange disabledTime}) :  super(
    key: key,
    strokeColor: Colors.transparent,
    handlerColor: Colors.transparent,
    selectedColor: Colors.transparent,
    backgroundColor: Colors.transparent,
    hideButtons: true,
    disabledTime:disabledTime
  );
}