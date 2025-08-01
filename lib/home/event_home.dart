import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';



abstract class ExploreTabEvent {}

class TabSelected extends ExploreTabEvent {
  final int index;

  TabSelected(this.index);
}

class InitializeExploreTabEvent extends ExploreTabEvent {
  final String? selectedLocation;
  final String? selectedAsset;
  final String? isoStart;
  final String? isoEnd;

  InitializeExploreTabEvent({
    this.selectedLocation,
    this.selectedAsset,
    this.isoStart,
    this.isoEnd,
  });
}
/*// Events
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class InitializeHomeEvent extends HomeEvent {
  final String? location;
  final String? asset;
  final String? start;
  final String? end;

  const InitializeHomeEvent(this.location, this.asset, this.start, this.end);

  @override
  List<Object?> get props => [location, asset, start, end];
}*/
