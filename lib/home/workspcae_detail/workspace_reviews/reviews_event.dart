abstract class ReviewEvent {}

class FetchReviews extends ReviewEvent {
  final String branchId;

  FetchReviews(this.branchId);
}
