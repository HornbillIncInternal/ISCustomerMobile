import 'package:hb_booking_mobile_app/search/date/event_date.dart';
import 'package:hb_booking_mobile_app/search/date/state_date.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class DateBloc extends Bloc<DateEvent, DateState> {
  DateBloc() : super(DateInitial()) {
    on<DateSelected>(_onDateSelected);
  }

  void _onDateSelected(DateSelected event, Emitter<DateState> emit) {
    emit(DateSelectionSuccess(event.dateRange));
  }
}

/*
class DateBloc extends Bloc<DateEvent, DateState> {
  DateBloc() : super(DateInitial());

  @override
  Stream<DateState> mapEventToState(DateEvent event) async* {
    if (event is DateSelected) {
      DateTime startTime = _convertFormat(event.dateRange.startDate.toString(), event.startTime);
      DateTime endTime = _convertFormat(event.dateRange.endDate.toString(), event.endTime);
      yield DateSelectionSuccess(event.dateRange, startTime, endTime);
    }
  }

  DateTime _convertFormat(String dateString, String timeString) {
    DateTime date = DateTime.parse(dateString);
    DateTime time = DateFormat('hh:mm a').parse(timeString);
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}*/
