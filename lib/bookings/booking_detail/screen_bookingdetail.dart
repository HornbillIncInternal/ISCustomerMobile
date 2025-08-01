import 'package:hb_booking_mobile_app/bookings/booking_detail/bloc_bookingdetail.dart';
import 'package:hb_booking_mobile_app/bookings/booking_detail/event_bookingdetail.dart';
import 'package:hb_booking_mobile_app/bookings/booking_detail/state_bookingdetail.dart';
import 'package:hb_booking_mobile_app/bookings/model_bookings.dart';
import 'package:hb_booking_mobile_app/bookings/screen_booking.dart';
import 'package:hb_booking_mobile_app/connectivity/connectivity_bloc.dart';
import 'package:hb_booking_mobile_app/connectivity/connectivity_state.dart';
import 'package:hb_booking_mobile_app/utils/colors.dart';
import 'package:hb_booking_mobile_app/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
class BookingDetailView extends StatelessWidget {
  final dynamic booking;
  final String usingStatus;

  BookingDetailView({required this.booking, required this.usingStatus});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BookingDetailBloc()
        ..add(LoadBookingDetail(booking: booking))
        ..add(GenerateQrCode(bookingId: booking.id)),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Booking Details'),
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
            return BlocConsumer<BookingDetailBloc, BookingDetailState>(
              listener: (context, state) {
                if (state is BookingDetailReviewSuccess) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => BookingsScreen()),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Review submitted successfully')),
                  );
                } else if (state is BookingDetailReviewFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to submit review: ${state.error}')),
                  );
                }
              },
              builder: (context, state) {
                if (state is BookingDetailLoading) {
                  return Center(child: CircularProgressIndicator(color: primary_color));
                } else if (state is BookingDetailLoaded) {
                  return Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Card(
                                  elevation: 4.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Image.asset('assets/images/im5.png'),
                                  ),
                                ),
                                SizedBox(height: 20.0),
                                Card(
                                  elevation: 4.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Safe access to booking title
                                        Text(
                                          _getBookingTitle(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'Booking ID:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 16.0,
                                              ),
                                            ),
                                            Text(
                                              ' ${booking.bookingId ?? 'N/A'}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4.0),
                                        // Safe access to branch name
                                        if (_getBranchName() != null)
                                          Text(
                                            '${capitalize(_getBranchName()!)}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        SizedBox(height: 4.0),
                                        Text(
                                          booking.status?.toString() ?? 'N/A',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0,
                                            color: Colors.green,
                                          ),
                                        ),
                                        SizedBox(height: 4.0),
                                        // Safe access to bookings count
                                        if (_getBookingsCount() > 0)
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                'No.of bookings: ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                '${_getBookingsCount()}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        SizedBox(height: 6.0),
                                        Divider(),
                                        SizedBox(height: 8.0),
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
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.0),
                                if (usingStatus == "completed")
                                  _buildRatingAndReviewSection(context, _getBranchId())
                                else
                                  Center(
                                    child: Card(
                                      elevation: 4.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          children: [
                                            Text(
                                              'Scan the QR Code for Check-In',
                                              style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 16.0),
                                            QrImage(
                                              data: state.qrCodeData,
                                              version: QrVersions.auto,
                                              size: 150.0,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (state is BookingDetailError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return Container();
              },
            );
          },
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

  // Safe method to get bookings count
  int _getBookingsCount() {
    if (booking.bookings != null) {
      return booking.bookings!.length;
    }
    return 0;
  }

  // Safe method to get branch ID
  String _getBranchId() {
    if (booking.branches != null && booking.branches!.isNotEmpty) {
      return booking.branches![0].sId ?? '';
    }
    if (booking.bookings != null && booking.bookings!.isNotEmpty) {
      return booking.bookings![0].branch?.sId ?? '';
    }
    return '';
  }

  // Safe method to check if time exists
  bool _hasTime() {
    return booking.fromTime != null && booking.toTime != null;
  }

  Widget _buildRatingAndReviewSection(BuildContext context, String bookingId) {
    final reviewController = TextEditingController();
    print("test bid-- ${bookingId}");

    return BlocBuilder<BookingDetailBloc, BookingDetailState>(
      builder: (context, state) {
        if (state is BookingDetailLoaded) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rate your experience',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < state.rating ? Icons.star : Icons.star_border,
                        size: 30.0,
                        color: primary_color,
                      ),
                      onPressed: () {
                        context
                            .read<BookingDetailBloc>()
                            .add(UpdateRating(rating: index + 1));
                      },
                    );
                  }),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: reviewController,
                  decoration: InputDecoration(
                      labelText: 'Write a feedback',
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(
                          color: primary_color,
                          decorationColor: primary_color
                      )
                  ),
                  maxLines: 3,
                  cursorColor: primary_color,
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (state.rating > 0 && reviewController.text.isNotEmpty) {
                      context.read<BookingDetailBloc>().add(
                        SubmitReview(
                          branchId: bookingId,
                          review: reviewController.text,
                          rating: state.rating,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please provide a rating and review')),
                      );
                    }
                  },
                  child: Text(
                    'Submit Review',
                    style: TextStyle(color: primary_color),
                  ),
                ),
              ],
            ),
          );
        } else if (state is BookingDetailReviewSubmitting) {
          return Center(child: CircularProgressIndicator());
        }
        return Container();
      },
    );
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


