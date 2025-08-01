import 'dart:convert';

import 'package:hb_booking_mobile_app/authentication/Signup/signup_event.dart';
import 'package:hb_booking_mobile_app/authentication/Signup/signup_state.dart';
import 'package:hb_booking_mobile_app/utils/base_url.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../model/model_signup.dart';
class SignupBloc extends Bloc<SignupEvent, SignupState> {
  SignupBloc() : super(SignupInitial()) {
    // Register the event handler for SignupButtonPressed
    on<SignupButtonPressed>(_onSignupButtonPressed);
  }

  // Define the event handler method
  Future<void> _onSignupButtonPressed(SignupButtonPressed event, Emitter<SignupState> emit) async {
    emit(SignupLoading());
    try {
      // Call your API here using event.name, event.email, event.password
      final response = await tenantRegisterAPI(event.name, event.email, event.password);

      // Check the status field to determine success or failure
      if (response.status == "success") {
        emit(SignupSuccess());
      } else {
        emit(SignupFailure(response.message)); // Use response.message for the error message
      }
    } catch (error) {
      emit(SignupFailure(error.toString()));
    }
  }
}


Future<SignupModel> tenantRegisterAPI(String name, String email, String password) async {
  final response = await http.post(
    Uri.parse('${auth_base_url}tenantRegister'),
    body: {
      'name': name,
      'email': email,
      'password': password,
    },
  );

  if (response.statusCode == 200) {
    return SignupModel.fromJson(json.decode(response.body)); // Expecting a full JSON response
  } else {
    return SignupModel(
      status: "failure", // Default failure status
      message: 'Registration failed',
      data: SignupData(accessToken: '', id: '', name: '', email: ''),
    );
  }
}



