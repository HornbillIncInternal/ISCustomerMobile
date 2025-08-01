import 'package:hb_booking_mobile_app/search/screen_booking_searchfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../home/bloc_home.dart';
import '../home/event_home.dart';

class AppBarr extends StatelessWidget implements PreferredSizeWidget {
  final String? selectedLocation;
  final String? selectedAsset;
  final String? selectedStart;
  final String? selectedEnd;

  const AppBarr({
    Key? key,
    this.selectedLocation,
    this.selectedAsset,
    this.selectedStart,
    this.selectedEnd,
  }) : super(key: key);

  static const tabs = [
    Tab(text: 'Conference', icon: Icon(Icons.meeting_room)),
    Tab(text: 'Desk', icon: Icon(Icons.desk)),
    Tab(text: 'Event space', icon: Icon(Icons.event)),
    Tab(text: 'Cabin', icon: Icon(Icons.cabin)),
    Tab(text: 'Workation', icon: Icon(Icons.workspace_premium)),
  ];

  static const topHeight = 90.0;
  static const bottomHeight = 72.0;

  @override
  Size get preferredSize => const Size.fromHeight(topHeight);

  // Helper method to split ISO datetime into date and time parts
  Map<String, String?> _splitDateTime(String? isoDateTime) {
    if (isoDateTime == null) {
      return {'date': null, 'time': null};
    }

    if (isoDateTime.contains('T')) {
      // Has time component
      final parts = isoDateTime.split('T');
      return {
        'date': parts[0],
        'time': parts.length > 1 ? parts[1] : null,
      };
    } else {
      // Date only
      return {'date': isoDateTime, 'time': null};
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 1,
      backgroundColor: Colors.white,
      toolbarHeight: topHeight,
      title: buildToolBar(context),
      //bottom: buildTabBar(context),
    );
  }

  Widget buildToolBar(BuildContext context) {
    return SizedBox(
      height: topHeight,
      child: Column(
        children: [
          Expanded(child: buildSearchBox(context)),
          const SizedBox(width: 16),
          // buildFilterButton(context),
          //  Container(
          //      child: Text("Save big with packages"))
        ],
      ),
    );
  }

