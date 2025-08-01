import 'package:hb_booking_mobile_app/search/state_search.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'event_search.dart';



class BookingSearchBloc extends Bloc<BookingSearchEvent, BookingSearchState> {
  BookingSearchBloc() : super(const BookingSearchState()) {
    on<UpdateStep>((event, emit) {
      emit(state.copyWith(step: event.step));
    });

    on<SelectLocation>((event, emit) {
      emit(state.copyWith(
        selectedLocation: event.location,
        step: BookingStep.selectGuests,
      ));
    });

    on<SelectAsset>((event, emit) {
      emit(state.copyWith(
        selectedAsset: event.asset,
        step: BookingStep.selectDate,
      ));
    });

    // Updated to handle separate date selection
    on<SelectDateRange>((event, emit) {
      emit(state.copyWith(
        selectedDate: event.startDate,
        selectedEndDate: event.endDate,
      ));
    });

    // New event handler for time selection
    on<SelectTimeRange>((event, emit) {
      emit(state.copyWith(
        selectedStartTime: event.startTime,
        selectedEndTime: event.endTime,
      ));
    });

    on<ClearAll>((event, emit) {
      emit(const BookingSearchState());
    });

    on<PerformSearch>((event, emit) {
      // Handle the search logic or trigger the navigation
    });
  }
}

/*
class BookingSearchBloc extends Bloc<BookingSearchEvent, BookingSearchState> {
  BookingSearchBloc() : super(const BookingSearchState()) {
    on<UpdateStep>((event, emit) {
      emit(state.copyWith(step: event.step));
    });

    on<SelectLocation>((event, emit) {
      emit(state.copyWith(
        selectedLocation: event.location,
        step: BookingStep.selectGuests,
      ));
    });

    on<SelectAsset>((event, emit) {
      emit(state.copyWith(
        selectedAsset: event.asset,
        step: BookingStep.selectDate,
      ));
    });

    on<SelectDateRange>((event, emit) {
      emit(state.copyWith(
        isoStart: event.start,
        isoEnd: event.end,
      ));
    });

    on<ClearAll>((event, emit) {
      emit(const BookingSearchState());
    });

    on<PerformSearch>((event, emit) {
      // Handle the search logic or trigger the navigation
    });
  }
}
*/






