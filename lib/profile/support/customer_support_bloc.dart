import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:hb_booking_mobile_app/profile/support/customer_support_event.dart';
import 'package:hb_booking_mobile_app/profile/support/customer_support_state.dart';
import 'package:hb_booking_mobile_app/profile/support/model_support.dart';
import 'package:hb_booking_mobile_app/utils/base_url.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class SupportBloc extends Bloc<SupportEvent, SupportState> {


  SupportBloc() : super(SupportInitial()) {
    on<SubmitSupportForm>((event, emit) async {
      emit(SupportLoading()); // Start loading

      try {
        // Call repository method to submit the support request
        final result = await submitSupportRequest(
         event.branchId,
           event.message,
        event.subject!,
        );
        emit(SupportSuccess(message: result.message!)); // Success state
      } catch (error) {
        emit(SupportError(error: error.toString())); // Error state
      }
    });
  }
  Future<SupportModel> submitSupportRequest(String branchId,String message, String subject) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken')??'';
    final response = await http.post(
      Uri.parse('${base_url}branch/${branchId}/tenantSupport'
      ),headers: <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization':'Bearer '+accessToken,
    },
      body: {
        "message": message,
        "subject": subject,
      },
    );

    if (response.statusCode == 200) {
      return SupportModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to submit support request');
    }
  }
}





