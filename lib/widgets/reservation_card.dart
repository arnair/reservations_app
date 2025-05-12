import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

Text createReservationText(Timestamp startTime, Timestamp endTime) {

  String formattedStart = DateFormat('kk:mm').format(DateTime.fromMillisecondsSinceEpoch(startTime.millisecondsSinceEpoch) );
  String dormattedEnd = DateFormat('kk:mm').format(DateTime.fromMillisecondsSinceEpoch(endTime.millisecondsSinceEpoch));
  return Text('$formattedStart - $dormattedEnd');
}

class ReservationCard extends StatelessWidget {
  final String tableName;
  final DateTime selectedDate;
  final Timestamp reservationStart;
  final Timestamp reservationEnd;
  final String tableID;

  const ReservationCard({
    super.key,
    required this.reservationStart,
    required this.reservationEnd,
    required this.tableName,
    required this.selectedDate,
    required this.tableID,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade800, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("tables")
                        .doc(tableID)
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

                      return Text(
                        snapshot.data!['tableName'],
                        style:  Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                        
                      );
                    },
                  ),
                  const SizedBox(height: 12,),
                  Text(DateFormat('d-MMM').format(selectedDate),),
                ],
              ),
            ),
            const SizedBox(width: 16,),
            Expanded(
              flex: 1,
              child: createReservationText(reservationStart, reservationEnd)
            ),
          ],
        ),
      ),
    );
  }
}