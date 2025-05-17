import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

import '../data/reservation_repository.dart';
import '../domain/reservation_model.dart';

enum ReservationError {
  userNotAuthenticated,
  equalStartAndEndTimes,
  timeSlotNotAvailable,
  unknown
}

class ReservationResult {
  final bool success;
  final ReservationError? error;
  final String? message;

  ReservationResult({
    required this.success,
    this.error,
    this.message,
  });

  static ReservationResult successful() {
    return ReservationResult(success: true);
  }

  static ReservationResult failure(ReservationError error, [String? message]) {
    return ReservationResult(
      success: false,
      error: error,
      message: message,
    );
  }
}

class ReservationController {
  final ReservationRepository repository;

  ReservationController({ReservationRepository? repository})
      : repository = repository ?? ReservationRepository();

  /// Create a new reservation
  Future<ReservationResult> createReservation({
    required String tableId,
    required DateTime selectedDate,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) async {
    // Check if user is authenticated
    final userId = repository.getCurrentUserId();
    if (userId == null) {
      log("User not authenticated");
      return ReservationResult.failure(ReservationError.userNotAuthenticated,
          "Please login to make a reservation");
    }

    // Validate times
    if (startTime.hour == endTime.hour && startTime.minute == endTime.minute) {
      log("Start and end times should not be equal!");
      return ReservationResult.failure(ReservationError.equalStartAndEndTimes,
          "Start and end times should not be equal!");
    }

    // Create DateTime objects from TimeOfDay
    DateTime startDate =
        repository.timeOfDayToDateTime(selectedDate, startTime);
    DateTime endDate = repository.timeOfDayToDateTime(selectedDate, endTime);

    // Debug: Print DateTime objects
    log("DateTime objects created - Start: ${startDate.toString()}, End: ${endDate.toString()}");

    // If end time is earlier than start time, assume it's the next day
    if (endTime.hour < startTime.hour ||
        (endTime.hour == startTime.hour && endTime.minute < startTime.minute)) {
      endDate = endDate.add(const Duration(days: 1));
      log("End time adjusted to next day: ${endDate.toString()}");
    }

    // Convert to Timestamp
    final startTimestamp = Timestamp.fromDate(startDate);
    final endTimestamp = Timestamp.fromDate(endDate);

    // Debug: Print Timestamp objects
    log("Timestamps created - Start: ${startTimestamp.toDate().toString()}, End: ${endTimestamp.toDate().toString()}");

    // Check availability
    final isAvailable = await repository.isTimeSlotAvailable(
      tableId: tableId,
      startTime: startTimestamp,
      endTime: endTimestamp,
      date: selectedDate,
    );

    if (!isAvailable) {
      return ReservationResult.failure(ReservationError.timeSlotNotAvailable,
          "Selected time slot is not available");
    }

    // Create reservation
    final success = await repository.createReservation(
      tableId: tableId,
      userId: userId,
      startDate: startTimestamp,
      endDate: endTimestamp,
    );

    if (success) {
      return ReservationResult.successful();
    } else {
      return ReservationResult.failure(
          ReservationError.unknown, "Failed to create reservation");
    }
  }

  /// Get reservations for a table on a specific date (one-time fetch)
  Future<List<Reservation>> getTableReservations(
      String tableId, DateTime date) async {
    return repository.getTableReservations(tableId, date);
  }

  /// Get all reservations for a table on a specific date as stream
  Stream<List<Reservation>> watchTableReservations(
      String tableId, DateTime date) {
    return repository.watchTableReservations(tableId, date);
  }
}
