import 'package:hb_booking_mobile_app/booking_steps.dart';
import 'package:hb_booking_mobile_app/bottom_navigation/landing_page.dart';
import 'package:hb_booking_mobile_app/home/bloc_home.dart';
import 'package:hb_booking_mobile_app/search/bloc_search.dart';
import 'package:hb_booking_mobile_app/search/state_search.dart';
import 'package:hb_booking_mobile_app/search/widgets/widget_asset.dart';
import 'package:hb_booking_mobile_app/search/widgets/widget_destination.dart';
import 'package:hb_booking_mobile_app/search/widgets/widget_select_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui'; // for ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../home/event_home.dart';
import '../home/home_screen.dart';
import 'event_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/*
class BookingSearchfieldScreen extends StatelessWidget {
  final void Function(String?, String?, String?, String?) onSearch;
  final String? location;
  final String? asset;
  final String? start;
  final String? end;

  const BookingSearchfieldScreen({
    Key? key,
    required this.onSearch,
    this.location,
    this.asset,
    this.start,
    this.end,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookingSearchBloc(),
      child: BlocBuilder<BookingSearchBloc, BookingSearchState>(
        builder: (context, state) {
          final textTheme = Theme.of(context).textTheme;

          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
            child: Scaffold(
              backgroundColor: Colors.white.withOpacity(0.5),
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                automaticallyImplyLeading: false,
                leading: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Workspaces',
                        style: textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                actions: const [SizedBox(width: 48.0)],
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          context.read<BookingSearchBloc>().add(const UpdateStep(BookingStep.selectDestination));
                        },
                        child: Hero(
                          tag: 'search',
                          child: SelectDestinationWidget(
                            step: state.step,
                            onSelect: (location) {
                              context.read<BookingSearchBloc>().add(SelectLocation(location));
                            },
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.read<BookingSearchBloc>().add(const UpdateStep(BookingStep.selectGuests));
                        },
                        child: SelectAssetWidget(
                          step: state.step,
                          onSelect: (asset) {
                            context.read<BookingSearchBloc>().add(SelectAsset(asset));
                          },
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.read<BookingSearchBloc>().add(const UpdateStep(BookingStep.selectDate));
                        },
                        child: SelectDateWidget(
                          step: state.step,
                          onConfirm: (start, end) {
                            context.read<BookingSearchBloc>().add(SelectDateRange(start, end));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: BottomAppBar(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                notchMargin: 0,
                color: Colors.white,
                surfaceTintColor: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        context.read<BookingSearchBloc>().add(ClearAll());
                      },
                      child: Text(
                        'Clear all',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () {
                        final state = context.read<BookingSearchBloc>().state;

                        // Trigger the search action
                        onSearch(state.selectedLocation, state.selectedAsset, state.isoStart, state.isoEnd);

                        // Navigate to MainScreen and pass the parameters
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => MainScreen(
                            selectedLocation: state.selectedLocation,
                            selectedAsset: state.selectedAsset,
                            isoStart: state.isoStart,
                            isoEnd: state.isoEnd,
                          ),
                        ));

                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.orange,
                        minimumSize: const Size(100, 56.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      icon: const Icon(Icons.search),
                      label: const Text('Search'),
                    ),




                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }


}
*/

class BookingSearchfieldScreen extends StatelessWidget {
  final void Function(String?, String?, String?, String?, String?, String?) onSearch;
  final String? location;
  final String? asset;
  final String? selectedDate;
  final String? selectedStartTime;
  final String? selectedEndTime;
  final String? selectedEndDate;

  const BookingSearchfieldScreen({
    Key? key,
    required this.onSearch,
    this.location,
    this.asset,
    this.selectedDate,
    this.selectedStartTime,
    this.selectedEndTime,
    this.selectedEndDate,
  }) : super(key: key);

  // Helper method to combine date and time into ISO string
  String? _combineDateTime(String? date, String? time) {
    if (date == null) return null;

    if (time != null) {
      return '${date}T$time';
    } else {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookingSearchBloc(),
      child: BlocBuilder<BookingSearchBloc, BookingSearchState>(
        builder: (context, state) {
          final textTheme = Theme.of(context).textTheme;

          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
            child: Scaffold(
              backgroundColor: Colors.white.withOpacity(0.5),
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                automaticallyImplyLeading: false,
                leading: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Workspaces',
                        style: textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                actions: const [SizedBox(width: 48.0)],
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          context.read<BookingSearchBloc>().add(const UpdateStep(BookingStep.selectDestination));
                        },
                        child: Hero(
                          tag: 'search',
                          child: SelectDestinationWidget(
                            step: state.step,
                            onSelect: (location) {
                              context.read<BookingSearchBloc>().add(SelectLocation(location));
                            },
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.read<BookingSearchBloc>().add(const UpdateStep(BookingStep.selectGuests));
                        },
                        child: SelectAssetWidget(
                          step: state.step,
                          onSelect: (asset) {
                            context.read<BookingSearchBloc>().add(SelectAsset(asset));
                          },
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.read<BookingSearchBloc>().add(const UpdateStep(BookingStep.selectDate));
                        },
                        child: SelectDateWidget(
                          step: state.step,
                          onDateConfirm: (startDate, endDate) {
                            context.read<BookingSearchBloc>().add(SelectDateRange(startDate, endDate));
                          },
                          onTimeConfirm: (startTime, endTime) {
                            context.read<BookingSearchBloc>().add(SelectTimeRange(startTime, endTime));
                          },
                          enableTimeSelection: true, // Enable time selection
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: BottomAppBar(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                notchMargin: 0,
                color: Colors.white,
                surfaceTintColor: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        context.read<BookingSearchBloc>().add(ClearAll());
                      },
                      child: Text(
                        'Clear all',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () {
                        final state = context.read<BookingSearchBloc>().state;

                        // Trigger the search action - pass null if time not selected
                        onSearch(
                            state.selectedLocation,
                            state.selectedAsset,
                            state.selectedDate,
                            state.selectedStartTime, // Can be null
                            state.selectedEndTime,   // Can be null
                            state.selectedEndDate
                        );

                        // Create ISO strings for MainScreen (backward compatibility)
                        final String? isoStart = _combineDateTime(state.selectedDate, state.selectedStartTime);
                        final String? isoEnd = _combineDateTime(state.selectedEndDate ?? state.selectedDate, state.selectedEndTime);

                        // Navigate to MainScreen with the expected parameters
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => MainScreen(
                            selectedLocation: state.selectedLocation,
                            selectedAsset: state.selectedAsset,
                            isoStart: isoStart,
                            isoEnd: isoEnd,
                          ),
                        ));
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.orange,
                        minimumSize: const Size(100, 56.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      icon: const Icon(Icons.search),
                      label: const Text('Search'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}







