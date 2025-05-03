import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ReservationTimes extends StatelessWidget {
  final DateTime currentDate;
  const ReservationTimes({
    super.key,
    required this.currentDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      padding: const EdgeInsets.symmetric(vertical: 20.0).copyWith(
        left: 15,
      ),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: const BorderRadius.all(
          Radius.circular(15),
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder(
              stream: FirebaseFirestore.instance
                .collection("reservations")
                .where('startDate', isGreaterThanOrEqualTo: currentDate)
                .where('startDate', isLessThan: currentDate.add(const Duration(days:1)))
                .snapshots(),
              
              builder:(context, snapshot)  {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (!snapshot.hasData) {
                  return const Text('Table is free!');
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    Text("${snapshot.data!.docs[index].data()['startDate']} - ${snapshot.data!.docs[index].data()['endDate']}");
                  }
                );
              },
            )
          ],
        ),
      ),
    );
  }
}