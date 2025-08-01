// Events
import 'package:hb_booking_mobile_app/search/destination/state_destination.dart';
import 'package:hb_booking_mobile_app/search/model/model_locaton.dart';
import 'package:hb_booking_mobile_app/utils/base_url.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import 'event_destination.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FetchBranches extends DestinationEvent {}

class DestinationBloc extends Bloc<DestinationEvent, DestinationState> {
  DestinationBloc() : super(DestinationInitial()) {
    on<FetchBranches>(_onFetchBranches);
    on<DestinationSelected>((event, emit) {
      emit(DestinationSelectionSuccess(event.destination));
    });
  }

  Future<void> _onFetchBranches(FetchBranches event, Emitter<DestinationState> emit) async {
    emit(DestinationLoading());
    try {
      final response = await http.get(Uri.parse('${base_url}branch/getBranches'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final branchData = BranchLocationModel.fromJson(data).data;
        if (branchData != null) {
          final branchNames = branchData.map((branch) => branch.name ?? '').where((name) => name.isNotEmpty).toList();
          emit(DestinationBranchesLoaded(branchNames));
        }
      } else {
        emit(DestinationError("Failed to load branches"));
      }
    } catch (e) {
      emit(DestinationError("Failed to load branches"));
    }
  }
}


/*class DestinationBloc extends Bloc<DestinationEvent, DestinationState> {
  DestinationBloc() : super(DestinationInitial()) {
    on<DestinationSelected>((event, emit) {
      emit(DestinationSelectionSuccess(event.destination));
    });
  }


}*/







