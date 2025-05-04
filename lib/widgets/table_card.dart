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
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      padding: const EdgeInsets.symmetric(vertical: 20.0).copyWith(
        left: 15,
      ),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 245, 199, 146),
        borderRadius: const BorderRadius.all(
          Radius.circular(15),
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tableName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20, bottom: 25),
                    child: Text(
                      '${length} x ${width}cm\n${length*2.54} x ${width*2.54}in',
                      style: const TextStyle(fontSize: 14),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                  .collection("reservations")
                  .where('startDate', isGreaterThanOrEqualTo: Timestamp.fromDate(selectedDate))
                  .where('startDate', isLessThan: Timestamp.fromDate(selectedDate.add(const Duration(days:1))))
                  // .where('tableID', isEqualTo: tableID)
                  .snapshots(),

                builder:(context, snapshot)  {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Text('No reservations');
                  }
              
                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        if (snapshot.data!.docs[index].data()['tableID'] == tableID) {
                          return create_reservation_text(
                            snapshot.data!.docs[index].data()['startDate'], 
                            snapshot.data!.docs[index].data()['endDate']
                          );
                        } else {
                          return const SizedBox(width: 0);
                        }
                      }
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}