// forgot_password_state.dart
import 'package:equatable/equatable.dart';

abstract class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object> get props => [];
}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoading extends ForgotPasswordState {}

class ForgotPasswordSuccess extends ForgotPasswordState {
  final String message;

  const ForgotPasswordSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class ForgotPasswordFailure extends ForgotPasswordState {
  final String error;

  const ForgotPasswordFailure(this.error);

  @override
  List<Object> get props => [error];
}
class OtpVerificationLoading extends ForgotPasswordState {}

class OtpVerificationSuccess extends ForgotPasswordState {
  final String message;
  OtpVerificationSuccess(this.message);
}

class OtpVerificationFailure extends ForgotPasswordState {
  final String error;
  OtpVerificationFailure(this.error);
}
class ResetPasswordLoading extends ForgotPasswordState {}

class ChangePasswordSuccess extends ForgotPasswordState {
  final String message;
  ChangePasswordSuccess(this.message);
}

class ChangePasswordFailure extends ForgotPasswordState {
  final String error;
  ChangePasswordFailure(this.error);
}
class ResendOtpLoading extends ForgotPasswordState {}

class ResendOtpSuccess extends ForgotPasswordState {
  final String message;
  ResendOtpSuccess(this.message);
}

class ResendOtpFailure extends ForgotPasswordState {
  final String error;
  ResendOtpFailure(this.error);
}