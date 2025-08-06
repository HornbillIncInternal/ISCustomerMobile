import 'package:hb_booking_mobile_app/authentication/bloc_login.dart';
import 'package:hb_booking_mobile_app/authentication/screen_login_confirmation.dart';

import 'package:hb_booking_mobile_app/booking/screen_booking.dart';
import 'package:hb_booking_mobile_app/connectivity/connectivity_bloc.dart';
import 'package:hb_booking_mobile_app/connectivity/connectivity_state.dart';
import 'package:hb_booking_mobile_app/home/model/model_assets.dart';
import 'package:hb_booking_mobile_app/home/workspcae_detail/event_workspacedetail.dart';
import 'package:hb_booking_mobile_app/home/workspcae_detail/selectDateWidgetForDetail.dart';

import 'package:hb_booking_mobile_app/home/workspcae_detail/state_workspacedetail.dart';
import 'package:hb_booking_mobile_app/home/workspcae_detail/widget_image_gallery.dart';
import 'package:hb_booking_mobile_app/home/workspcae_detail/workspace_reviews/review_repository.dart';
import 'package:hb_booking_mobile_app/home/workspcae_detail/workspace_reviews/reviews_bloc.dart';
import 'package:hb_booking_mobile_app/home/workspcae_detail/workspace_reviews/screen_reviews.dart';
import 'package:hb_booking_mobile_app/utils/colors.dart';
import 'package:hb_booking_mobile_app/utils/functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hb_booking_mobile_app/utils/is_loader.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../search/state_search.dart';
import '../../search/widgets/widget_select_date.dart';
import 'bloc_workspacedetail.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:hb_booking_mobile_app/authentication/bloc_login.dart';
import 'package:hb_booking_mobile_app/authentication/screen_login_confirmation.dart';
import 'package:hb_booking_mobile_app/booking/screen_booking.dart';
import 'package:hb_booking_mobile_app/connectivity/connectivity_bloc.dart';
import 'package:hb_booking_mobile_app/connectivity/connectivity_state.dart';
import 'package:hb_booking_mobile_app/home/model/model_assets.dart';
import 'package:hb_booking_mobile_app/home/workspcae_detail/event_workspacedetail.dart';
import 'package:hb_booking_mobile_app/home/workspcae_detail/state_workspacedetail.dart';
import 'package:hb_booking_mobile_app/home/workspcae_detail/widget_image_gallery.dart';
import 'package:hb_booking_mobile_app/home/workspcae_detail/workspace_reviews/review_repository.dart';
import 'package:hb_booking_mobile_app/home/workspcae_detail/workspace_reviews/reviews_bloc.dart';
import 'package:hb_booking_mobile_app/home/workspcae_detail/workspace_reviews/screen_reviews.dart';
import 'package:hb_booking_mobile_app/utils/colors.dart';
import 'package:hb_booking_mobile_app/utils/functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hb_booking_mobile_app/utils/is_loader.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../search/state_search.dart';
import 'bloc_workspacedetail.dart';

class WorkspaceDetailScreen extends StatefulWidget {
  final Datum apiResponse;
  final int index;
  final String? selectedDate;
  final String? selectedStartTime;
  final String? selectedEndTime;
  final String? selectedEndDate;

  const WorkspaceDetailScreen({
    Key? key,
    required this.apiResponse,
    required this.index,
    this.selectedDate,
    this.selectedStartTime,
    this.selectedEndTime,
    this.selectedEndDate,
  }) : super(key: key);

  @override
  State<WorkspaceDetailScreen> createState() => _WorkspaceDetailScreenState();
}

class _WorkspaceDetailScreenState extends State<WorkspaceDetailScreen> {
  bool _isAmenitiesExpanded = false;
  bool _isOHExpanded = false;
  bool _isPackageExpanded = false;
  int _currentImageIndex = 0;
  int _deskCounter = 1;
  double _totalPrice = 0.0;
  late DateTime startDate;
  late DateTime endDate;
  List<Map<String, String>> dateTimeRanges = [];
  bool containsSunday = false;
  late WorkspaceDetailBloc _workspaceDetailBloc;
  bool _showDiscount = false;
  double _effectivePrice = 0.0;
  double _totalEffectiveAmount = 0.0;

  // Track whether time is selected
  bool hasTimeSelected = false;

  @override
  void initState() {
    super.initState();
    _workspaceDetailBloc = WorkspaceDetailBloc();

    // Initialize from separate parameters
    String? startDateStr = widget.selectedDate;
    String? endDateStr = widget.selectedEndDate ?? widget.selectedDate;
    String? startTimeStr = widget.selectedStartTime;
    String? endTimeStr = widget.selectedEndTime;

    // Check if time is actually selected (both start and end time must be present and not default values)
    hasTimeSelected = startTimeStr != null &&
        endTimeStr != null &&
        startTimeStr.isNotEmpty &&
        endTimeStr.isNotEmpty &&
        startTimeStr != '00:00:00' &&
        endTimeStr != '00:00:00';

    print("=== INITIALIZATION DEBUG ===");
    print("selectedDate: $startDateStr");
    print("selectedEndDate: $endDateStr");
    print("selectedStartTime: $startTimeStr");
    print("selectedEndTime: $endTimeStr");
    print("hasTimeSelected: $hasTimeSelected");
    print("==========================");

    setState(() {
      if (startDateStr != null) {
        if (hasTimeSelected) {
          // With time - use the actual selected times
          startDate = DateTime.parse('${startDateStr}T$startTimeStr');
          endDate = DateTime.parse('${endDateStr}T$endTimeStr');
        } else {
          // Date only - NO DEFAULT TIMES, just use the date at midnight
          startDate = DateTime.parse('${startDateStr}T00:00:00');
          endDate = DateTime.parse('${endDateStr}T00:00:00');
        }
      } else {
        // No date provided - use current date at midnight (NO DEFAULT TIMES)
        final now = DateTime.now();
        startDate = DateTime(now.year, now.month, now.day, 0, 0, 0);
        endDate = DateTime(now.year, now.month, now.day, 0, 0, 0);
      }

      dateTimeRanges = splitDateRangeIgnoringSundays(startDate, endDate);
      _totalPrice = calculateTotalPrice().toDouble(); // Calculate initial price
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // FIXED: Pass the correct hasTimeSelected state during initialization
      _workspaceDetailBloc.add(InitializeWorkspaceDetail(
        apiResponse: widget.apiResponse,
        startDate: startDate,
        endDate: endDate,
        hasTimeSelected: hasTimeSelected, // Pass the actual time selection state
      ));
    });
  }

  void _onDateRangeUpdate(String isoStart, String isoEnd) {
    final newStartDate = DateTime.parse(isoStart);
    final newEndDate = DateTime.parse(isoEnd);

    print("=== DATE RANGE UPDATE DEBUG ===");
    print("Start: ${newStartDate.toString()} (${isoStart})");
    print("End: ${newEndDate.toString()} (${isoEnd})");

    // FIXED: Better detection of time selection
    final startTimeString = isoStart.split('T')[1];
    final endTimeString = isoEnd.split('T')[1];

    // FIXED: More comprehensive time detection
    final hasNewTimeSelected = (startTimeString != '00:00:00' || endTimeString != '00:00:00') &&
        startTimeString != '23:59:00' &&
        endTimeString != '23:59:00' &&
        startTimeString.isNotEmpty &&
        endTimeString.isNotEmpty;

    print("Time detection:");
    print("Start time string: $startTimeString");
    print("End time string: $endTimeString");
    print("Has new time selected (initial): $hasNewTimeSelected");

    // FIXED: Also check if the times are meaningful business hours
    bool isMeaningfulTime = false;
    if (hasNewTimeSelected) {
      final startHour = newStartDate.hour;
      final endHour = newEndDate.hour;

      // Consider it meaningful if it's not midnight or if hours are different
      isMeaningfulTime = (startHour != 0 || endHour != 0) &&
          (startHour != endHour || newStartDate.minute != newEndDate.minute);

      print("Start hour: $startHour, End hour: $endHour");
      print("Is meaningful time: $isMeaningfulTime");
    }

    final finalTimeSelected = hasNewTimeSelected && isMeaningfulTime;
    print("Final time selected: $finalTimeSelected");
    print("===============================");

    setState(() {
      startDate = newStartDate;
      endDate = newEndDate;
      hasTimeSelected = finalTimeSelected; // FIXED: Use the refined detection

      // Regenerate the date ranges with the updated time
      dateTimeRanges = splitDateRangeIgnoringSundays(startDate, endDate);

      print("Updated state variables:");
      print("startDate: ${startDate.toString()}");
      print("endDate: ${endDate.toString()}");
      print("hasTimeSelected: $hasTimeSelected");
      print("dateTimeRanges: $dateTimeRanges");
    });

    // FIXED: Clear cache before making new API call to ensure fresh data
    _workspaceDetailBloc.clearEffectivePackagesCache();

    // Update date range in bloc to fetch effective packages
    _workspaceDetailBloc.add(UpdateDateRange(
      startDate: newStartDate,
      endDate: newEndDate,
      hasTimeSelected: finalTimeSelected, // FIXED: Use the refined detection
    ));

    print("Dispatched UpdateDateRange event with hasTimeSelected: $finalTimeSelected");
  }

