import 'package:equatable/equatable.dart';



class ExploreTabState {
  final int selectedIndex;
  final String? selectedLocation;
  final String? selectedAsset;
  final String? isoStart;
  final String? isoEnd;

  ExploreTabState({
    required this.selectedIndex,
    this.selectedLocation,
    this.selectedAsset,
    this.isoStart,
    this.isoEnd,
  });
}

/*
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitialState extends HomeState {}

class HomeLoadedState extends HomeState {
  final String? selectedLocation;
  final String? selectedAsset;
  final String? isoStart;
  final String? isoEnd;

  const HomeLoadedState({this.selectedLocation, this.selectedAsset, this.isoStart, this.isoEnd});

  @override
  List<Object?> get props => [selectedLocation, selectedAsset, isoStart, isoEnd];
}*/
