import 'package:hb_booking_mobile_app/search/bloc_search.dart';
import 'package:hb_booking_mobile_app/search/date/bloc_date.dart';
import 'package:hb_booking_mobile_app/search/date/state_date.dart';
import 'package:hb_booking_mobile_app/search/destination/bloc_destination.dart';
import 'package:hb_booking_mobile_app/search/state_search.dart';
import 'package:hb_booking_mobile_app/search/widgets/widget_app_calender.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hb_booking_mobile_app/utils/colors.dart';
import 'package:intl/intl.dart';


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../home/asset_bloc/asset_bloc.dart';
import '../../home/asset_bloc/asset_event.dart';

class SelectDateWidget extends StatefulWidget {
  final BookingStep step;
  final void Function(String startDate, String? endDate) onDateConfirm;
  final void Function(String startTime, String endTime)? onTimeConfirm; // Optional
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final String? initialStartTime;
  final String? initialEndTime;
  final bool showConfirmButton;
  final bool enableTimeSelection; // New flag to control time picker visibility

  const SelectDateWidget({
    Key? key,
    required this.step,
    required this.onDateConfirm,
    this.onTimeConfirm,
    this.initialStartDate,
    this.initialEndDate,
    this.initialStartTime,
    this.initialEndTime,
    this.showConfirmButton = false,
    this.enableTimeSelection = false, // Default to true, can be disabled
  }) : super(key: key);

  @override
  _SelectDateWidgetState createState() => _SelectDateWidgetState();
}

class _SelectDateWidgetState extends State<SelectDateWidget> {
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  int startHour = 9;
  int startMinute = 0;
  int endHour = 18;
  int endMinute = 0;
  bool isDateRangeSelected = false;
  bool isTimeSelected = false; // Track if user actually selected time
  bool enableTimeSelection = false; // New state variable for toggle

  @override
  void initState() {
    super.initState();

    // Initialize time selection toggle based on widget parameter
    enableTimeSelection = false;

    // Initialize with provided dates if available
    if (widget.initialStartDate != null) {
      selectedStartDate = widget.initialStartDate;
      isDateRangeSelected = true;
    }

    if (widget.initialEndDate != null) {
      selectedEndDate = widget.initialEndDate;
    } else if (selectedStartDate != null) {
      selectedEndDate = selectedStartDate;
    }

    // Initialize time from provided string if available
    if (widget.initialStartTime != null) {
      final timeParts = widget.initialStartTime!.split(':');
      startHour = int.parse(timeParts[0]);
      startMinute = int.parse(timeParts[1]);
      isTimeSelected = true;
      enableTimeSelection = true; // Enable toggle if initial time is provided
    }

    if (widget.initialEndTime != null) {
      final timeParts = widget.initialEndTime!.split(':');
      endHour = int.parse(timeParts[0]);
      endMinute = int.parse(timeParts[1]);
      isTimeSelected = true;
    }

    print('SelectDateWidget initialized with:');
    print('Start date: $selectedStartDate, time: ${isTimeSelected ? "$startHour:$startMinute" : "not selected"}');
    print('End date: $selectedEndDate, time: ${isTimeSelected ? "$endHour:$endMinute" : "not selected"}');
    print('Time selection enabled: $enableTimeSelection');
  }

