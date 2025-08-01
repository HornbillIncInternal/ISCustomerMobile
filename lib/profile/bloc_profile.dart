import 'package:hb_booking_mobile_app/profile/state_profile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'event_profile.dart';
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<CheckLoginStatus>(_onCheckLoginStatus);
    on<LogoutEvent>(_onLogoutEvent);
    on<UpdateProfile>(_onUpdateProfile);
  }

  Future<void> _onCheckLoginStatus(
      CheckLoginStatus event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      final username = prefs.getString('username') ?? 'User';
      final email = prefs.getString('email') ?? 'user@example.com';

      emit(ProfileLoaded(username: username, email: email));
    } else {
      emit(ProfileLoggedOut());
    }
  }

  Future<void> _onLogoutEvent(
      LogoutEvent event, Emitter<ProfileState> emit) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.clear(); // Clear all stored preferences
    await _setIsLoggedInStatus(false);
    emit(ProfileLoggedOut());
  }
  Future<void> _setIsLoggedInStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', status);
  }

  void _onUpdateProfile(UpdateProfile event, Emitter<ProfileState> emit) {
    emit(ProfileLoaded(username: event.username, email: event.email));
  }
}


/*
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<CheckLoginStatus>(_onCheckLoginStatus);
    on<LogoutEvent>(_onLogoutEvent);
    on<UpdateProfile>(_onUpdateProfile);
  }

  Future<void> _onCheckLoginStatus(
      CheckLoginStatus event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      final username = prefs.getString('username') ?? 'User';
      final email = prefs.getString('email') ?? 'user@example.com';

      emit(ProfileLoaded(username: username, email: email));
    } else {
      emit(ProfileLoggedOut());
    }
  }

  Future<void> _onLogoutEvent(
      LogoutEvent event, Emitter<ProfileState> emit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    emit(ProfileLoggedOut());
  }

  void _onUpdateProfile(UpdateProfile event, Emitter<ProfileState> emit) {
    emit(ProfileLoaded(username: event.username, email: event.email));
  }
}

*/

/*
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<CheckLoginStatus>(_onCheckLoginStatus);
    on<LogoutEvent>(_onLogout);
  }

  void _onCheckLoginStatus(CheckLoginStatus event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    print('CheckLoginStatus event triggered');

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      print('isLoggedIn: $isLoggedIn');

      if (isLoggedIn) {
        // Assuming you fetch user details from SharedPreferences or another source
        String username = "Rinshad"; // Replace with actual data
        String email = "corporateuser@example.com"; // Replace with actual data

        emit(ProfileLoaded(username: username, email: email));
        print('ProfileLoaded state emitted');
      } else {
        emit(ProfileLoggedOut());
        print('ProfileLoggedOut state emitted');
      }
    } catch (e) {
      print('Error occurred: $e');
      emit(ProfileLoggedOut());
    }
  }

  void _onLogout(LogoutEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    print('LogoutEvent triggered');

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken');
      await prefs.remove('isLoggedIn');
      await prefs.remove('rememberMe');

      emit(ProfileLoggedOut());
      print('ProfileLoggedOut state emitted');
    } catch (e) {
      print('Error during logout: $e');
      emit(ProfileLoggedOut()); // Ensure we still log out even if there's an error
    }
  }
}
*/
