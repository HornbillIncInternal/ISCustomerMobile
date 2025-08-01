import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Bottom Navigation Events
abstract class BottomNavigationEvent extends Equatable {
  const BottomNavigationEvent();

  @override
  List<Object> get props => [];
}

class NavigationTapped extends BottomNavigationEvent {
  final int index;

  const NavigationTapped(this.index);

  @override
  List<Object> get props => [index];
}

// Bottom Navigation States
class BottomNavigationState extends Equatable {
  final int currentIndex;

  const BottomNavigationState({this.currentIndex = 0});

  @override
  List<Object> get props => [currentIndex];
}
class BottomNavigationBloc extends Bloc<BottomNavigationEvent, BottomNavigationState> {
  BottomNavigationBloc() : super(const BottomNavigationState()) {
    // Register the event handler for NavigationTapped
    on<NavigationTapped>((event, emit) {
      emit(BottomNavigationState(currentIndex: event.index));
    });
  }
}

/*
// Bottom Navigation Bloc
class BottomNavigationBloc extends Bloc<BottomNavigationEvent, BottomNavigationState> {
  BottomNavigationBloc() : super(const BottomNavigationState());

  @override
  Stream<BottomNavigationState> mapEventToState(BottomNavigationEvent event) async* {
    if (event is NavigationTapped) {
      yield BottomNavigationState(currentIndex: event.index);
    }
  }
}
*/



