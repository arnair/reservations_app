import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:developer';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:toastification/toastification.dart';
import 'package:time_range_picker/time_range_picker.dart';

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
  var reservationStart = TimeOfDay(hour: 2, minute: 0);
  var reservationEnd = TimeOfDay(hour: 3, minute: 0);

  Future<void> uploadReservationToDb() async {
    try {
      final id = const Uuid().v4();

      DateTime startDate = widget.selectedDate.add(Duration(hours: reservationStart.hour, minutes: reservationStart.minute));
      DateTime endDate = widget.selectedDate.add(Duration(hours: reservationEnd.hour, minutes: reservationEnd.minute));

      int startSecondsSinceEpoch = (startDate.millisecondsSinceEpoch/1000).toInt();
      int endSecondsSinceEpoch = (endDate.millisecondsSinceEpoch/1000).toInt();

      Timestamp start = Timestamp(startSecondsSinceEpoch, 0);
      Timestamp end = Timestamp(endSecondsSinceEpoch, 0);

      print('Reserving from ${start} to ${end}');

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
    }
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

                  List<TimeRangePicker> pickerList = [];

                  if (snapshot.hasData && !snapshot.data!.docs.isEmpty) {
                    final filtered = snapshot.data!.docs
                      .where((doc) => doc.data()['tableID'] == widget.tableId)
                      .toList();
                    
                    filtered.forEach((data) {
                      pickerList.add(
                        DisabledTimeRange(
                          disabledTime: TimeRange(
                              startTime: TimeOfDay.fromDateTime(
                                DateTime.fromMillisecondsSinceEpoch(data['startDate'].millisecondsSinceEpoch)
                              ),
                              endTime: TimeOfDay.fromDateTime(
                                DateTime.fromMillisecondsSinceEpoch(data['endDate'].millisecondsSinceEpoch)
                              ),
                            )
                        )
                      );
                    });
                  }

                  pickerList.add(
                    TimeRangePicker(
                      interval: const Duration(minutes: 15),
                      hideButtons: true,
                      // onStartChange: (start) => setState(() {reservationStart = start;}),
                      // onEndChange: (end) => setState(() {reservationEnd = end;}),
                      start: TimeOfDay(hour: 2, minute: 0),
                      end: TimeOfDay(hour: 3, minute: 0),
                    ),
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