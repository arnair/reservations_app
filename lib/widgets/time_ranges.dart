


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
    
    List<ClockLabel> labels = [];
    int offset = 90;
    for (int index = 0; index < 12; index++) {
      labels.add(ClockLabel.fromDegree(deg: (index * 30 + offset).toDouble(), text: '${index * 2}'));
    }
    
    return TimeRangePicker(
      interval: const Duration(minutes: 15),
      hideButtons: true,
      onStartChange: (start) => setState(() {widget.reservationStart = start;}),
      onEndChange: (end) => setState(() {widget.reservationEnd = end;}),
      start: widget.reservationStart,
      end: widget.reservationEnd,
      labels: labels,
      labelOffset: -20,
      ticks: 24,
      ticksOffset: -7,
      ticksLength: 15,
      minDuration: const Duration(minutes: 60),
      maxDuration: const Duration(hours: 8),
    );
  }
}

class DisabledTimeRange extends TimeRangePicker {
  DisabledTimeRange({super.key, required TimeRange disabledTime}) :  super(
    strokeColor: Colors.transparent,
    handlerColor: Colors.transparent,
    selectedColor: Colors.transparent,
    backgroundColor: Colors.transparent,
    hideButtons: true,
    disabledTime:disabledTime
  );
}