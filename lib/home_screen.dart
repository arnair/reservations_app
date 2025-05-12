import 'package:flutter/material.dart';

import 'package:reservations_app/reservations_screen.dart';

enum Page {makeReservationsPage, deleteReservationsPage, unknownPage}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<HomeScreen> {
  final selectedDateNotifier = ValueNotifier(DateTime.now());
  var selectedIndex = Page.makeReservationsPage;

  @override
  Widget build(BuildContext context) {
    Widget page;

    switch (selectedIndex) {
      case Page.makeReservationsPage:
        page = MakeReservationsScreen();
        break;
      case Page.deleteReservationsPage:
        page = Placeholder();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservations'),
        actions: [
          // ReserveButton(),
        ],
      ),
      body: Expanded(
        child: Container(
          child: page,
        ),
      ),
    );
  }
}