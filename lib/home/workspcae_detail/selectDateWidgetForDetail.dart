import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import 'package:hb_booking_mobile_app/search/state_search.dart';

import 'package:hb_booking_mobile_app/utils/colors.dart';

import '../../search/date/bloc_date.dart';
import '../../search/date/event_date.dart';
import '../../search/date/state_date.dart';

// Import this file as: import '../../search/widgets/widget_select_date_detail.dart';

class SelectDateWidgetForDetail extends StatefulWidget {
  final BookingStep step;
  final void Function(String startDate, String? endDate) onDateConfirm;
  final void Function(String startTime, String endTime)? onTimeConfirm;
  final VoidCallback? onTimeDisabled;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final String? initialStartTime;
  final String? initialEndTime;
  final bool showConfirmButton;
  final bool enableTimeSelection;

  const SelectDateWidgetForDetail({
    Key? key,
    required this.step,
    required this.onDateConfirm,
    this.onTimeConfirm,
    this.onTimeDisabled,
    this.initialStartDate,
    this.initialEndDate,
    this.initialStartTime,
    this.initialEndTime,
    this.showConfirmButton = false,
    this.enableTimeSelection = false,
  }) : super(key: key);

  @override
  _SelectDateWidgetForDetailState createState() => _SelectDateWidgetForDetailState();
}

class _SelectDateWidgetForDetailState extends State<SelectDateWidgetForDetail> {
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  int startHour = 9;
  int startMinute = 0;
  int endHour = 18;
  int endMinute = 0;
  bool isDateRangeSelected = false;
  bool isTimeSelected = false;
  bool enableTimeSelection = false;

  @override
  void initState() {
    super.initState();

    // Initialize time selection toggle based on widget parameter OR if initial time is provided
    enableTimeSelection = widget.enableTimeSelection ||
        (widget.initialStartTime != null && widget.initialStartTime!.isNotEmpty);

    // Initialize with provided dates if available
    if (widget.initialStartDate != null) {
      selectedStartDate = widget.initialStartDate;
      selectedEndDate = widget.initialEndDate ?? widget.initialStartDate;
      isDateRangeSelected = true;

      print('SelectDateWidgetForDetail initialized with dates:');
      print('Start: $selectedStartDate');
      print('End: $selectedEndDate');
      print('Date range selected: $isDateRangeSelected');
    }

    // Initialize time from provided string if available
    if (widget.initialStartTime != null && widget.initialStartTime!.isNotEmpty) {
      final timeParts = widget.initialStartTime!.split(':');
      if (timeParts.length >= 2) {
        startHour = int.parse(timeParts[0]);
        startMinute = int.parse(timeParts[1]);
        isTimeSelected = true;
        enableTimeSelection = true;
      }
    }

    if (widget.initialEndTime != null && widget.initialEndTime!.isNotEmpty) {
      final timeParts = widget.initialEndTime!.split(':');
      if (timeParts.length >= 2) {
        endHour = int.parse(timeParts[0]);
        endMinute = int.parse(timeParts[1]);
        isTimeSelected = true;
      }
    }

    // If no initial times but enableTimeSelection is true, set defaults
    if (enableTimeSelection && !isTimeSelected) {
      startHour = 9;
      startMinute = 0;
      endHour = 18;
      endMinute = 0;
      isTimeSelected = true;
    }

    print('SelectDateWidgetForDetail initialized with:');
    print('Start date: $selectedStartDate, time: ${isTimeSelected ? "$startHour:$startMinute" : "not selected"}');
    print('End date: $selectedEndDate, time: ${isTimeSelected ? "$endHour:$endMinute" : "not selected"}');
    print('Time selection enabled: $enableTimeSelection');
    print('Date range selected: $isDateRangeSelected');
  }

