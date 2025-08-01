import 'package:hb_booking_mobile_app/booking_steps.dart';
import 'package:equatable/equatable.dart';

import 'package:equatable/equatable.dart';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';


import 'package:equatable/equatable.dart';

enum BookingStep { selectDestination, selectGuests, selectDate }

class BookingSearchState extends Equatable {
  final BookingStep step;
  final String? selectedLocation;
  final String? selectedAsset;
  final String? selectedDate; // Date only (YYYY-MM-DD)
  final String? selectedStartTime; // Time only (HH:mm:ss) - nullable
  final String? selectedEndTime; // Time only (HH:mm:ss) - nullable
  final String? selectedEndDate; // End date for range bookings

  const BookingSearchState({
    this.step = BookingStep.selectDestination,
    this.selectedLocation,
    this.selectedAsset,
    this.selectedDate,
    this.selectedStartTime, // Can be null
    this.selectedEndTime,   // Can be null
    this.selectedEndDate,
  });

  BookingSearchState copyWith({
    BookingStep? step,
    String? selectedLocation,
    String? selectedAsset,
    String? selectedDate,
    String? selectedStartTime,
    String? selectedEndTime,
    String? selectedEndDate,
  }) {
    return BookingSearchState(
      step: step ?? this.step,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      selectedAsset: selectedAsset ?? this.selectedAsset,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedStartTime: selectedStartTime ?? this.selectedStartTime,
      selectedEndTime: selectedEndTime ?? this.selectedEndTime,
      selectedEndDate: selectedEndDate ?? this.selectedEndDate,
    );
  }

  @override
  List<Object?> get props => [
    step,
    selectedLocation ?? '',
    selectedAsset ?? '',
    selectedDate ?? '',
    selectedStartTime,  // Can be null
    selectedEndTime,    // Can be null
    selectedEndDate ?? '',
  ];
}

/*
class BookingSearchState extends Equatable {
  final BookingStep step;
  final String? selectedLocation;
  final String? selectedAsset;
  final String? isoStart;
  final String? isoEnd;

  const BookingSearchState({
    this.step = BookingStep.selectDestination,
    this.selectedLocation,
    this.selectedAsset,
    this.isoStart,
    this.isoEnd,
  });

  BookingSearchState copyWith({
    BookingStep? step,
    String? selectedLocation,
    String? selectedAsset,
    String? isoStart,
    String? isoEnd,
  }) {
    return BookingSearchState(
      step: step ?? this.step,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      selectedAsset: selectedAsset ?? this.selectedAsset,
      isoStart: isoStart ?? this.isoStart,
      isoEnd: isoEnd ?? this.isoEnd,
    );
  }

  @override
  List<Object?> get props => [
    step,
    selectedLocation ?? '',
    selectedAsset ?? '',
    isoStart ?? '',
    isoEnd ?? '',
  ];
}
*/



