// forgot_password_event.dart
import 'package:equatable/equatable.dart';

abstract class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();

  @override
  List<Object> get props => [];
}

class ForgotPasswordRequested extends ForgotPasswordEvent {
  final String email;

  const ForgotPasswordRequested(this.email);

  @override
  List<Object> get props => [email];
}
class VerifyOtpRequested extends ForgotPasswordEvent {
  final String otp;
  VerifyOtpRequested(this.otp);
}

class ResendOtpRequested extends ForgotPasswordEvent {

}
class ChangePasswordRequested extends ForgotPasswordEvent {
  final String password;
  ChangePasswordRequested(this.password);
}