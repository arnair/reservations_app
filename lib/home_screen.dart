// Widgets
import 'package:reservations_app/widgets/date_selector.dart';
import 'package:reservations_app/widgets/table_card.dart';
import 'package:reservations_app/widgets/reservation_times.dart';

// Database
import 'package:reservations_app/database/add_new_reservation.dart';

// Flutter
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<HomeScreen> {
  final selectedDateNotifier = ValueNotifier(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservations'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReserveTable(),
                ),
              );
            },
            icon: const Icon(
              CupertinoIcons.add,
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            DateSelector(dateNotifier: selectedDateNotifier,),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("tables")
                  /*.where('startDate',
                      isGreaterThanOrEqualTo: selectedDate.value)
                  .where('startDate',
                      isLessThan: selectedDate.value.add(const Duration(days:1)))*/
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
                      return Row(
                        children: [
                          Expanded(
                            child: TableCard(
                              tableName: snapshot.data!.docs[index].data()['tableName'],
                              length: snapshot.data!.docs[index].data()['length'],
                              width: snapshot.data!.docs[index].data()['width'],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: ReservationTimes(currentDate: selectedDateNotifier.value)
                          )
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}