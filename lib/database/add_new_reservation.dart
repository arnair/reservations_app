import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:developer';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:toastification/toastification.dart';
import 'package:time_range_picker/time_range_picker.dart';

import 'package:reservations_app/widgets/time_ranges.dart';

class CustomTimeRange {
  final Timestamp startTime;
  final Timestamp endTime;

  const CustomTimeRange({required this.startTime, required this.endTime});
}

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

bool isTimeSlotAvailable(CustomTimeRange currentSlot, CustomTimeRange occupiedSlot) {
  log("currentSlot start: ${currentSlot.startTime.millisecondsSinceEpoch} - occupiedSlot start: ${occupiedSlot.startTime.millisecondsSinceEpoch}");
  log("currentSlot end: ${currentSlot.endTime.millisecondsSinceEpoch} - occupiedSlot end: ${occupiedSlot.endTime.millisecondsSinceEpoch}");

  // Check if current slot starts within occupied slot
  if ((currentSlot.startTime.millisecondsSinceEpoch > occupiedSlot.startTime.millisecondsSinceEpoch) && (currentSlot.startTime.millisecondsSinceEpoch < occupiedSlot.endTime.millisecondsSinceEpoch)) {
    log("Selected slot starts within occupied slot!");
    toastification.show(
      title: Text("Selected slot starts within occupied slot!"),
      autoCloseDuration: const Duration(seconds: 10),
      type: ToastificationType.error,
    );

    return false;
  }

  // Check if current slot ends within occupied slot
  if ((currentSlot.endTime.millisecondsSinceEpoch > occupiedSlot.startTime.millisecondsSinceEpoch) && (currentSlot.endTime.millisecondsSinceEpoch < occupiedSlot.endTime.millisecondsSinceEpoch)) {
    log("Selected slot ends within occupied slot!");
    toastification.show(
      title: Text("Selected slot ends within occupied slot!"),
      autoCloseDuration: const Duration(seconds: 10),
      type: ToastificationType.error,
    );

    return false;
  }

  // Check if occupied slot is within current slot
  if ((currentSlot.startTime.millisecondsSinceEpoch <= occupiedSlot.startTime.millisecondsSinceEpoch) && (currentSlot.endTime.millisecondsSinceEpoch >= occupiedSlot.endTime.millisecondsSinceEpoch)) {
    log("Selected slot is already reserved!");
    toastification.show(
      title: Text("Selected slot is already reserved!"),
      autoCloseDuration: const Duration(seconds: 10),
      type: ToastificationType.error,
    );

    return false;
  }
  

  return true;
}

class _ReserveTableState extends State<ReserveTable> {
  var reservationStart = TimeOfDay(hour: 2, minute: 0);
  var reservationEnd = TimeOfDay(hour: 3, minute: 0);
  final MainTimeRange mainPicker = MainTimeRange();

  List<CustomTimeRange> reservedSlots = [];

  Future<bool> uploadReservationToDb() async {
    final id = const Uuid().v4();

    if (reservationEnd.isAtSameTimeAs(reservationStart)) {
      log("Start and end times whould not be equal!");
      toastification.show(
        title: Text("Start and end times whould not be equal!"),
        autoCloseDuration: const Duration(seconds: 10),
        type: ToastificationType.error,
      );

      return false;
    }

    DateTime startDate = widget.selectedDate.add(Duration(
      hours: mainPicker.reservationStart.hour, 
      minutes: mainPicker.reservationStart.minute
    ));
    DateTime endDate = widget.selectedDate.add(Duration(
      hours: mainPicker.reservationEnd.hour, 
      minutes: mainPicker.reservationEnd.minute
    ));

    CustomTimeRange currentSlot = CustomTimeRange(startTime: Timestamp.fromDate(startDate), endTime: Timestamp.fromDate(endDate));

    if (mainPicker.reservationStart.hour > mainPicker.reservationEnd.hour) {
      endDate = endDate.add(Duration(days: 1));
      log('Adding one day to end duration');
    }

    for (var occupiedSlot in reservedSlots) {
      if (!isTimeSlotAvailable(currentSlot, occupiedSlot)) return false;
    }

    int startSecondsSinceEpoch = (startDate.millisecondsSinceEpoch/1000).toInt();
    int endSecondsSinceEpoch = (endDate.millisecondsSinceEpoch/1000).toInt();

    Timestamp start = Timestamp(startSecondsSinceEpoch, 0);
    Timestamp end = Timestamp(endSecondsSinceEpoch, 0);

    try {
      await FirebaseFirestore.instance.collection("reservations").doc(id).set({
        "userID": FirebaseAuth.instance.currentUser!.uid,
        "creationDate": FieldValue.serverTimestamp(),
        "tableID": widget.tableId,
        "startDate": start,
        "endDate": end
      });

      log(id);

    } on FirebaseAuthException catch (e) {
      log(e.message!);
      toastification.show(title: Text(e.message!),
        autoCloseDuration: const Duration(seconds: 5),
      );

      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('d-MMM').format(widget.selectedDate)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [              
              const SizedBox(height: 10),

              StreamBuilder(
                stream: FirebaseFirestore.instance
                      .collection("reservations")
                      .where('startDate', isGreaterThanOrEqualTo: Timestamp.fromDate(widget.selectedDate))
                      .where('startDate', isLessThan: Timestamp.fromDate(widget.selectedDate.add(const Duration(days:1))))
                      .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  List<Widget> pickerList = [];
                  reservedSlots.clear();

                  if (snapshot.hasData && !snapshot.data!.docs.isEmpty) {
                    final filtered = snapshot.data!.docs
                      .where((doc) => doc.data()['tableID'] == widget.tableId)
                      .toList();
                    
                    filtered.forEach((data) {
                      DateTime start = DateTime.fromMillisecondsSinceEpoch(data['startDate'].millisecondsSinceEpoch);
                      DateTime end  = DateTime.fromMillisecondsSinceEpoch(data['endDate'].millisecondsSinceEpoch);

                      reservedSlots.add(CustomTimeRange(
                        startTime: data['startDate'], 
                        endTime: data['endDate'],
                      ));

                      pickerList.add(
                        DisabledTimeRange(
                          disabledTime: TimeRange(
                            startTime: TimeOfDay.fromDateTime(start),
                            endTime: TimeOfDay.fromDateTime(end),
                          )
                        )
                      );
                    });
                  }

                  pickerList.add(
                    mainPicker
                  );

                  return Stack(
                    alignment: AlignmentDirectional.topStart,
                    children: pickerList,
                  );
                }
              ),              

              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  await uploadReservationToDb();
                },
                child: Text(
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
}