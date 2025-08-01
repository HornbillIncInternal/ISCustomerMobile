import 'package:hb_booking_mobile_app/home/workspcae_detail/workspace_reviews/review_repository.dart';
import 'package:hb_booking_mobile_app/home/workspcae_detail/workspace_reviews/reviews_event.dart';
import 'package:hb_booking_mobile_app/home/workspcae_detail/workspace_reviews/reviews_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final ReviewRepository reviewRepository;

  ReviewBloc(this.reviewRepository) : super(ReviewInitial()) {
    // Register the event handler for FetchReviews
    on<FetchReviews>((event, emit) async {
      emit(ReviewLoading());
      try {
        final reviews = await reviewRepository.fetchReviews(event.branchId);
        emit(ReviewLoaded(reviews));
      } catch (e) {
        emit(ReviewError('Failed to fetch reviews: ${e.toString()}'));
      }
    });
  }
}


