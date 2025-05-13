import 'package:flutter/material.dart';
import 'package:reservations_app/database/add_new_reservation.dart';

class ReserveButton extends StatelessWidget {
  final String tableID;
  final DateTime selectedDate;

  const ReserveButton({
    super.key, 
    required this.tableID,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {

    return IconButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReserveTable(tableId: tableID, selectedDate: selectedDate,),
          ),
        );
      },
      icon: Icon(
        const IconData(0xe403, fontFamily: 'MaterialIcons'),
        color: Colors.grey.shade800
      ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({super.key, required this.icon, this.onPressed});
  final void Function()? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: Colors.grey.shade800
      ),
    );
  }
}
