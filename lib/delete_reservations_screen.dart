import 'package:flutter/material.dart';
import 'dart:developer';

// Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Widgets
import 'package:reservations_app/widgets/reserve_table_buttons.dart';

import 'package:toastification/toastification.dart';

// app
import 'package:reservations_app/widgets/reservation_card.dart';

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

              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  String tableName = 'Test';

                  Timestamp startTime = snapshot.data!.docs[index].data()['startDate'];
                  Timestamp endtTime = snapshot.data!.docs[index].data()['endDate'];
                  DateTime selectedDate = DateTime.fromMillisecondsSinceEpoch(startTime.millisecondsSinceEpoch);

                  return Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: ReservationCard(
                          tableID: snapshot.data!.docs[index].data()['tableID'],
                          selectedDate: selectedDate,
                          reservationStart: startTime,
                          reservationEnd: endtTime,
                          tableName: tableName,
                        ),
                      ),
                      CustomIconButton(
                        icon: const IconData(0xeeaa, fontFamily: 'MaterialIcons'),
                        onPressed: () {
                          try {
                            FirebaseFirestore.instance
                            .collection("reservations")
                            .doc(snapshot.data!.docs[index].id)
                            .delete()
                            .then((_) {
                              log("Reservation deleted");
                              toastification.show(title: Text("Reservation deleted"),
                                autoCloseDuration: const Duration(seconds: 5),
                              );
                            });
                          } on FirebaseException catch (e) {
                            log(e.message!);
                            toastification.show(title: Text(e.message!),
                              autoCloseDuration: const Duration(seconds: 5),
                              type: ToastificationType.error
                            );
                          }
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}