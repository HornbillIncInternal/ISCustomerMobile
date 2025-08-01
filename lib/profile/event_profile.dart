import 'package:equatable/equatable.dart';


abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class CheckLoginStatus extends ProfileEvent {}

class LogoutEvent extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final String username;
  final String email;

  const UpdateProfile({required this.username, required this.email});

  @override
  List<Object> get props => [username, email];
}


/*
  abstract class ProfileEvent extends Equatable {
    const ProfileEvent();

    @override
    List<Object> get props => [];
  }

  class CheckLoginStatus extends ProfileEvent {}

  class LogoutEvent extends ProfileEvent {}*/