  void _updateTimeSelection(int newStartHour, int newStartMinute, int newEndHour, int newEndMinute) {
    setState(() {
      startHour = newStartHour;
      startMinute = newStartMinute;
      endHour = newEndHour;
      endMinute = newEndMinute;
      isTimeSelected = true; // Mark that user has selected time
    });

    print('Time selection updated to:');
    print('Start time: $startHour:$startMinute');
    print('End time: $endHour:$endMinute');

    // Only call time confirmation if callback is provided and time selection is enabled
    if (enableTimeSelection && widget.onTimeConfirm != null) {
      String startTime = '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}:00';
      String endTime = '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}:00';
      widget.onTimeConfirm!(startTime, endTime);
    }

    // Trigger refresh of shared AssetBloc when time changes
    _triggerAssetRefresh();

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

      // Trigger refresh of shared AssetBloc when date changes
      _triggerAssetRefresh();

      // Auto-confirm if not showing a confirm button
      if (!widget.showConfirmButton) {
        _confirmDateSelection();
      }
    }
  }

  // Method to trigger AssetBloc refresh when date/time changes
  void _triggerAssetRefresh() {
    if (mounted && context.mounted) {
      // Check if AssetBloc is available in the widget tree
      try {
        final assetBloc = context.read<AssetBloc>();

        // Get current search parameters from BookingSearchBloc if available
        String? location;
        String? asset;

        try {
          final bookingState = context.read<BookingSearchBloc>().state;
          location = bookingState.selectedLocation;
          asset = bookingState.selectedAsset;
        } catch (e) {
          // BookingSearchBloc might not be available, use defaults
          location = 'kochi';
          asset = null;
        }

        // Format dates
        String? startDate;
        String? endDate;
        if (selectedStartDate != null) {
          startDate = '${selectedStartDate!.year}-${selectedStartDate!.month.toString().padLeft(2, '0')}-${selectedStartDate!.day.toString().padLeft(2, '0')}';
        }
        if (selectedEndDate != null) {
          endDate = '${selectedEndDate!.year}-${selectedEndDate!.month.toString().padLeft(2, '0')}-${selectedEndDate!.day.toString().padLeft(2, '0')}';
        }

        // Format times if selected and enabled
        String? startTime;
        String? endTime;
        if (enableTimeSelection && isTimeSelected) {
          startTime = '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}:00';
          endTime = '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}:00';
        }

        // Trigger new asset fetch with updated parameters
        assetBloc.add(FetchAssetsEvent(
          location: location ?? 'kochi',
          asset: asset,
          startDate: startDate,
          startTime: startTime,
          endDate: endDate,
          endTime: endTime,
          context: context,
        ));

        print('AssetBloc refresh triggered with updated date/time');
      } catch (e) {
        print('AssetBloc not available in widget tree: $e');
      }
    }
  }

  void _confirmDateSelection() {
    if (selectedStartDate != null && selectedEndDate != null) {
      // Format dates as YYYY-MM-DD
      String startDate = '${selectedStartDate!.year}-${selectedStartDate!.month.toString().padLeft(2, '0')}-${selectedStartDate!.day.toString().padLeft(2, '0')}';
      String? endDate = selectedEndDate != selectedStartDate
          ? '${selectedEndDate!.year}-${selectedEndDate!.month.toString().padLeft(2, '0')}-${selectedEndDate!.day.toString().padLeft(2, '0')}'
          : null;

      print('Date confirmation triggered with:');
      print('Start date: $startDate');
      print('End date: $endDate');

      widget.onDateConfirm(startDate, endDate);

      // Only confirm time if user has actually selected time AND callback is provided AND time selection is enabled
      if (enableTimeSelection && isTimeSelected && widget.onTimeConfirm != null) {
        String startTime = '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}:00';
        String endTime = '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}:00';
        widget.onTimeConfirm!(startTime, endTime);
      }
    } else {
      print('Cannot confirm - date range not fully selected');
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
                    Text(
                      'When?',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: size.height * 0.02),

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
                              } else {
                                // Set default times when enabled
                                startHour = 9;
                                startMinute = 0;
                                endHour = 18;
                                endMinute = 0;
                                isTimeSelected = true;

                                // Trigger time confirmation immediately with default values
                                if (widget.onTimeConfirm != null) {
                                  String startTime = '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}:00';
                                  String endTime = '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}:00';
                                  widget.onTimeConfirm!(startTime, endTime);
                                }
                              }
                            });

                            // Trigger asset refresh when toggle changes
                            _triggerAssetRefresh();
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: size.height * 0.02),

                    AppCalendar(
                      onConfirm: (dateRange) {
                        _updateDateSelection(dateRange);
                      },
                    ),

                    // Only show time picker if enabled
                    if (enableTimeSelection) ...[
                      SizedBox(height: size.height * 0.01),
                      TimePickerSection(
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

class TimePickerSection extends StatefulWidget {
  final void Function(int startHour, int startMinute, int endHour, int endMinute) onTimeSelected;
  final int initialStartHour;
  final int initialEndHour;

  const TimePickerSection({
    Key? key,
    required this.onTimeSelected,
    this.initialStartHour = 9,
    this.initialEndHour = 18,
  }) : super(key: key);

  @override
  _TimePickerSectionState createState() => _TimePickerSectionState();
}

class _TimePickerSectionState extends State<TimePickerSection> {
  late int _startHour;
  late int _endHour;

  @override
  void initState() {
    super.initState();

    // Ensure initial hours are within the valid range (9 AM to 6 PM)
    _startHour = widget.initialStartHour.clamp(9, 17); // Start time max 5 PM (so end time can be at least 6 PM)
    _endHour = widget.initialEndHour.clamp(_startHour + 1, 18); // End time must be after start and max 6 PM

    print('TimePickerSection initialized with start hour: $_startHour, end hour: $_endHour');
  }

  @override
  void didUpdateWidget(TimePickerSection oldWidget) {
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
                    items: _getEndHourItems(), // Use the separate method for end time items
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
/*class SelectDateWidget extends StatefulWidget {
  final BookingStep step;
  final void Function(String startDate, String? endDate) onDateConfirm;
  final void Function(String startTime, String endTime)? onTimeConfirm; // Optional
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final String? initialStartTime;
  final String? initialEndTime;
  final bool showConfirmButton;
  final bool enableTimeSelection; // New flag to control time picker visibility

  const SelectDateWidget({
    Key? key,
    required this.step,
    required this.onDateConfirm,
    this.onTimeConfirm,
    this.initialStartDate,
    this.initialEndDate,
    this.initialStartTime,
    this.initialEndTime,
    this.showConfirmButton = false,
    this.enableTimeSelection = true, // Default to true, can be disabled
  }) : super(key: key);

  @override
  _SelectDateWidgetState createState() => _SelectDateWidgetState();
}

class _SelectDateWidgetState extends State<SelectDateWidget> {
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  int startHour = 9;
  int startMinute = 0;
  int endHour = 18;
  int endMinute = 0;
  bool isDateRangeSelected = false;
  bool isTimeSelected = false; // Track if user actually selected time

  @override
  void initState() {
    super.initState();

    // Initialize with provided dates if available
    if (widget.initialStartDate != null) {
      selectedStartDate = widget.initialStartDate;
      isDateRangeSelected = true;
    }

    if (widget.initialEndDate != null) {
      selectedEndDate = widget.initialEndDate;
    } else if (selectedStartDate != null) {
      selectedEndDate = selectedStartDate;
    }

    // Initialize time from provided string if available
    if (widget.initialStartTime != null) {
      final timeParts = widget.initialStartTime!.split(':');
      startHour = int.parse(timeParts[0]);
      startMinute = int.parse(timeParts[1]);
      isTimeSelected = true;
    }

    if (widget.initialEndTime != null) {
      final timeParts = widget.initialEndTime!.split(':');
      endHour = int.parse(timeParts[0]);
      endMinute = int.parse(timeParts[1]);
      isTimeSelected = true;
    }

    print('SelectDateWidget initialized with:');
    print('Start date: $selectedStartDate, time: ${isTimeSelected ? "$startHour:$startMinute" : "not selected"}');
    print('End date: $selectedEndDate, time: ${isTimeSelected ? "$endHour:$endMinute" : "not selected"}');
  }

  void _updateTimeSelection(int newStartHour, int newStartMinute, int newEndHour, int newEndMinute) {
    setState(() {
      startHour = newStartHour;
      startMinute = newStartMinute;
      endHour = newEndHour;
      endMinute = newEndMinute;
      isTimeSelected = true; // Mark that user has selected time
    });

    print('Time selection updated to:');
    print('Start time: $startHour:$startMinute');
    print('End time: $endHour:$endMinute');

    // Only call time confirmation if callback is provided
    if (widget.onTimeConfirm != null) {
      String startTime = '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}:00';
      String endTime = '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}:00';
      widget.onTimeConfirm!(startTime, endTime);
    }

    // Trigger refresh of shared AssetBloc when time changes
    _triggerAssetRefresh();

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

      // Trigger refresh of shared AssetBloc when date changes
      _triggerAssetRefresh();

      // Auto-confirm if not showing a confirm button
      if (!widget.showConfirmButton) {
        _confirmDateSelection();
      }
    }
  }

  // Method to trigger AssetBloc refresh when date/time changes
  void _triggerAssetRefresh() {
    if (mounted && context.mounted) {
      // Check if AssetBloc is available in the widget tree
      try {
        final assetBloc = context.read<AssetBloc>();

        // Get current search parameters from BookingSearchBloc if available
        String? location;
        String? asset;

        try {
          final bookingState = context.read<BookingSearchBloc>().state;
          location = bookingState.selectedLocation;
          asset = bookingState.selectedAsset;
        } catch (e) {
          // BookingSearchBloc might not be available, use defaults
          location = 'kochi';
          asset = null;
        }

        // Format dates
        String? startDate;
        String? endDate;
        if (selectedStartDate != null) {
          startDate = '${selectedStartDate!.year}-${selectedStartDate!.month.toString().padLeft(2, '0')}-${selectedStartDate!.day.toString().padLeft(2, '0')}';
        }
        if (selectedEndDate != null) {
          endDate = '${selectedEndDate!.year}-${selectedEndDate!.month.toString().padLeft(2, '0')}-${selectedEndDate!.day.toString().padLeft(2, '0')}';
        }

        // Format times if selected
        String? startTime;
        String? endTime;
        if (isTimeSelected) {
          startTime = '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}:00';
          endTime = '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}:00';
        }

        // Trigger new asset fetch with updated parameters
        assetBloc.add(FetchAssetsEvent(
          location: location ?? 'kochi',
          asset: asset,
          startDate: startDate,
          startTime: startTime,
          endDate: endDate,
          endTime: endTime,
          context: context,
        ));

        print('AssetBloc refresh triggered with updated date/time');
      } catch (e) {
        print('AssetBloc not available in widget tree: $e');
      }
    }
  }

  void _confirmDateSelection() {
    if (selectedStartDate != null && selectedEndDate != null) {
      // Format dates as YYYY-MM-DD
      String startDate = '${selectedStartDate!.year}-${selectedStartDate!.month.toString().padLeft(2, '0')}-${selectedStartDate!.day.toString().padLeft(2, '0')}';
      String? endDate = selectedEndDate != selectedStartDate
          ? '${selectedEndDate!.year}-${selectedEndDate!.month.toString().padLeft(2, '0')}-${selectedEndDate!.day.toString().padLeft(2, '0')}'
          : null;

      print('Date confirmation triggered with:');
      print('Start date: $startDate');
      print('End date: $endDate');

      widget.onDateConfirm(startDate, endDate);

      // Only confirm time if user has actually selected time AND callback is provided
      if (isTimeSelected && widget.onTimeConfirm != null) {
        String startTime = '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}:00';
        String endTime = '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}:00';
        widget.onTimeConfirm!(startTime, endTime);
      }
    } else {
      print('Cannot confirm - date range not fully selected');
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
                    Text(
                      'When?',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: size.height * 0.02),
                    AppCalendar(
                      onConfirm: (dateRange) {
                        _updateDateSelection(dateRange);
                      },
                    ),
                    // Only show time picker if enabled
                    if (widget.enableTimeSelection) ...[
                      SizedBox(height: size.height * 0.01),
                      TimePickerSection(
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

class TimePickerSection extends StatefulWidget {
  final void Function(int startHour, int startMinute, int endHour, int endMinute) onTimeSelected;
  final int initialStartHour;
  final int initialEndHour;

  const TimePickerSection({
    Key? key,
    required this.onTimeSelected,
    this.initialStartHour = 9,
    this.initialEndHour = 18,
  }) : super(key: key);

  @override
  _TimePickerSectionState createState() => _TimePickerSectionState();
}

class _TimePickerSectionState extends State<TimePickerSection> {
  late int _startHour;
  late int _endHour;

  @override
  void initState() {
    super.initState();
    _startHour = widget.initialStartHour;
    _endHour = widget.initialEndHour;

    print('TimePickerSection initialized with start hour: $_startHour, end hour: $_endHour');
  }

  @override
  void didUpdateWidget(TimePickerSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update hours if initial values changed
    if (oldWidget.initialStartHour != widget.initialStartHour) {
      _startHour = widget.initialStartHour;
    }
    if (oldWidget.initialEndHour != widget.initialEndHour) {
      _endHour = widget.initialEndHour;
    }
  }

  List<DropdownMenuItem<int>> _getHourItems() {
    return List.generate(24, (index) {
      int hour = index;
      String hourText = hour.toString().padLeft(2, '0');
      return DropdownMenuItem(
        value: hour,
        child: Text('$hourText:00'),
      );
    });
  }

  void _updateStartTime(int? newValue) {
    if (newValue != null) {
      setState(() {
        _startHour = newValue;
        // Ensure end time is after start time
        if (_endHour <= _startHour) {
          _endHour = (_startHour + 1) % 24;
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
        // Ensure start time is before end time
        if (_endHour <= _startHour) {
          _startHour = (_endHour - 1 + 24) % 24; // Handle wrapping around to previous day
        }
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
                    items: _getHourItems(),
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
}*/

/*class SelectDateWidget extends StatefulWidget {
  final BookingStep step;
  final void Function(String startDate, String? endDate) onDateConfirm;
  final void Function(String startTime, String endTime)? onTimeConfirm; // Optional
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final String? initialStartTime;
  final String? initialEndTime;
  final bool showConfirmButton;
  final bool enableTimeSelection; // New flag to control time picker visibility

  const SelectDateWidget({
    Key? key,
    required this.step,
    required this.onDateConfirm,
    this.onTimeConfirm,
    this.initialStartDate,
    this.initialEndDate,
    this.initialStartTime,
    this.initialEndTime,
    this.showConfirmButton = false,
    this.enableTimeSelection = true, // Default to true, can be disabled
  }) : super(key: key);

  @override
  _SelectDateWidgetState createState() => _SelectDateWidgetState();
}

class _SelectDateWidgetState extends State<SelectDateWidget> {
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  int startHour = 9;
  int startMinute = 0;
  int endHour = 18;
  int endMinute = 0;
  bool isDateRangeSelected = false;
  bool isTimeSelected = false; // Track if user actually selected time

  @override
  void initState() {
    super.initState();

    // Initialize with provided dates if available
    if (widget.initialStartDate != null) {
      selectedStartDate = widget.initialStartDate;
      isDateRangeSelected = true;
    }

    if (widget.initialEndDate != null) {
      selectedEndDate = widget.initialEndDate;
    } else if (selectedStartDate != null) {
      selectedEndDate = selectedStartDate;
    }

    // Initialize time from provided string if available
    if (widget.initialStartTime != null) {
      final timeParts = widget.initialStartTime!.split(':');
      startHour = int.parse(timeParts[0]);
      startMinute = int.parse(timeParts[1]);
      isTimeSelected = true;
    }

    if (widget.initialEndTime != null) {
      final timeParts = widget.initialEndTime!.split(':');
      endHour = int.parse(timeParts[0]);
      endMinute = int.parse(timeParts[1]);
      isTimeSelected = true;
    }

    print('SelectDateWidget initialized with:');
    print('Start date: $selectedStartDate, time: ${isTimeSelected ? "$startHour:$startMinute" : "not selected"}');
    print('End date: $selectedEndDate, time: ${isTimeSelected ? "$endHour:$endMinute" : "not selected"}');
  }

  void _updateTimeSelection(int newStartHour, int newStartMinute, int newEndHour, int newEndMinute) {
    setState(() {
      startHour = newStartHour;
      startMinute = newStartMinute;
      endHour = newEndHour;
      endMinute = newEndMinute;
      isTimeSelected = true; // Mark that user has selected time
    });

    print('Time selection updated to:');
    print('Start time: $startHour:$startMinute');
    print('End time: $endHour:$endMinute');

    // Only call time confirmation if callback is provided
    if (widget.onTimeConfirm != null) {
      String startTime = '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}:00';
      String endTime = '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}:00';
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
    if (selectedStartDate != null && selectedEndDate != null) {
      // Format dates as YYYY-MM-DD
      String startDate = '${selectedStartDate!.year}-${selectedStartDate!.month.toString().padLeft(2, '0')}-${selectedStartDate!.day.toString().padLeft(2, '0')}';
      String? endDate = selectedEndDate != selectedStartDate
          ? '${selectedEndDate!.year}-${selectedEndDate!.month.toString().padLeft(2, '0')}-${selectedEndDate!.day.toString().padLeft(2, '0')}'
          : null;

      print('Date confirmation triggered with:');
      print('Start date: $startDate');
      print('End date: $endDate');

      widget.onDateConfirm(startDate, endDate);

      // Only confirm time if user has actually selected time AND callback is provided
      if (isTimeSelected && widget.onTimeConfirm != null) {
        String startTime = '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}:00';
        String endTime = '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}:00';
        widget.onTimeConfirm!(startTime, endTime);
      }
    } else {
      print('Cannot confirm - date range not fully selected');
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
                    Text(
                      'When?',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: size.height * 0.02),
                    AppCalendar(
                      onConfirm: (dateRange) {
                        _updateDateSelection(dateRange);
                      },
                    ),
                    // Only show time picker if enabled
                    if (widget.enableTimeSelection) ...[
                      SizedBox(height: size.height * 0.01),
                      TimePickerSection(
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
*//*class SelectDateWidget extends StatefulWidget {
  final BookingStep step;
  final void Function(String isoStart, String isoEnd) onConfirm;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final bool showConfirmButton;  // Add this flag to determine if we show the confirm button

  const SelectDateWidget({
    Key? key,
    required this.step,
    required this.onConfirm,
    this.initialStartDate,
    this.initialEndDate,
    this.showConfirmButton = false,  // Default to false for BookingSearchfieldScreen
  }) : super(key: key);

  @override
  _SelectDateWidgetState createState() => _SelectDateWidgetState();
}

class _SelectDateWidgetState extends State<SelectDateWidget> {
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  int startHour = 9;
  int startMinute = 0;
  int endHour = 18;
  int endMinute = 0;
  bool isDateRangeSelected = false;

  @override
  void initState() {
    super.initState();

    // Initialize with provided dates if available
    if (widget.initialStartDate != null) {
      selectedStartDate = widget.initialStartDate;
      startHour = widget.initialStartDate!.hour;
      startMinute = widget.initialStartDate!.minute;
      isDateRangeSelected = true;
    }

    if (widget.initialEndDate != null) {
      selectedEndDate = widget.initialEndDate;
      endHour = widget.initialEndDate!.hour;
      endMinute = widget.initialEndDate!.minute;
    } else if (selectedStartDate != null) {
      // If only start date is available, set end date to the same
      selectedEndDate = selectedStartDate;
    }

    // Debug log
    print('SelectDateWidget initialized with:');
    print('Start date: $selectedStartDate, time: $startHour:$startMinute');
    print('End date: $selectedEndDate, time: $endHour:$endMinute');
  }

  void _updateTimeSelection(int newStartHour, int newStartMinute, int newEndHour, int newEndMinute) {
    setState(() {
      startHour = newStartHour;
      startMinute = newStartMinute;
      endHour = newEndHour;
      endMinute = newEndMinute;
    });

    print('Time selection updated to:');
    print('Start time: $startHour:$startMinute');
    print('End time: $endHour:$endMinute');

    // Auto-confirm if not showing a confirm button
    if (!widget.showConfirmButton && isDateRangeSelected) {
      _confirmSelection();
    }
  }

  // Update this method to accept the format that AppCalendar provides
  void _updateDateSelection(dynamic dateRangeData) {
    // Extract start and end dates based on your AppCalendar's actual return type
    DateTime? startDate;
    DateTime? endDate;

    if (dateRangeData is Map<String, dynamic>) {
      // If AppCalendar returns a Map
      startDate = dateRangeData['startDate'];
      endDate = dateRangeData['endDate'] ?? dateRangeData['startDate'];
    } else if (dateRangeData.startDate != null) {
      // If AppCalendar returns an object with startDate property
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
        _confirmSelection();
      }
    }
  }

  void _confirmSelection() {
    if (selectedStartDate != null && selectedEndDate != null) {
      DateTime startDateTime = DateTime(
        selectedStartDate!.year,
        selectedStartDate!.month,
        selectedStartDate!.day,
        startHour,
        startMinute,
      );

      DateTime endDateTime = DateTime(
        selectedEndDate!.year,
        selectedEndDate!.month,
        selectedEndDate!.day,
        endHour,
        endMinute,
      );

      String isoStart = startDateTime.toIso8601String();
      String isoEnd = endDateTime.toIso8601String();

      // Debug log
      print('Confirmation triggered with:');
      print('Start: $isoStart (${startDateTime.toString()})');
      print('End: $isoEnd (${endDateTime.toString()})');

      widget.onConfirm(isoStart, isoEnd);
    } else {
      print('Cannot confirm - date range not fully selected');
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
              _confirmSelection();
            }
          }

          return Card(
            elevation: 0.0,
            clipBehavior: Clip.antiAlias,
            child: AnimatedContainer(
              height: widget.step == BookingStep.selectDate
                  ? size.height * 0.6 // Use 60% of screen height
                  : 60,
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: size.height * 0.02, // 2% of screen height
                horizontal: size.width * 0.05, // 5% of screen width
              ),
              duration: const Duration(milliseconds: 300),
              child: widget.step == BookingStep.selectDate
                  ? SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'When?',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: size.height * 0.02), // 2% of screen height
                    AppCalendar(
                      onConfirm: (dateRange) {
                        _updateDateSelection(dateRange);
                      },
                    ),
                    SizedBox(height: size.height * 0.01), // 1% of screen height
                    TimePickerSection(
                      initialStartHour: startHour,
                      initialEndHour: endHour,
                      onTimeSelected: _updateTimeSelection,
                    ),
                    // Only show the confirmation button if requested
                    if (widget.showConfirmButton) ...[
                      SizedBox(height: size.height * 0.02), // 2% of screen height
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isDateRangeSelected ? _confirmSelection : null,
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
}*//*
class TimePickerSection extends StatefulWidget {
  final void Function(int startHour, int startMinute, int endHour, int endMinute) onTimeSelected;
  final int initialStartHour;
  final int initialEndHour;

  const TimePickerSection({
    Key? key,
    required this.onTimeSelected,
    this.initialStartHour = 9,
    this.initialEndHour = 18,
  }) : super(key: key);

  @override
  _TimePickerSectionState createState() => _TimePickerSectionState();
}

class _TimePickerSectionState extends State<TimePickerSection> {
  late int _startHour;
  late int _endHour;

  @override
  void initState() {
    super.initState();
    _startHour = widget.initialStartHour;
    _endHour = widget.initialEndHour;

    // Debug log
    print('TimePickerSection initialized with start hour: $_startHour, end hour: $_endHour');
  }

  List<DropdownMenuItem<int>> _getHourItems() {
    return List.generate(24, (index) {
      int hour = index;
      String hourText = hour.toString().padLeft(2, '0');
      return DropdownMenuItem(
        value: hour,
        child: Text('$hourText:00'),
      );
    });
  }

  // Validate times but don't trigger the callback automatically
  void _updateStartTime(int? newValue) {
    if (newValue != null) {
      setState(() {
        _startHour = newValue;
        // Ensure end time is after start time
        if (_endHour <= _startHour) {
          _endHour = (_startHour + 1) % 24;
        }
      });

      // Call the parent component's handler but don't trigger confirmation
      widget.onTimeSelected(_startHour, 0, _endHour, 0);
    }
  }

  void _updateEndTime(int? newValue) {
    if (newValue != null) {
      setState(() {
        _endHour = newValue;
        // Ensure start time is before end time
        if (_endHour <= _startHour) {
          _startHour = (_endHour - 1 + 24) % 24; // Handle wrapping around to previous day
        }
      });

      // Call the parent component's handler but don't trigger confirmation
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
                    items: _getHourItems(),
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
}*/















