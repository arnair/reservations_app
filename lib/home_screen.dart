import 'package:flutter/material.dart';
import 'package:reservations_app/delete_reservations_screen.dart';

import 'package:reservations_app/make_reservations_screen.dart';
import 'package:reservations_app/widgets/reserve_table_buttons.dart';

enum Page {makeReservationsPage, deleteReservationsPage, unknownPage}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<HomeScreen> {
  final selectedDateNotifier = ValueNotifier(DateTime.now());
  var selectedIndex = Page.makeReservationsPage;
  var pageTitle;

  @override
  Widget build(BuildContext context) {
    Widget page;

    switch (selectedIndex) {
      case Page.makeReservationsPage:
        page = MakeReservationsScreen();
        pageTitle = 'New reservation';
        break;
      case Page.deleteReservationsPage:
        page = DeleteReservationsScreen();
        pageTitle = 'My reservations';
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
        actions: [
          CustomIconButton(
            icon: IconData(0xe403, 
            fontFamily: 'MaterialIcons'),
            onPressed:() => setState(() {
              selectedIndex = Page.makeReservationsPage;

            }),
          ),
          CustomIconButton(
            icon: IconData(0xeeaa, 
            fontFamily: 'MaterialIcons'),
            onPressed:() => setState(() {selectedIndex = Page.deleteReservationsPage;}),
          ),
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