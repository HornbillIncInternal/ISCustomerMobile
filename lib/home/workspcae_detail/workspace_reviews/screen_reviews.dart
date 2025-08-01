import 'package:hb_booking_mobile_app/home/model/model_review.dart';
import 'package:hb_booking_mobile_app/home/workspcae_detail/workspace_reviews/review_repository.dart';
import 'package:hb_booking_mobile_app/home/workspcae_detail/workspace_reviews/reviews_bloc.dart';
import 'package:hb_booking_mobile_app/home/workspcae_detail/workspace_reviews/reviews_event.dart';
import 'package:hb_booking_mobile_app/home/workspcae_detail/workspace_reviews/reviews_state.dart';
import 'package:hb_booking_mobile_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class ReviewPage extends StatelessWidget {
  final String branchId;

  ReviewPage({required this.branchId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReviewBloc(RepositoryProvider.of<ReviewRepository>(context))
        ..add(FetchReviews(branchId)),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Reviews'),
        ),
        body: BlocBuilder<ReviewBloc, ReviewState>(
          builder: (context, state) {
            if (state is ReviewLoaded) {
              if (state.reviews.isEmpty) {
                // Display empty state when there are no reviews
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(65.0),
                        child: Image.asset('assets/images/no_review.png'),
                      ),

                    ],
                  ),
                );
              }
              return ListView.builder(
                itemCount: state.reviews.length,
                itemBuilder: (context, index) {
                  final review = state.reviews[index];
                  return ReviewCard(review: review);
                },
              );
            } else if (state is ReviewLoading) {
              return Center(child: CircularProgressIndicator(color: primary_color,));
            } else if (state is ReviewError) {
              return Center(child: Text('Error: ${state.message}'));
            } else {
              return Center(child: Text('Please wait while we load reviews.'));
            }
          },
        ),
      ),
    );
  }
}



class ReviewCard extends StatefulWidget {
  final ReviewData review;

  ReviewCard({required this.review});

  @override
  _ReviewCardState createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title (User Name) - Handle null user
            Text(
              widget.review.user?.name ?? '',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 8),

            // Review Description with Expandable Text
            GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Text(
                widget.review.review ?? 'No review text',
                maxLines: isExpanded ? null : 2, // Expand/collapse logic
                overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),

            SizedBox(height: 12),

            // Star Rating and Rating Number
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.star, color: Colors.amber, size: 20),
                SizedBox(width: 4),
                Text('${widget.review.rating ?? 0}/5', style: TextStyle(fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
