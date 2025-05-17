import 'package:flutter/material.dart';
import 'package:reservations_app/features/reservations/presentation/delete_reservations_screen.dart';
import 'package:reservations_app/features/reservations/presentation/make_reservations_screen.dart';
import 'package:reservations_app/widgets/reserve_table_buttons.dart';
import 'package:reservations_app/features/authentication/presentation/auth_controller.dart';

enum Page { makeReservationsPage, deleteReservationsPage, unknownPage }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<HomeScreen> {
  final _authController = AuthController();
  final selectedDateNotifier = ValueNotifier(DateTime.now());
  var selectedIndex = Page.makeReservationsPage;
  var pageTitle = 'ERROR';

  @override
  Widget build(BuildContext context) {
    Widget page;

    switch (selectedIndex) {
      case Page.makeReservationsPage:
        page = const MakeReservationsScreen();
        pageTitle = 'New reservation';
        break;
      case Page.deleteReservationsPage:
        page = const DeleteReservationsScreen();
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
            icon: const IconData(0xe403, fontFamily: 'MaterialIcons'),
            onPressed: () => setState(() {
              selectedIndex = Page.makeReservationsPage;
            }),
          ),
          CustomIconButton(
            icon: const IconData(0xeeaa, fontFamily: 'MaterialIcons'),
            onPressed: () => setState(() {
              selectedIndex = Page.deleteReservationsPage;
            }),
          ),
          CustomIconButton(
            icon: const IconData(0xf199, fontFamily: 'MaterialIcons'),
            onPressed: () => _authController.signOutUser(context),
          ),
        ],
      ),
      body: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: page,
      ),
    );
  }
}
