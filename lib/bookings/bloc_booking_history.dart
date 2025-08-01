import 'package:bloc/bloc.dart';
import 'package:hb_booking_mobile_app/bookings/event_booking_history.dart';
import 'package:hb_booking_mobile_app/bookings/model_bookings.dart';
import 'package:hb_booking_mobile_app/bookings/model_cancel.dart';
import 'package:hb_booking_mobile_app/bookings/state_booking_history.dart';
import 'package:hb_booking_mobile_app/utils/base_url.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import the FlutterToast package

class BookingHistoryBloc extends Bloc<BookingHistoryEvent, BookingHistoryState> {
  BookingHistoryBloc() : super(BookingHistoryInitial()) {
    on<FetchBookingHistory>(_onFetchBookings);
    on<CancelBookingHistory>(_onCancelBooking);
  }
  Future<void> _onFetchBookings(FetchBookingHistory event, Emitter<BookingHistoryState> emit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userid') ?? '';
    print("upri---- ${userId}");

    emit(BookingHistoryLoading());

    try {
      final response = await http.get(
        Uri.parse('${base_url}booking/getBookingsByTenant/$userId'),
      );
      print("upri---- ${response.body}");

      if (response.statusCode == 200) {
        final bookingData = BookingHistoryModel.fromJson(jsonDecode(response.body));

        if (event.status == 'upcoming') {
          List<Upcoming> upcomingBookings = [];
          for (BookingData datum in bookingData.data!) {
            upcomingBookings.addAll(datum.upcoming!);
          }
          emit(BookingHistoryLoadedUpcoming(bookings: upcomingBookings));
        } else if (event.status == 'completed') {
          List<Completed> completedBookings = [];
          for (BookingData datum in bookingData!.data!) {
            completedBookings.addAll(datum.completed!);
          }
          emit(BookingHistoryLoadedCompleted(bookings: completedBookings));
        }
      } else {
        emit(BookingHistoryError(message: 'Failed to load bookings.'));
      }
    } catch (e) {
      emit(BookingHistoryError(message: e.toString()));
    }
  }



  Future<void> _onCancelBooking(CancelBookingHistory event, Emitter<BookingHistoryState> emit) async {
    try {
      emit(BookingHistoryLoading());
      print("res-- can -${event.bookingId}");
      final response = await http.post(
        Uri.parse('${base_url}booking/cancel/${event.bookingId}'),
      );
print("res-- can -${response.body}");

      if (response.statusCode == 200) {
        final cancelData = CancelModel.fromJson(jsonDecode(response.body));
        Fluttertoast.showToast(
          msg: cancelData.message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        emit(BookingHistoryCancelled(message: cancelData.message));
        // Refresh the bookings list after cancellation
       add(FetchBookingHistory(status: 'upcoming'));
      } else {
        final errorData = CancelModel.fromJson(jsonDecode(response.body));
        Fluttertoast.showToast(
          msg: errorData.message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        emit(BookingHistoryError(message: 'Failed to cancel booking.'));
      }
    } catch (e) {
      emit(BookingHistoryError(message: e.toString()));
    }
  }
}



