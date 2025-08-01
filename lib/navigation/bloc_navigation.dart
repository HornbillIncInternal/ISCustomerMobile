import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Navigation Events Enum
enum NavigationEvent { explore, bookings, profile }

class NavigationBloc extends Bloc<NavigationEvent, int> {
  NavigationBloc() : super(0) {
    on<NavigationEvent>((event, emit) {
      switch (event) {
        case NavigationEvent.explore:
          emit(0);
          break;
        case NavigationEvent.bookings:
          emit(1);
          break;
        case NavigationEvent.profile:
          emit(2);
          break;
      }
    });
  }
}