/*class BookingDetailView extends StatelessWidget {
  final dynamic booking;
  final String usingStatus;

  BookingDetailView({required this.booking, required this.usingStatus});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BookingDetailBloc()
        ..add(LoadBookingDetail(booking: booking))
        ..add(GenerateQrCode(bookingId: booking.id)),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Booking Details'),
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
            return BlocConsumer<BookingDetailBloc, BookingDetailState>(
              listener: (context, state) {
                if (state is BookingDetailReviewSuccess) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => BookingsScreen()),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Review submitted successfully')),
                  );
                } else if (state is BookingDetailReviewFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to submit review: ${state.error}')),
                  );
                }
              },
              builder: (context, state) {
                if (state is BookingDetailLoading) {
                  return Center(child: CircularProgressIndicator(color: primary_color));
                } else if (state is BookingDetailLoaded) {
                  return Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Card(
                                  elevation: 4.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Image.asset('assets/images/im5.png'),
                                  ),
                                ),
                                SizedBox(height: 20.0),
                                Card(
                                  elevation: 4.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                  booking.bookings?[0].asset?.title?.toString().toUpperCase() ?? 'N/A',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'Booking ID:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 16.0,
                                              ),
                                            ),

                                            Text(
                                              ' ${booking.bookingId ?? 'N/A'}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4.0),
                                        if (booking.branches != null && booking.branches!.isNotEmpty)
                                          Text(
                                            '${capitalize(booking.branches![0].name) }',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        SizedBox(height: 4.0),
                                        Text(
                                          booking.status?.toString() ?? 'N/A',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0,
                                            color: Colors.green,
                                          ),
                                        ),
                                        SizedBox(height: 4.0),
                                        if (booking.bookings != null && booking.bookings!.isNotEmpty)
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                'No.of bookings: ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                '${booking.bookings.length}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        SizedBox(height: 6.0),
                                        Divider(),
                                        SizedBox(height: 8.0),
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
                                            Text(
                                              '${_formatTime(booking.fromTime)} - ${_formatTime(booking.toTime)}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.0),
                                if (usingStatus == "completed")
                                  _buildRatingAndReviewSection(context, booking.branches[0].sId ?? '')
                                else
                                  Center(
                                    child: Card(
                                      elevation: 4.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          children: [
                                            Text(
                                              'Scan the QR Code for Check-In',
                                              style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 16.0),
                                            QrImage(
                                              data: state.qrCodeData,
                                              version: QrVersions.auto,
                                              size: 150.0,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (state is BookingDetailError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return Container();
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildRatingAndReviewSection(BuildContext context, String bookingId) {
    final reviewController = TextEditingController();
print("test bid-- ${bookingId}");
    return BlocBuilder<BookingDetailBloc, BookingDetailState>(
      builder: (context, state) {
        if (state is BookingDetailLoaded) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rate your experience',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < state.rating ? Icons.star : Icons.star_border,
                        size: 30.0,
                        color: primary_color,
                      ),
                      onPressed: () {
                        context
                            .read<BookingDetailBloc>()
                            .add(UpdateRating(rating: index + 1));
                      },
                    );
                  }),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: reviewController,
                  decoration: InputDecoration(
                      labelText: 'Write a feedback',
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(
                          color: primary_color,
                          decorationColor: primary_color
                      )
                  ),
                  maxLines: 3,
                  cursorColor: primary_color,
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (state.rating > 0 && reviewController.text.isNotEmpty) {
                      context.read<BookingDetailBloc>().add(
                        SubmitReview(
                          branchId: bookingId,
                          review: reviewController.text,
                          rating: state.rating,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please provide a rating and review')),
                      );
                    }
                  },
                  child: Text(
                    'Submit Review',
                    style: TextStyle(color: primary_color),
                  ),
                ),
              ],
            ),
          );
        } else if (state is BookingDetailReviewSubmitting) {
          return Center(child: CircularProgressIndicator());
        }
        return Container();
      },
    );
  }

  String _formatTime(String timeString) {
    // Split the time string by '.'
    String timeWithoutMillis = timeString.split('.')[0];

    // Split hours, minutes, seconds
    List<String> timeParts = timeWithoutMillis.split(':');

    // Return only hours and minutes joined with ':'
    return '${timeParts[0]}:${timeParts[1]}';
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
}*/

