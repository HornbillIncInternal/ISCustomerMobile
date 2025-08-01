import 'package:equatable/equatable.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

abstract class DateEvent extends Equatable {
  const DateEvent();

  @override
  List<Object?> get props => [];
}

class DateSelected extends DateEvent {
  final PickerDateRange dateRange;

  const DateSelected(this.dateRange);

  @override
  List<Object?> get props => [dateRange];
}
/*
abstract class DateEvent {}

class DateSelected extends DateEvent {
  final PickerDateRange dateRange;
  final String startTime;
  final String endTime;

  DateSelected(this.dateRange, this.startTime, this.endTime);
}*/
