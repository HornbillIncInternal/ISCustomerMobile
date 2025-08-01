import 'package:hb_booking_mobile_app/bookings/screen_booking.dart';
import 'package:hb_booking_mobile_app/home/home_screen.dart';
import 'package:hb_booking_mobile_app/profile/screen_profile.dart';
import 'package:hb_booking_mobile_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../home/bloc_home.dart';
import '../home/event_home.dart';
import 'bloc_nav.dart';


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreen extends StatelessWidget {
  final String? selectedLocation;
  final String? selectedAsset;
  final String? isoStart;
  final String? isoEnd;
  final int initialIndex;

  const MainScreen({
    Key? key,
    this.initialIndex = 0,
    this.selectedLocation,
    this.selectedAsset,
    this.isoStart,
    this.isoEnd,
  }) : super(key: key);

  // Helper method to split ISO datetime into date and time parts
  Map<String, String?> _splitDateTime(String? isoDateTime) {
    if (isoDateTime == null) {
      return {'date': null, 'time': null};
    }

    if (isoDateTime.contains('T')) {
      // Has time component: "2025-07-20T09:00:00"
      final parts = isoDateTime.split('T');
      return {
        'date': parts[0],      // "2025-07-20"
        'time': parts.length > 1 ? parts[1] : null,  // "09:00:00"
      };
    } else {
      // Date only: "2025-07-20"
      return {'date': isoDateTime, 'time': null};
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if the screen width is larger than 768px (typical tablet breakpoint)
    final bool isWebLayout = MediaQuery.of(context).size.width > 768;

    return MultiBlocProvider(
      providers: [
        BlocProvider<BottomNavigationBloc>(
          create: (_) => BottomNavigationBloc(),
        ),
        BlocProvider<ExploreTabBloc>(
          create: (_) => ExploreTabBloc()
            ..add(InitializeExploreTabEvent(
              selectedLocation: selectedLocation,
              selectedAsset: selectedAsset,
              isoStart: isoStart,
              isoEnd: isoEnd,
            )),
        ),
      ],
      child: Scaffold(
        // Conditional rendering of drawer for web layout
        drawer: isWebLayout ? null : _buildDrawer(context),

        // For web layout, show the navigation rail on the left
        body: isWebLayout
            ? Row(
          children: [
            BlocBuilder<BottomNavigationBloc, BottomNavigationState>(
              builder: (context, state) {
                return NavigationRail(
                  selectedIndex: state.currentIndex,
                  onDestinationSelected: (index) {
                    context
                        .read<BottomNavigationBloc>()
                        .add(NavigationTapped(index));
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.explore),
                      label: Text('Explore'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.book),
                      label: Text('Bookings'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person),
                      label: Text('Profile'),
                    ),
                  ],
                );
              },
            ),
            VerticalDivider(thickness: 1, width: 1),
            // Main content area
            Expanded(
              child: _buildBody(context),
            ),
          ],
        )
            : _buildBody(context),

        // Show bottom navigation only for mobile layout
        bottomNavigationBar: isWebLayout
            ? null
            : BlocBuilder<BottomNavigationBloc, BottomNavigationState>(
          builder: (context, state) {
            return BottomNavigationBar(
              selectedItemColor: primary_color,
              currentIndex: state.currentIndex,
              onTap: (index) {
                context
                    .read<BottomNavigationBloc>()
                    .add(NavigationTapped(index));
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.explore),
                  label: 'Explore',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.book),
                  label: 'Bookings',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Extracted body builder method
  Widget _buildBody(BuildContext context) {
    // Split ISO datetime strings into separate date and time components
    final startParts = _splitDateTime(isoStart);
    final endParts = _splitDateTime(isoEnd);

    return BlocBuilder<BottomNavigationBloc, BottomNavigationState>(
      builder: (context, state) {
        switch (state.currentIndex) {
          case 0:
            return ExplorePage(
              selectedLocation: selectedLocation,
              selectedAsset: selectedAsset,
              selectedDate: startParts['date'],
              selectedStartTime: startParts['time'],
              selectedEndTime: endParts['time'],
              selectedEndDate: endParts['date'],
            );
          case 1:
            return BookingsScreen();
          case 2:
            return ProfileScreen();
          default:
            return ExplorePage(
              selectedLocation: selectedLocation,
              selectedAsset: selectedAsset,
              selectedDate: startParts['date'],
              selectedStartTime: startParts['time'],
              selectedEndTime: endParts['time'],
              selectedEndDate: endParts['date'],
            );
        }
      },
    );
  }

  // Optional drawer for mobile layout
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: primary_color,
            ),
            child: Text('Your App Name'),
          ),
          ListTile(
            leading: Icon(Icons.explore),
            title: Text('Explore'),
            onTap: () {
              context.read<BottomNavigationBloc>().add(NavigationTapped(0));
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.book),
            title: Text('Bookings'),
            onTap: () {
              context.read<BottomNavigationBloc>().add(NavigationTapped(1));
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {
              context.read<BottomNavigationBloc>().add(NavigationTapped(2));
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

/*class MainScreen extends StatelessWidget {
  final String? selectedLocation;
  final String? selectedAsset;
  final String? isoStart;
  final String? isoEnd;
  final int initialIndex;

  const MainScreen({
    Key? key,
    this.initialIndex = 0,
    this.selectedLocation,
    this.selectedAsset,
    this.isoStart,
    this.isoEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if the screen width is larger than 768px (typical tablet breakpoint)
    final bool isWebLayout = MediaQuery.of(context).size.width > 768;

    return MultiBlocProvider(
      providers: [
        BlocProvider<BottomNavigationBloc>(
          create: (_) => BottomNavigationBloc(),
        ),
        BlocProvider<ExploreTabBloc>(
          create: (_) => ExploreTabBloc()
            ..add(InitializeExploreTabEvent(
              selectedLocation: selectedLocation,
              selectedAsset: selectedAsset,
              isoStart: isoStart,
              isoEnd: isoEnd,
            )),
        ),
      ],
      child: Scaffold(
        // Conditional rendering of drawer for web layout
        drawer: isWebLayout ? null : _buildDrawer(context),

        // For web layout, show the navigation rail on the left
        body: isWebLayout
            ? Row(
          children: [
            BlocBuilder<BottomNavigationBloc, BottomNavigationState>(
              builder: (context, state) {
                return NavigationRail(
                  selectedIndex: state.currentIndex,
                  onDestinationSelected: (index) {
                    context
                        .read<BottomNavigationBloc>()
                        .add(NavigationTapped(index));
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.explore),
                      label: Text('Explore'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.book),
                      label: Text('Bookings'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person),
                      label: Text('Profile'),
                    ),
                  ],
                );
              },
            ),
            VerticalDivider(thickness: 1, width: 1),
            // Main content area
            Expanded(
              child: _buildBody(context),
            ),
          ],
        )
            : _buildBody(context),

        // Show bottom navigation only for mobile layout
        bottomNavigationBar: isWebLayout
            ? null
            : BlocBuilder<BottomNavigationBloc, BottomNavigationState>(
          builder: (context, state) {
            return BottomNavigationBar(
              selectedItemColor: primary_color,
              currentIndex: state.currentIndex,
              onTap: (index) {
                context
                    .read<BottomNavigationBloc>()
                    .add(NavigationTapped(index));
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.explore),
                  label: 'Explore',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.book),
                  label: 'Bookings',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Extracted body builder method
  Widget _buildBody(BuildContext context) {
    return BlocBuilder<BottomNavigationBloc, BottomNavigationState>(
      builder: (context, state) {
        switch (state.currentIndex) {
          case 0:
            return ExplorePage(
              selectedLocation: selectedLocation,
              selectedAsset: selectedAsset,
              isoStart: isoStart,
              isoEnd: isoEnd,
            );
          case 1:
            return BookingsScreen();
          case 2:
            return ProfileScreen();
          default:
            return ExplorePage(
              selectedLocation: selectedLocation,
              selectedAsset: selectedAsset,
              isoStart: isoStart,
              isoEnd: isoEnd,
            );
        }
      },
    );
  }

  // Optional drawer for mobile layout
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: primary_color,
            ),
            child: Text('Your App Name'),
          ),
          ListTile(
            leading: Icon(Icons.explore),
            title: Text('Explore'),
            onTap: () {
              context.read<BottomNavigationBloc>().add(NavigationTapped(0));
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.book),
            title: Text('Bookings'),
            onTap: () {
              context.read<BottomNavigationBloc>().add(NavigationTapped(1));
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {
              context.read<BottomNavigationBloc>().add(NavigationTapped(2));
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}*/
// ---working code below
/*class MainScreen extends StatelessWidget {
  final String? selectedLocation;
  final String? selectedAsset;
  final String? isoStart;
  final String? isoEnd;
  final int initialIndex;
  const MainScreen({
    Key? key,
    this.initialIndex = 0,
    this.selectedLocation,
    this.selectedAsset,
    this.isoStart,
    this.isoEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BottomNavigationBloc>(
          create: (_) => BottomNavigationBloc(),
        ),
        BlocProvider<ExploreTabBloc>(
          create: (_) => ExploreTabBloc()
            ..add(InitializeExploreTabEvent(
              selectedLocation: selectedLocation,
              selectedAsset: selectedAsset,
              isoStart: isoStart,
              isoEnd: isoEnd,
            )),
        ),
      ],
      child: Scaffold(
        body: BlocBuilder<BottomNavigationBloc, BottomNavigationState>(
          builder: (context, state) {
            switch (state.currentIndex) {
              case 0:
                return ExplorePage(
                  selectedLocation: selectedLocation,
                  selectedAsset: selectedAsset,
                  isoStart: isoStart,
                  isoEnd: isoEnd,
                );
              case 1:
                return BookingsScreen();
              case 2:
                return ProfileScreen();
              default:
                return ExplorePage(
                  selectedLocation: selectedLocation,
                  selectedAsset: selectedAsset,
                  isoStart: isoStart,
                  isoEnd: isoEnd,
                );
            }
          },
        ),
        bottomNavigationBar: BlocBuilder<BottomNavigationBloc, BottomNavigationState>(
          builder: (context, state) {
            return BottomNavigationBar(
              selectedItemColor: primary_color,
              currentIndex: state.currentIndex,
              onTap: (index) {
                context.read<BottomNavigationBloc>().add(NavigationTapped(index));
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.explore),
                  label: 'Explore',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.book),
                  label: 'Bookings',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}*/
//---- working code above
//value work properly
/*class MainScreen extends StatelessWidget {
  final String? selectedLocation;
  final String? selectedAsset;
  final String? isoStart;
  final String? isoEnd;

  const MainScreen({
    Key? key,
    this.selectedLocation,
    this.selectedAsset,
    this.isoStart,
    this.isoEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BottomNavigationBloc>(
          create: (_) => BottomNavigationBloc(),
        ),
        BlocProvider<ExploreTabBloc>(
          create: (_) => ExploreTabBloc()
            ..add(InitializeExploreTabEvent(
              selectedLocation: selectedLocation,
              selectedAsset: selectedAsset,
              isoStart: isoStart,
              isoEnd: isoEnd,
            )),
        ),
      ],
      child: Scaffold(

        body: BlocBuilder<BottomNavigationBloc, BottomNavigationState>(
          builder: (context, state) {
            switch (state.currentIndex) {
              case 0:
                return ExplorePage(
                  selectedLocation: selectedLocation,
                  selectedAsset: selectedAsset,
                  isoStart: isoStart,
                  isoEnd: isoEnd,
                );
              case 1:
                return Center(child: Text('Bookings Page'));
              case 2:
                return Center(child: Text('Profile Page'));
              default:
                return ExplorePage(
                  selectedLocation: selectedLocation,
                  selectedAsset: selectedAsset,
                  isoStart: isoStart,
                  isoEnd: isoEnd,
                );
            }
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: context.read<BottomNavigationBloc>().state.currentIndex,
          onTap: (index) {
            context.read<BottomNavigationBloc>().add(NavigationTapped(index));
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}*/





/*  class MainScreen extends StatelessWidget {
    final String? selectedLocation;
    final String? selectedAsset;
    final String? isoStart;
    final String? isoEnd;

    const MainScreen({
      Key? key,
      this.selectedLocation,
      this.selectedAsset,
      this.isoStart,
      this.isoEnd,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
      return BlocProvider(
        create: (_) => BottomNavigationBloc(),
        child: Scaffold(
          body: BlocBuilder<BottomNavigationBloc, BottomNavigationState>(
            builder: (context, state) {
              switch (state.currentIndex) {
                case 0:
                  return ExplorePage(
                    selectedLocation: selectedLocation,
                    selectedAsset: selectedAsset,
                    isoStart: isoStart,
                    isoEnd: isoEnd,
                  );
                case 1:
                  return Center(child: Text('Bookings Page'));
                case 2:
                  return Center(child: Text('Profile Page'));
                default:
                  return ExplorePage(
                    selectedLocation: selectedLocation,
                    selectedAsset: selectedAsset,
                    isoStart: isoStart,
                    isoEnd: isoEnd,
                  );
              }
            },
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: context.read<BottomNavigationBloc>().state.currentIndex,
            onTap: (index) {
              context.read<BottomNavigationBloc>().add(NavigationTapped(index));
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.explore),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book),
                label: 'Bookings',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      );
    }
  }*/
