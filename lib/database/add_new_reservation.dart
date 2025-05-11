import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:developer';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:toastification/toastification.dart';

class ReserveTable extends StatefulWidget {
  final String tableId;
  final DateTime selectedDate;

  const ReserveTable({
    super.key,
    required this.tableId, 
    required this.selectedDate,
  });

  @override
  State<ReserveTable> createState() => _ReserveTableState();
}

class _ReserveTableState extends State<ReserveTable> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  File? file;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> uploadReservationToDb() async {
    try {
      final id = const Uuid().v4();

      await FirebaseFirestore.instance.collection("reservations").doc(id).set({
        "title": titleController.text.trim(),
        "description": descriptionController.text.trim(),
        "userID": FirebaseAuth.instance.currentUser!.uid,
        "creationDate": FieldValue.serverTimestamp(),
      });

      log(id);

    } on FirebaseAuthException catch (e) {
      log(e.message!);
      toastification.show(title: Text(e.message!),
        autoCloseDuration: const Duration(seconds: 5),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reserve table'),
        actions: [
          GestureDetector(
            onTap: () async {
              final selDate = await showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(
                  const Duration(days: 90),
                ),
              );
              if (selDate != null) {
                setState(() {
                  // selectedDate = selDate;
                });
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                DateFormat('MM-d-y').format(widget.selectedDate),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [              
              const SizedBox(height: 10),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Title',
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Description',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  await uploadReservationToDb();
                },
                child: const Text(
                  'SUBMIT',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}