import 'package:flutter/material.dart';
import 'package:reservations_app/database/add_new_reservation.dart';
import 'package:flutter/cupertino.dart';

class ReserveButton extends StatelessWidget {
  final String tableID;

  const ReserveButton({
    super.key, 
    required this.tableID
  });

  @override
  Widget build(BuildContext context) {

    return IconButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ReserveTable(),
          ),
        );
      },
      icon: Icon(
        IconData(0xe403, fontFamily: 'MaterialIcons'),
        color: Colors.grey.shade800
      ),
    );
  }
}