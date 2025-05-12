import 'package:flutter/material.dart';

// Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Widgets
import 'package:reservations_app/widgets/date_selector.dart';
import 'package:reservations_app/widgets/table_card.dart';
import 'package:reservations_app/widgets/reserve_table_buttons.dart';

// app
import 'package:reservations_app/widgets/reservation_card.dart';
import 'package:time_range_picker/time_range_picker.dart';

class DeleteReservationsScreen extends StatefulWidget {
  const DeleteReservationsScreen({super.key});

  @override
  State<DeleteReservationsScreen> createState() => _DeleteReservationsScreenState();
}

class _DeleteReservationsScreenState extends State<DeleteReservationsScreen> {
  final selectedDateNotifier = ValueNotifier(DateTime.now());

    @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("reservations")
                .where('userID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (!snapshot.hasData) {
                return const Text('No data here :(');
              }

              return Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return ValueListenableBuilder<DateTime>(
                      valueListenable: selectedDateNotifier,
                      builder: (context, DateTime value, child) {
                        String tableName = 'Test';

                        Timestamp startTime = snapshot.data!.docs[index].data()['startDate'];
                        Timestamp endtTime = snapshot.data!.docs[index].data()['endDate'];
                        DateTime selectedDate = DateTime.fromMillisecondsSinceEpoch(startTime.millisecondsSinceEpoch);

                        return ReservationCard(
                          tableID: snapshot.data!.docs[index].data()['tableID'],
                          selectedDate: selectedDate,
                          reservationStart: startTime,
                          reservationEnd: endtTime,
                          tableName: tableName,
                        );
                      }
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}