  @override
  void didUpdateWidget(SelectDateWidgetForDetail oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update dates when widget parameters change
    if (oldWidget.initialStartDate != widget.initialStartDate ||
        oldWidget.initialEndDate != widget.initialEndDate) {
      setState(() {
        if (widget.initialStartDate != null) {
          selectedStartDate = widget.initialStartDate;
          selectedEndDate = widget.initialEndDate ?? widget.initialStartDate;
          isDateRangeSelected = true;

          print('Updated dates from widget:');
          print('Start: $selectedStartDate');
          print('End: $selectedEndDate');
        }
      });
    }

    // Update enableTimeSelection when widget parameter changes
    if (oldWidget.enableTimeSelection != widget.enableTimeSelection) {
      print('SelectDateWidgetForDetail: enableTimeSelection changed from ${oldWidget.enableTimeSelection} to ${widget.enableTimeSelection}');
      setState(() {
        enableTimeSelection = widget.enableTimeSelection;

        if (enableTimeSelection && !isTimeSelected) {
          // Enable time selection with defaults
          startHour = 9;
          startMinute = 0;
          endHour = 18;
          endMinute = 0;
          isTimeSelected = true;

          // Call onTimeConfirm with default values
          if (widget.onTimeConfirm != null) {
            String startTime = '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}:00';
            String endTime = '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}:00';
            widget.onTimeConfirm!(startTime, endTime);
          }
        } else if (!enableTimeSelection) {
          // Disable time selection
          isTimeSelected = false;
          if (widget.onTimeDisabled != null) {
            widget.onTimeDisabled!();
          }
        }
      });
    }

    // Update time values if they changed
    if (oldWidget.initialStartTime != widget.initialStartTime ||
        oldWidget.initialEndTime != widget.initialEndTime) {
      if (widget.initialStartTime != null && widget.initialStartTime!.isNotEmpty) {
        final timeParts = widget.initialStartTime!.split(':');
        if (timeParts.length >= 2) {
          setState(() {
            startHour = int.parse(timeParts[0]);
            startMinute = int.parse(timeParts[1]);
            isTimeSelected = true;
          });
        }
      }

      if (widget.initialEndTime != null && widget.initialEndTime!.isNotEmpty) {
        final timeParts = widget.initialEndTime!.split(':');
        if (timeParts.length >= 2) {
          setState(() {
            endHour = int.parse(timeParts[0]);
            endMinute = int.parse(timeParts[1]);
          });
        }
      }
    }
  }

  void _updateTimeSelection(int newStartHour, int newStartMinute, int newEndHour, int newEndMinute) {
    setState(() {
      startHour = newStartHour;
      startMinute = newStartMinute;
      endHour = newEndHour;
      endMinute = newEndMinute;
      isTimeSelected = true;
    });

    print('Time selection updated to:');
    print('Start time: $startHour:$startMinute');
    print('End time: $endHour:$endMinute');

    // Always call time confirmation if callback is provided and time selection is enabled
    if (enableTimeSelection && widget.onTimeConfirm != null) {
      String startTime = '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}:00';
      String endTime = '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}:00';
      print('Calling onTimeConfirm with: $startTime, $endTime');
      widget.onTimeConfirm!(startTime, endTime);
    }

    // Auto-confirm if not showing a confirm button and date is selected
    if (!widget.showConfirmButton && isDateRangeSelected) {
      _confirmDateSelection();
    }
  }

  void _updateDateSelection(dynamic dateRangeData) {
    DateTime? startDate;
    DateTime? endDate;

    if (dateRangeData is Map<String, dynamic>) {
      startDate = dateRangeData['startDate'];
      endDate = dateRangeData['endDate'] ?? dateRangeData['startDate'];
    } else if (dateRangeData.startDate != null) {
      startDate = dateRangeData.startDate;
      endDate = dateRangeData.endDate ?? dateRangeData.startDate;
    }

    if (startDate != null) {
      setState(() {
        selectedStartDate = startDate;
        selectedEndDate = endDate ?? startDate;
        isDateRangeSelected = true;
      });

      print('Date selection updated to:');
      print('Start date: $selectedStartDate');
      print('End date: $selectedEndDate');

      // Auto-confirm if not showing a confirm button
      if (!widget.showConfirmButton) {
        _confirmDateSelection();
      }
    }
  }

