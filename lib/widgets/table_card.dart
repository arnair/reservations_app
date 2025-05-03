import 'package:flutter/material.dart';

class TableCard extends StatelessWidget {
  final int length;
  final int width;
  final String tableName;
  const TableCard({
    super.key,
    required this.length,
    required this.width,
    required this.tableName,
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
        color: const Color.fromARGB(255, 228, 164, 92),
        borderRadius: const BorderRadius.all(
          Radius.circular(15),
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
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
                '${length}x${width}cm\n${length*2.54}x${width*2.54}in',
                style: const TextStyle(fontSize: 14),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}