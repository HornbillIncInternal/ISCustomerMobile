import 'dart:async';
import 'package:hb_booking_mobile_app/connectivity/connectivity_event.dart';
import 'package:hb_booking_mobile_app/connectivity/connectivity_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final Connectivity _connectivity;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  ConnectivityBloc(this._connectivity) : super(ConnectivityCheckingState()) {
    on<CheckConnectivity>((event, emit) async {
      final result = await _connectivity.checkConnectivity();
      emit(_getConnectivityState(result));
    });

    on<ConnectivityChanged>((event, emit) {
      emit(event.isConnected ? ConnectedState() : DisconnectedState());
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
          (result) {
        add(ConnectivityChanged(result != ConnectivityResult.none));
      },
    );
  }

  ConnectivityState _getConnectivityState(ConnectivityResult result) {
    return result == ConnectivityResult.none ? DisconnectedState() : ConnectedState();
  }

  @override
  Future<void> close() {
    _connectivitySubscription.cancel();
    return super.close();
  }
}
