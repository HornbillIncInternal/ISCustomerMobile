// import 'package:booking_hb_app/booking/state_booking.dart';
// import 'package:equatable/equatable.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
//
//
//
//
// abstract class BookingEvent extends Equatable {
//   const BookingEvent();
//
//   @override
//   List<Object?> get props => [];
// }
//
// class StartBooking extends BookingEvent {
//   final String assetId;
//   final String fromDate;
//   final String toDate;
//   final double totalPrice;
//
//   const StartBooking({
//     required this.assetId,
//     required this.fromDate,
//     required this.toDate,
//     required this.totalPrice,
//   });
//
//   @override
//   List<Object?> get props => [assetId, fromDate, toDate, totalPrice];
// }
//
// class PaymentSuccess extends BookingEvent {}
//
// class PaymentFailure extends BookingEvent {
//   final String error;
//
//   const PaymentFailure(this.error);
//
//   @override
//   List<Object?> get props => [error];
// }
//
// class NavigateToHomePage extends BookingEvent {}