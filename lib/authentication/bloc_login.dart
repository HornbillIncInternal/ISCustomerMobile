import 'dart:convert';

import 'package:hb_booking_mobile_app/authentication/model/model_login.dart';
import 'package:hb_booking_mobile_app/authentication/state_login.dart';
import 'package:hb_booking_mobile_app/utils/base_url.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'event_login.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginButtonPressed>(_onLoginButtonPressed);
  }

  Future<void> _onLoginButtonPressed(
      LoginButtonPressed event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    final String apiUrl =
        '${auth_base_url}getTenantAccessToken';


      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": event.email,
          "password": event.password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          final loginData = LoginModel.fromJson(responseData);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', loginData.data.accessToken);
          await prefs.setString('userid', loginData.data.id);
          await prefs.setBool('isLoggedIn', true);

          // Save email if rememberMe is selected, otherwise remove it
          if (event.rememberMe) {
            await prefs.setString('email', event.email);
          } else {
            await prefs.remove('email');
          }
          await prefs.setBool('rememberMe', event.rememberMe);
          await prefs.setString('username', loginData.data.fullName); // Example username
          await prefs.setString('email', loginData.data.email); // Example email

          emit(LoginSuccess(
            username: loginData.data.fullName, // Use the full name from the response
            email: loginData.data.email, // Use the email from the response
          ));
        } else {
          emit(LoginFailure(error: "Invalid credentials"));
        }
      } else {
        emit(LoginFailure(error: "Invalid credentials"));
      }
    try {  } catch (e) {
      emit(LoginFailure(error: "An error occurred: $e"));
    }
  }
}





