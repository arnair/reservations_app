import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

Text create_reservation_text(Timestamp startTime, Timestamp endTime) {

  String formatted_start = DateFormat('kk:mm').format(DateTime.fromMillisecondsSinceEpoch(startTime.millisecondsSinceEpoch) );
  String formatted_end = DateFormat('kk:mm').format(DateTime.fromMillisecondsSinceEpoch(endTime.millisecondsSinceEpoch));
  return Text('${formatted_start} - ${formatted_end}');
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

    return Card(
      color: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1.5),
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
                  Text(
                    tableName,
                    style:  Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                    
                  ),
                  const SizedBox(height: 12,),
                  Text("$length x $width cm\n$inchesLength x $inchesWidth in",),
                ],
              ),
            ),
            const SizedBox(width: 16,),
            Expanded(
              flex: 1,
              child: Column(
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
                            return create_reservation_text(
                              filtered[index].data()['startDate'], 
                              filtered[index].data()['endDate']
                            );
                          }
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}