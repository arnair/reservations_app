import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:toastification/toastification.dart';
import 'package:time_range_picker/time_range_picker.dart';

import 'package:reservations_app/widgets/time_ranges.dart';
import '../domain/reservation_model.dart';
import 'reservation_controller.dart';

class ReserveTable extends StatefulWidget {
  final String tableId;
  final DateTime selectedDate;

  const ReserveTable({
    super.key,
    required this.tableId,
    required this.selectedDate,
  });

  @override
  State<ReserveTable> createState() => _ReserveTableState();
}

class _ReserveTableState extends State<ReserveTable> {
  late MainTimeRange mainPicker;
  final ReservationController _controller = ReservationController();
  bool _isLoading = true;
  List<Reservation> _reservations = [];

  // Store the selected times
  TimeOfDay _selectedStartTime = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay _selectedEndTime = const TimeOfDay(hour: 8, minute: 0);

  @override
  void initState() {
    super.initState();
    // Initialize the time picker with a callback
    mainPicker = MainTimeRange(
      initialStart: const TimeOfDay(hour: 6, minute: 0),
      initialEnd: const TimeOfDay(hour: 8, minute: 0),
      onTimeChanged: (start, end) {
        setState(() {
          _selectedStartTime = start;
          _selectedEndTime = end;
        });
      },
    );
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    final reservations = await _controller.getTableReservations(
        widget.tableId, widget.selectedDate);

    if (mounted) {
      setState(() {
        _reservations = reservations;
        _isLoading = false;
      });
    }
  }

  Future<void> _onSubmit() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _controller.createReservation(
      tableId: widget.tableId,
      selectedDate: widget.selectedDate,
      startTime: _selectedStartTime,
      endTime: _selectedEndTime,
    );

    if (!mounted) return;

    if (result.success) {
      toastification.show(
        context: context,
        title: const Text("Time slot successfully reserved!"),
        autoCloseDuration: const Duration(seconds: 5),
        type: ToastificationType.success,
      );
      Navigator.of(context).pop();
    } else {
      setState(() {
        _isLoading = false;
      });

      toastification.show(
        context: context,
        title: Text(result.message ?? "Failed to create reservation"),
        autoCloseDuration: const Duration(seconds: 5),
        type: ToastificationType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('d-MMM').format(widget.selectedDate)),
      ),
      body: Container(
        constraints: const BoxConstraints(maxWidth: 550),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                _buildTimePicker(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _onSubmit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'SUBMIT',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    // Create disabled time ranges for each reservation
    List<Widget> disabledRanges = [];

    if (_reservations.isEmpty) {
      // No reservations yet
      disabledRanges.add(
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              "No existing reservations for this table on this date.",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      );
    } else {
      // Add a header to indicate disabled times
      disabledRanges.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            "Reserved time slots are shown in red",
            style: TextStyle(
              color: Colors.red.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

      for (var reservation in _reservations) {
        // Convert Firestore Timestamp to TimeOfDay
        final startDateTime = reservation.startDate.toDate();
        final endDateTime = reservation.endDate.toDate();

        final startTimeOfDay =
            TimeOfDay(hour: startDateTime.hour, minute: startDateTime.minute);

        final endTimeOfDay =
            TimeOfDay(hour: endDateTime.hour, minute: endDateTime.minute);

        disabledRanges.add(DisabledTimeRange(
          disabledTime: TimeRange(
            startTime: startTimeOfDay,
            endTime: endTimeOfDay,
          ),
        ));
      }
    }

    // Add the main time picker last so it's on top
    disabledRanges.add(mainPicker);

    return Stack(
      alignment: AlignmentDirectional.topStart,
      children: disabledRanges,
    );
  }
}
