import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSelector extends StatefulWidget {
  final ValueNotifier dateNotifier;

  const DateSelector({required this.dateNotifier, super.key});

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

DateTime getTodayAt0000() {
  DateTime? now = DateTime.now(); //lets say Jul 25 10:35:90
  final today = DateTime(now.year, now.month,  now.day); // Set to Jul 25 00:00:00
  return today;
}

class _DateSelectorState extends State<DateSelector> {
  int weekOffset = 0;

  _DateSelectorState();

  List<DateTime> generateWeekDates(int weekOffset) {
    DateTime today = getTodayAt0000();
    DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    startOfWeek = startOfWeek.add(Duration(days: weekOffset * 7));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> weekDates = generateWeekDates(weekOffset);
    String monthName = DateFormat('MMMM').format(weekDates.first);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(
            bottom: 10.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: weekOffset <= 0 ? null : () => setState(() {weekOffset--;}),

              ),
              Text(
                monthName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () {
                  setState(() {
                    weekOffset++;
                  });
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: weekDates.length,
              itemBuilder: (context, index) {
                DateTime date = weekDates[index];
                bool isSelected = DateFormat('d').format(widget.dateNotifier.value) ==
                        DateFormat('d').format(date) &&
                    widget.dateNotifier.value.month == date.month &&
                    widget.dateNotifier.value.year == date.year;

                bool earlierThanToday = date.isBefore(getTodayAt0000());
                Color textColor = Colors.black87;

                if (earlierThanToday) {
                  textColor = Colors.grey.shade300;
                } else if (isSelected) {
                  textColor = Colors.white;
                }

                return GestureDetector(
                  onTap: earlierThanToday ? null : () => setState(() {widget.dateNotifier.value = date;}),
                  child: Container(
                    width: 70,
                    margin:
                        const EdgeInsets.only(right: 8), // Space between items
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.deepOrangeAccent
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? Colors.deepOrangeAccent
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('d').format(date), // Day of the month
                          style: TextStyle(
                            color: textColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          DateFormat('E')
                              .format(date), // Short weekday (Mon, Tue, etc.)
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}