  void _confirmDateSelection() {
    if (selectedStartDate == null || selectedEndDate == null) {
      print('Cannot confirm - dates not selected');
      return;
    }

    // Format dates as YYYY-MM-DD
    String startDate = '${selectedStartDate!.year}-${selectedStartDate!.month.toString().padLeft(2, '0')}-${selectedStartDate!.day.toString().padLeft(2, '0')}';
    String? endDate = selectedEndDate != selectedStartDate
        ? '${selectedEndDate!.year}-${selectedEndDate!.month.toString().padLeft(2, '0')}-${selectedEndDate!.day.toString().padLeft(2, '0')}'
        : null;

    print('Date confirmation triggered with:');
    print('Start date: $startDate');
    print('End date: $endDate');
    print('Enable time selection: $enableTimeSelection');
    print('Is time selected: $isTimeSelected');

    widget.onDateConfirm(startDate, endDate);

    // FIXED: Always confirm time state, even if disabled
    if (widget.onTimeConfirm != null) {
      if (enableTimeSelection && isTimeSelected) {
        String startTime = '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}:00';
        String endTime = '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}:00';
        print('Confirming time selection: $startTime to $endTime');
        widget.onTimeConfirm!(startTime, endTime);
      } else {
        // FIXED: When time is disabled, pass default times to indicate no specific time
        print('Time selection disabled - passing default midnight times');
        widget.onTimeConfirm!('00:00:00', '00:00:00');
      }
    }

    // FIXED: Also call onTimeDisabled when time selection is disabled
    if (!enableTimeSelection && widget.onTimeDisabled != null) {
      print('Calling onTimeDisabled callback');
      widget.onTimeDisabled!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocProvider(
      create: (_) => DateBloc(),
      child: BlocBuilder<DateBloc, DateState>(
        builder: (context, state) {
          String displayText = '';

          // Don't override existing selection if we already have dates
          if (state is DateSelectionSuccess && !isDateRangeSelected) {
            final DateFormat formatter = DateFormat('MM/dd/yyyy');
            final startDate = formatter.format(state.dateRange.startDate!);
            final endDate = formatter.format(state.dateRange.endDate ?? state.dateRange.startDate!);
            displayText = '$startDate to $endDate';

            // Update selected dates from state when calendar changes
            setState(() {
              selectedStartDate = state.dateRange.startDate;
              selectedEndDate = state.dateRange.endDate ?? state.dateRange.startDate;
              isDateRangeSelected = true;
            });

            // Auto-confirm if not showing a confirm button
            if (!widget.showConfirmButton) {
              _confirmDateSelection();
            }
          } else if (isDateRangeSelected && selectedStartDate != null && selectedEndDate != null) {
            // Show current selection if we have dates
            final DateFormat formatter = DateFormat('MM/dd/yyyy');
            final startDate = formatter.format(selectedStartDate!);
            final endDate = formatter.format(selectedEndDate!);
            displayText = '$startDate to $endDate';
          }

          return Card(
            elevation: 0.0,
            clipBehavior: Clip.antiAlias,
            child: AnimatedContainer(
              height: widget.step == BookingStep.selectDate
                  ? size.height * 0.6
                  : 60,
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: size.height * 0.02,
                horizontal: size.width * 0.05,
              ),
              duration: const Duration(milliseconds: 300),
              child: widget.step == BookingStep.selectDate
                  ? SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [


                    // Time selection toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select specific time?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Switch(
                          activeColor: primary_color,
                          value: enableTimeSelection,
                          onChanged: (value) {
                            setState(() {
                              enableTimeSelection = value;
                              if (!value) {
                                // Clear time selection when disabled
                                isTimeSelected = false;
                                startHour = 9;
                                startMinute = 0;
                                endHour = 18;
                                endMinute = 0;
                                print('Time selection disabled - clearing time data');

                                if (widget.onTimeDisabled != null) {
                                  widget.onTimeDisabled!();
                                }
                              } else {
                                // Set default times when enabled
                                startHour = 9;
                                startMinute = 0;
                                endHour = 18;
                                endMinute = 0;
                                isTimeSelected = true;
                                print('Time selection enabled with default times: 9:00 to 18:00');

                                if (widget.onTimeConfirm != null) {
                                  String startTime = '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}:00';
                                  String endTime = '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}:00';
                                  print('Calling onTimeConfirm with default values: $startTime, $endTime');
                                  widget.onTimeConfirm!(startTime, endTime);
                                }
                              }
                            });

                            // Only auto-confirm if dates are actually selected
                            if (isDateRangeSelected && selectedStartDate != null && selectedEndDate != null) {
                              _confirmDateSelection();
                            }
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: size.height * 0.02),

                    // Pass initial dates to AppCalendar for highlighting
                    AppCalendarForDetail(
                      initialStartDate: selectedStartDate,
                      initialEndDate: selectedEndDate,
                      onConfirm: (dateRange) {
                        _updateDateSelection(dateRange);
                      },
                    ),

                    // Only show time picker if enabled
                    if (enableTimeSelection) ...[
                      SizedBox(height: size.height * 0.01),
                      TimePickerSectionForDetail(
                        initialStartHour: startHour,
                        initialEndHour: endHour,
                        onTimeSelected: _updateTimeSelection,
                      ),
                    ],

                    if (widget.showConfirmButton) ...[
                      SizedBox(height: size.height * 0.02),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isDateRangeSelected ? _confirmDateSelection : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Confirm Selection',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'When',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Flexible(
                    child: Text(
                      displayText,
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TimePickerSectionForDetail extends StatefulWidget {
  final void Function(int startHour, int startMinute, int endHour, int endMinute) onTimeSelected;
  final int initialStartHour;
  final int initialEndHour;

  const TimePickerSectionForDetail({
    Key? key,
    required this.onTimeSelected,
    this.initialStartHour = 9,
    this.initialEndHour = 18,
  }) : super(key: key);

  @override
  _TimePickerSectionForDetailState createState() => _TimePickerSectionForDetailState();
}

class _TimePickerSectionForDetailState extends State<TimePickerSectionForDetail> {
  late int _startHour;
  late int _endHour;

  @override
  void initState() {
    super.initState();

    // Ensure initial hours are within the valid range (9 AM to 6 PM)
    _startHour = widget.initialStartHour.clamp(9, 17);
    _endHour = widget.initialEndHour.clamp(_startHour + 1, 18);

    print('TimePickerSectionForDetail initialized with start hour: $_startHour, end hour: $_endHour');
  }

  @override
  void didUpdateWidget(TimePickerSectionForDetail oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update hours if initial values changed, ensuring they're within valid range
    if (oldWidget.initialStartHour != widget.initialStartHour) {
      _startHour = widget.initialStartHour.clamp(9, 17);
    }
    if (oldWidget.initialEndHour != widget.initialEndHour) {
      _endHour = widget.initialEndHour.clamp(_startHour + 1, 18);
    }
  }

  List<DropdownMenuItem<int>> _getHourItems() {
    // Only allow hours from 9 AM (9) to 6 PM (18)
    return List.generate(10, (index) {
      int hour = index + 9; // Start from 9 AM
      String hourText = hour.toString().padLeft(2, '0');
      String displayText = hour <= 12 ? '$hourText:00 AM' : '${(hour - 12).toString().padLeft(2, '0')}:00 PM';
      if (hour == 12) displayText = '12:00 PM';

      return DropdownMenuItem(
        value: hour,
        child: Text(displayText),
      );
    });
  }

  List<DropdownMenuItem<int>> _getEndHourItems() {
    // End time options should be greater than start time and within 9 AM to 6 PM range
    List<DropdownMenuItem<int>> items = [];

    for (int hour = _startHour + 1; hour <= 18; hour++) {
      String hourText = hour.toString().padLeft(2, '0');
      String displayText = hour <= 12 ? '$hourText:00 AM' : '${(hour - 12).toString().padLeft(2, '0')}:00 PM';
      if (hour == 12) displayText = '12:00 PM';

      items.add(DropdownMenuItem(
        value: hour,
        child: Text(displayText),
      ));
    }

    return items;
  }

  void _updateStartTime(int? newValue) {
    if (newValue != null) {
      setState(() {
        _startHour = newValue;
        // Ensure end time is after start time and within valid range
        if (_endHour <= _startHour) {
          _endHour = _startHour + 1;
        }
        // Make sure end time doesn't exceed 6 PM
        if (_endHour > 18) {
          _endHour = 18;
        }
      });

      print('Start time updated to: $_startHour:00');

      // Call the parent component's handler
      widget.onTimeSelected(_startHour, 0, _endHour, 0);
    }
  }

  void _updateEndTime(int? newValue) {
    if (newValue != null) {
      setState(() {
        _endHour = newValue;
        // No need to adjust start time since end time dropdown only shows valid options
      });

      print('End time updated to: $_endHour:00');

      // Call the parent component's handler
      widget.onTimeSelected(_startHour, 0, _endHour, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Time',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Start Time:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _startHour,
                    items: _getHourItems(),
                    onChanged: _updateStartTime,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'End Time:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _endHour,
                    items: _getEndHourItems(),
                    onChanged: _updateEndTime,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AppCalendarForDetail extends StatelessWidget {
  final void Function(PickerDateRange) onConfirm;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  AppCalendarForDetail({
    super.key,
    required this.onConfirm,
    this.initialStartDate,
    this.initialEndDate,
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
    DateTime endDate = DateTime(startDate.year + 1, startDate.month, startDate.day);

    addAllSundays(startDate, endDate);

    return BlocBuilder<DateBloc, DateState>(
      builder: (context, state) {
        // Create initial range from provided dates
        PickerDateRange? initialSelectedRange;

        if (state is DateSelectionSuccess) {
          // Use the state if available
          initialSelectedRange = state.dateRange;
        } else if (initialStartDate != null) {
          // Use the provided initial dates for highlighting
          initialSelectedRange = PickerDateRange(
            initialStartDate,
            initialEndDate ?? initialStartDate,
          );

          print('AppCalendarForDetail: Using initial dates for highlighting');
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

            // Use the calculated initial range
            initialSelectedRange: initialSelectedRange,

            // Add initial display date to focus on the selected month
            initialDisplayDate: initialStartDate ?? DateTime.now(),
          ),
        );
      },
    );
  }
}