import 'package:equatable/equatable.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';



abstract class DateState extends Equatable {
  const DateState();

  @override
  List<Object?> get props => [];
}

class DateInitial extends DateState {}

class DateSelectionSuccess extends DateState {
  final PickerDateRange dateRange;

  const DateSelectionSuccess(this.dateRange);

  @override
  List<Object?> get props => [dateRange];
}

/*
abstract class DateState {}

class DateInitial extends DateState {}

class DateSelectionSuccess extends DateState {
  final PickerDateRange dateRange;
  final DateTime startTime;
  final DateTime endTime;

  DateSelectionSuccess(this.dateRange, this.startTime, this.endTime);
}*/
