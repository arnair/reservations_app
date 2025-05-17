import 'package:flutter/material.dart';
import 'package:time_range_picker/time_range_picker.dart';

class MainTimeRange extends StatefulWidget {
  final TimeOfDay initialStart;
  final TimeOfDay initialEnd;

  // Add a callback function for time changes
  final Function(TimeOfDay, TimeOfDay)? onTimeChanged;

  const MainTimeRange({
    super.key,
    this.initialStart = const TimeOfDay(hour: 12, minute: 0),
    this.initialEnd = const TimeOfDay(hour: 13, minute: 0),
    this.onTimeChanged,
  });

  @override
  State<MainTimeRange> createState() => _MainTimeRangeState();
}

class _MainTimeRangeState extends State<MainTimeRange> {
  late TimeOfDay _currentReservationStart;
  late TimeOfDay _currentReservationEnd;

  // Getters for the current start and end times
  TimeOfDay get reservationStart => _currentReservationStart;
  TimeOfDay get reservationEnd => _currentReservationEnd;

  @override
  void initState() {
    super.initState();
    _currentReservationStart = widget.initialStart;
    _currentReservationEnd = widget.initialEnd;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<ClockLabel> labels = [];
    int offset = 90;
    for (int index = 0; index < 12; index++) {
      labels.add(ClockLabel.fromDegree(
          deg: (index * 30 + offset).toDouble(), text: '${index * 2}'));
    }

    return TimeRangePicker(
      interval: const Duration(minutes: 15),
      hideButtons: true,
      onStartChange: (start) {
        setState(() {
          _currentReservationStart = start;
          if (widget.onTimeChanged != null) {
            widget.onTimeChanged!(
                _currentReservationStart, _currentReservationEnd);
          }
        });
      },
      onEndChange: (end) {
        setState(() {
          _currentReservationEnd = end;
          if (widget.onTimeChanged != null) {
            widget.onTimeChanged!(
                _currentReservationStart, _currentReservationEnd);
          }
        });
      },
      start: _currentReservationStart,
      end: _currentReservationEnd,
      labels: labels,
      labelOffset: -20,
      ticks: 24,
      ticksOffset: -7,
      ticksLength: 15,
      minDuration: const Duration(minutes: 30),
      maxDuration: const Duration(hours: 8),
      handlerRadius: 8,
      strokeWidth: 4,
      strokeColor: Theme.of(context).primaryColor,
      handlerColor: Theme.of(context).primaryColor,
      selectedColor: Theme.of(context).primaryColor,
    );
  }
}

class DisabledTimeRange extends TimeRangePicker {
  DisabledTimeRange({super.key, required TimeRange disabledTime})
      : super(
            strokeColor: Colors.red,
            handlerColor: Colors.transparent,
            selectedColor: Colors.red,
            backgroundColor: Colors.transparent,
            hideButtons: true,
            disabledTime: disabledTime);
}
