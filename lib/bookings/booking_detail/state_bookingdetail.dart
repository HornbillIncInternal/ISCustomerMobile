import 'package:hb_booking_mobile_app/bookings/model_bookings.dart';
import 'package:equatable/equatable.dart';



abstract class BookingDetailState extends Equatable {
  const BookingDetailState();

  @override
  List<Object> get props => [];
}

class BookingDetailInitial extends BookingDetailState {}

class BookingDetailLoading extends BookingDetailState {}

class BookingDetailLoaded extends BookingDetailState {
  final dynamic booking; // Accept both Upcoming and Completed
  final String qrCodeData;
  final int rating; // Rating for the booking
  final String? review; // Optional review message

  const BookingDetailLoaded({
    required this.booking,
    required this.qrCodeData,
    this.rating = 0, // Initialize with 0 rating by default
    this.review,
  });

  @override
  List<Object> get props => [booking, qrCodeData, rating, review ?? ''];
}

class BookingDetailError extends BookingDetailState {
  final String message;

  const BookingDetailError({required this.message});

  @override
  List<Object> get props => [message];
}

class BookingDetailReviewSubmitting extends BookingDetailState {
  const BookingDetailReviewSubmitting();
}

class BookingDetailReviewSuccess extends BookingDetailState {
  final String message;

  const BookingDetailReviewSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class BookingDetailReviewFailure extends BookingDetailState {
  final String error;

  const BookingDetailReviewFailure({required this.error});

  @override
  List<Object> get props => [error];
}


/*abstract class BookingDetailState extends Equatable {

  const BookingDetailState();

  @override
  List<Object> get props => [];

}

class BookingDetailInitial extends BookingDetailState {}

class BookingDetailLoading extends BookingDetailState {}

class BookingDetailLoaded extends BookingDetailState {
  final dynamic booking; // Accept both Upcoming and Completed
  final String qrCodeData;

  const BookingDetailLoaded({required this.booking, required this.qrCodeData});

  @override
  List<Object> get props => [booking, qrCodeData];
}

class BookingDetailError extends BookingDetailState {
  final String message;

  const BookingDetailError({required this.message});

  @override
  List<Object> get props => [message];
}*/


