// forgot_password_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:hb_booking_mobile_app/authentication/forgot/change_password_model.dart';
import 'package:hb_booking_mobile_app/authentication/forgot/event_forgot.dart';
import 'package:hb_booking_mobile_app/authentication/forgot/model_forgot.dart';
import 'package:hb_booking_mobile_app/authentication/forgot/model_otpVerify.dart';
import 'package:hb_booking_mobile_app/authentication/forgot/state_forgot.dart';
import 'package:hb_booking_mobile_app/utils/base_url.dart';
import 'package:hb_booking_mobile_app/authentication/forgot/event_forgot.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';



class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc() : super(ForgotPasswordInitial()) {

    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<ChangePasswordRequested>(_onChangePasswordRequested);
    on<ResendOtpRequested>(_onResendOtpRequested);
  }

  Future<void> _onForgotPasswordRequested(
      ForgotPasswordRequested event, Emitter<ForgotPasswordState> emit) async {
    emit(ForgotPasswordLoading());

    try {
      final response = await http.post(
        Uri.parse('${auth_base_url}tenantForgotPassword'),
        body: {'email': event.email},
      );

      if (response.statusCode == 200) {
        final data = ForgotModel.fromJson(json.decode(response.body));
       await SharedPreferences.getInstance().then((prefs) => prefs.setString('forgottoken', data.data?.token ?? ''));
        await SharedPreferences.getInstance().then((prefs) => prefs.setString('forgotemail', event.email));

        emit(ForgotPasswordSuccess(data.message ?? "OTP sent successfully"));
      } else {
        final data = ForgotModel.fromJson(json.decode(response.body));
        emit(ForgotPasswordFailure(data.message??"Failed to send OTP"));
      }
    } catch (e) {
      emit(ForgotPasswordFailure("An error occurred: ${e.toString()}"));
    }
  }
  Future<void> _onResendOtpRequested(
      ResendOtpRequested event, Emitter<ForgotPasswordState> emit) async {
    emit(ResendOtpLoading());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('forgotemail')??'';
    try {
      final response = await http.post(
        Uri.parse('${auth_base_url}tenantForgotPassword'),
        body: {'email': email},
      );

      if (response.statusCode == 200) {
        emit(ResendOtpSuccess('OTP has been resent successfully.'));
      } else {
        final errorData = jsonDecode(response.body);
        emit(ResendOtpFailure(errorData['message'] ?? 'Failed to resend OTP'));
      }
    } catch (error) {
      emit(ResendOtpFailure('An error occurred. Please try again.'));
    }
  }
  Future<void> _onVerifyOtpRequested(
      VerifyOtpRequested event, Emitter<ForgotPasswordState> emit) async {
    emit(OtpVerificationLoading());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('forgottoken')??'';
    print("reso-- ${accessToken}");
    try {
      final response = await http.post(
        Uri.parse('${auth_base_url}tenantOtpVerification'),
        body: {'otp': event.otp},
        headers: { 'Authorization':'Bearer '+accessToken,},

      );
print("forgot resp--${response.body}");
      if (response.statusCode == 200) {
        final data = OtpModel.fromJson(json.decode(response.body));
        emit(OtpVerificationSuccess(data.message ?? "OTP verified successfully"));
      } else {
        emit(OtpVerificationFailure("Invalid OTP"));
      }
    } catch (e) {
      emit(OtpVerificationFailure("An error occurred: ${e.toString()}"));
    }
  }
  Future<void> _onChangePasswordRequested(
      ChangePasswordRequested event, Emitter<ForgotPasswordState> emit) async {
    emit(ForgotPasswordLoading());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('forgottoken')??'';
    try {
      final response = await http.post(
        Uri.parse('${auth_base_url}tenantResetPassword'),
        body: jsonEncode({"password": event.password}),
        headers: {"Content-Type": "application/json",'Authorization':'Bearer '+accessToken,},
      );

      if (response.statusCode == 200) {
        final data = ChangePassswordModel.fromJson(jsonDecode(response.body));
        emit(ChangePasswordSuccess(data.message ?? 'Password changed successfully'));
      } else {
        final errorData = jsonDecode(response.body);
        emit(ChangePasswordFailure(errorData['message'] ?? 'Failed to change password'));
      }
    } catch (error) {
      emit(ChangePasswordFailure('An error occurred. Please try again.'));
    }
  }

}
