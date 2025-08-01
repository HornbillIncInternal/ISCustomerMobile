// import 'package:equatable/equatable.dart';
//
// abstract class BookingState extends Equatable {
//   const BookingState();
//
//   @override
//   List<Object?> get props => [];
// }
//
// class BookingInitial extends BookingState {}
//
// class BookingLoading extends BookingState {
//   final String assetId;
//   final String fromDate;
//   final String toDate;
//
//   BookingLoading({
//     required this.assetId,
//     required this.fromDate,
//     required this.toDate,
//   });
//
//   @override
//   List<Object?> get props => [assetId, fromDate, toDate];
// }
//
// class BookingSuccess extends BookingState {}
// class BookingNavigationSuccess extends BookingState {
//
// }
// class BookingFailure extends BookingState {
//   final String error;
//
//   const BookingFailure(this.error);
//
//   @override
//   List<Object?> get props => [error];
// }
//
