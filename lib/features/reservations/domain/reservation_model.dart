import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String id;
  final String userId;
  final String tableId;
  final Timestamp startDate;
  final Timestamp endDate;
  final Timestamp creationDate;

  const Reservation({
    required this.id,
    required this.userId,
    required this.tableId,
    required this.startDate,
    required this.endDate,
    required this.creationDate,
  });

  // Helper method to check if two time slots overlap
  static bool doTimeSlotsOverlap(Timestamp startTime1, Timestamp endTime1,
      Timestamp startTime2, Timestamp endTime2) {
    // Check if slot1 starts within slot2
    if ((startTime1.millisecondsSinceEpoch >
            startTime2.millisecondsSinceEpoch) &&
        (startTime1.millisecondsSinceEpoch < endTime2.millisecondsSinceEpoch)) {
      return true;
    }

    // Check if slot1 ends within slot2
    if ((endTime1.millisecondsSinceEpoch > startTime2.millisecondsSinceEpoch) &&
        (endTime1.millisecondsSinceEpoch < endTime2.millisecondsSinceEpoch)) {
      return true;
    }

    // Check if slot2 is completely within slot1
    if ((startTime1.millisecondsSinceEpoch <=
            startTime2.millisecondsSinceEpoch) &&
        (endTime1.millisecondsSinceEpoch >= endTime2.millisecondsSinceEpoch)) {
      return true;
    }

    return false;
  }
}
