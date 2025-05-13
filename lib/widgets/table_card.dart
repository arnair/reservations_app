import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

Row createReservationText(Timestamp startTime, Timestamp endTime) {

  String formattedStart = DateFormat('kk:mm').format(DateTime.fromMillisecondsSinceEpoch(startTime.millisecondsSinceEpoch) );
  String dormattedEnd = DateFormat('kk:mm').format(DateTime.fromMillisecondsSinceEpoch(endTime.millisecondsSinceEpoch));
  return Row(
    children: [
      Icon(Icons.access_time, size: 16,),
      const SizedBox(width: 4),
      Text('$formattedStart - $dormattedEnd'),
    ],
  );
}

class TableCard extends StatelessWidget {
  final int length;
  final int width;
  final String tableName;
  final DateTime selectedDate;
  final String tableID;

  const TableCard({
    super.key,
    required this.length,
    required this.width,
    required this.tableName,
    required this.selectedDate,
    required this.tableID,
  });

  @override
  Widget build(BuildContext context) {
    final inchesLength = (length / 2.54).toStringAsFixed(0);
    final inchesWidth = (width / 2.54).toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tableName,
                style:  Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                
              ),
              const SizedBox(height: 12,),
              Row(
                children: [
                  const Icon(
                    Icons.table_restaurant,
                    size: 36,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 16),
                  Text("$length x $width cm\n$inchesLength x $inchesWidth in",),
                ],
              ),
            ],
          ),
          const SizedBox(width: 16,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Reserved slots", 
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                    ),),
              const SizedBox(height: 8),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                  .collection("reservations")
                  .where('startDate', isGreaterThanOrEqualTo: Timestamp.fromDate(selectedDate))
                  .where('startDate', isLessThan: Timestamp.fromDate(selectedDate.add(const Duration(days:1))))
                  .snapshots(),

                builder:(context, snapshot)  {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Text('No reserved slots', style: TextStyle(color: Colors.grey[500]));
                  }

                  final filtered = snapshot.data!.docs
                      .where((doc) => doc.data()['tableID'] == tableID)
                      .toList();

                  if (filtered.isEmpty) {
                    return Text('No reserved slots', style: TextStyle(color: Colors.grey[500]));
                  }
              
                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        return createReservationText(
                          filtered[index].data()['startDate'], 
                          filtered[index].data()['endDate']
                        );
                      }
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}