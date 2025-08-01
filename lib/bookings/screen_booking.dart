import 'package:hb_booking_mobile_app/bookings/bloc_booking_history.dart';
import 'package:hb_booking_mobile_app/bookings/booking_detail/screen_bookingdetail.dart';
import 'package:hb_booking_mobile_app/bookings/event_booking_history.dart';
import 'package:hb_booking_mobile_app/bookings/model_bookings.dart';
import 'package:hb_booking_mobile_app/bookings/state_booking_history.dart';
import 'package:hb_booking_mobile_app/connectivity/connectivity_bloc.dart';
import 'package:hb_booking_mobile_app/connectivity/connectivity_state.dart';
import 'package:hb_booking_mobile_app/utils/colors.dart';
import 'package:hb_booking_mobile_app/utils/functions.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/is_loader.dart';
import 'booking_detail/bloc_bookingdetail.dart';

class BookingsScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BookingHistoryBloc(),
      child: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Bookings'),
              ),
              body: Center(child:OfficeLoader(  size: 70,)),
            );
          } else if (snapshot.hasData && !snapshot.data!) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Bookings'),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/notAuthenticated.jpg',
                      width: 200,
                      height: 200,
                    ),
                    Text(
                      'Login to continue',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  title: Text('Bookings'),
                  bottom: TabBar(
                    indicatorColor: primary_color,
                    labelColor: primary_color,
                    onTap: (index) {
                      final status = index == 0 ? 'upcoming' : 'completed';
                      context.read<BookingHistoryBloc>().add(FetchBookingHistory(status: status));
                    },
                    tabs: [
                      Tab(text: 'Upcoming'),
                      Tab(text: 'Completed'),
                    ],
                  ),
                ),
                body: TabBarView(
                  children: [
                    BookingsList(status: 'upcoming'),
                    BookingsList(status: 'completed'),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}
class BookingsList extends StatelessWidget {
  final String status;

  BookingsList({required this.status});

  List<T> _sortBookingsByDate<T>(List<T> bookings) {
    return List.from(bookings)..sort((a, b) {
      // Parse the dates for comparison
      DateTime dateA = DateTime.parse((a as dynamic).fromDate);
      DateTime dateB = DateTime.parse((b as dynamic).fromDate);
      // Sort in descending order (most recent date first)
      return dateB.compareTo(dateA);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityBloc, ConnectivityState>(
      builder: (context, connectivityState) {
        if (connectivityState is DisconnectedState) {
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
        return BlocBuilder<BookingHistoryBloc, BookingHistoryState>(
          builder: (context, state) {
            print("Current state: $state");
            print("Status filter: $status");

            if (state is BookingHistoryInitial) {
              context.read<BookingHistoryBloc>().add(FetchBookingHistory(status: status));
              return Center(child: OfficeLoader(size: 70,));
            } else if (state is BookingHistoryLoading) {
              return Center(child: OfficeLoader(size: 70,));
            } else if (state is BookingHistoryLoadedUpcoming && status == 'upcoming') {
              print("Upcoming bookings count: ${state.bookings.length}");

              if (state.bookings.isEmpty) {
                return _buildEmptyState();
              }

              final sortedBookings = _sortBookingsByDate(state.bookings);

              return ListView.builder(
                itemCount: sortedBookings.length,
                itemBuilder: (context, index) {
                  if (index >= sortedBookings.length) {
                    print("Index out of range: $index >= ${sortedBookings.length}");
                    return Container(); // Return empty container for safety
                  }

                  Upcoming booking = sortedBookings[index];
                  return BookingCard(booking: booking, status: status);
                },
              );
            } else if (state is BookingHistoryLoadedCompleted && status == 'completed') {
              print("Completed bookings count: ${state.bookings.length}");

              if (state.bookings.isEmpty) {
                return _buildEmptyState();
              }

              final sortedBookings = _sortBookingsByDate(state.bookings);

              return ListView.builder(
                itemCount: sortedBookings.length,
                itemBuilder: (context, index) {
                  if (index >= sortedBookings.length) {
                    print("Index out of range: $index >= ${sortedBookings.length}");
                    return Container(); // Return empty container for safety
                  }

                  Completed booking = sortedBookings[index];
                  return BookingCard(booking: booking, status: status);
                },
              );
            } else if (state is BookingHistoryError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is BookingHistoryCancelled) {
              // After cancellation, fetch bookings again
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<BookingHistoryBloc>().add(FetchBookingHistory(status: status));
              });
              return Center(child: OfficeLoader(size: 70,));
            }

            return Center(child: Text('No data available for $status bookings.'));
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/nodata.png',
          width: 200,
          height: 200,
        ),
        const SizedBox(height: 16),

        const Text(
          "No bookings available!",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
// class BookingsList extends StatelessWidget {
//   final String status;
//
//   BookingsList({required this.status});
//
//   List<T> _sortBookingsByDate<T>(List<T> bookings) {
//     return List.from(bookings)..sort((a, b) {
//       // Parse the dates for comparison
//       DateTime dateA = DateTime.parse((a as dynamic).fromDate);
//       DateTime dateB = DateTime.parse((b as dynamic).fromDate);
//       // Sort in ascending order (earliest date first)
//       return dateA.compareTo(dateB);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<ConnectivityBloc, ConnectivityState>(
//       builder: (context, connectivityState) {
//         if (connectivityState is DisconnectedState) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(65.0),
//                   child: Image.asset('assets/images/no_internet.png'),
//                 ),
//                 SizedBox(height: 16),
//               ],
//             ),
//           );
//         }
//         return BlocBuilder<BookingHistoryBloc, BookingHistoryState>(
//           builder: (context, state) {
//             print("Current state: $state");
//             print("Status filter: $status");
//
//             if (state is BookingHistoryInitial) {
//               context.read<BookingHistoryBloc>().add(FetchBookingHistory(status: status));
//               return Center(child: OfficeLoader(  size: 70,));
//             } else if (state is BookingHistoryLoading) {
//               return Center(child: OfficeLoader(  size: 70,));
//             } else if (state is BookingHistoryLoadedUpcoming && status == 'upcoming') {
//               print("Upcoming bookings count: ${state.bookings.length}");
//
//               if (state.bookings.isEmpty) {
//                 return _buildEmptyState();
//               }
//
//               final sortedBookings = _sortBookingsByDate(state.bookings);
//
//               return ListView.builder(
//                 itemCount: sortedBookings.length,
//                 itemBuilder: (context, index) {
//                   if (index >= sortedBookings.length) {
//                     print("Index out of range: $index >= ${sortedBookings.length}");
//                     return Container(); // Return empty container for safety
//                   }
//
//                   Upcoming booking = sortedBookings[index];
//                   return BookingCard(booking: booking, status: status);
//                 },
//               );
//             } else if (state is BookingHistoryLoadedCompleted && status == 'completed') {
//               print("Completed bookings count: ${state.bookings.length}");
//
//               if (state.bookings.isEmpty) {
//                 return _buildEmptyState();
//               }
//
//               final sortedBookings = _sortBookingsByDate(state.bookings);
//
//               return ListView.builder(
//                 itemCount: sortedBookings.length,
//                 itemBuilder: (context, index) {
//                   if (index >= sortedBookings.length) {
//                     print("Index out of range: $index >= ${sortedBookings.length}");
//                     return Container(); // Return empty container for safety
//                   }
//
//                   Completed booking = sortedBookings[index];
//                   return BookingCard(booking: booking, status: status);
//                 },
//               );
//             } else if (state is BookingHistoryError) {
//               return Center(child: Text('Error: ${state.message}'));
//             } else if (state is BookingHistoryCancelled) {
//               // After cancellation, fetch bookings again
//               WidgetsBinding.instance.addPostFrameCallback((_) {
//                 context.read<BookingHistoryBloc>().add(FetchBookingHistory(status: status));
//               });
//               return Center(child: OfficeLoader(  size: 70,));
//             }
//
//             return Center(child: Text('No data available for $status bookings.'));
//           },
//         );
//       },
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Image.asset(
//           'assets/images/nodata.png',
//           width: 200,
//           height: 200,
//         ),
//         const SizedBox(height: 16),
//
//         const Text(
//           "No bookings available!",
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.normal,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }
// }


class BookingCard extends StatelessWidget {
  final dynamic booking;
  final String status;

  BookingCard({required this.booking, required this.status});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (_) => BookingDetailBloc(),
                child: BookingDetailView(booking: booking, usingStatus: status),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Safe access to booking title
              Text(
                _getBookingTitle(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Id: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    booking.bookingId ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              // Safe access to branch name
              if (_getBranchName() != null)
                Text(
                  '${capitalize(_getBranchName()!)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              // Safe access to desk count
              if (_getDeskCount() > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'No.of desk: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${_getDeskCount()}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_formatDate(booking.fromDate)} - ${_formatDate(booking.toDate)}',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                  // Safe access to time
                  if (_hasTime())
                    Text(
                      '${_formatTime(booking.fromTime)} - ${_formatTime(booking.toTime)}',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                booking.status?.toString() ?? 'N/A',
                style: TextStyle(
                  color: booking.status == 'booked' ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Safe method to get booking title
  String _getBookingTitle() {
    if (booking.bookings != null && booking.bookings!.isNotEmpty) {
      return booking.bookings![0].asset?.title?.toString().toUpperCase() ?? 'N/A';
    }
    return 'N/A';
  }

  // Safe method to get branch name
  String? _getBranchName() {
    if (booking.branches != null && booking.branches!.isNotEmpty) {
      return booking.branches![0].name;
    }
    if (booking.bookings != null && booking.bookings!.isNotEmpty) {
      return booking.bookings![0].branch?.name;
    }
    return null;
  }

  // Safe method to get desk count
  int _getDeskCount() {
    if (booking.bookings != null) {
      return booking.bookings!.length;
    }
    return 0;
  }

  // Safe method to check if time exists
  bool _hasTime() {
    return booking.fromTime != null && booking.toTime != null;
  }

  String _formatTime(String? timeString) {
    if (timeString == null) return '';

    // Split the time string by '.'
    String timeWithoutMillis = timeString.split('.')[0];

    // Split hours, minutes, seconds
    List<String> timeParts = timeWithoutMillis.split(':');

    // Return only hours and minutes joined with ':'
    if (timeParts.length >= 2) {
      return '${timeParts[0]}:${timeParts[1]}';
    }
    return timeString;
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}
/*class BookingsList extends StatelessWidget {
  final String status;

  BookingsList({required this.status});
  List<dynamic> _sortBookingsByDate(List<dynamic> bookings) {
    return List.from(bookings)..sort((a, b) {
      // Parse the dates for comparison
      DateTime dateA = DateTime.parse(a.fromDate);
      DateTime dateB = DateTime.parse(b.fromDate);
      // Sort in ascending order (earliest date first)
      return dateA.compareTo(dateB);
    });
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityBloc, ConnectivityState>(
      builder: (context, connectivityState) {
        if (connectivityState is DisconnectedState) {
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
        return BlocBuilder<BookingHistoryBloc, BookingHistoryState>(
          builder: (context, state) {
            if (state is BookingHistoryInitial) {
              context.read<BookingHistoryBloc>().add(FetchBookingHistory(status: status));
              return Center(child: CircularProgressIndicator(color: primary_color));
            } else if (state is BookingHistoryLoading) {
              return Center(child: CircularProgressIndicator(color: primary_color));
            } else if (state is BookingHistoryLoadedUpcoming && status == 'upcoming') {
              if (state.bookings.isEmpty) {
                return _buildEmptyState();
              }
              final sortedBookings = _sortBookingsByDate(state.bookings);
              return ListView.builder(
                itemCount: sortedBookings.length,
                itemBuilder: (context, index) {
                  Upcoming booking = sortedBookings[index];
                  return BookingCard(booking: booking, status: status);
                },
              );
            } else if (state is BookingHistoryLoadedCompleted && status == 'completed') {
              if (state.bookings.isEmpty) {
                return _buildEmptyState();
              }
              final sortedBookings = _sortBookingsByDate(state.bookings);
              return ListView.builder(
                itemCount: sortedBookings.length,
                itemBuilder: (context, index) {
                  Completed booking = sortedBookings[index];
                  return BookingCard(booking: booking, status: status);
                },
              );
            } else if (state is BookingHistoryError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return Center(child: Text('No data available.'));
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/nodata.png',
          width: 200,
          height: 200,
        ),
        const SizedBox(height: 16),
        const Text(
          'Oops',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          "No bookings available!",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}*/

/*class BookingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BookingHistoryBloc(),
      child: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Bookings'),
              ),
              body: Center(child: CircularProgressIndicator(color: primary_color)),
            );
          } else if (snapshot.hasData && !snapshot.data!) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Bookings'),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/notAuthenticated.jpg', // Make sure the path is correct
                      width: 200,
                      height: 200,
                    ),
                    Text(
                      'Login to continue',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  title: Text('Bookings'),
                  bottom: TabBar(
                    indicatorColor: primary_color, // Replace with your primary color
                    labelColor: primary_color, // Replace with your primary color
                    onTap: (index) {
                      final status = index == 0 ? 'upcoming' : 'completed';
                      context.read<BookingHistoryBloc>().add(FetchBookingHistory(status: status));
                    },
                    tabs: [
                      Tab(text: 'Upcoming'),
                      Tab(text: 'Completed'),
                    ],
                  ),
                ),
                body: TabBarView(
                  children: [
                    BookingsList(status: 'upcoming'),
                    BookingsList(status: 'completed'),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}



class BookingsList extends StatelessWidget {
  final String status;

  BookingsList({required this.status});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityBloc, ConnectivityState>(
      builder: (context, connectivityState) {
        if (connectivityState is DisconnectedState) {
          // Display no connection image when disconnected
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Padding(
                  padding: const EdgeInsets.all(65.0),
                  child: Image.asset('assets/images/no_internet.png',),
                ),
                SizedBox(height: 16),

              ],
            ),
          );
        }
    return BlocBuilder<BookingHistoryBloc, BookingHistoryState>(
      builder: (context, state) {
        print("hist-- ${state.toString()}");
        // If it's the initial state, trigger the fetch event for the first time
        if (state is BookingHistoryInitial) {
          context.read<BookingHistoryBloc>().add(FetchBookingHistory(status: status));
          return Center(child: CircularProgressIndicator(color: primary_color)); // Replace with your primary color
        } else if (state is BookingHistoryLoading) {
          return Center(child: CircularProgressIndicator(color: primary_color)); // Replace with your primary color
        } else if (state is BookingHistoryLoadedUpcoming && status == 'upcoming') {
          if (state.bookings.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/nodata.png', // Make sure the path is correct
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Oops',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Center(
                  child: const Text(
                    "No bookings available!",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,

                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          }
          print("hist-- ${state.bookings.length.toString()}");
          return ListView.builder(

            itemCount: state.bookings.length,
            itemBuilder: (context, index) {
              Upcoming booking = state.bookings[index];
              return BookingCard(booking: booking, status: status);
            },
          );
        } else if (state is BookingHistoryLoadedCompleted && status == 'completed') {
          if (state.bookings.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/nodata.png', // Make sure the path is correct
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Oops',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Center(
                  child: const Text(
                    "No bookings available!",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,

                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          }

          return ListView.builder(

            itemCount: state.bookings.length,
            itemBuilder: (context, index) {
              Completed booking = state.bookings[index];
              return BookingCard(booking: booking, status: status);
            },
          );
        } else if (state is BookingHistoryError) {
          return Center(child: Text('Error: ${state.message}'));
        } else {
          return Center(child: Text('No data available.'));
        }
      },
    );
  },
);
  }
}

class BookingCard extends StatelessWidget {
  final dynamic booking;
  final String status;

  BookingCard({required this.booking, required this.status});

  @override
  Widget build(BuildContext context) {
    print("--st--  ${status}" );
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: InkWell(
        onTap: () {
          // Navigate to BookingDetailView when the card is tapped
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (_) => BookingDetailBloc(),
                child: BookingDetailView(booking: booking,usingStatus: status,),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${booking.bookings[0].asset.title.toString().toUpperCase()}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Id: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),   Text(
                    '${booking.id}',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Text(
                '${capitalize(booking.branch.name.toString())}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_formatDate(booking.fromDate)} - ${_formatDate(booking.toDate)}',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),     Text(
                    '${_formatTime(booking.fromDate)} - ${_formatTime(booking.toDate)}',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),

                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${booking.status.toString().split('.').last}',
                    style: TextStyle(
                      color: booking.status == 'booked' ? Colors.green : Colors.red,
                    ),
                  ),
                  // if (status == "upcoming")
                  //   ElevatedButton(
                  //     onPressed: () {
                  //       context.read<BookingHistoryBloc>().add(CancelBookingHistory(bookingId: booking.id));
                  //     },
                  //     child: Text('Cancel', style: TextStyle(color: Colors.red)),
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.white,
                  //     ),
                  //   ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
String _formatTime(DateTime dateTime) {
  return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
}*/



