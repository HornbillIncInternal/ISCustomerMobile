import 'package:equatable/equatable.dart';


abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String username;
  final String email;

  const ProfileLoaded({required this.username, required this.email});

  @override
  List<Object> get props => [username, email];
}

class ProfileLoggedOut extends ProfileState {}

class ProfileError extends ProfileState {
  final String error;

  const ProfileError({required this.error});

  @override
  List<Object> get props => [error];
}


/*abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String username;
  final String email;

  const ProfileLoaded({required this.username, required this.email});

  @override
  List<Object> get props => [username, email];
}

class ProfileLoggedOut extends ProfileState {}*/