  // FIXED: Force refresh of effective packages when time selection changes
  void _onTimeSelectionToggle(bool enableTime) {
    print("Time selection toggle changed to: $enableTime");

    setState(() {
      hasTimeSelected = enableTime;

      // If disabling time, reset to midnight
      if (!enableTime) {
        startDate = DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0);
        endDate = DateTime(endDate.year, endDate.month, endDate.day, 0, 0, 0);
      } else {
        // If enabling time, set default business hours
        startDate = DateTime(startDate.year, startDate.month, startDate.day, 9, 0, 0);
        endDate = DateTime(endDate.year, endDate.month, endDate.day, 18, 0, 0);
      }

      // Regenerate date ranges
      dateTimeRanges = splitDateRangeIgnoringSundays(startDate, endDate);
    });

    // FIXED: Clear cache and force fresh API call
    _workspaceDetailBloc.clearEffectivePackagesCache();

    // Trigger effective packages refresh with new time selection state
    _workspaceDetailBloc.add(UpdateDateRange(
      startDate: startDate,
      endDate: endDate,
      hasTimeSelected: enableTime,
    ));

    print("Triggered effective packages refresh after time toggle");
  }

  // Updated price calculation to use effective packages data from state
  num calculateTotalPrice() {
    // Try to get effective packages data from bloc state
    EffectivePackagesData? effectivePackagesData;
    if (_workspaceDetailBloc.state is WorkspaceDetailLoaded) {
      final state = _workspaceDetailBloc.state as WorkspaceDetailLoaded;
      effectivePackagesData = state.effectivePackagesData;
    }

    // Use effective packages data if available, otherwise fall back to original data
    final usePrice = effectivePackagesData?.price != null && effectivePackagesData!.price! > 0;

    final displayPrice = usePrice
        ? effectivePackagesData!.price!.toDouble()
        : (effectivePackagesData?.effectivePrice?.toDouble() ??
        widget.apiResponse.rate?.effectivePrice?.toDouble() ?? 0.0);

    // Store the effective price for display and payment calculations
    _effectivePrice = effectivePackagesData?.effectivePrice?.toDouble() ??
        widget.apiResponse.rate?.effectivePrice?.toDouble() ?? 0.0;

    // Check if asset type is desk
    final isDesk = widget.apiResponse.assetType?.title?.toLowerCase() == 'desk';

    // Calculate business days (excluding Sundays)
    final numberOfDays = dateTimeRanges.isNotEmpty ? dateTimeRanges.length : 1;

    // Get package information for rate type (use effective packages if available)
    dynamic package;
    if (effectivePackagesData?.packages?.isNotEmpty == true) {
      package = effectivePackagesData!.packages.first;
    } else if (widget.apiResponse.rate?.packages?.isNotEmpty == true) {
      package = widget.apiResponse.rate!.packages?.first;
    }

    num totalAmount = 0;

    // Safe way to get duration unit
    String? durationUnit;
    if (package != null) {
      if (package is EffectivePackage) {
        durationUnit = package.duration.unit.toLowerCase();
      } else {
        durationUnit = package.duration?.unit?.toString().split('.').last.toLowerCase();
      }
    }

    print("Package duration unit: $durationUnit");
    print("StartDate: $startDate, EndDate: $endDate");
    print("Date ranges count: ${dateTimeRanges.length}");
    print("Has time selected: $hasTimeSelected");
    print("Is desk: $isDesk");
    print("Desk counter: $_deskCounter");
    print("Effective price from API: $_effectivePrice");

    // Handle hourly rate calculation ONLY if time is actually selected by user
    if (durationUnit == 'hour' && hasTimeSelected) {
      final totalHours = endDate.difference(startDate).inHours.clamp(1, 24);

      print("Total calculated hours: $totalHours");

      // Calculate display price (the one shown to users) based on price
      totalAmount = isDesk ?
      totalHours * _deskCounter * displayPrice :
      totalHours * displayPrice;

      // Calculate effective price (the one actually used for payment)
      _totalEffectiveAmount = isDesk ?
      totalHours * _deskCounter * _effectivePrice :
      totalHours * _effectivePrice;
    }
    // For daily rates or when NO time is selected (date-only booking)
    else {
      print("Using daily rate calculation (no specific time selected or daily rate)");

      // Calculate display price based on daily rate
      totalAmount = isDesk ?
      numberOfDays * _deskCounter * displayPrice :
      numberOfDays * displayPrice;

      // Calculate effective price
      _totalEffectiveAmount = isDesk ?
      numberOfDays * _deskCounter * _effectivePrice :
      numberOfDays * _effectivePrice;
    }

    // Only show discounted price when price is different from effectivePrice
    _showDiscount = usePrice && _effectivePrice < displayPrice;

    print("Final calculated total amount: $totalAmount");
    print("Effective amount: $_totalEffectiveAmount");
    print("Show discount: $_showDiscount");

    return totalAmount;
  }

  // Keep existing date range calculation
  List<Map<String, String>> splitDateRangeIgnoringSundays(DateTime startDate, DateTime endDate) {
    final ranges = <Map<String, String>>[];
    var currentDay = DateTime(startDate.year, startDate.month, startDate.day);
    containsSunday = false;

    // Calculate difference in days between start and end date and add 1 to include both days
    final daysDifference = endDate.difference(startDate).inDays + 1;

    for(int i = 0; i < daysDifference; i++) {
      if (currentDay.weekday == DateTime.sunday) {
        containsSunday = true;
      } else {
        if (hasTimeSelected) {
          // Preserve the actual selected hours and minutes
          ranges.add({
            'start': DateTime(
              currentDay.year,
              currentDay.month,
              currentDay.day,
              startDate.hour,
              startDate.minute,
            ).toIso8601String(),
            'end': DateTime(
              currentDay.year,
              currentDay.month,
              currentDay.day,
              endDate.hour,
              endDate.minute,
            ).toIso8601String(),
          });
        } else {
          // Date only - no specific times, use full day (00:00 to 23:59)
          ranges.add({
            'start': DateTime(
              currentDay.year,
              currentDay.month,
              currentDay.day,
              0,
              0,
            ).toIso8601String(),
            'end': DateTime(
              currentDay.year,
              currentDay.month,
              currentDay.day,
              23,
              59,
            ).toIso8601String(),
          });
        }
      }
      currentDay = currentDay.add(Duration(days: 1));
    }

    // Debug to verify time components
    for (var range in ranges) {
      print("Range: ${range['start']} to ${range['end']}");
    }

    return ranges;
  }

  void _showSelectDateWidget(BuildContext context) {
    print("Opening date/time picker with initial values:");
    print("Initial Start: ${startDate.toString()}");
    print("Initial End: ${endDate.toString()}");
    print("Has time selected: $hasTimeSelected");

    // Store the bloc reference before opening the modal
    final workspaceDetailBloc = context.read<WorkspaceDetailBloc>();

    // Extract initial date and time values from existing DateTime objects
    String initialStartDateStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    String? initialStartTimeStr;
    if (hasTimeSelected) {
      initialStartTimeStr = '${startDate.hour.toString().padLeft(2, '0')}:${startDate.minute.toString().padLeft(2, '0')}:${startDate.second.toString().padLeft(2, '0')}';
    }

    String initialEndDateStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
    String? initialEndTimeStr;
    if (hasTimeSelected) {
      initialEndTimeStr = '${endDate.hour.toString().padLeft(2, '0')}:${endDate.minute.toString().padLeft(2, '0')}:${endDate.second.toString().padLeft(2, '0')}';
    }

    // Variables to store selected values
    String? selectedStartDate = initialStartDateStr;
    String? selectedEndDate = initialEndDateStr;
    String? selectedStartTime = initialStartTimeStr;
    String? selectedEndTime = initialEndTimeStr;

    // Initialize enableTimeSelection based on whether time was previously selected
    bool enableTimeSelection = hasTimeSelected;

    print("Modal initialization:");
    print("enableTimeSelection: $enableTimeSelection");
    print("initialStartTimeStr: $initialStartTimeStr");
    print("initialEndTimeStr: $initialEndTimeStr");

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              child: BlocProvider.value(
                value: workspaceDetailBloc,
                child: SafeArea(
                  child: Column(
                    children: [
                      // Header with close button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Select Date & Time',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () => Navigator.pop(bottomSheetContext),
                            ),
                          ],
                        ),
                      ),

                      // SelectDateWidgetForDetail with proper state management
                      Expanded(
                        child: SelectDateWidgetForDetail(
                          key: ValueKey('date_widget_${enableTimeSelection}_${DateTime.now().millisecondsSinceEpoch}'),
                          step: BookingStep.selectDate,
                          initialStartDate: startDate,
                          initialEndDate: endDate,
                          initialStartTime: enableTimeSelection ? selectedStartTime : null,
                          initialEndTime: enableTimeSelection ? selectedEndTime : null,
                          showConfirmButton: false,
                          enableTimeSelection: enableTimeSelection,
                          onDateConfirm: (String startDateStr, String? endDateStr) {
                            print("Date confirmation callback received:");
                            print("startDate: $startDateStr");
                            print("endDate: $endDateStr");

                            setModalState(() {
                              selectedStartDate = startDateStr;
                              selectedEndDate = endDateStr;
                            });
                          },
                          onTimeConfirm: (String startTimeStr, String endTimeStr) {
                            print("Time confirmation callback received:");
                            print("startTime: $startTimeStr");
                            print("endTime: $endTimeStr");

                            setModalState(() {
                              selectedStartTime = startTimeStr;
                              selectedEndTime = endTimeStr;
                              enableTimeSelection = true;
                            });
                          },
                          onTimeDisabled: () {
                            print("Time disabled callback received - clearing time data");
                            setModalState(() {
                              selectedStartTime = null;
                              selectedEndTime = null;
                              enableTimeSelection = false;
                            });
                          },
                        ),
                      ),

                      // Custom confirm button at the bottom
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              String? isoStart;
                              String? isoEnd;

                              // FIXED: Better logic for time selection detection
                              bool hasActualTimeSelection = enableTimeSelection &&
                                  selectedStartTime != null &&
                                  selectedEndTime != null &&
                                  selectedStartTime!.isNotEmpty &&
                                  selectedEndTime!.isNotEmpty &&
                                  selectedStartTime != '00:00:00' &&
                                  selectedEndTime != '00:00:00';

                              if (hasActualTimeSelection) {
                                // Combine date and time to create ISO strings
                                isoStart = '${selectedStartDate}T$selectedStartTime';
                                isoEnd = '${selectedEndDate ?? selectedStartDate}T$selectedEndTime';
                                print("Creating ISO with time: $isoStart to $isoEnd");
                              } else {
                                // Date only - use minimal time (00:00:00) to indicate no specific time
                                isoStart = '${selectedStartDate}T00:00:00';
                                isoEnd = '${selectedEndDate ?? selectedStartDate}T00:00:00';
                                print("Creating ISO without time: $isoStart to $isoEnd");
                              }

                              print("Manual confirmation triggered:");
                              print("isoStart: $isoStart");
                              print("isoEnd: $isoEnd");
                              print("enableTimeSelection: $enableTimeSelection");
                              print("hasActualTimeSelection: $hasActualTimeSelection");
                              print("selectedStartTime: $selectedStartTime");
                              print("selectedEndTime: $selectedEndTime");

                              // Close the bottom sheet
                              Navigator.pop(bottomSheetContext);

                              // Update date range
                              if (isoStart != null && isoEnd != null) {
                                _onDateRangeUpdate(isoStart, isoEnd);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
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
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _workspaceDetailBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(capitalize(widget.apiResponse.familyTitle ?? 'Workspace')),
        ),
        body: BlocBuilder<ConnectivityBloc, ConnectivityState>(
          builder: (context, connectivityState) {
            if (connectivityState is DisconnectedState) {
              return _buildNoConnectionView();
            }

            return BlocConsumer<WorkspaceDetailBloc, WorkspaceDetailState>(
              listener: (context, state) {
                print("=== BLOC LISTENER TRIGGERED ===");
                print("State type: ${state.runtimeType}");
                if (state is WorkspaceDetailLoaded) {
                  print("WorkspaceDetailLoaded state received");
                  print("Effective packages available: ${state.effectivePackagesData != null}");
                  if (state.effectivePackagesData != null) {
                    print("New packages count: ${state.effectivePackagesData!.packages.length}");
                    print("New effective price: ${state.effectivePackagesData!.effectivePrice}");
                  }
                  _handleEffectivePackagesUpdate(state);
                } else {
                  print("Non-loaded state received: ${state.runtimeType}");
                }
                print("===============================");
              },
              builder: (context, state) {
                print("=== BLOC BUILDER TRIGGERED ===");
                print("Building with state: ${state.runtimeType}");

                if (state is WorkspaceDetailLoaded) {
                  print("Building workspace detail with loaded state");
                  if (state.effectivePackagesData != null) {
                    print("Builder - Effective packages count: ${state.effectivePackagesData!.packages.length}");
                  }
                  return _buildWorkspaceDetail(context, state);
                } else if (state is WorkspaceDetailLoading) {
                  print("Showing loading state");
                  return Center(child: OfficeLoader());
                } else {
                  print("Showing error state");
                  return Center(child: Text('Error loading workspace details'));
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildNoConnectionView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(65.0),
            child: Image.asset('assets/images/no_internet.png'),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  void _handleEffectivePackagesUpdate(WorkspaceDetailLoaded state) {
    print("=== HANDLING EFFECTIVE PACKAGES UPDATE ===");
    print("Received effective packages data: ${state.effectivePackagesData != null}");
    if (state.effectivePackagesData != null) {
      print("Price: ${state.effectivePackagesData!.price}");
      print("Effective Price: ${state.effectivePackagesData!.effectivePrice}");
      print("Packages count: ${state.effectivePackagesData!.packages.length}");

      // Print each package for debugging
      for (int i = 0; i < state.effectivePackagesData!.packages.length; i++) {
        final package = state.effectivePackagesData!.packages[i];
        print("Package $i: ${package.name}, rate: ${package.rate}, type: ${package.type}");
      }
    }

    // FIXED: Force a complete setState rebuild
    if (mounted) {
      setState(() {
        // Force recalculation of price with updated effective packages data
        _totalPrice = _calculateTotalPriceWithState(state).toDouble();

        // Update effective price from state if available
        if (state.effectivePackagesData?.effectivePrice != null) {
          _effectivePrice = state.effectivePackagesData!.effectivePrice!.toDouble();

          // Recalculate effective amount as well
          final isDesk = widget.apiResponse.assetType?.title?.toLowerCase() == 'desk';
          final numberOfDays = dateTimeRanges.isNotEmpty ? dateTimeRanges.length : 1;

          if (hasTimeSelected) {
            final totalHours = endDate.difference(startDate).inHours.clamp(1, 24);
            _totalEffectiveAmount = isDesk ? totalHours * _deskCounter * _effectivePrice : totalHours * _effectivePrice;
          } else {
            _totalEffectiveAmount = isDesk ? numberOfDays * _deskCounter * _effectivePrice : numberOfDays * _effectivePrice;
          }

          // Update discount flag
          final usePrice = state.effectivePackagesData?.price != null && state.effectivePackagesData!.price! > 0;
          final displayPrice = usePrice ? state.effectivePackagesData!.price!.toDouble() : _effectivePrice;
          _showDiscount = usePrice && _effectivePrice < displayPrice;
        }
      });

      print("=== PRICE UPDATE RESULTS ===");
      print("New total price: $_totalPrice");
      print("Effective price: $_effectivePrice");
      print("Total effective amount: $_totalEffectiveAmount");
      print("Show discount: $_showDiscount");
      print("============================");

      // FIXED: Force another setState to ensure UI rebuild
      Future.microtask(() {
        if (mounted) {
          setState(() {
            // This empty setState forces a rebuild
          });
        }
      });
    }
  }

  // FIXED: Create a new method that calculates price using the provided state
  num _calculateTotalPriceWithState(WorkspaceDetailLoaded state) {
    final effectivePackagesData = state.effectivePackagesData;

    // Use effective packages data if available, otherwise fall back to original data
    final usePrice = effectivePackagesData?.price != null && effectivePackagesData!.price! > 0;

    final displayPrice = usePrice
        ? effectivePackagesData!.price!.toDouble()
        : (effectivePackagesData?.effectivePrice?.toDouble() ??
        widget.apiResponse.rate?.effectivePrice?.toDouble() ?? 0.0);

    // Store the effective price for display and payment calculations
    _effectivePrice = effectivePackagesData?.effectivePrice?.toDouble() ??
        widget.apiResponse.rate?.effectivePrice?.toDouble() ?? 0.0;

    // Check if asset type is desk
    final isDesk = widget.apiResponse.assetType?.title?.toLowerCase() == 'desk';

    // Calculate business days (excluding Sundays)
    final numberOfDays = dateTimeRanges.isNotEmpty ? dateTimeRanges.length : 1;

    // Get package information for rate type (use effective packages if available)
    dynamic package;
    if (effectivePackagesData?.packages?.isNotEmpty == true) {
      package = effectivePackagesData!.packages.first;
    } else if (widget.apiResponse.rate?.packages?.isNotEmpty == true) {
      package = widget.apiResponse.rate!.packages?.first;
    }

    num totalAmount = 0;

    // Safe way to get duration unit
    String? durationUnit;
    if (package != null) {
      if (package is EffectivePackage) {
        durationUnit = package.duration.unit.toLowerCase();
      } else {
        durationUnit = package.duration?.unit?.toString().split('.').last.toLowerCase();
      }
    }

    print("=== PRICE CALCULATION WITH STATE ===");
    print("Package duration unit: $durationUnit");
    print("StartDate: $startDate, EndDate: $endDate");
    print("Date ranges count: ${dateTimeRanges.length}");
    print("Has time selected: $hasTimeSelected");
    print("Is desk: $isDesk");
    print("Desk counter: $_deskCounter");
    print("Display price: $displayPrice");
    print("Effective price: $_effectivePrice");

    // Handle hourly rate calculation ONLY if time is actually selected by user
    if (durationUnit == 'hour' && hasTimeSelected) {
      final totalHours = endDate.difference(startDate).inHours.clamp(1, 24);

      print("Total calculated hours: $totalHours");

      // Calculate display price (the one shown to users) based on price
      totalAmount = isDesk ?
      totalHours * _deskCounter * displayPrice :
      totalHours * displayPrice;

      // Calculate effective price (the one actually used for payment)
      _totalEffectiveAmount = isDesk ?
      totalHours * _deskCounter * _effectivePrice :
      totalHours * _effectivePrice;
    }
    // For daily rates or when NO time is selected (date-only booking)
    else {
      print("Using daily rate calculation (no specific time selected or daily rate)");

      // Calculate display price based on daily rate
      totalAmount = isDesk ?
      numberOfDays * _deskCounter * displayPrice :
      numberOfDays * displayPrice;

      // Calculate effective price
      _totalEffectiveAmount = isDesk ?
      numberOfDays * _deskCounter * _effectivePrice :
      numberOfDays * _effectivePrice;
    }

    // Only show discounted price when price is different from effectivePrice
    _showDiscount = usePrice && _effectivePrice < displayPrice;

    print("Final calculated total amount: $totalAmount");
    print("Effective amount: $_totalEffectiveAmount");
    print("Show discount: $_showDiscount");
    print("=====================================");

    return totalAmount;
  }

  Widget _buildWorkspaceDetail(BuildContext context, WorkspaceDetailLoaded state) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section
                _buildImageSection(state),
                SizedBox(height: 20),

                // Location and description
                _buildLocationAndDescription(state),
                SizedBox(height: 20),

                // Collapsible sections
                _buildCollapsibleSections(state),
                SizedBox(height: 280),
              ],
            ),
          ),
        ),

        // Bottom section with pricing
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildBottomSection(context, state),
        ),
      ],
    );
  }

  Widget _buildImageSection(WorkspaceDetailLoaded state) {
    final images = state.asset.images ?? [];
    if (images.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.grey[300],
        ),
        child: Icon(Icons.image, size: 50, color: Colors.grey[600]),
      );
    }

    return Container(
      height: 200,
      child: PageView.builder(
        itemCount: images.length,
        onPageChanged: (index) => setState(() => _currentImageIndex = index),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Image.network(
              state.asset.thumbnail?.path ?? 'https://via.placeholder.com/150',
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: Icon(Icons.error, size: 50),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationAndDescription(WorkspaceDetailLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${state.asset.branch?.name ?? ''}, ${state.asset.branch?.address?.name ?? ''}",
          overflow: TextOverflow.fade,
          softWrap: true,
        ),
        SizedBox(height: 10),
        Text(
          "About the Workspace",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        AnimatedSize(
          duration: Duration(milliseconds: 200),
          child: ConstrainedBox(
            constraints: state.isExpanded
                ? BoxConstraints()
                : BoxConstraints(maxHeight: 65),
            child: Text(
              state.asset.branch?.description ?? 'No description available',
              overflow: TextOverflow.fade,
              softWrap: true,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _workspaceDetailBloc.add(ToggleDescription()),
          child: Text(
            state.isExpanded ? 'Show less' : 'Read more',
            style: TextStyle(color: Colors.blue),
          ),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.star, color: Theme.of(context).primaryColor, size: 12),
            SizedBox(width: 4),
            Text(state.asset.branch?.averageRating?.toString() ?? 'N/A'),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => ReviewBloc(ReviewRepository()),
                      child: ReviewPage(branchId: state.asset.branch?.id ?? ''),
                    ),
                  ),
                );
              },
              child: Text(
                ' review(s)',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCollapsibleSections(WorkspaceDetailLoaded state) {
    return Column(
      children: [
        // Amenities section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Amenities",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(_isAmenitiesExpanded ? Icons.remove : Icons.add),
              onPressed: () {
                setState(() {
                  _isAmenitiesExpanded = !_isAmenitiesExpanded;
                });
              },
            ),
          ],
        ),
        if (_isAmenitiesExpanded) buildAmenitiesList(state.asset.aminities ?? []),
        SizedBox(height: 20),

        // Operating Hours section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Operating Hours",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(_isOHExpanded ? Icons.remove : Icons.add),
              onPressed: () {
                setState(() {
                  _isOHExpanded = !_isOHExpanded;
                });
              },
            ),
          ],
        ),
        if (_isOHExpanded) _buildOperatingHours(state.asset.branch?.openingHours),
        SizedBox(height: 20),

        // Package details - pass the state and force rebuild with key
        Container(
          key: ValueKey('package_details_${state.effectivePackagesData?.packages?.length ?? 0}_${state.effectivePackagesData?.effectivePrice ?? 0}'),
          child: _buildPackageDetails(state),
        ),
      ],
    );
  }

  Widget _buildBottomSection(BuildContext context, WorkspaceDetailLoaded state) {
    final isDesk = widget.apiResponse.assetType?.title?.toLowerCase() == 'desk';

    print("=== BUILDING BOTTOM SECTION ===");
    print("Current _totalPrice: $_totalPrice");
    print("Current _totalEffectiveAmount: $_totalEffectiveAmount");
    print("Current _showDiscount: $_showDiscount");
    print("Current hasTimeSelected: $hasTimeSelected");
    print("State effective packages: ${state.effectivePackagesData != null}");
    if (state.effectivePackagesData != null) {
      print("State packages count: ${state.effectivePackagesData!.packages.length}");
      print("State effective price: ${state.effectivePackagesData!.effectivePrice}");
    }
    print("==============================");

    return Container(
      key: ValueKey('bottom_section_${_totalPrice}_${_showDiscount}_${hasTimeSelected}'),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 2),
            blurRadius: 6.0,
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Price and date section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show original price with strikethrough if there's a discount
                if (_showDiscount)
                  Text(
                    NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(_totalPrice),
                    key: ValueKey('original_price_$_totalPrice'),
                    style: TextStyle(
                      fontSize: 14,
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey[600],
                    ),
                  ),
                // Show the effective price (actual payment amount)
                Text(
                  _showDiscount
                      ? NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(_totalEffectiveAmount)
                      : NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(_totalPrice),
                  key: ValueKey('effective_price_${_showDiscount ? _totalEffectiveAmount : _totalPrice}'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _showDiscount ? Colors.green[700] : Colors.black,
                  ),
                ),

                // Date and time display - conditional based on hasTimeSelected
                GestureDetector(
                  onTap: () => _showSelectDateWidget(context),
                  child: Row(
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Always show date range
                            Text(
                              '${DateFormat('dd MMM').format(startDate)} - ${DateFormat('dd MMM').format(endDate)}',
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                            // Only show time if it was actually selected by user
                            if (hasTimeSelected)
                              Text(
                                '${DateFormat('h:mm a').format(startDate)} - ${DateFormat('h:mm a').format(endDate)}',
                                style: TextStyle(color: Colors.blueAccent, fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.blueAccent,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Desk counter for desk assets ONLY
          if (isDesk)
            Row(
              children: [
                IconButton(
                  onPressed: _deskCounter > 1 ? () {
                    setState(() {
                      _deskCounter--;
                      _totalPrice = calculateTotalPrice().toDouble();
                    });
                  } : null,
                  icon: Icon(Icons.remove),
                  iconSize: 20,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _deskCounter.toString(),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _deskCounter++;
                      _totalPrice = calculateTotalPrice().toDouble();
                    });
                  },
                  icon: Icon(Icons.add),
                  iconSize: 20,
                ),
              ],
            ),

          // Add some spacing if not a desk
          if (!isDesk) SizedBox(width: 16),

          // Booking button
          ElevatedButton(
            onPressed: () => _handleBooking(context, state),
            child: Text(
              'Select & Continue',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBooking(BuildContext context, WorkspaceDetailLoaded state) async {
    bool isLoggedIn = await _checkLoginStatus();
    if (!isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => LoginBloc(),
            child: LoginConfirmationScreen(
              apiResponse: widget.apiResponse,
              index: widget.index,
              selectedDate: widget.selectedDate,
              selectedEndDate: widget.selectedEndDate,
              selectedStartTime: widget.selectedStartTime,
              selectedEndTime: widget.selectedEndTime,
            ),
          ),
        ),
      );
      return;
    }

    final priceToPass = _showDiscount ? _totalEffectiveAmount : _totalPrice;

    // Proceed to booking confirmation
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScreenHomeConfirmation(
          totalPrice: priceToPass,
          selectedDate: startDate.toString(),
          selectedEndDate: endDate.toString(),
          dateTimeRanges: dateTimeRanges,
          assetId: widget.apiResponse.availableItems?.items?.isNotEmpty == true
              ? widget.apiResponse.availableItems!.items![0].assets![0].id!
              : '',
          familyId: widget.apiResponse.familyId ?? '',
          assetName: widget.apiResponse.familyTitle ?? '',
          deskCounter: _deskCounter.toString(),
          availableItems: widget.apiResponse.availableItems?.items ?? [],
          assetType: widget.apiResponse.assetType?.title ?? '',
        ),
      ),
    );
  }

  Widget buildAmenitiesList(List<String> amenities) {
    if (amenities.isNotEmpty) {
      return Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: amenities.map((amenity) {
          String displayText = amenity
              .split(RegExp(r'[_\s-]'))
              .map((word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : '')
              .join(' ');

          IconData iconData = _getAmenityIcon(amenity);

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                child: Icon(
                  iconData,
                  size: 16,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: 4),
              Text(
                displayText,
                style: TextStyle(fontSize: 12),
              ),
            ],
          );
        }).toList(),
      );
    } else {
      return Text("No amenities available");
    }
  }

  IconData _getAmenityIcon(String amenity) {
    final String lowercaseAmenity = amenity.toLowerCase();

    if (lowercaseAmenity.contains('wifi')) {
      return Icons.wifi;
    } else if (lowercaseAmenity.contains('hdmi')) {
      return Icons.connected_tv;
    } else if (lowercaseAmenity.contains('mike') || lowercaseAmenity.contains('mic')) {
      return Icons.mic;
    } else if (lowercaseAmenity.contains('pantry') || lowercaseAmenity.contains('kitchen')) {
      return Icons.kitchen;
    } else if (lowercaseAmenity.contains('speaker')) {
      return Icons.speaker;
    } else if (lowercaseAmenity.contains('sport')) {
      return Icons.sports;
    } else if (lowercaseAmenity.contains('projector')) {
      return Icons.videocam;
    } else if (lowercaseAmenity.contains('printer')) {
      return Icons.print;
    } else if (lowercaseAmenity.contains('desk')) {
      return Icons.desk;
    } else if (lowercaseAmenity.contains('locker')) {
      return Icons.lock;
    } else if (lowercaseAmenity.contains('parking')) {
      return Icons.local_parking;
    } else if (lowercaseAmenity.contains('coffee')) {
      return Icons.coffee;
    } else {
      return Icons.check_circle_outline;
    }
  }

  // Updated to use effective packages data from bloc state with force refresh
  Widget _buildPackageDetails(WorkspaceDetailLoaded state) {
    print("=== BUILDING PACKAGE DETAILS ===");

    // Use effective packages data if available, otherwise fall back to original
    final effectivePackages = state.effectivePackagesData?.packages;
    final originalPackages = widget.apiResponse.rate?.packages;

    List<dynamic> packages = [];
    bool usingEffectivePackages = false;

    if (effectivePackages?.isNotEmpty == true) {
      packages = effectivePackages!;
      usingEffectivePackages = true;
      print("Using effective packages: ${packages.length} packages");
    } else if (originalPackages?.isNotEmpty == true) {
      packages = originalPackages!;
      print("Using original packages: ${packages.length} packages");
    }

    print("Total packages to display: ${packages.length}");
    print("Using effective packages: $usingEffectivePackages");

    if (packages.isEmpty) {
      print("No packages available to display");
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            setState(() {
              _isPackageExpanded = !_isPackageExpanded;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Available packages',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(width: 4),
              Icon(
                _isPackageExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 16,
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
        if (_isPackageExpanded) ...[
          const SizedBox(height: 6),
          // Add timestamp for debugging
          if (usingEffectivePackages)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                'Last updated: ${DateFormat('HH:mm:ss').format(DateTime.now())}',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.grey[500],
                ),
              ),
            ),
          // FIXED: Force rebuild with unique keys and state-based rendering
          Container(
            key: ValueKey('packages_${state.effectivePackagesData?.packages?.length ?? 0}_${DateTime.now().millisecondsSinceEpoch}'),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: packages.map((package) {
                // Handle both EffectivePackage and original Package types
                String name;
                double rate;
                String durationUnit;
                int durationValue;
                bool isEffectivePackage = package is EffectivePackage;

                if (isEffectivePackage) {
                  final effectivePackage = package as EffectivePackage;
                  name = effectivePackage.name;
                  rate = effectivePackage.rate;
                  durationUnit = effectivePackage.duration.unit;
                  durationValue = effectivePackage.duration.value;
                } else {
                  // Original Package type - access properties safely
                  name = package.name ?? '';
                  rate = package.rate?.toDouble() ?? 0.0;
                  durationUnit = package.duration?.unit?.toString().split('.').last.toLowerCase() ?? 'hour';
                  durationValue = package.duration?.value ?? 1;
                }

                final duration = '$durationValue $durationUnit${durationValue > 1 ? "s" : ""}';

                print("Rendering package: $name, rate: $rate, duration: $duration, isEffective: $isEffectivePackage");

                return Container(
                  key: ValueKey('${isEffectivePackage ? 'effective' : 'original'}_${name}_${rate}_${DateTime.now().millisecondsSinceEpoch}'),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: isEffectivePackage ? Colors.green[100] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                    border: isEffectivePackage
                        ? Border.all(color: Colors.green[300]!, width: 1)
                        : null,
                  ),
                  child: Text(
                    '$name (₹${rate.toStringAsFixed(0)}/$duration)',
                    style: TextStyle(
                      fontSize: 11,
                      color: isEffectivePackage ? Colors.green[700] : Colors.grey[700],
                      fontWeight: isEffectivePackage ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOperatingHours(List<OpeningHour>? openingHours) {
    if (openingHours == null || openingHours.isEmpty) {
      return Container();
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListView.separated(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: openingHours.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey.shade200,
        ),
        itemBuilder: (context, index) {
          final hours = openingHours[index];
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  capitalize(hours.day!),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: hours.isOpen! ? FontWeight.w500 : FontWeight.w400,
                    color: hours.isOpen! ? Colors.black87 : Colors.grey,
                  ),
                ),
                Text(
                  hours.isOpen!
                      ? (hours.allDay! ? '24 Hours' : '${hours.from} - ${hours.to}')
                      : 'Closed',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: hours.isOpen!
                        ? (hours.allDay! ? Colors.green : Colors.black87)
                        : Colors.red,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  void dispose() {
    _workspaceDetailBloc.close();
    super.dispose();
  }
}
/*import 'package:hb_booking_mobile_app/authentication/bloc_login.dart';
import 'package:hb_booking_mobile_app/authentication/screen_login_confirmation.dart';
import 'package:hb_booking_mobile_app/booking/screen_booking.dart';
import 'package:hb_booking_mobile_app/connectivity/connectivity_bloc.dart';
import 'package:hb_booking_mobile_app/connectivity/connectivity_state.dart';
import 'package:hb_booking_mobile_app/home/model/model_assets.dart';
import 'package:hb_booking_mobile_app/home/workspcae_detail/event_workspacedetail.dart';
import 'package:hb_booking_mobile_app/home/workspcae_detail/state_workspacedetail.dart';
import 'package:hb_booking_mobile_app/home/workspcae_detail/widget_image_gallery.dart';
import 'package:hb_booking_mobile_app/home/workspcae_detail/workspace_reviews/review_repository.dart';
import 'package:hb_booking_mobile_app/home/workspcae_detail/workspace_reviews/reviews_bloc.dart';
import 'package:hb_booking_mobile_app/home/workspcae_detail/workspace_reviews/screen_reviews.dart';
import 'package:hb_booking_mobile_app/utils/colors.dart';
import 'package:hb_booking_mobile_app/utils/functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hb_booking_mobile_app/utils/is_loader.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../search/state_search.dart';

import 'bloc_workspacedetail.dart';

class WorkspaceDetailScreen extends StatefulWidget {
  final Datum apiResponse;
  final int index;
  final String? selectedDate;
  final String? selectedStartTime;
  final String? selectedEndTime;
  final String? selectedEndDate;

  const WorkspaceDetailScreen({
    Key? key,
    required this.apiResponse,
    required this.index,
    this.selectedDate,
    this.selectedStartTime,
    this.selectedEndTime,
    this.selectedEndDate,
  }) : super(key: key);

  @override
  State<WorkspaceDetailScreen> createState() => _WorkspaceDetailScreenState();
}

class _WorkspaceDetailScreenState extends State<WorkspaceDetailScreen> {
  bool _isAmenitiesExpanded = false;
  bool _isOHExpanded = false;
  bool _isPackageExpanded = false;
  int _currentImageIndex = 0;
  int _deskCounter = 1;
  double _totalPrice = 0.0;
  late DateTime startDate;
  late DateTime endDate;
  List<Map<String, String>> dateTimeRanges = [];
  bool containsSunday = false;
  late WorkspaceDetailBloc _workspaceDetailBloc;
  bool _showDiscount = false;
  double _effectivePrice = 0.0;
  double _totalEffectiveAmount = 0.0;

  // Track whether time is selected
  bool hasTimeSelected = false;

  @override
  void initState() {
    super.initState();
    _workspaceDetailBloc = WorkspaceDetailBloc();

    // Initialize from separate parameters
    String? startDateStr = widget.selectedDate;
    String? endDateStr = widget.selectedEndDate ?? widget.selectedDate;
    String? startTimeStr = widget.selectedStartTime;
    String? endTimeStr = widget.selectedEndTime;

    // Check if time is actually selected (both start and end time must be present and not default values)
    hasTimeSelected = startTimeStr != null &&
        endTimeStr != null &&
        startTimeStr.isNotEmpty &&
        endTimeStr.isNotEmpty &&
        startTimeStr != '00:00:00' &&
        endTimeStr != '00:00:00';

    print("=== INITIALIZATION DEBUG ===");
    print("selectedDate: $startDateStr");
    print("selectedEndDate: $endDateStr");
    print("selectedStartTime: $startTimeStr");
    print("selectedEndTime: $endTimeStr");
    print("hasTimeSelected: $hasTimeSelected");
    print("==========================");

    setState(() {
      if (startDateStr != null) {
        if (hasTimeSelected) {
          // With time - use the actual selected times
          startDate = DateTime.parse('${startDateStr}T$startTimeStr');
          endDate = DateTime.parse('${endDateStr}T$endTimeStr');
        } else {
          // Date only - NO DEFAULT TIMES, just use the date at midnight
          startDate = DateTime.parse('${startDateStr}T00:00:00');
          endDate = DateTime.parse('${endDateStr}T00:00:00');
        }
      } else {
        // No date provided - use current date at midnight (NO DEFAULT TIMES)
        final now = DateTime.now();
        startDate = DateTime(now.year, now.month, now.day, 0, 0, 0);
        endDate = DateTime(now.year, now.month, now.day, 0, 0, 0);
      }

      dateTimeRanges = splitDateRangeIgnoringSundays(startDate, endDate);
      _totalPrice = calculateTotalPrice().toDouble(); // Calculate initial price
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // FIXED: Pass the correct hasTimeSelected state during initialization
      _workspaceDetailBloc.add(InitializeWorkspaceDetail(
        apiResponse: widget.apiResponse,
        startDate: startDate,
        endDate: endDate,
        hasTimeSelected: hasTimeSelected, // Pass the actual time selection state
      ));
    });
  }

  void _onDateRangeUpdate(String isoStart, String isoEnd) {
    final newStartDate = DateTime.parse(isoStart);
    final newEndDate = DateTime.parse(isoEnd);

    print("=== DATE RANGE UPDATE DEBUG ===");
    print("Start: ${newStartDate.toString()} (${isoStart})");
    print("End: ${newEndDate.toString()} (${isoEnd})");

    // FIXED: Better detection of time selection
    final startTimeString = isoStart.split('T')[1];
    final endTimeString = isoEnd.split('T')[1];

    // FIXED: More comprehensive time detection
    final hasNewTimeSelected = (startTimeString != '00:00:00' || endTimeString != '00:00:00') &&
        startTimeString != '23:59:00' &&
        endTimeString != '23:59:00' &&
        startTimeString.isNotEmpty &&
        endTimeString.isNotEmpty;

    print("Time detection:");
    print("Start time string: $startTimeString");
    print("End time string: $endTimeString");
    print("Has new time selected (initial): $hasNewTimeSelected");

    // FIXED: Also check if the times are meaningful business hours
    bool isMeaningfulTime = false;
    if (hasNewTimeSelected) {
      final startHour = newStartDate.hour;
      final endHour = newEndDate.hour;

      // Consider it meaningful if it's not midnight or if hours are different
      isMeaningfulTime = (startHour != 0 || endHour != 0) &&
          (startHour != endHour || newStartDate.minute != newEndDate.minute);

      print("Start hour: $startHour, End hour: $endHour");
      print("Is meaningful time: $isMeaningfulTime");
    }

    final finalTimeSelected = hasNewTimeSelected && isMeaningfulTime;
    print("Final time selected: $finalTimeSelected");
    print("===============================");

    setState(() {
      startDate = newStartDate;
      endDate = newEndDate;
      hasTimeSelected = finalTimeSelected; // FIXED: Use the refined detection

      // Regenerate the date ranges with the updated time
      dateTimeRanges = splitDateRangeIgnoringSundays(startDate, endDate);

      print("Updated state variables:");
      print("startDate: ${startDate.toString()}");
      print("endDate: ${endDate.toString()}");
      print("hasTimeSelected: $hasTimeSelected");
      print("dateTimeRanges: $dateTimeRanges");
    });

    // FIXED: Clear cache before making new API call to ensure fresh data
    _workspaceDetailBloc.clearEffectivePackagesCache();

    // Update date range in bloc to fetch effective packages
    _workspaceDetailBloc.add(UpdateDateRange(
      startDate: newStartDate,
      endDate: newEndDate,
      hasTimeSelected: finalTimeSelected, // FIXED: Use the refined detection
    ));

    print("Dispatched UpdateDateRange event with hasTimeSelected: $finalTimeSelected");
  }

  // FIXED: Force refresh of effective packages when time selection changes
  void _onTimeSelectionToggle(bool enableTime) {
    print("Time selection toggle changed to: $enableTime");

    setState(() {
      hasTimeSelected = enableTime;

      // If disabling time, reset to midnight
      if (!enableTime) {
        startDate = DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0);
        endDate = DateTime(endDate.year, endDate.month, endDate.day, 0, 0, 0);
      } else {
        // If enabling time, set default business hours
        startDate = DateTime(startDate.year, startDate.month, startDate.day, 9, 0, 0);
        endDate = DateTime(endDate.year, endDate.month, endDate.day, 18, 0, 0);
      }

      // Regenerate date ranges
      dateTimeRanges = splitDateRangeIgnoringSundays(startDate, endDate);
    });

    // FIXED: Clear cache and force fresh API call
    _workspaceDetailBloc.clearEffectivePackagesCache();

    // Trigger effective packages refresh with new time selection state
    _workspaceDetailBloc.add(UpdateDateRange(
      startDate: startDate,
      endDate: endDate,
      hasTimeSelected: enableTime,
    ));

    print("Triggered effective packages refresh after time toggle");
  }

  // Updated price calculation to use effective packages data from state
  num calculateTotalPrice() {
    // Try to get effective packages data from bloc state
    EffectivePackagesData? effectivePackagesData;
    if (_workspaceDetailBloc.state is WorkspaceDetailLoaded) {
      final state = _workspaceDetailBloc.state as WorkspaceDetailLoaded;
      effectivePackagesData = state.effectivePackagesData;
    }

    // Use effective packages data if available, otherwise fall back to original data
    final usePrice = effectivePackagesData?.price != null && effectivePackagesData!.price! > 0;

    final displayPrice = usePrice
        ? effectivePackagesData!.price!.toDouble()
        : (effectivePackagesData?.effectivePrice?.toDouble() ??
        widget.apiResponse.rate?.effectivePrice?.toDouble() ?? 0.0);

    // Store the effective price for display and payment calculations
    _effectivePrice = effectivePackagesData?.effectivePrice?.toDouble() ??
        widget.apiResponse.rate?.effectivePrice?.toDouble() ?? 0.0;

    // Check if asset type is desk
    final isDesk = widget.apiResponse.assetType?.title?.toLowerCase() == 'desk';

    // Calculate business days (excluding Sundays)
    final numberOfDays = dateTimeRanges.isNotEmpty ? dateTimeRanges.length : 1;

    // Get package information for rate type (use effective packages if available)
    dynamic package;
    if (effectivePackagesData?.packages?.isNotEmpty == true) {
      package = effectivePackagesData!.packages.first;
    } else if (widget.apiResponse.rate?.packages?.isNotEmpty == true) {
      package = widget.apiResponse.rate!.packages?.first;
    }

    num totalAmount = 0;

    // Safe way to get duration unit
    String? durationUnit;
    if (package != null) {
      if (package is EffectivePackage) {
        durationUnit = package.duration.unit.toLowerCase();
      } else {
        durationUnit = package.duration?.unit?.toString().split('.').last.toLowerCase();
      }
    }

    print("Package duration unit: $durationUnit");
    print("StartDate: $startDate, EndDate: $endDate");
    print("Date ranges count: ${dateTimeRanges.length}");
    print("Has time selected: $hasTimeSelected");
    print("Is desk: $isDesk");
    print("Desk counter: $_deskCounter");
    print("Effective price from API: $_effectivePrice");

    // Handle hourly rate calculation ONLY if time is actually selected by user
    if (durationUnit == 'hour' && hasTimeSelected) {
      final totalHours = endDate.difference(startDate).inHours.clamp(1, 24);

      print("Total calculated hours: $totalHours");

      // Calculate display price (the one shown to users) based on price
      totalAmount = isDesk ?
      totalHours * _deskCounter * displayPrice :
      totalHours * displayPrice;

      // Calculate effective price (the one actually used for payment)
      _totalEffectiveAmount = isDesk ?
      totalHours * _deskCounter * _effectivePrice :
      totalHours * _effectivePrice;
    }
    // For daily rates or when NO time is selected (date-only booking)
    else {
      print("Using daily rate calculation (no specific time selected or daily rate)");

      // Calculate display price based on daily rate
      totalAmount = isDesk ?
      numberOfDays * _deskCounter * displayPrice :
      numberOfDays * displayPrice;

      // Calculate effective price
      _totalEffectiveAmount = isDesk ?
      numberOfDays * _deskCounter * _effectivePrice :
      numberOfDays * _effectivePrice;
    }

    // Only show discounted price when price is different from effectivePrice
    _showDiscount = usePrice && _effectivePrice < displayPrice;

    print("Final calculated total amount: $totalAmount");
    print("Effective amount: $_totalEffectiveAmount");
    print("Show discount: $_showDiscount");

    return totalAmount;
  }

  // Keep existing date range calculation
  List<Map<String, String>> splitDateRangeIgnoringSundays(DateTime startDate, DateTime endDate) {
    final ranges = <Map<String, String>>[];
    var currentDay = DateTime(startDate.year, startDate.month, startDate.day);
    containsSunday = false;

    // Calculate difference in days between start and end date and add 1 to include both days
    final daysDifference = endDate.difference(startDate).inDays + 1;

    for(int i = 0; i < daysDifference; i++) {
      if (currentDay.weekday == DateTime.sunday) {
        containsSunday = true;
      } else {
        if (hasTimeSelected) {
          // Preserve the actual selected hours and minutes
          ranges.add({
            'start': DateTime(
              currentDay.year,
              currentDay.month,
              currentDay.day,
              startDate.hour,
              startDate.minute,
            ).toIso8601String(),
            'end': DateTime(
              currentDay.year,
              currentDay.month,
              currentDay.day,
              endDate.hour,
              endDate.minute,
            ).toIso8601String(),
          });
        } else {
          // Date only - no specific times, use full day (00:00 to 23:59)
          ranges.add({
            'start': DateTime(
              currentDay.year,
              currentDay.month,
              currentDay.day,
              0,
              0,
            ).toIso8601String(),
            'end': DateTime(
              currentDay.year,
              currentDay.month,
              currentDay.day,
              23,
              59,
            ).toIso8601String(),
          });
        }
      }
      currentDay = currentDay.add(Duration(days: 1));
    }

    // Debug to verify time components
    for (var range in ranges) {
      print("Range: ${range['start']} to ${range['end']}");
    }

    return ranges;
  }

  void _showSelectDateWidget(BuildContext context) {
    print("Opening date/time picker with initial values:");
    print("Initial Start: ${startDate.toString()}");
    print("Initial End: ${endDate.toString()}");
    print("Has time selected: $hasTimeSelected");

    // Store the bloc reference before opening the modal
    final workspaceDetailBloc = context.read<WorkspaceDetailBloc>();

    // Extract initial date and time values from existing DateTime objects
    String initialStartDateStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    String? initialStartTimeStr;
    if (hasTimeSelected) {
      initialStartTimeStr = '${startDate.hour.toString().padLeft(2, '0')}:${startDate.minute.toString().padLeft(2, '0')}:${startDate.second.toString().padLeft(2, '0')}';
    }

    String initialEndDateStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
    String? initialEndTimeStr;
    if (hasTimeSelected) {
      initialEndTimeStr = '${endDate.hour.toString().padLeft(2, '0')}:${endDate.minute.toString().padLeft(2, '0')}:${endDate.second.toString().padLeft(2, '0')}';
    }

    // Variables to store selected values
    String? selectedStartDate = initialStartDateStr;
    String? selectedEndDate = initialEndDateStr;
    String? selectedStartTime = initialStartTimeStr;
    String? selectedEndTime = initialEndTimeStr;

    // Initialize enableTimeSelection based on whether time was previously selected
    bool enableTimeSelection = hasTimeSelected;

    print("Modal initialization:");
    print("enableTimeSelection: $enableTimeSelection");
    print("initialStartTimeStr: $initialStartTimeStr");
    print("initialEndTimeStr: $initialEndTimeStr");

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              child: BlocProvider.value(
                value: workspaceDetailBloc,
                child: SafeArea(
                  child: Column(
                    children: [
                      // Header with close button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Select Date & Time',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () => Navigator.pop(bottomSheetContext),
                            ),
                          ],
                        ),
                      ),

                      // SelectDateWidgetForDetail with proper state management
                      Expanded(
                        child: SelectDateWidgetForDetail(
                          key: ValueKey('date_widget_${enableTimeSelection}_${DateTime.now().millisecondsSinceEpoch}'),
                          step: BookingStep.selectDate,
                          initialStartDate: startDate,
                          initialEndDate: endDate,
                          initialStartTime: enableTimeSelection ? selectedStartTime : null,
                          initialEndTime: enableTimeSelection ? selectedEndTime : null,
                          showConfirmButton: false,
                          enableTimeSelection: enableTimeSelection,
                          onDateConfirm: (String startDateStr, String? endDateStr) {
                            print("Date confirmation callback received:");
                            print("startDate: $startDateStr");
                            print("endDate: $endDateStr");

                            setModalState(() {
                              selectedStartDate = startDateStr;
                              selectedEndDate = endDateStr;
                            });
                          },
                          onTimeConfirm: (String startTimeStr, String endTimeStr) {
                            print("Time confirmation callback received:");
                            print("startTime: $startTimeStr");
                            print("endTime: $endTimeStr");

                            setModalState(() {
                              selectedStartTime = startTimeStr;
                              selectedEndTime = endTimeStr;
                              enableTimeSelection = true;
                            });
                          },
                          onTimeDisabled: () {
                            print("Time disabled callback received - clearing time data");
                            setModalState(() {
                              selectedStartTime = null;
                              selectedEndTime = null;
                              enableTimeSelection = false;
                            });
                          },
                        ),
                      ),

                      // Custom confirm button at the bottom
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              String? isoStart;
                              String? isoEnd;

                              // FIXED: Better logic for time selection detection
                              bool hasActualTimeSelection = enableTimeSelection &&
                                  selectedStartTime != null &&
                                  selectedEndTime != null &&
                                  selectedStartTime!.isNotEmpty &&
                                  selectedEndTime!.isNotEmpty &&
                                  selectedStartTime != '00:00:00' &&
                                  selectedEndTime != '00:00:00';

                              if (hasActualTimeSelection) {
                                // Combine date and time to create ISO strings
                                isoStart = '${selectedStartDate}T$selectedStartTime';
                                isoEnd = '${selectedEndDate ?? selectedStartDate}T$selectedEndTime';
                                print("Creating ISO with time: $isoStart to $isoEnd");
                              } else {
                                // Date only - use minimal time (00:00:00) to indicate no specific time
                                isoStart = '${selectedStartDate}T00:00:00';
                                isoEnd = '${selectedEndDate ?? selectedStartDate}T00:00:00';
                                print("Creating ISO without time: $isoStart to $isoEnd");
                              }

                              print("Manual confirmation triggered:");
                              print("isoStart: $isoStart");
                              print("isoEnd: $isoEnd");
                              print("enableTimeSelection: $enableTimeSelection");
                              print("hasActualTimeSelection: $hasActualTimeSelection");
                              print("selectedStartTime: $selectedStartTime");
                              print("selectedEndTime: $selectedEndTime");

                              // Close the bottom sheet
                              Navigator.pop(bottomSheetContext);

                              // Update date range
                              if (isoStart != null && isoEnd != null) {
                                _onDateRangeUpdate(isoStart, isoEnd);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
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
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _workspaceDetailBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(capitalize(widget.apiResponse.familyTitle ?? 'Workspace')),
        ),
        body: BlocBuilder<ConnectivityBloc, ConnectivityState>(
          builder: (context, connectivityState) {
            if (connectivityState is DisconnectedState) {
              return _buildNoConnectionView();
            }

            return BlocConsumer<WorkspaceDetailBloc, WorkspaceDetailState>(
              listener: (context, state) {
                if (state is WorkspaceDetailLoaded) {
                  _handleEffectivePackagesUpdate(state);
                }
              },
              builder: (context, state) {
                if (state is WorkspaceDetailLoaded) {
                  return _buildWorkspaceDetail(context, state);
                } else if (state is WorkspaceDetailLoading) {
                  return Center(child: OfficeLoader());
                } else {
                  return Center(child: Text('Error loading workspace details'));
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildNoConnectionView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(65.0),
            child: Image.asset('assets/images/no_internet.png'),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  void _handleEffectivePackagesUpdate(WorkspaceDetailLoaded state) {
    setState(() {
      // Force recalculation of price with updated effective packages data
      _totalPrice = calculateTotalPrice().toDouble();

      // Update effective price from state if available
      if (state.effectivePackagesData?.effectivePrice != null) {
        _effectivePrice = state.effectivePackagesData!.effectivePrice!.toDouble();

        // Recalculate effective amount as well
        final isDesk = widget.apiResponse.assetType?.title?.toLowerCase() == 'desk';
        final numberOfDays = dateTimeRanges.isNotEmpty ? dateTimeRanges.length : 1;

        if (hasTimeSelected) {
          final totalHours = endDate.difference(startDate).inHours.clamp(1, 24);
          _totalEffectiveAmount = isDesk ? totalHours * _deskCounter * _effectivePrice : totalHours * _effectivePrice;
        } else {
          _totalEffectiveAmount = isDesk ? numberOfDays * _deskCounter * _effectivePrice : numberOfDays * _effectivePrice;
        }

        // Update discount flag
        final usePrice = state.effectivePackagesData?.price != null && state.effectivePackagesData!.price! > 0;
        final displayPrice = usePrice ? state.effectivePackagesData!.price!.toDouble() : _effectivePrice;
        _showDiscount = usePrice && _effectivePrice < displayPrice;
      }
    });

    print("Effective packages updated:");
    print("New total price: $_totalPrice");
    print("Effective price: $_effectivePrice");
    print("Total effective amount: $_totalEffectiveAmount");
    print("Show discount: $_showDiscount");
    print("Packages count: ${state.effectivePackagesData?.packages?.length ?? 0}");

    // Force UI rebuild to show updated packages
    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildWorkspaceDetail(BuildContext context, WorkspaceDetailLoaded state) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section
                _buildImageSection(state),
                SizedBox(height: 20),

                // Location and description
                _buildLocationAndDescription(state),
                SizedBox(height: 20),

                // Collapsible sections
                _buildCollapsibleSections(state),
                SizedBox(height: 280),
              ],
            ),
          ),
        ),

        // Bottom section with pricing
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildBottomSection(context, state),
        ),
      ],
    );
  }

  Widget _buildImageSection(WorkspaceDetailLoaded state) {
    final images = state.asset.images ?? [];
    if (images.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.grey[300],
        ),
        child: Icon(Icons.image, size: 50, color: Colors.grey[600]),
      );
    }

    return Container(
      height: 200,
      child: PageView.builder(
        itemCount: images.length,
        onPageChanged: (index) => setState(() => _currentImageIndex = index),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Image.network(
              state.asset.thumbnail?.path ?? 'https://via.placeholder.com/150',
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: Icon(Icons.error, size: 50),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationAndDescription(WorkspaceDetailLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${state.asset.branch?.name ?? ''}, ${state.asset.branch?.address?.name ?? ''}",
          overflow: TextOverflow.fade,
          softWrap: true,
        ),
        SizedBox(height: 10),
        Text(
          "About the Workspace",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        AnimatedSize(
          duration: Duration(milliseconds: 200),
          child: ConstrainedBox(
            constraints: state.isExpanded
                ? BoxConstraints()
                : BoxConstraints(maxHeight: 65),
            child: Text(
              state.asset.branch?.description ?? 'No description available',
              overflow: TextOverflow.fade,
              softWrap: true,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _workspaceDetailBloc.add(ToggleDescription()),
          child: Text(
            state.isExpanded ? 'Show less' : 'Read more',
            style: TextStyle(color: Colors.blue),
          ),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.star, color: Theme.of(context).primaryColor, size: 12),
            SizedBox(width: 4),
            Text(state.asset.branch?.averageRating?.toString() ?? 'N/A'),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => ReviewBloc(ReviewRepository()),
                      child: ReviewPage(branchId: state.asset.branch?.id ?? ''),
                    ),
                  ),
                );
              },
              child: Text(
                ' review(s)',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCollapsibleSections(WorkspaceDetailLoaded state) {
    return Column(
      children: [
        // Amenities section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Amenities",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(_isAmenitiesExpanded ? Icons.remove : Icons.add),
              onPressed: () {
                setState(() {
                  _isAmenitiesExpanded = !_isAmenitiesExpanded;
                });
              },
            ),
          ],
        ),
        if (_isAmenitiesExpanded) buildAmenitiesList(state.asset.aminities ?? []),
        SizedBox(height: 20),

        // Operating Hours section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Operating Hours",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(_isOHExpanded ? Icons.remove : Icons.add),
              onPressed: () {
                setState(() {
                  _isOHExpanded = !_isOHExpanded;
                });
              },
            ),
          ],
        ),
        if (_isOHExpanded) _buildOperatingHours(state.asset.branch?.openingHours),
        SizedBox(height: 20),

        // Package details - pass the state instead of just packages
        _buildPackageDetails(state),
      ],
    );
  }

  Widget _buildBottomSection(BuildContext context, WorkspaceDetailLoaded state) {
    final isDesk = widget.apiResponse.assetType?.title?.toLowerCase() == 'desk';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 2),
            blurRadius: 6.0,
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Price and date section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show original price with strikethrough if there's a discount
                if (_showDiscount)
                  Text(
                    NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(_totalPrice),
                    style: TextStyle(
                      fontSize: 14,
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey[600],
                    ),
                  ),
                // Show the effective price (actual payment amount)
                Text(
                  _showDiscount
                      ? NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(_totalEffectiveAmount)
                      : NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(_totalPrice),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _showDiscount ? Colors.green[700] : Colors.black,
                  ),
                ),

                // Date and time display - conditional based on hasTimeSelected
                GestureDetector(
                  onTap: () => _showSelectDateWidget(context),
                  child: Row(
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Always show date range
                            Text(
                              '${DateFormat('dd MMM').format(startDate)} - ${DateFormat('dd MMM').format(endDate)}',
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                            // Only show time if it was actually selected by user
                            if (hasTimeSelected)
                              Text(
                                '${DateFormat('h:mm a').format(startDate)} - ${DateFormat('h:mm a').format(endDate)}',
                                style: TextStyle(color: Colors.blueAccent, fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.blueAccent,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Desk counter for desk assets ONLY
          if (isDesk)
            Row(
              children: [
                IconButton(
                  onPressed: _deskCounter > 1 ? () {
                    setState(() {
                      _deskCounter--;
                      _totalPrice = calculateTotalPrice().toDouble();
                    });
                  } : null,
                  icon: Icon(Icons.remove),
                  iconSize: 20,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _deskCounter.toString(),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _deskCounter++;
                      _totalPrice = calculateTotalPrice().toDouble();
                    });
                  },
                  icon: Icon(Icons.add),
                  iconSize: 20,
                ),
              ],
            ),

          // Add some spacing if not a desk
          if (!isDesk) SizedBox(width: 16),

          // Booking button
          ElevatedButton(
            onPressed: () => _handleBooking(context, state),
            child: Text(
              'Select & Continue',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBooking(BuildContext context, WorkspaceDetailLoaded state) async {
    bool isLoggedIn = await _checkLoginStatus();
    if (!isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => LoginBloc(),
            child: LoginConfirmationScreen(
              apiResponse: widget.apiResponse,
              index: widget.index,
              selectedDate: widget.selectedDate,
              selectedEndDate: widget.selectedEndDate,
              selectedStartTime: widget.selectedStartTime,
              selectedEndTime: widget.selectedEndTime,
            ),
          ),
        ),
      );
      return;
    }

    final priceToPass = _showDiscount ? _totalEffectiveAmount : _totalPrice;

    // Proceed to booking confirmation
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScreenHomeConfirmation(
          totalPrice: priceToPass,
          selectedDate: startDate.toString(),
          selectedEndDate: endDate.toString(),
          dateTimeRanges: dateTimeRanges,
          assetId: widget.apiResponse.availableItems?.items?.isNotEmpty == true
              ? widget.apiResponse.availableItems!.items![0].assets![0].id!
              : '',
          familyId: widget.apiResponse.familyId ?? '',
          assetName: widget.apiResponse.familyTitle ?? '',
          deskCounter: _deskCounter.toString(),
          availableItems: widget.apiResponse.availableItems?.items ?? [],
          assetType: widget.apiResponse.assetType?.title ?? '',
        ),
      ),
    );
  }

  Widget buildAmenitiesList(List<String> amenities) {
    if (amenities.isNotEmpty) {
      return Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: amenities.map((amenity) {
          String displayText = amenity
              .split(RegExp(r'[_\s-]'))
              .map((word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : '')
              .join(' ');

          IconData iconData = _getAmenityIcon(amenity);

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                child: Icon(
                  iconData,
                  size: 16,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: 4),
              Text(
                displayText,
                style: TextStyle(fontSize: 12),
              ),
            ],
          );
        }).toList(),
      );
    } else {
      return Text("No amenities available");
    }
  }

  IconData _getAmenityIcon(String amenity) {
    final String lowercaseAmenity = amenity.toLowerCase();

    if (lowercaseAmenity.contains('wifi')) {
      return Icons.wifi;
    } else if (lowercaseAmenity.contains('hdmi')) {
      return Icons.connected_tv;
    } else if (lowercaseAmenity.contains('mike') || lowercaseAmenity.contains('mic')) {
      return Icons.mic;
    } else if (lowercaseAmenity.contains('pantry') || lowercaseAmenity.contains('kitchen')) {
      return Icons.kitchen;
    } else if (lowercaseAmenity.contains('speaker')) {
      return Icons.speaker;
    } else if (lowercaseAmenity.contains('sport')) {
      return Icons.sports;
    } else if (lowercaseAmenity.contains('projector')) {
      return Icons.videocam;
    } else if (lowercaseAmenity.contains('printer')) {
      return Icons.print;
    } else if (lowercaseAmenity.contains('desk')) {
      return Icons.desk;
    } else if (lowercaseAmenity.contains('locker')) {
      return Icons.lock;
    } else if (lowercaseAmenity.contains('parking')) {
      return Icons.local_parking;
    } else if (lowercaseAmenity.contains('coffee')) {
      return Icons.coffee;
    } else {
      return Icons.check_circle_outline;
    }
  }

  // Updated to use effective packages data from bloc state with force refresh
  Widget _buildPackageDetails(WorkspaceDetailLoaded state) {
    // Use effective packages data if available, otherwise fall back to original
    final effectivePackages = state.effectivePackagesData?.packages;
    final originalPackages = widget.apiResponse.rate?.packages;

    List<dynamic> packages = [];
    bool usingEffectivePackages = false;

    if (effectivePackages?.isNotEmpty == true) {
      packages = effectivePackages!;
      usingEffectivePackages = true;
      print("Using effective packages: ${packages.length} packages");
    } else if (originalPackages?.isNotEmpty == true) {
      packages = originalPackages!;
      print("Using original packages: ${packages.length} packages");
    }

    if (packages.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            setState(() {
              _isPackageExpanded = !_isPackageExpanded;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Available packages',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              // Show indicator if using updated effective packages
              if (usingEffectivePackages)
                Container(
                  margin: EdgeInsets.only(left: 4),
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Updated',
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              SizedBox(width: 4),
              Icon(
                _isPackageExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 16,
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
        if (_isPackageExpanded) ...[
          const SizedBox(height: 6),
          // Add timestamp for debugging
          if (usingEffectivePackages)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                'Last updated: ${DateFormat('HH:mm:ss').format(DateTime.now())}',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.grey[500],
                ),
              ),
            ),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: packages.map((package) {
              // Handle both EffectivePackage and original Package types
              String name;
              double rate;
              String durationUnit;
              int durationValue;
              bool isEffectivePackage = package is EffectivePackage;

              if (isEffectivePackage) {
                final effectivePackage = package as EffectivePackage;
                name = effectivePackage.name;
                rate = effectivePackage.rate;
                durationUnit = effectivePackage.duration.unit;
                durationValue = effectivePackage.duration.value;
              } else {
                // Original Package type - access properties safely
                name = package.name ?? '';
                rate = package.rate?.toDouble() ?? 0.0;
                durationUnit = package.duration?.unit?.toString().split('.').last.toLowerCase() ?? 'hour';
                durationValue = package.duration?.value ?? 1;
              }

              final duration = '$durationValue $durationUnit${durationValue > 1 ? "s" : ""}';

              return Container(
                key: ValueKey('${isEffectivePackage ? 'effective' : 'original'}_${name}_${rate}'),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: isEffectivePackage ? Colors.green[100] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                  border: isEffectivePackage
                      ? Border.all(color: Colors.green[300]!, width: 1)
                      : null,
                ),
                child: Text(
                  '$name (₹${rate.toStringAsFixed(0)}/$duration)',
                  style: TextStyle(
                    fontSize: 11,
                    color: isEffectivePackage ? Colors.green[700] : Colors.grey[700],
                    fontWeight: isEffectivePackage ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildOperatingHours(List<OpeningHour>? openingHours) {
    if (openingHours == null || openingHours.isEmpty) {
      return Container();
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListView.separated(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: openingHours.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey.shade200,
        ),
        itemBuilder: (context, index) {
          final hours = openingHours[index];
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  capitalize(hours.day!),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: hours.isOpen! ? FontWeight.w500 : FontWeight.w400,
                    color: hours.isOpen! ? Colors.black87 : Colors.grey,
                  ),
                ),
                Text(
                  hours.isOpen!
                      ? (hours.allDay! ? '24 Hours' : '${hours.from} - ${hours.to}')
                      : 'Closed',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: hours.isOpen!
                        ? (hours.allDay! ? Colors.green : Colors.black87)
                        : Colors.red,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  void dispose() {
    _workspaceDetailBloc.close();
    super.dispose();
  }
}*/


