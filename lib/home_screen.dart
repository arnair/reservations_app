// Widgets
import 'package:reservations_app/widgets/date_selector.dart';
import 'package:reservations_app/widgets/table_card.dart';
import 'package:reservations_app/widgets/reserve_table_button.dart';

// Flutter
import 'package:flutter/material.dart';

// Firebase
import 'package:cloud_firestore/cloud_firestore.dart';

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
          // ReserveButton(),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            DateSelector(dateNotifier: selectedDateNotifier,),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("tables")
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
                      return ValueListenableBuilder<DateTime>(
                        valueListenable: selectedDateNotifier,
                        builder: (context, DateTime value, child) {
                          return Row(
                            children: [
                              Expanded(
                                child: TableCard(
                                  tableName: snapshot.data!.docs[index].data()['tableName'],
                                  length: snapshot.data!.docs[index].data()['length'],
                                  width: snapshot.data!.docs[index].data()['width'],
                                  selectedDate: DateTime(selectedDateNotifier.value.year, selectedDateNotifier.value.month,  selectedDateNotifier.value.day),
                                  tableID: snapshot.data!.docs[index].id,
                                ),
                              ),
                              ReserveButton(
                                tableID: snapshot.data!.docs[index].id, 
                                selectedDate: DateTime(selectedDateNotifier.value.year, selectedDateNotifier.value.month,  selectedDateNotifier.value.day)
                              ),
                            ],
                          );
                        }
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