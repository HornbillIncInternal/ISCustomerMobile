import 'package:hb_booking_mobile_app/home/state_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'event_home.dart';


class ExploreTabBloc extends Bloc<ExploreTabEvent, ExploreTabState> {
  ExploreTabBloc()
      : super(ExploreTabState(selectedIndex: 0, selectedLocation: null, selectedAsset: null, isoStart: null, isoEnd: null)) {
    on<TabSelected>((event, emit) {
      emit(ExploreTabState(
        selectedIndex: event.index,
        selectedLocation: state.selectedLocation,
        selectedAsset: state.selectedAsset,
        isoStart: state.isoStart,
        isoEnd: state.isoEnd,
      ));
    });

    on<InitializeExploreTabEvent>((event, emit) {
      emit(ExploreTabState(
        selectedIndex: state.selectedIndex,
        selectedLocation: event.selectedLocation,
        selectedAsset: event.selectedAsset,
        isoStart: event.isoStart,
        isoEnd: event.isoEnd,
      ));
    });
  }
}

/*class ExploreTabBloc extends Bloc<ExploreTabEvent, ExploreTabState> {
  ExploreTabBloc() : super(ExploreTabState(selectedIndex: 0)) {
    on<TabSelected>((event, emit) {
      emit(ExploreTabState(selectedIndex: event.index));
    });
  }
}*/
