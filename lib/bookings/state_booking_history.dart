import 'package:hb_booking_mobile_app/bookings/model_bookings.dart';
import 'package:equatable/equatable.dart';



abstract class BookingHistoryState extends Equatable {
  const BookingHistoryState();

  @override
  List<Object> get props => [];
}

class BookingHistoryInitial extends BookingHistoryState {}

class BookingHistoryLoading extends BookingHistoryState {}

class BookingHistoryLoaded extends BookingHistoryState {
  final List<Completed> bookings;

  const BookingHistoryLoaded({required this.bookings});

  @override
  List<Object> get props => [bookings];
}

class BookingHistoryError extends BookingHistoryState {
  final String message;

  const BookingHistoryError({required this.message});

  @override
  List<Object> get props => [message];
}

class BookingHistoryCancelled extends BookingHistoryState {
  final String message;

  const BookingHistoryCancelled({required this.message});

  @override
  List<Object> get props => [message];
}
class BookingHistoryLoadedCompleted extends BookingHistoryState {
  final List<Completed> bookings;

  const BookingHistoryLoadedCompleted({required this.bookings});

  @override
  List<Object> get props => [bookings];
}

class BookingHistoryLoadedUpcoming extends BookingHistoryState {
  final List<Upcoming> bookings;

  const BookingHistoryLoadedUpcoming({required this.bookings});

  @override
  List<Object> get props => [bookings];
}

