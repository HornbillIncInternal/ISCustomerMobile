import 'package:hb_booking_mobile_app/search/state_search.dart';
import 'package:equatable/equatable.dart';


import 'package:equatable/equatable.dart';

import '../booking_steps.dart';
import 'package:equatable/equatable.dart';

import 'package:equatable/equatable.dart';





/*abstract class BookingSearchEvent extends Equatable {
  const BookingSearchEvent();

  @override
  List<Object?> get props => [];
}

class UpdateStep extends BookingSearchEvent {
  final BookingStep step;

  const UpdateStep(this.step);

  @override
  List<Object?> get props => [step];
}

class SelectLocation extends BookingSearchEvent {
  final String location;

  const SelectLocation(this.location);

  @override
  List<Object?> get props => [location];
}

class SelectAsset extends BookingSearchEvent {
  final String asset;

  const SelectAsset(this.asset);

  @override
  List<Object?> get props => [asset];
}

class SelectDateRange extends BookingSearchEvent {
  final String start;
  final String end;

  const SelectDateRange(this.start, this.end);

  @override
  List<Object?> get props => [start, end];
}

class ClearAll extends BookingSearchEvent {}*/
abstract class BookingSearchEvent extends Equatable {
  const BookingSearchEvent();

  @override
  List<Object?> get props => [];
}

class UpdateStep extends BookingSearchEvent {
  final BookingStep step;

  const UpdateStep(this.step);

  @override
  List<Object?> get props => [step];
}

class SelectLocation extends BookingSearchEvent {
  final String location;

  const SelectLocation(this.location);

  @override
  List<Object?> get props => [location];
}

class SelectAsset extends BookingSearchEvent {
  final String asset;

  const SelectAsset(this.asset);

  @override
  List<Object?> get props => [asset];
}

class SelectDateRange extends BookingSearchEvent {
  final String startDate;
  final String? endDate;

  const SelectDateRange(this.startDate, [this.endDate]);

  @override
  List<Object?> get props => [startDate, endDate];
}

class SelectTimeRange extends BookingSearchEvent {
  final String startTime;
  final String endTime;

  const SelectTimeRange(this.startTime, this.endTime);

  @override
  List<Object?> get props => [startTime, endTime];
}

class ClearAll extends BookingSearchEvent {}
class PerformSearch extends BookingSearchEvent {}






