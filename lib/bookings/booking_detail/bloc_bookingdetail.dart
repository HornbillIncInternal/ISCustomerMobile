import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:hb_booking_mobile_app/bookings/booking_detail/event_bookingdetail.dart';
import 'package:hb_booking_mobile_app/bookings/booking_detail/state_bookingdetail.dart';
import 'package:hb_booking_mobile_app/bookings/model_bookings.dart';
import 'package:hb_booking_mobile_app/utils/base_url.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class BookingDetailBloc extends Bloc<BookingDetailEvent, BookingDetailState> {
  int rating = 0; // Track rating

  BookingDetailBloc() : super(BookingDetailInitial()) {
    on<LoadBookingDetail>(_onLoadBookingDetail);
    on<GenerateQrCode>(_onGenerateQrCode);
    on<SubmitReview>(_onSubmitReview);
    on<UpdateRating>(_onUpdateRating); // Register the UpdateRating event
  }

  void _onLoadBookingDetail(
      LoadBookingDetail event,
      Emitter<BookingDetailState> emit,
      ) {
    emit(BookingDetailLoaded(booking: event.booking, qrCodeData: event.booking.id));
  }

  void _onGenerateQrCode(
      GenerateQrCode event,
      Emitter<BookingDetailState> emit,
      ) async {
    try {
      final booking = (state is BookingDetailLoaded) ? (state as BookingDetailLoaded).booking : null;
      emit(BookingDetailLoading());

      if (booking == null) {
        throw Exception('Booking information is missing');
      }

      final qrCodeData = event.bookingId;
      emit(BookingDetailLoaded(booking: booking, qrCodeData: qrCodeData));
    } catch (error) {
      emit(BookingDetailError(message: error.toString()));
    }
  }

  void _onSubmitReview(
      SubmitReview event,
      Emitter<BookingDetailState> emit,
      ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken')??'';
      print("from blocb---- ${event.branchId}");
      print("from bloc---- ${event.review}");
      print("from bloc---- ${event.rating}");
      emit(BookingDetailLoading());

      final url = '${base_url}branch/${event.branchId}/reviews';
      final body = {
        'review': event.review,
        'rating': event.rating,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':'Bearer '+accessToken,
        },
        body: jsonEncode(body),
      );
print("status code-- ${response.body}");
      if (response.statusCode == 200) {
        // final booking = (state as BookingDetailLoaded).booking;
        emit(BookingDetailReviewSuccess(message: 'Review submitted successfully!'));
        //
      }

    } catch (error) {
      emit(BookingDetailError(message: error.toString()));
    }
  }

  void _onUpdateRating(
      UpdateRating event,
      Emitter<BookingDetailState> emit,
      ) {
    rating = event.rating;
    if (state is BookingDetailLoaded) {
      final booking = (state as BookingDetailLoaded).booking;
      emit(BookingDetailLoaded(booking: booking, qrCodeData: booking.id, rating: rating));
    }
  }
}

/*class BookingDetailBloc extends Bloc<BookingDetailEvent, BookingDetailState> {
  BookingDetailBloc() : super(BookingDetailInitial()) {
    on<LoadBookingDetail>(_onLoadBookingDetail);
    on<GenerateQrCode>(_onGenerateQrCode);
  }

  void _onLoadBookingDetail(
      LoadBookingDetail event,
      Emitter<BookingDetailState> emit,
      ) {
    emit(BookingDetailLoaded(booking: event.booking, qrCodeData: event.booking.id));
  }

  void _onGenerateQrCode(
      GenerateQrCode event,
      Emitter<BookingDetailState> emit,
      ) async {
    try {
      // Retrieve the current booking information before emitting the loading state
      final booking = (state is BookingDetailLoaded) ? (state as BookingDetailLoaded).booking : null;

      emit(BookingDetailLoading());

      if (booking == null) {
        throw Exception('Booking information is missing');
      }

      // Generate the QR code data
      final qrCodeData = event.bookingId;

      emit(BookingDetailLoaded(booking: booking, qrCodeData: qrCodeData));
    } catch (error) {
      emit(BookingDetailError(message: error.toString()));
    }
  }

}*/