  Widget buildSearchBox(BuildContext context) {
    // Check if selections have been made
    final hasSelections = selectedLocation != null && selectedStart != null && selectedEnd != null && selectedAsset != null;

    String formatDate(String isoDate) {
      // Handle both ISO datetime and date-only formats
      final dateOnly = isoDate.contains('T') ? isoDate.split('T')[0] : isoDate;
      final date = DateTime.parse(dateOnly);
      return DateFormat('d MMM').format(date);
    }

    final inputArea = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hasSelections ? selectedLocation! : 'Work space location?',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 4),
        Text(
          hasSelections
              ? '${formatDate(selectedStart!)} - ${formatDate(selectedEnd!)} '
              : 'Where · When · Workspace type',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: Colors.black54),
        ),
      ],
    );

    const decoration = ShapeDecoration(
      color: Colors.white,
      shape: StadiumBorder(
        side: BorderSide(color: Colors.black12),
      ),
      shadows: [
        BoxShadow(
          color: Color(0x0a000000),
          spreadRadius: 4,
          blurRadius: 8,
          offset: Offset(1, 1),
        ),
      ],
    );

    return GestureDetector(
      onTap: () {
        // Split the ISO datetime strings into separate date and time components
        final startParts = _splitDateTime(selectedStart);
        final endParts = _splitDateTime(selectedEnd);

        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => BookingSearchfieldScreen(
            // Pass the current values as initial values
            location: selectedLocation,
            asset: selectedAsset,
            selectedDate: startParts['date'],
            selectedStartTime: startParts['time'],
            selectedEndTime: endParts['time'],
            selectedEndDate: endParts['date'],
            // Updated onSearch callback with 6 parameters
            onSearch: (location, asset, selectedDate, selectedStartTime, selectedEndTime, selectedEndDate) {
              // Combine date and time back into ISO format for ExploreTabBloc
              String? isoStart;
              String? isoEnd;

              if (selectedDate != null) {
                if (selectedStartTime != null) {
                  isoStart = '${selectedDate}T$selectedStartTime';
                } else {
                  isoStart = selectedDate;
                }
              }

              if (selectedEndDate != null || selectedDate != null) {
                final endDate = selectedEndDate ?? selectedDate;
                if (selectedEndTime != null) {
                  isoEnd = '${endDate}T$selectedEndTime';
                } else {
                  isoEnd = endDate;
                }
              }

              // Handle the search callback with original format for ExploreTabBloc
              context.read<ExploreTabBloc>().add(
                InitializeExploreTabEvent(
                  selectedLocation: location,
                  selectedAsset: asset,
                  isoStart: isoStart,
                  isoEnd: isoEnd,
                ),
              );

              // Navigate back to the explore page
              Navigator.of(context).pop();
            },
          ),
        ));
      },
      child: Container(
        height: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: decoration,
        child: Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 12.0),
          child: Row(
            children: [
              const Icon(
                Icons.search,
                size: 24.0,
                color: Colors.black87,
              ),
              const SizedBox(width: 8),
              Expanded(child: inputArea),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFilterButton(BuildContext context) {
    return IconButton(
      onPressed: () {},
      color: Colors.black,
      icon: const Icon(Icons.tune_outlined),
    );
  }
}

/*
class AppBarr extends StatelessWidget implements PreferredSizeWidget {
  final String? selectedLocation;
  final String? selectedAsset;
  final String? selectedStart;
  final String? selectedEnd;

  const AppBarr({
    Key? key,
    this.selectedLocation,
    this.selectedAsset,
    this.selectedStart,
    this.selectedEnd,
  }) : super(key: key);

  static const tabs = [
    Tab(text: 'Conference', icon: Icon(Icons.meeting_room)),
    Tab(text: 'Desk', icon: Icon(Icons.desk)),
    Tab(text: 'Event space', icon: Icon(Icons.event)),
    Tab(text: 'Cabin', icon: Icon(Icons.cabin)),
    Tab(text: 'Workation', icon: Icon(Icons.workspace_premium)),
  ];

  static const topHeight = 90.0;
  static const bottomHeight = 72.0;

  @override
  Size get preferredSize => const Size.fromHeight(topHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 1,
      backgroundColor: Colors.white,
      toolbarHeight: topHeight,
      title: buildToolBar(context),
      //bottom: buildTabBar(context),
    );
  }

  Widget buildToolBar(BuildContext context) {
    return SizedBox(
      height: topHeight,
      child: Column(
        children: [
          Expanded(child: buildSearchBox(context)),
          const SizedBox(width: 16),
         // buildFilterButton(context),
         //  Container(
         //      child: Text("Save big with packages"))
        ],
      ),
    );
  }
  Widget buildSearchBox(BuildContext context) {
    // Check if selections have been made
    final hasSelections = selectedLocation != null && selectedStart != null && selectedEnd != null && selectedAsset != null;

    String formatDate(String isoDate) {
      final date = DateTime.parse(isoDate);
      return DateFormat('d MMM').format(date);
    }

    final inputArea = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hasSelections ? selectedLocation! : 'Work space location?',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 4),
        Text(
          hasSelections
              ? '${formatDate(selectedStart!)} - ${formatDate(selectedEnd!)} '
              : 'Where · When · Workspace type',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: Colors.black54),
        ),
      ],
    );

    const decoration = ShapeDecoration(
      color: Colors.white,
      shape: StadiumBorder(
        side: BorderSide(color: Colors.black12),
      ),
      shadows: [
        BoxShadow(
          color: Color(0x0a000000),
          spreadRadius: 4,
          blurRadius: 8,
          offset: Offset(1, 1),
        ),
      ],
    );

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => BookingSearchfieldScreen(
            onSearch: (location, asset, start, end) {
              // Handle the search callback
              context.read<ExploreTabBloc>().add(
                InitializeExploreTabEvent(
                  selectedLocation: location,
                  selectedAsset: asset,
                  isoStart: start,
                  isoEnd: end,
                ),
              );

              // Navigate back to the explore page
              Navigator.of(context).pop();
            },
          ),
        ));
      },
      child: Container(
        height: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: decoration,
        child: Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 12.0),
          child: Row(
            children: [
              const Icon(
                Icons.search,
                size: 24.0,
                color: Colors.black87,
              ),
              const SizedBox(width: 8),
              Expanded(child: inputArea),
            ],
          ),
        ),
      ),
    );
  }



  Widget buildFilterButton(BuildContext context) {
    return IconButton(
      onPressed: () {},
      color: Colors.black,
      icon: const Icon(Icons.tune_outlined),
    );
  }
}
*/




