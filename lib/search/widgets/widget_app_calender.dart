import 'package:hb_booking_mobile_app/search/date/bloc_date.dart';
import 'package:hb_booking_mobile_app/search/date/event_date.dart';
import 'package:hb_booking_mobile_app/search/date/state_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hb_booking_mobile_app/utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../destination/bloc_destination.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
class AppCalendar extends StatelessWidget {
  final void Function(PickerDateRange) onConfirm;
  final DateTime? initialStartDate; // Add this parameter
  final DateTime? initialEndDate;   // Add this parameter

  AppCalendar({
    super.key,
    required this.onConfirm,
    this.initialStartDate,    // Add this
    this.initialEndDate,      // Add this
  });

  final List<DateTime> disabledDates = [];

  void addAllSundays(DateTime startDate, DateTime endDate) {
    DateTime currentDate = startDate;

    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      // Check if the current date is a Sunday
      if (currentDate.weekday == DateTime.sunday) {
        disabledDates.add(currentDate);
      }
      // Move to the next day
      currentDate = currentDate.add(const Duration(days: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime(startDate.year + 1, startDate.month, startDate.day); // Next 1 year

    addAllSundays(startDate, endDate);

    print(disabledDates);

    return BlocBuilder<DateBloc, DateState>(
      builder: (context, state) {
        // FIXED: Create initial range from provided dates
        PickerDateRange? initialSelectedRange;

        if (state is DateSelectionSuccess) {
          // Use the state if available
          initialSelectedRange = state.dateRange;
        } else if (initialStartDate != null) {
          // FIXED: Use the provided initial dates for highlighting
          initialSelectedRange = PickerDateRange(
            initialStartDate,
            initialEndDate ?? initialStartDate,
          );

          print('AppCalendar: Using initial dates for highlighting');
          print('Initial start: $initialStartDate');
          print('Initial end: ${initialEndDate ?? initialStartDate}');
        }

        return Padding(
          padding: const EdgeInsets.only(top: 4.0, left: 16, right: 16, bottom: 2),
          child: SfDateRangePicker(
            minDate: DateTime.now(),
            todayHighlightColor: primary_color,
            startRangeSelectionColor: primary_color,
            endRangeSelectionColor: primary_color,
            rangeSelectionColor: Colors.orangeAccent,

            selectableDayPredicate: (date) {
              return !disabledDates.contains(date);
            },

            onSelectionChanged: (args) {
              if (args.value is PickerDateRange) {
                final selectedDateRange = args.value as PickerDateRange;
                BlocProvider.of<DateBloc>(context)
                    .add(DateSelected(selectedDateRange));
                onConfirm(selectedDateRange);
                print("Selected Date Range: ${selectedDateRange.startDate} to ${selectedDateRange.endDate}");
              }
            },

            selectionMode: DateRangePickerSelectionMode.range,

            // FIXED: Use the calculated initial range
            initialSelectedRange: initialSelectedRange,

            // FIXED: Add initial display date to focus on the selected month
            initialDisplayDate: initialStartDate ?? DateTime.now(),
          ),
        );
      },
    );
  }
}
/*class AppCalendar extends StatelessWidget {
  final void Function(PickerDateRange) onConfirm;

  AppCalendar({super.key, required this.onConfirm});
  final List<DateTime> disabledDates = [];

  void addAllSundays(DateTime startDate, DateTime endDate) {
    DateTime currentDate = startDate;

    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      // Check if the current date is a Sunday
      if (currentDate.weekday == DateTime.sunday) {
        disabledDates.add(currentDate);
      }
      // Move to the next day
      currentDate = currentDate.add(const Duration(days: 1));
    }
  }
  @override
  Widget build(BuildContext context) {


    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime(startDate.year + 1, startDate.month, startDate.day); // Next 1 year

    addAllSundays(startDate, endDate);

    print(disabledDates);

    return BlocBuilder<DateBloc, DateState>(
      builder: (context, state) {
        return Padding(
          padding:
              const EdgeInsets.only(top: 4.0, left: 16, right: 16, bottom: 2),
          child: SfDateRangePicker(
            minDate: DateTime.now(),
            todayHighlightColor: primary_color,
            startRangeSelectionColor: primary_color,
            endRangeSelectionColor: primary_color,
            rangeSelectionColor: Colors.orangeAccent,

            selectableDayPredicate: (date) {
              return !disabledDates.contains(date);
            },
            onSelectionChanged: (args) {
              if (args.value is PickerDateRange) {
                final selectedDateRange = args.value as PickerDateRange;
                BlocProvider.of<DateBloc>(context)
                    .add(DateSelected(selectedDateRange));
                onConfirm(selectedDateRange);
                print(
                    "Selected Date Range: ${selectedDateRange.startDate} to ${selectedDateRange.endDate}");
              }
            },
            selectionMode: DateRangePickerSelectionMode.range,
            initialSelectedRange:
                state is DateSelectionSuccess ? state.dateRange : null,
          ),
        );
      },
    );
  }
}*/

/*class AppCalendar extends StatelessWidget {
  final void Function(PickerDateRange, DateTime, DateTime) onConfirm;

   AppCalendar({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DateBloc, DateState>(
      builder: (context, state) {
        PickerDateRange? selectedDateRange;
        String? selectedStartTime;
        String? selectedEndTime;

        if (state is DateSelectionSuccess) {
          selectedDateRange = state.dateRange;
          selectedStartTime = DateFormat('hh:mm a').format(state.startTime);
          selectedEndTime = DateFormat('hh:mm a').format(state.endTime);
          onConfirm(state.dateRange, state.startTime, state.endTime);
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SfDateRangePicker(
                minDate: DateTime.now(),
                onSelectionChanged: (args) {
                  selectedDateRange = args.value;
                  _updateSelection(context, selectedDateRange, selectedStartTime, selectedEndTime);
                },
                selectionMode: DateRangePickerSelectionMode.range,
                initialSelectedRange: PickerDateRange(
                  DateTime.now().subtract(const Duration(days: 5)),
                  DateTime.now().add(const Duration(days: 5)),
                ),
              ),
              const SizedBox(height: 16.0),
              if (selectedDateRange != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        hint: const Text('Start Time'),
                        value: selectedStartTime,
                        onChanged: (newValue) {
                          selectedStartTime = newValue;
                          _updateSelection(context, selectedDateRange, selectedStartTime, selectedEndTime);
                        },
                        items: _timeSlots.map<DropdownMenuItem<String>>((value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: DropdownButton<String>(
                        hint: const Text('End Time'),
                        value: selectedEndTime,
                        onChanged: (newValue) {
                          selectedEndTime = newValue;
                          _updateSelection(context, selectedDateRange, selectedStartTime, selectedEndTime);
                        },
                        items: _timeSlots.map<DropdownMenuItem<String>>((value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _updateSelection(BuildContext context, PickerDateRange? dateRange, String? startTime, String? endTime) {
    if (dateRange != null && startTime != null && endTime != null) {
      BlocProvider.of<DateBloc>(context).add(DateSelected(dateRange, startTime, endTime));
    }
  }

  final List<String> _timeSlots = [
    '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM',
    '11:00 AM', '11:30 AM', '12:00 PM', '12:30 PM',
    '01:00 PM', '01:30 PM', '02:00 PM', '02:30 PM',
    '03:00 PM', '03:30 PM', '04:00 PM', '04:30 PM',
    '05:00 PM', '05:30 PM', '06:00 PM', '06:30 PM',
    '07:00 PM',
  ];
}*/
