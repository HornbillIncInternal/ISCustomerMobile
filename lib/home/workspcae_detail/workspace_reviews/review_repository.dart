import 'dart:convert';
import 'package:hb_booking_mobile_app/home/model/model_review.dart';
import 'package:hb_booking_mobile_app/utils/base_url.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReviewRepository {


  ReviewRepository();
  Future<List<ReviewData>> fetchReviews(String branchId) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken')??'';
    final response = await http.get(Uri.parse('${base_url}branch/$branchId/reviews')
      ,headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization':'Bearer '+accessToken,
    },);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print("respons-- ${response.body}");
      // Ensure the response contains a 'data' key that holds the reviews.
      if (jsonResponse['data'] != null && jsonResponse['data'] is List) {
        return (jsonResponse['data'] as List)
            .map((reviewJson) => ReviewData.fromJson(reviewJson))
            .toList();
      } else {
        throw Exception('Unexpected response format: reviews not found');
      }
    } else {
      throw Exception('Failed to load reviews');
    }
  }


}
