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
import '../../search/widgets/widget_select_date.dart';
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
  int _currentImageIndex = 0;
  int _deskCounter = 1;
  double _totalPrice = 0.0;
  late DateTime startDate;
  late DateTime endDate;
  List<Map<String, String>> dateTimeRanges = [];
  bool containsSunday = false;
  AvailableItems? currentAvailableItems;
  late WorkspaceDetailBloc _workspaceDetailBloc;
  bool _showDiscount = false;
  double _effectivePrice = 0.0;
  double _totalEffectiveAmount = 0.0;

  // Store the latest availability data for passing to booking confirmation
  AvailabilityData? latestAvailabilityData;

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

    // Check if time is actually selected (both start and end time must be present)
    hasTimeSelected = startTimeStr != null && endTimeStr != null;

    print("Initializing WorkspaceDetailScreen:");
    print("selectedDate: $startDateStr");
    print("selectedEndDate: $endDateStr");
    print("selectedStartTime: $startTimeStr");
    print("selectedEndTime: $endTimeStr");
    print("hasTimeSelected: $hasTimeSelected");

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
      _workspaceDetailBloc.add(InitializeWorkspaceDetail(
        apiResponse: widget.apiResponse,
        startDate: startDate,
        endDate: endDate,
      ));
    });
  }

  void _onDateRangeUpdate(String isoStart, String isoEnd) {
    final newStartDate = DateTime.parse(isoStart);
    final newEndDate = DateTime.parse(isoEnd);

    print("Date range update called with:");
    print("Start: ${newStartDate.toString()} (${isoStart})");
    print("End: ${newEndDate.toString()} (${isoEnd})");

    // Check if the new selection has meaningful time components (not default 00:00:00)
    final hasNewTimeSelected = isoStart.contains('T') &&
        isoStart.split('T')[1] != '00:00:00' &&
        isoEnd.contains('T') &&
        isoEnd.split('T')[1] != '00:00:00';

    setState(() {
      startDate = newStartDate;
      endDate = newEndDate;
      hasTimeSelected = hasNewTimeSelected;

      // Regenerate the date ranges with the updated time
      dateTimeRanges = splitDateRangeIgnoringSundays(startDate, endDate);

      // Force recalculation of the total price with the new time range
      _totalPrice = calculateTotalPrice().toDouble();

      print("Updated state variables:");
      print("startDate: ${startDate.toString()}");
      print("endDate: ${endDate.toString()}");
      print("hasTimeSelected: $hasTimeSelected");
      print("dateTimeRanges: $dateTimeRanges");
      print("_totalPrice: $_totalPrice");
    });

    // Fetch availability data and update available count
    final assetId = widget.apiResponse.availableItems?.items?.isNotEmpty == true
        ? widget.apiResponse.availableItems!.items![0].assets![0].id!
        : '';

    if (assetId.isNotEmpty) {
      _workspaceDetailBloc.add(FetchAvailabilityAndUpdate(
        assetId: assetId,
        startDate: newStartDate,
        endDate: newEndDate,
        hasTimeSelected: hasNewTimeSelected, // Pass the time selection status
      ));
    }
  }

  // Keep your existing complex price calculation method
  num calculateTotalPrice() {
    // Get price from the asset's rate (use price if available, otherwise use effectivePrice)
    final usePrice = widget.apiResponse.rate?.price != null && widget.apiResponse.rate!.price! > 0;

    final displayPrice = usePrice ?
    widget.apiResponse.rate!.price!.toDouble() :
    widget.apiResponse.rate!.effectivePrice!.toDouble();

    // Check if asset type is desk
    final isDesk = widget.apiResponse.assetType?.title?.toLowerCase() == 'desk';

    // Calculate business days (excluding Sundays)
    final numberOfDays = dateTimeRanges.isNotEmpty ? dateTimeRanges.length : 1;

    // Get package information for rate type
    final package = widget.apiResponse.rate?.packages?.isNotEmpty == true ?
    widget.apiResponse.rate!.packages?.first : null;

    // Store the effective price for display
    _effectivePrice = widget.apiResponse.rate!.effectivePrice!.toDouble();

    // Calculate total amount
    num totalAmount = 0;

    print("Package duration unit: ${package?.duration?.unit}");
    print("StartDate: $startDate, EndDate: $endDate");
    print("Date ranges count: ${dateTimeRanges.length}");
    print("Has time selected: $hasTimeSelected");
    print("Is desk: $isDesk");
    print("Desk counter: $_deskCounter");
    print("Desk counter: ${package?.duration?.unit?.toString().toLowerCase()}");

    // Handle hourly rate calculation ONLY if time is actually selected by user
    if (package?.duration?.unit?.toString().toLowerCase() == 'unit.hour') {
      int totalHours = 0;

      for (var dateRange in dateTimeRanges) {
        final start = DateTime.parse(dateRange['start']!);
        final end = DateTime.parse(dateRange['end']!);

        print("Processing range: ${start.toString()} to ${end.toString()}");

        // Get weekday (0 = Monday, 6 = Sunday)
        final weekday = start.weekday % 7;

        // Find the operating hours for this weekday from the branch
        AOpeningHour? dayHours;
        if (_workspaceDetailBloc.state is WorkspaceDetailLoaded) {
          final state = _workspaceDetailBloc.state as WorkspaceDetailLoaded;
          if (latestAvailabilityData?.data?.isNotEmpty == true) {
            dayHours = latestAvailabilityData!.data.first.branch.openingHours.firstWhere(
                  (hours) => hours.day.toLowerCase() == _getWeekdayName(weekday).toLowerCase(),
              orElse: () => AOpeningHour(
                day: _getWeekdayName(weekday),
                isOpen: false,
                allDay: false,
                from: '',
                to: '',
              ),
            );
          }
        }

        // If branch is closed on this day, skip
        if (dayHours?.isOpen == false) continue;

        // If the branch has all-day (24 hours) operations
        if (dayHours?.allDay == true) {
          final hourDiff = end.difference(start).inHours;
          totalHours += hourDiff;
          print("All-day branch hours. Adding $hourDiff hours");
          continue;
        }

        // Parse branch operating hours
        DateTime? branchOpen;
        DateTime? branchClose;

        if (dayHours?.from != null && dayHours?.to != null) {
          try {
            final fromTime = TimeOfDay.fromDateTime(DateFormat('HH:mm').parse(dayHours!.from!));
            final toTime = TimeOfDay.fromDateTime(DateFormat('HH:mm').parse(dayHours!.to!));

            branchOpen = DateTime(start.year, start.month, start.day,
                fromTime.hour, fromTime.minute);
            branchClose = DateTime(start.year, start.month, start.day,
                toTime.hour, toTime.minute);

            // Adjust if branch closes next day
            if (branchClose.isBefore(branchOpen)) {
              branchClose = branchClose.add(Duration(days: 1));
            }

            print("Branch hours: ${branchOpen.toString()} to ${branchClose.toString()}");
          } catch (e) {
            print("Error parsing branch hours: $e");
            // Fallback to default working hours if parsing fails
            branchOpen = DateTime(start.year, start.month, start.day, 9, 0);
            branchClose = DateTime(start.year, start.month, start.day, 18, 0);
          }
        } else {
          // Default operating hours (9 AM to 6 PM)
          branchOpen = DateTime(start.year, start.month, start.day, 9, 0);
          branchClose = DateTime(start.year, start.month, start.day, 18, 0);
        }

        // Calculate the overlapping hours between booking and branch operating hours
        DateTime effectiveStart = start.isAfter(branchOpen) ? start : branchOpen;
        DateTime effectiveEnd = end.isBefore(branchClose) ? end : branchClose;

        // Only count hours if there is a valid time range
        if (effectiveEnd.isAfter(effectiveStart)) {
          int hours = effectiveEnd.difference(effectiveStart).inHours;
          totalHours += hours;
          print("Added $hours hours from effective range ${effectiveStart.toString()} to ${effectiveEnd.toString()}");
        } else {
          print("No valid time range: ${effectiveStart.toString()} to ${effectiveEnd.toString()}");
        }
      }

      print("Total calculated hours: $totalHours");

      // Calculate display price (the one shown to users) based on price
      // Multiply by desk counter if it's a desk asset
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
      // Multiply by desk counter if it's a desk asset
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

  String _getWeekdayName(int weekday) {
    const weekdays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return weekdays[weekday];
  }

  // Keep your existing date range calculation
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
    String? initialStartDateStr;
    String? initialEndDateStr;
    String? initialStartTimeStr;
    String? initialEndTimeStr;

    if (startDate != null) {
      initialStartDateStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      if (hasTimeSelected) {
        initialStartTimeStr = '${startDate.hour.toString().padLeft(2, '0')}:${startDate.minute.toString().padLeft(2, '0')}:${startDate.second.toString().padLeft(2, '0')}';
      }
    }

    if (endDate != null) {
      initialEndDateStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
      if (hasTimeSelected) {
        initialEndTimeStr = '${endDate.hour.toString().padLeft(2, '0')}:${endDate.minute.toString().padLeft(2, '0')}:${endDate.second.toString().padLeft(2, '0')}';
      }
    }

    // Variables to store selected values
    String? selectedStartDate = initialStartDateStr;
    String? selectedEndDate = initialEndDateStr;
    String? selectedStartTime = initialStartTimeStr;
    String? selectedEndTime = initialEndTimeStr;
    bool enableTimeSelection = hasTimeSelected; // Initialize based on current state

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
                value: workspaceDetailBloc, // Use the stored bloc reference
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



                      // SelectDateWidget with conditional time selection - Wrapped in Expanded
                      Expanded(
                        child: SelectDateWidget(
                          step: BookingStep.selectDate,
                          initialStartDate: startDate,
                          initialEndDate: endDate,
                          initialStartTime: enableTimeSelection ? initialStartTimeStr : null,
                          initialEndTime: enableTimeSelection ? initialEndTimeStr : null,
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
                          onTimeConfirm: enableTimeSelection ? (String startTimeStr, String endTimeStr) {
                            print("Time confirmation callback received:");
                            print("startTime: $startTimeStr");
                            print("endTime: $endTimeStr");

                            setModalState(() {
                              selectedStartTime = startTimeStr;
                              selectedEndTime = endTimeStr;
                            });
                          } : null,
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

                              if (enableTimeSelection && selectedStartTime != null && selectedEndTime != null) {
                                // Combine date and time to create ISO strings
                                isoStart = '${selectedStartDate}T$selectedStartTime';
                                isoEnd = '${selectedEndDate ?? selectedStartDate}T$selectedEndTime';
                              } else {
                                // Date only - use minimal time (00:00:00) to indicate no specific time
                                isoStart = '${selectedStartDate}T00:00:00';
                                isoEnd = '${selectedEndDate ?? selectedStartDate}T00:00:00';
                              }

                              print("Manual confirmation triggered:");
                              print("isoStart: $isoStart");
                              print("isoEnd: $isoEnd");
                              print("enableTimeSelection: $enableTimeSelection");

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
                  _handleAvailabilityUpdate(state);
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

  void _handleAvailabilityUpdate(WorkspaceDetailLoaded state) {
    final availableCount = state.availableCount;

    setState(() {
      if (_deskCounter > availableCount && availableCount > 0) {
        _deskCounter = availableCount;
      }
      _totalPrice = calculateTotalPrice().toDouble();
    });

    // Fetch the latest availability data to store for booking
    _fetchLatestAvailabilityData();
  }

  // Method to fetch and store latest availability data
  Future<void> _fetchLatestAvailabilityData() async {
    try {
      final assetId = widget.apiResponse.assetType?.id ?? '';

      if (assetId.isNotEmpty) {
        final availabilityData = await _workspaceDetailBloc.fetchAvailabilityDataOptimized(
          assetId: assetId,
          start: startDate.toIso8601String(),
          end: endDate.toIso8601String(),
          hasTimeSelected: hasTimeSelected,
        );

        setState(() {
          latestAvailabilityData = availabilityData;
        });

        print("Stored latest availability data with ${availabilityData.data.length} assets and ${availabilityData.availableItemsCount} total slots");
      }
    } catch (e) {
      print('Error fetching latest availability data: $e');
    }
  }

  Widget _buildWorkspaceDetail(BuildContext context, WorkspaceDetailLoaded state) {
    final availableCount = state.availableCount;

    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section (optimized)
                _buildImageSection(state),
                SizedBox(height: 20),

                // Availability indicator
                _buildAvailabilityIndicator(availableCount),
                SizedBox(height: 10),

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

        // Bottom section with your existing price calculation
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

  Widget _buildAvailabilityIndicator(int availableCount) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: availableCount > 0 ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: availableCount > 0 ? Colors.green[200]! : Colors.red[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            availableCount > 0 ? Icons.check_circle : Icons.error,
            size: 16,
          ),
          SizedBox(width: 8),
          Text(
            availableCount > 0
                ? "Available: $availableCount"
                : "Not available for selected time",
            style: TextStyle(
              color: availableCount > 0 ? Colors.green[700] : Colors.red[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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

        // Package details
        _buildPackageDetails(widget.apiResponse.rate?.packages),
      ],
    );
  }
  Widget _buildBottomSection(BuildContext context, WorkspaceDetailLoaded state) {
    final availableCount = state.availableCount;
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
                  onPressed: availableCount > 0 && _deskCounter > 1 ? () {
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
                  onPressed: availableCount > 0 && _deskCounter < availableCount ? () {
                    setState(() {
                      _deskCounter++;
                      _totalPrice = calculateTotalPrice().toDouble();
                    });
                  } : null,
                  icon: Icon(Icons.add),
                  iconSize: 20,
                ),
              ],
            ),

          // Add some spacing if not a desk
          if (!isDesk) SizedBox(width: 16),

          // Booking button - disabled when availableCount is 0
          ElevatedButton(
            onPressed: availableCount > 0 ? () => _handleBooking(context, state, availableCount) : null,
            child: Text(
              availableCount > 0 ? 'Select & Continue' : 'Not Available',
              style: TextStyle(
                color: availableCount > 0 ? Colors.white : Colors.grey[600],
                fontSize: 14,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: availableCount > 0 ? Theme.of(context).primaryColor : Colors.grey[300],
              disabledBackgroundColor: Colors.grey[300],
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
/*  Widget _buildBottomSection(BuildContext context, WorkspaceDetailLoaded state) {
    final availableCount = state.availableCount;

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

          // Desk counter for desk assets
          if (state.asset.assetType?.title?.toLowerCase() == 'desk')
            Row(
              children: [
                IconButton(
                  onPressed: availableCount > 0 && _deskCounter > 1 ? () {
                    setState(() {
                      _deskCounter--;
                      _totalPrice = calculateTotalPrice().toDouble();
                    });
                  } : null,
                  icon: Icon(Icons.remove),
                ),
                Text(
                  _deskCounter.toString(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: availableCount > 0 && _deskCounter < availableCount ? () {
                    setState(() {
                      _deskCounter++;
                      _totalPrice = calculateTotalPrice().toDouble();
                    });
                  } : null,
                  icon: Icon(Icons.add),
                ),
              ],
            ),

          // Booking button - disabled when availableCount is 0
          ElevatedButton(
            onPressed: availableCount > 0 ? () => _handleBooking(context, state, availableCount) : null,
            child: Text(
              availableCount > 0 ? 'Select & Continue' : 'Not Available',
              style: TextStyle(
                color: availableCount > 0 ? Colors.white : Colors.grey[600],
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: availableCount > 0 ? Theme.of(context).primaryColor : Colors.grey[300],
              disabledBackgroundColor: Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }*/

  Future<void> _handleBooking(BuildContext context, WorkspaceDetailLoaded state, int availableCount) async {
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

    // Use the available count from state for validation
    if (availableCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Assets not available in selected date range")),
      );
      return;
    }

    if (_deskCounter > availableCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Only $availableCount assets available")),
      );
      setState(() {
        _deskCounter = availableCount;
      });
      return;
    }

    // Ensure we have the latest availability data
    if (latestAvailabilityData == null) {
      await _fetchLatestAvailabilityData();
    }

    final priceToPass = _showDiscount ? _totalEffectiveAmount : _totalPrice;

    // Proceed to booking confirmation with slots data
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
          assetType:widget.apiResponse.assetType?.title??'' ,
        ),
      ),
    );
  }

  Widget buildAmenitiesList(List<String> amenities) {
    print("Amenities input type: ${amenities.runtimeType}");
    print("Amenities content: $amenities");

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

  bool _isPackageExpanded = false;

  Widget _buildPackageDetails(List<Package>? packages) {
    if (packages == null || packages.isEmpty) {
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
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: packages.map((package) {
              final duration = '${package.duration?.value ?? 1} ${package.duration?.unit?.toString().split('.').last.toLowerCase() ?? 'hour'}${(package.duration?.value ?? 1) > 1 ? "s" : ""}';

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${package.name} (₹${package.rate}/${duration})',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[700],
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
                  capitalize(hours.day ?? ''),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: (hours.isOpen ?? false) ? FontWeight.w500 : FontWeight.w400,
                    color: (hours.isOpen ?? false) ? Colors.black87 : Colors.grey,
                  ),
                ),
                Text(
                  (hours.isOpen ?? false)
                      ? ((hours.allDay ?? false) ? '24 Hours' : '${hours.from} - ${hours.to}')
                      : 'Closed',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: (hours.isOpen ?? false)
                        ? ((hours.allDay ?? false) ? Colors.green : Colors.black87)
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

/*
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
  int _currentImageIndex = 0;
  int _deskCounter = 1;
  double _totalPrice = 0.0;
  late DateTime startDate;
  late DateTime endDate;
  List<Map<String, String>> dateTimeRanges = [];
  bool containsSunday = false;
  AvailableItems? currentAvailableItems;
  late WorkspaceDetailBloc _workspaceDetailBloc;
  bool _showDiscount = false;
  double _effectivePrice = 0.0;
  double _totalEffectiveAmount = 0.0;

  // Store the latest availability data for passing to booking confirmation
  AvailabilityData? latestAvailabilityData;

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

    // Check if time is actually selected (both start and end time must be present)
    hasTimeSelected = startTimeStr != null && endTimeStr != null;

    print("Initializing WorkspaceDetailScreen:");
    print("selectedDate: $startDateStr");
    print("selectedEndDate: $endDateStr");
    print("selectedStartTime: $startTimeStr");
    print("selectedEndTime: $endTimeStr");
    print("hasTimeSelected: $hasTimeSelected");

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
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _workspaceDetailBloc.add(InitializeWorkspaceDetail(
        apiResponse: widget.apiResponse,
        startDate: startDate,
        endDate: endDate,
      ));
    });
  }

  void _onDateRangeUpdate(String isoStart, String isoEnd) {
    final newStartDate = DateTime.parse(isoStart);
    final newEndDate = DateTime.parse(isoEnd);

    print("Date range update called with:");
    print("Start: ${newStartDate.toString()} (${isoStart})");
    print("End: ${newEndDate.toString()} (${isoEnd})");

    // Check if the new selection has meaningful time components (not default 00:00:00)
    final hasNewTimeSelected = isoStart.contains('T') &&
        isoStart.split('T')[1] != '00:00:00' &&
        isoEnd.contains('T') &&
        isoEnd.split('T')[1] != '00:00:00';

    setState(() {
      startDate = newStartDate;
      endDate = newEndDate;
      hasTimeSelected = hasNewTimeSelected;

      // Regenerate the date ranges with the updated time
      dateTimeRanges = splitDateRangeIgnoringSundays(startDate, endDate);

      // Force recalculation of the total price with the new time range
      _totalPrice = calculateTotalPrice().toDouble();

      print("Updated state variables:");
      print("startDate: ${startDate.toString()}");
      print("endDate: ${endDate.toString()}");
      print("hasTimeSelected: $hasTimeSelected");
      print("dateTimeRanges: $dateTimeRanges");
      print("_totalPrice: $_totalPrice");
    });

    // Fetch availability data and update available count
    _workspaceDetailBloc.add(FetchAvailabilityAndUpdate(
      assetId: widget.apiResponse.availableItems!.items![0].assets![0].id!,
      startDate: newStartDate,
      endDate: newEndDate,
      hasTimeSelected: hasNewTimeSelected, // Pass the time selection status
    ));
  }

  void _showSelectDateWidget(BuildContext context) {
    print("Opening date/time picker with initial values:");
    print("Initial Start: ${startDate.toString()}");
    print("Initial End: ${endDate.toString()}");
    print("Has time selected: $hasTimeSelected");

    // Store the bloc reference before opening the modal
    final workspaceDetailBloc = context.read<WorkspaceDetailBloc>();

    // Extract initial date and time values from existing DateTime objects
    String? initialStartDateStr;
    String? initialEndDateStr;
    String? initialStartTimeStr;
    String? initialEndTimeStr;

    if (startDate != null) {
      initialStartDateStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      if (hasTimeSelected) {
        initialStartTimeStr = '${startDate.hour.toString().padLeft(2, '0')}:${startDate.minute.toString().padLeft(2, '0')}:${startDate.second.toString().padLeft(2, '0')}';
      }
    }

    if (endDate != null) {
      initialEndDateStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
      if (hasTimeSelected) {
        initialEndTimeStr = '${endDate.hour.toString().padLeft(2, '0')}:${endDate.minute.toString().padLeft(2, '0')}:${endDate.second.toString().padLeft(2, '0')}';
      }
    }

    // Variables to store selected values
    String? selectedStartDate = initialStartDateStr;
    String? selectedEndDate = initialEndDateStr;
    String? selectedStartTime = initialStartTimeStr;
    String? selectedEndTime = initialEndTimeStr;
    bool enableTimeSelection = hasTimeSelected; // Initialize based on current state

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
                value: workspaceDetailBloc, // Use the stored bloc reference
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
                      Divider(),

                      // Time selection toggle
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
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
                              value: enableTimeSelection,
                              onChanged: (value) {
                                setModalState(() {
                                  enableTimeSelection = value;
                                  if (!value) {
                                    // Clear time selection when disabled
                                    selectedStartTime = null;
                                    selectedEndTime = null;
                                  } else {
                                    // Set default times when enabled
                                    selectedStartTime = '09:00:00';
                                    selectedEndTime = '18:00:00';
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      Divider(),

                      // SelectDateWidget with conditional time selection - Wrapped in Expanded
                      Expanded(
                        child: SingleChildScrollView(
                          child: SelectDateWidget(
                            step: BookingStep.selectDate,
                            initialStartDate: startDate,
                            initialEndDate: endDate,
                            initialStartTime: enableTimeSelection ? initialStartTimeStr : null,
                            initialEndTime: enableTimeSelection ? initialEndTimeStr : null,
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
                            onTimeConfirm: enableTimeSelection ? (String startTimeStr, String endTimeStr) {
                              print("Time confirmation callback received:");
                              print("startTime: $startTimeStr");
                              print("endTime: $endTimeStr");

                              setModalState(() {
                                selectedStartTime = startTimeStr;
                                selectedEndTime = endTimeStr;
                              });
                            } : null,
                          ),
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

                              if (enableTimeSelection && selectedStartTime != null && selectedEndTime != null) {
                                // Combine date and time to create ISO strings
                                isoStart = '${selectedStartDate}T$selectedStartTime';
                                isoEnd = '${selectedEndDate ?? selectedStartDate}T$selectedEndTime';
                              } else {
                                // Date only - use minimal time (00:00:00) to indicate no specific time
                                isoStart = '${selectedStartDate}T00:00:00';
                                isoEnd = '${selectedEndDate ?? selectedStartDate}T00:00:00';
                              }

                              print("Manual confirmation triggered:");
                              print("isoStart: $isoStart");
                              print("isoEnd: $isoEnd");
                              print("enableTimeSelection: $enableTimeSelection");

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

  Widget _buildBottomSection(BuildContext context, WorkspaceDetailLoaded state) {
    final availableCount = state.availableCount;

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
          Column(
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
                    Column(
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
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.blueAccent,
                      size: 16,
                    ),
                  ],
                ),
              )
            ],
          ),

          // Desk counter for desk assets
          if (state.asset.assetType!.title!.toLowerCase() == 'desk')
            Row(
              children: [
                IconButton(
                  onPressed: availableCount > 0 ? () {
                    setState(() {
                      if (_deskCounter > 1) {
                        _deskCounter--;
                        _totalPrice = calculateTotalPrice().toDouble();
                      }
                    });
                  } : null,
                  icon: Icon(Icons.remove),
                ),
                Text(
                  _deskCounter.toString(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: availableCount > 0 ? () {
                    if (_deskCounter < availableCount) {
                      setState(() {
                        _deskCounter++;
                        _totalPrice = calculateTotalPrice().toDouble();
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Maximum availability exceeded.")),
                      );
                    }
                  } : null,
                  icon: Icon(Icons.add),
                ),
              ],
            ),

          // Booking button - disabled when availableCount is 0
          ElevatedButton(
            onPressed: availableCount > 0 ? () => _handleBooking(context, state, availableCount) : null,
            child: Text(
              availableCount > 0 ? 'Select & Continue' : 'Not Available',
              style: TextStyle(
                color: availableCount > 0 ? Colors.white : Colors.grey[600],
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: availableCount > 0 ? Theme.of(context).primaryColor : Colors.grey[300],
              disabledBackgroundColor: Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }

  num calculateTotalPrice() {
    // Get price from the asset's rate (use price if available, otherwise use effectivePrice)
    final usePrice = widget.apiResponse.rate!.price! != null && widget.apiResponse.rate!.price! > 0;

    final displayPrice = usePrice ?
    widget.apiResponse.rate!.price!.toDouble() :
    widget.apiResponse.rate!.effectivePrice!.toDouble();

    final isDesk = widget.apiResponse.assetType?.title?.toLowerCase() == 'desk';

    // Calculate business days (excluding Sundays)
    final numberOfDays = dateTimeRanges.isNotEmpty ? dateTimeRanges.length : 1;

    // Get package information for rate type
    final package = widget.apiResponse.rate!.packages?.isNotEmpty == true ?
    widget.apiResponse.rate!.packages?.first : null;

    // Store the effective price for display
    _effectivePrice = widget.apiResponse.rate!.effectivePrice.toDouble();

    // Calculate total amount
    num totalAmount = 0;

    print("Package duration unit: ${package?.duration?.unit}");
    print("StartDate: $startDate, EndDate: $endDate");
    print("Date ranges count: ${dateTimeRanges.length}");
    print("Has time selected: $hasTimeSelected");

    // Handle hourly rate calculation ONLY if time is actually selected by user
    if (package?.duration?.unit?.toString().toLowerCase() == 'hour' && hasTimeSelected) {
      int totalHours = 0;

      for (var dateRange in dateTimeRanges) {
        final start = DateTime.parse(dateRange['start']!);
        final end = DateTime.parse(dateRange['end']!);

        print("Processing range: ${start.toString()} to ${end.toString()}");

        // Get weekday (0 = Monday, 6 = Sunday)
        final weekday = start.weekday % 7;

        // Find the operating hours for this weekday from the branch
        AOpeningHour? dayHours;
        if (_workspaceDetailBloc.state is WorkspaceDetailLoaded) {
          final state = _workspaceDetailBloc.state as WorkspaceDetailLoaded;
          dayHours = latestAvailabilityData!.data.first.branch.openingHours.firstWhere(
                (hours) => hours.day.toLowerCase() == _getWeekdayName(weekday).toLowerCase(),
            orElse: () => AOpeningHour(
              day: _getWeekdayName(weekday),
              isOpen: false,
              allDay: false,
              from: '',
              to: '',
            ),
          );
        }

        // If branch is closed on this day, skip
        if (dayHours?.isOpen == false) continue;

        // If the branch has all-day (24 hours) operations
        if (dayHours?.allDay == true) {
          final hourDiff = end.difference(start).inHours;
          totalHours += hourDiff;
          print("All-day branch hours. Adding $hourDiff hours");
          continue;
        }

        // Parse branch operating hours
        DateTime? branchOpen;
        DateTime? branchClose;

        if (dayHours?.from != null && dayHours?.to != null) {
          try {
            final fromTime = TimeOfDay.fromDateTime(DateFormat('HH:mm').parse(dayHours!.from!));
            final toTime = TimeOfDay.fromDateTime(DateFormat('HH:mm').parse(dayHours!.to!));

            branchOpen = DateTime(start.year, start.month, start.day,
                fromTime.hour, fromTime.minute);
            branchClose = DateTime(start.year, start.month, start.day,
                toTime.hour, toTime.minute);

            // Adjust if branch closes next day
            if (branchClose.isBefore(branchOpen)) {
              branchClose = branchClose.add(Duration(days: 1));
            }

            print("Branch hours: ${branchOpen.toString()} to ${branchClose.toString()}");
          } catch (e) {
            print("Error parsing branch hours: $e");
            // Fallback to default working hours if parsing fails
            branchOpen = DateTime(start.year, start.month, start.day, 9, 0);
            branchClose = DateTime(start.year, start.month, start.day, 18, 0);
          }
        } else {
          // Default operating hours (9 AM to 6 PM)
          branchOpen = DateTime(start.year, start.month, start.day, 9, 0);
          branchClose = DateTime(start.year, start.month, start.day, 18, 0);
        }

        // Calculate the overlapping hours between booking and branch operating hours
        DateTime effectiveStart = start.isAfter(branchOpen) ? start : branchOpen;
        DateTime effectiveEnd = end.isBefore(branchClose) ? end : branchClose;

        // Only count hours if there is a valid time range
        if (effectiveEnd.isAfter(effectiveStart)) {
          int hours = effectiveEnd.difference(effectiveStart).inHours;
          totalHours += hours;
          print("Added $hours hours from effective range ${effectiveStart.toString()} to ${effectiveEnd.toString()}");
        } else {
          print("No valid time range: ${effectiveStart.toString()} to ${effectiveEnd.toString()}");
        }
      }

      print("Total calculated hours: $totalHours");

      // Calculate display price (the one shown to users) based on price
      totalAmount = isDesk ? totalHours * _deskCounter * displayPrice : totalHours * displayPrice;

      // Calculate effective price (the one actually used for payment)
      _totalEffectiveAmount = isDesk ?
      totalHours * _deskCounter * _effectivePrice :
      totalHours * _effectivePrice;
    }
    // For daily rates or when NO time is selected (date-only booking)
    else {
      print("Using daily rate calculation (no specific time selected)");

      // Calculate display price based on daily rate
      totalAmount = isDesk ? numberOfDays * _deskCounter * displayPrice : numberOfDays * displayPrice;

      // Calculate effective price
      _totalEffectiveAmount = isDesk ?
      numberOfDays * _deskCounter * _effectivePrice :
      numberOfDays * _effectivePrice;
    }

    // Only show discounted price when price is different from effectivePrice
    _showDiscount = usePrice && _effectivePrice < displayPrice;

    print("Final calculated total amount: $totalAmount");
    print("Effective amount: $_totalEffectiveAmount");

    return totalAmount;
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return weekdays[weekday];
  }

  List<Map<String, String>> splitDateRangeIgnoringSundays(
      DateTime startDate, DateTime endDate) {
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

  @override
  void dispose() {
    _workspaceDetailBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _workspaceDetailBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(capitalize(widget.apiResponse!.familyTitle!) ?? 'Workspace'),
        ),
        body: BlocBuilder<ConnectivityBloc, ConnectivityState>(
          builder: (context, connectivityState) {
            if (connectivityState is DisconnectedState) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(45.0),
                      child: Image.asset('assets/images/no_internet.png'),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              );
            }

            return BlocConsumer<WorkspaceDetailBloc, WorkspaceDetailState>(
              listener: (context, state) {
                if (state is WorkspaceDetailLoaded) {
                  _handleAvailabilityUpdate(state);
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

  void _handleAvailabilityUpdate(WorkspaceDetailLoaded state) {
    final availableCount = state.availableCount;

    setState(() {
      if (_deskCounter > availableCount) {
        _deskCounter = availableCount > 0 ? availableCount : 1;
      }
      _totalPrice = calculateTotalPrice().toDouble();
    });

    // Fetch the latest availability data to store for booking
    _fetchLatestAvailabilityData();
  }

  // Method to fetch and store latest availability data
  Future<void> _fetchLatestAvailabilityData() async {
    try {
      final assetId =  widget.apiResponse.assetType!.id!;


      if (assetId.isNotEmpty) {
        final availabilityData = await _workspaceDetailBloc.fetchAvailabilityData(
          assetId: assetId,
          start: startDate.toIso8601String(),
          end: endDate.toIso8601String(),
          hasTimeSelected: hasTimeSelected,
        );

        setState(() {
          latestAvailabilityData = availabilityData;
        });

        print("Stored latest availability data with ${availabilityData.data!.length} assets and ${availabilityData.availableItemsCount} total slots");
      }
    } catch (e) {
      print('Error fetching latest availability data: $e');
    }
  }

  Widget _buildWorkspaceDetail(BuildContext context, WorkspaceDetailLoaded state) {
    final availableCount = state.availableCount;

    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageGalleryScreen(
                              images: state.asset!.images!,
                              initialIndex: _currentImageIndex,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 200,
                        child: PageView.builder(
                          itemCount: state.asset.images!.length!,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(15.0),
                              child: Image.network(
                                state.asset?.thumbnail?.path ??
                                    'https://via.placeholder.com/150',
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          state.asset.images!.length!,
                              (index) => Container(
                            margin: EdgeInsets.symmetric(horizontal: 2),
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == index
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Updated availability display with color coding
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: availableCount > 0 ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: availableCount > 0 ? Colors.green[200]! : Colors.red[200]!,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        availableCount > 0 ? Icons.check_circle : Icons.error,
                        // color: availableCount > 0 ? Colors.green[700] : Colors.red[700],
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        availableCount > 0
                            ? "Available: $availableCount"
                            : "Not available for selected time",
                        style: TextStyle(
                          color: availableCount > 0 ? Colors.green[700] : Colors.red[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10),
                Text(
                  "${state.asset.branch!.name!}, ${state.asset.branch!.address!.name!}",
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
                      state.asset.branch!.description! ??
                          'No description available',
                      overflow: TextOverflow.fade,
                      softWrap: true,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    context
                        .read<WorkspaceDetailBloc>()
                        .add(ToggleDescription());
                  },
                  child: Text(
                    state.isExpanded ? 'Show less' : 'Read more',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.star,
                        color: Theme.of(context).primaryColor, size: 12),
                    SizedBox(width: 4),
                    Text(
                        state.asset.branch?.averageRating?.toString() ?? 'N/A'),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider(
                                create: (context) => ReviewBloc(
                                  ReviewRepository(),
                                ),
                                child: ReviewPage(
                                    branchId: state.asset.branch!.id!),
                              ),
                            ),
                          );
                        },
                        child: Text(
                          ' review(s)',
                          style: TextStyle(color: Colors.blue),
                        )),
                  ],
                ),

                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Amenities",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon:
                      Icon(_isAmenitiesExpanded ? Icons.remove : Icons.add),
                      onPressed: () {
                        setState(() {
                          _isAmenitiesExpanded = !_isAmenitiesExpanded;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 0),
                if (_isAmenitiesExpanded)
                  buildAmenitiesList(state.asset.aminities!),

                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Operating Hours",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon:
                      Icon(_isOHExpanded ? Icons.remove : Icons.add),
                      onPressed: () {
                        setState(() {
                          _isOHExpanded = !_isOHExpanded;
                        });
                      },
                    ),
                  ],
                ),
                if(_isOHExpanded)
                  _buildOperatingHours(state.asset.branch?.openingHours),
                SizedBox(height: 20),
                _buildPackageDetails(widget.apiResponse.rate!.packages!),
                SizedBox(height: 280),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildBottomSection(context, state),
        ),
      ],
    );
  }

  Future<void> _handleBooking(BuildContext context, WorkspaceDetailLoaded state, int availableCount) async {
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

    // Use the available count from state for validation
    if (availableCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Assets not available in selected date range")),
      );
      return;
    }

    if (_deskCounter > availableCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Only $availableCount assets available")),
      );
      setState(() {
        _deskCounter = availableCount;
      });
      return;
    }

    // Ensure we have the latest availability data
    if (latestAvailabilityData == null) {
      await _fetchLatestAvailabilityData();
    }

    final priceToPass = _showDiscount ? _totalEffectiveAmount : _totalPrice;

    // Proceed to booking confirmation with slots data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScreenHomeConfirmation(
          totalPrice: priceToPass,
          selectedDate: startDate.toString(),
          selectedEndDate: endDate.toString(),
          dateTimeRanges: dateTimeRanges,
          assetId: widget.apiResponse!.availableItems!.items![0].assets![0].id!,
          familyId: widget.apiResponse.familyId!,
          assetName: widget.apiResponse.familyTitle!,
          deskCounter: _deskCounter.toString(),
          availableItems: widget.apiResponse.availableItems!.items!,
          // Pass the slots data from your API response
         // slotsData: latestAvailabilityData?.data ?? [],
        ),
      ),
    );
  }

  Widget buildAmenitiesList(List<String> amenities) {
    print("Amenities input type: ${amenities.runtimeType}");
    print("Amenities content: $amenities");

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

  bool _isPackageExpanded = false;

  Widget _buildPackageDetails(List<Package>? packages) {
    if (packages == null || packages.isEmpty) {
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
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: packages.map((package) {
              final duration = '${package.duration!.value!} ${package.duration!.unit!.toString().split('.').last.toLowerCase()}${package.duration!.value! > 1 ? "s" : ""}';

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${package.name} (₹${package.rate}/${duration})',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[700],
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
                  capitalize(hours.day.toString() ?? ''),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: hours.isOpen ?? false ? FontWeight.w500 : FontWeight.w400,
                    color: hours.isOpen ?? false ? Colors.black87 : Colors.grey,
                  ),
                ),
                Text(
                  hours.isOpen ?? false
                      ? (hours.allDay ?? false ? '24 Hours' : '${hours.from} - ${hours.to}')
                      : 'Closed',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: hours.isOpen ?? false
                        ? (hours.allDay ?? false ? Colors.green : Colors.black87)
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
}
*/



/*
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
  int _currentImageIndex = 0;
  int _deskCounter = 1;
  double _totalPrice = 0.0;
  late DateTime startDate;
  late DateTime endDate;
  List<Map<String, String>> dateTimeRanges = [];
  bool containsSunday = false;
  AvailableItems? currentAvailableItems;
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

    // Check if time is actually selected (both start and end time must be present)
    hasTimeSelected = startTimeStr != null && endTimeStr != null;

    print("Initializing WorkspaceDetailScreen:");
    print("selectedDate: $startDateStr");
    print("selectedEndDate: $endDateStr");
    print("selectedStartTime: $startTimeStr");
    print("selectedEndTime: $endTimeStr");
    print("hasTimeSelected: $hasTimeSelected");

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
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _workspaceDetailBloc.add(InitializeWorkspaceDetail(
        apiResponse: widget.apiResponse,
        startDate: startDate,
        endDate: endDate,
      ));
    });
  }

  void _onDateRangeUpdate(String isoStart, String isoEnd) {
    final newStartDate = DateTime.parse(isoStart);
    final newEndDate = DateTime.parse(isoEnd);

    print("Date range update called with:");
    print("Start: ${newStartDate.toString()} (${isoStart})");
    print("End: ${newEndDate.toString()} (${isoEnd})");

    // Check if the new selection has meaningful time components (not default 00:00:00)
    final hasNewTimeSelected = isoStart.contains('T') &&
        isoStart.split('T')[1] != '00:00:00' &&
        isoEnd.contains('T') &&
        isoEnd.split('T')[1] != '00:00:00';

    setState(() {
      startDate = newStartDate;
      endDate = newEndDate;
      hasTimeSelected = hasNewTimeSelected;

      // Regenerate the date ranges with the updated time
      dateTimeRanges = splitDateRangeIgnoringSundays(startDate, endDate);

      // Force recalculation of the total price with the new time range
      _totalPrice = calculateTotalPrice().toDouble();

      print("Updated state variables:");
      print("startDate: ${startDate.toString()}");
      print("endDate: ${endDate.toString()}");
      print("hasTimeSelected: $hasTimeSelected");
      print("dateTimeRanges: $dateTimeRanges");
      print("_totalPrice: $_totalPrice");
    });

    // Notify the bloc about the date change to update availability
    _workspaceDetailBloc.add(UpdateDateRange(
      startDate,
      endDate,
    ));
  }

  void _showSelectDateWidget(BuildContext context) {
    print("Opening date/time picker with initial values:");
    print("Initial Start: ${startDate.toString()}");
    print("Initial End: ${endDate.toString()}");
    print("Has time selected: $hasTimeSelected");

    // Store the bloc reference before opening the modal
    final workspaceDetailBloc = context.read<WorkspaceDetailBloc>();

    // Extract initial date and time values from existing DateTime objects
    String? initialStartDateStr;
    String? initialEndDateStr;
    String? initialStartTimeStr;
    String? initialEndTimeStr;

    if (startDate != null) {
      initialStartDateStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      if (hasTimeSelected) {
        initialStartTimeStr = '${startDate.hour.toString().padLeft(2, '0')}:${startDate.minute.toString().padLeft(2, '0')}:${startDate.second.toString().padLeft(2, '0')}';
      }
    }

    if (endDate != null) {
      initialEndDateStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
      if (hasTimeSelected) {
        initialEndTimeStr = '${endDate.hour.toString().padLeft(2, '0')}:${endDate.minute.toString().padLeft(2, '0')}:${endDate.second.toString().padLeft(2, '0')}';
      }
    }

    // Variables to store selected values
    String? selectedStartDate = initialStartDateStr;
    String? selectedEndDate = initialEndDateStr;
    String? selectedStartTime = initialStartTimeStr;
    String? selectedEndTime = initialEndTimeStr;
    bool enableTimeSelection = hasTimeSelected; // Initialize based on current state

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
                value: workspaceDetailBloc, // Use the stored bloc reference
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
                      Divider(),

                      // Time selection toggle
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
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
                              value: enableTimeSelection,
                              onChanged: (value) {
                                setModalState(() {
                                  enableTimeSelection = value;
                                  if (!value) {
                                    // Clear time selection when disabled
                                    selectedStartTime = null;
                                    selectedEndTime = null;
                                  } else {
                                    // Set default times when enabled
                                    selectedStartTime = '09:00:00';
                                    selectedEndTime = '18:00:00';
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      Divider(),

                      // SelectDateWidget with conditional time selection - Wrapped in Expanded
                      Expanded(
                        child: SingleChildScrollView(
                          child: SelectDateWidget(
                            step: BookingStep.selectDate,
                            initialStartDate: startDate,
                            initialEndDate: endDate,
                            initialStartTime: enableTimeSelection ? initialStartTimeStr : null,
                            initialEndTime: enableTimeSelection ? initialEndTimeStr : null,
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
                            onTimeConfirm: enableTimeSelection ? (String startTimeStr, String endTimeStr) {
                              print("Time confirmation callback received:");
                              print("startTime: $startTimeStr");
                              print("endTime: $endTimeStr");

                              setModalState(() {
                                selectedStartTime = startTimeStr;
                                selectedEndTime = endTimeStr;
                              });
                            } : null,
                          ),
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

                              if (enableTimeSelection && selectedStartTime != null && selectedEndTime != null) {
                                // Combine date and time to create ISO strings
                                isoStart = '${selectedStartDate}T$selectedStartTime';
                                isoEnd = '${selectedEndDate ?? selectedStartDate}T$selectedEndTime';
                              } else {
                                // Date only - use minimal time (00:00:00) to indicate no specific time
                                isoStart = '${selectedStartDate}T00:00:00';
                                isoEnd = '${selectedEndDate ?? selectedStartDate}T00:00:00';
                              }

                              print("Manual confirmation triggered:");
                              print("isoStart: $isoStart");
                              print("isoEnd: $isoEnd");
                              print("enableTimeSelection: $enableTimeSelection");

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

  Widget _buildBottomSection(BuildContext context, WorkspaceDetailLoaded state) {
    final availableCount = state.availableCount;

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
          Column(
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
                    Column(
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
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.blueAccent,
                      size: 16,
                    ),
                  ],
                ),
              )
            ],
          ),

          // Desk counter for desk assets
          if (state.asset.assetType!.title!.toLowerCase() == 'desk')
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (_deskCounter > 1) {
                        _deskCounter--;
                        _totalPrice = calculateTotalPrice().toDouble();
                      }
                    });
                  },
                  icon: Icon(Icons.remove),
                ),
                Text(
                  _deskCounter.toString(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () {
                    if (_deskCounter < availableCount) {
                      setState(() {
                        _deskCounter++;
                        _totalPrice = calculateTotalPrice().toDouble();
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Maximum availability exceeded.")),
                      );
                    }
                  },
                  icon: Icon(Icons.add),
                ),
              ],
            ),

          // Booking button
          ElevatedButton(
            onPressed: () => _handleBooking(context, state, availableCount),
            child: Text(
              'Select & Continue',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  num calculateTotalPrice() {
    // Get price from the asset's rate (use price if available, otherwise use effectivePrice)
    final usePrice = widget.apiResponse.rate!.price! != null && widget.apiResponse.rate!.price! > 0;

    final displayPrice = usePrice ?
    widget.apiResponse.rate!.price!.toDouble() :
    widget.apiResponse.rate!.effectivePrice!.toDouble();

    final isDesk = widget.apiResponse.assetType?.title?.toLowerCase() == 'desk';

    // Calculate business days (excluding Sundays)
    final numberOfDays = dateTimeRanges.isNotEmpty ? dateTimeRanges.length : 1;

    // Get package information for rate type
    final package = widget.apiResponse.rate!.packages?.isNotEmpty == true ?
    widget.apiResponse.rate!.packages?.first : null;

    // Store the effective price for display
    _effectivePrice = widget.apiResponse.rate!.effectivePrice.toDouble();

    // Calculate total amount
    num totalAmount = 0;

    print("Package duration unit: ${package?.duration?.unit}");
    print("StartDate: $startDate, EndDate: $endDate");
    print("Date ranges count: ${dateTimeRanges.length}");
    print("Has time selected: $hasTimeSelected");

    // Handle hourly rate calculation ONLY if time is actually selected by user
    if (package?.duration?.unit?.toString().toLowerCase() == 'hour' && hasTimeSelected) {
      int totalHours = 0;

      for (var dateRange in dateTimeRanges) {
        final start = DateTime.parse(dateRange['start']!);
        final end = DateTime.parse(dateRange['end']!);

        print("Processing range: ${start.toString()} to ${end.toString()}");

        // Get weekday (0 = Monday, 6 = Sunday)
        final weekday = start.weekday % 7;

        // Find the operating hours for this weekday from the branch
        OpeningHour? dayHours;
        if (_workspaceDetailBloc.state is WorkspaceDetailLoaded) {
          final state = _workspaceDetailBloc.state as WorkspaceDetailLoaded;
          dayHours = state.asset.branch?.openingHours?.firstWhere(
                (hours) => hours.day.toString().toLowerCase() ==
                _getWeekdayName(weekday).toLowerCase(),
            orElse: () => OpeningHour(),
          );
        }

        // If branch is closed on this day, skip
        if (dayHours?.isOpen == false) continue;

        // If the branch has all-day (24 hours) operations
        if (dayHours?.allDay == true) {
          final hourDiff = end.difference(start).inHours;
          totalHours += hourDiff;
          print("All-day branch hours. Adding $hourDiff hours");
          continue;
        }

        // Parse branch operating hours
        DateTime? branchOpen;
        DateTime? branchClose;

        if (dayHours?.from != null && dayHours?.to != null) {
          try {
            final fromTime = TimeOfDay.fromDateTime(DateFormat('HH:mm').parse(dayHours!.from!));
            final toTime = TimeOfDay.fromDateTime(DateFormat('HH:mm').parse(dayHours!.to!));

            branchOpen = DateTime(start.year, start.month, start.day,
                fromTime.hour, fromTime.minute);
            branchClose = DateTime(start.year, start.month, start.day,
                toTime.hour, toTime.minute);

            // Adjust if branch closes next day
            if (branchClose.isBefore(branchOpen)) {
              branchClose = branchClose.add(Duration(days: 1));
            }

            print("Branch hours: ${branchOpen.toString()} to ${branchClose.toString()}");
          } catch (e) {
            print("Error parsing branch hours: $e");
            // Fallback to default working hours if parsing fails
            branchOpen = DateTime(start.year, start.month, start.day, 9, 0);
            branchClose = DateTime(start.year, start.month, start.day, 18, 0);
          }
        } else {
          // Default operating hours (9 AM to 6 PM)
          branchOpen = DateTime(start.year, start.month, start.day, 9, 0);
          branchClose = DateTime(start.year, start.month, start.day, 18, 0);
        }

        // Calculate the overlapping hours between booking and branch operating hours
        DateTime effectiveStart = start.isAfter(branchOpen) ? start : branchOpen;
        DateTime effectiveEnd = end.isBefore(branchClose) ? end : branchClose;

        // Only count hours if there is a valid time range
        if (effectiveEnd.isAfter(effectiveStart)) {
          int hours = effectiveEnd.difference(effectiveStart).inHours;
          totalHours += hours;
          print("Added $hours hours from effective range ${effectiveStart.toString()} to ${effectiveEnd.toString()}");
        } else {
          print("No valid time range: ${effectiveStart.toString()} to ${effectiveEnd.toString()}");
        }
      }

      print("Total calculated hours: $totalHours");

      // Calculate display price (the one shown to users) based on price
      totalAmount = isDesk ? totalHours * _deskCounter * displayPrice : totalHours * displayPrice;

      // Calculate effective price (the one actually used for payment)
      _totalEffectiveAmount = isDesk ?
      totalHours * _deskCounter * _effectivePrice :
      totalHours * _effectivePrice;
    }
    // For daily rates or when NO time is selected (date-only booking)
    else {
      print("Using daily rate calculation (no specific time selected)");

      // Calculate display price based on daily rate
      totalAmount = isDesk ? numberOfDays * _deskCounter * displayPrice : numberOfDays * displayPrice;

      // Calculate effective price
      _totalEffectiveAmount = isDesk ?
      numberOfDays * _deskCounter * _effectivePrice :
      numberOfDays * _effectivePrice;
    }

    // Only show discounted price when price is different from effectivePrice
    _showDiscount = usePrice && _effectivePrice < displayPrice;

    print("Final calculated total amount: $totalAmount");
    print("Effective amount: $_totalEffectiveAmount");

    return totalAmount;
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return weekdays[weekday];
  }

  List<Map<String, String>> splitDateRangeIgnoringSundays(
      DateTime startDate, DateTime endDate) {
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

  @override
  void dispose() {
    _workspaceDetailBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _workspaceDetailBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(capitalize(widget.apiResponse!.familyTitle!) ?? 'Workspace'),
        ),
        body: BlocBuilder<ConnectivityBloc, ConnectivityState>(
          builder: (context, connectivityState) {
            if (connectivityState is DisconnectedState) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(45.0),
                      child: Image.asset('assets/images/no_internet.png'),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              );
            }

            return BlocConsumer<WorkspaceDetailBloc, WorkspaceDetailState>(
              listener: (context, state) {
                if (state is WorkspaceDetailLoaded) {
                  _handleAvailabilityUpdate(state);
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

  void _handleAvailabilityUpdate(WorkspaceDetailLoaded state) {
    final availableCount = state.availableCount;

    setState(() {
      if (_deskCounter > availableCount) {
        _deskCounter = availableCount;
      }
      _totalPrice = calculateTotalPrice().toDouble();
    });
  }

  Widget _buildWorkspaceDetail(BuildContext context, WorkspaceDetailLoaded state) {
    final availableCount = state.availableCount;

    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageGalleryScreen(
                              images: state.asset!.images!,
                              initialIndex: _currentImageIndex,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 200,
                        child: PageView.builder(
                          itemCount: state.asset.images!.length!,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(15.0),
                              child: Image.network(
                                state.asset?.thumbnail?.path ??
                                    'https://via.placeholder.com/150',
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          state.asset.images!.length!,
                              (index) => Container(
                            margin: EdgeInsets.symmetric(horizontal: 2),
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == index
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  "Available numbers: $availableCount",
                  overflow: TextOverflow.fade,
                  softWrap: true,
                ),
                SizedBox(height: 10),
                Text(
                  "${state.asset.branch!.name!}, ${state.asset.branch!.address!.name!}",
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
                      state.asset.branch!.description! ??
                          'No description available',
                      overflow: TextOverflow.fade,
                      softWrap: true,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    context
                        .read<WorkspaceDetailBloc>()
                        .add(ToggleDescription());
                  },
                  child: Text(
                    state.isExpanded ? 'Show less' : 'Read more',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.star,
                        color: Theme.of(context).primaryColor, size: 12),
                    SizedBox(width: 4),
                    Text(
                        state.asset.branch?.averageRating?.toString() ?? 'N/A'),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider(
                                create: (context) => ReviewBloc(
                                  ReviewRepository(),
                                ),
                                child: ReviewPage(
                                    branchId: state.asset.branch!.id!),
                              ),
                            ),
                          );
                        },
                        child: Text(
                          ' review(s)',
                          style: TextStyle(color: Colors.blue),
                        )),
                  ],
                ),

                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Amenities",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon:
                      Icon(_isAmenitiesExpanded ? Icons.remove : Icons.add),
                      onPressed: () {
                        setState(() {
                          _isAmenitiesExpanded = !_isAmenitiesExpanded;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 0),
                if (_isAmenitiesExpanded)
                  buildAmenitiesList(state.asset.aminities!),

                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Operating Hours",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon:
                      Icon(_isOHExpanded ? Icons.remove : Icons.add),
                      onPressed: () {
                        setState(() {
                          _isOHExpanded = !_isOHExpanded;
                        });
                      },
                    ),
                  ],
                ),
                if(_isOHExpanded)
                  _buildOperatingHours(state.asset.branch?.openingHours),
                SizedBox(height: 20),
                _buildPackageDetails(widget.apiResponse.rate!.packages!),
                SizedBox(height: 280),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildBottomSection(context, state),
        ),
      ],
    );
  }

  Future<void> _handleBooking(BuildContext context, WorkspaceDetailLoaded state, int availableCount) async {
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
              selectedDate:widget.selectedDate ,
              selectedEndDate: widget.selectedEndDate,
              selectedStartTime: widget.selectedStartTime,
              selectedEndTime: widget.selectedEndTime,

            ),
          ),
        ),
      );
      return;
    }

    // Use the available count from state for validation
    if (availableCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Assets not available in selected date range")),
      );
      return;
    }

    if (_deskCounter > availableCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Only $availableCount assets available")),
      );
      setState(() {
        _deskCounter = availableCount;
      });
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
          assetId: widget.apiResponse!.availableItems!.items![0].assets![0].id!,
          familyId: widget.apiResponse.familyId!,
          assetName: widget.apiResponse.familyTitle!,
          deskCounter: _deskCounter.toString(),
          availableItems: widget.apiResponse.availableItems!.items!,
        ),
      ),
    );
  }

  Widget buildAmenitiesList(List<String> amenities) {
    print("Amenities input type: ${amenities.runtimeType}");
    print("Amenities content: $amenities");

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

  bool _isPackageExpanded = false;

  Widget _buildPackageDetails(List<Package>? packages) {
    if (packages == null || packages.isEmpty) {
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
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: packages.map((package) {
              final duration = '${package.duration!.value!} ${package.duration!.unit!.toString().split('.').last.toLowerCase()}${package.duration!.value! > 1 ? "s" : ""}';

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${package.name} (₹${package.rate}/${duration})',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[700],
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
                  capitalize(hours.day.toString() ?? ''),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: hours.isOpen ?? false ? FontWeight.w500 : FontWeight.w400,
                    color: hours.isOpen ?? false ? Colors.black87 : Colors.grey,
                  ),
                ),
                Text(
                  hours.isOpen ?? false
                      ? (hours.allDay ?? false ? '24 Hours' : '${hours.from} - ${hours.to}')
                      : 'Closed',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: hours.isOpen ?? false
                        ? (hours.allDay ?? false ? Colors.green : Colors.black87)
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
}
*/






