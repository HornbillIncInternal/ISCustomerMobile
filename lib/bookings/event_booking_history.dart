import 'package:equatable/equatable.dart';




abstract class BookingHistoryEvent extends Equatable {
  const BookingHistoryEvent();

  @override
  List<Object> get props => [];
}

class FetchBookingHistory extends BookingHistoryEvent {
  final String status;

  const FetchBookingHistory({required this.status});

  @override
  List<Object> get props => [status];
}

class CancelBookingHistory extends BookingHistoryEvent {
  final String bookingId;

  const CancelBookingHistory({required this.bookingId});

  @override
  List<Object> get props => [bookingId];
}
