import 'package:hb_booking_mobile_app/bookings/model_bookings.dart';
import 'package:equatable/equatable.dart';



abstract class BookingDetailEvent extends Equatable {
  const BookingDetailEvent();

  @override
  List<Object> get props => [];
}

class LoadBookingDetail extends BookingDetailEvent {
  final dynamic booking; // Accept both Upcoming and Completed

  const LoadBookingDetail({required this.booking});

  @override
  List<Object> get props => [booking];
}

class GenerateQrCode extends BookingDetailEvent {
  final String bookingId;

  const GenerateQrCode({required this.bookingId});

  @override
  List<Object> get props => [bookingId];
}

class UpdateRating extends BookingDetailEvent {
  final int rating;

  const UpdateRating({required this.rating});

  @override
  List<Object> get props => [rating];
}

class SubmitReview extends BookingDetailEvent {
  final String branchId;
  final String review;
  final int rating;

  const SubmitReview({
    required this.branchId,
    required this.review,
    required this.rating,
  });

  @override
  List<Object> get props => [branchId, review, rating];
}


/*abstract class BookingDetailEvent extends Equatable {
  const BookingDetailEvent();

  @override
  List<Object> get props => [];
}

class LoadBookingDetail extends BookingDetailEvent {
  final dynamic booking; // Accept both Upcoming and Completed

  const LoadBookingDetail({required this.booking});

  @override
  List<Object> get props => [booking];
}

class GenerateQrCode extends BookingDetailEvent {
  final String bookingId;

  const GenerateQrCode({required this.bookingId});

  @override
  List<Object> get props => [bookingId];
}
class UpdateRating extends BookingDetailEvent {
  final int rating;

  const UpdateRating({required this.rating});

  @override
  List<Object> get props => [rating];
}
class SubmitReview extends BookingDetailEvent {
  final String branchId;
  final String review;
  final int rating;

  const SubmitReview({
    required this.branchId,
    required this.review,
    required this.rating,
  });

  @override
  List<Object> get props => [branchId, review, rating];
}*/





