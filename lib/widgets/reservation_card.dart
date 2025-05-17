import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

Text createReservationText(Timestamp startTime, Timestamp endTime) {
  String formattedStart = DateFormat('kk:mm').format(
      DateTime.fromMillisecondsSinceEpoch(startTime.millisecondsSinceEpoch));
  String dormattedEnd = DateFormat('kk:mm').format(
      DateTime.fromMillisecondsSinceEpoch(endTime.millisecondsSinceEpoch));
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
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.table_restaurant,
            size: 36,
            color: Colors.grey,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("tables")
                    .doc(tableID)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2));
                  }
                  if (!snapshot.hasData) {
                    return const Text(
                      'Unknown Table',
                      style: TextStyle(color: Colors.redAccent),
                    );
                  }
                  return Text(
                    snapshot.data!['tableName'],
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.1,
                        ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('d MMM').format(selectedDate),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.access_time,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  createReservationText(reservationStart, reservationEnd),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
