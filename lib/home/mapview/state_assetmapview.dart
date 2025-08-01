import 'package:hb_booking_mobile_app/home/model/model_assets.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/*abstract class AssetMapState extends Equatable {
  const AssetMapState();

  @override
  List<Object> get props => [];
}

class AssetMapInitial extends AssetMapState {}

class AssetMapLoading extends AssetMapState {}

class AssetMapLoaded extends AssetMapState {
  final Set<Marker> markers;
  final Datum? selectedAsset;
  final int? selectedIndex;

  const AssetMapLoaded({
    required this.markers,
    this.selectedAsset,
    this.selectedIndex,
  });

  @override
  List<Object> get props => [markers, selectedAsset ?? '', selectedIndex ?? 0];
}

class AssetMapError extends AssetMapState {
  final String message;

  const AssetMapError(this.message);

  @override
  List<Object> get props => [message];
}*/
// States
abstract class AssetMapState extends Equatable {
  const AssetMapState();

  @override
  List<Object> get props => [];
}

class AssetMapInitial extends AssetMapState {}

class AssetMapLoading extends AssetMapState {}

class AssetMapLoaded extends AssetMapState {
  final Set<Marker> markers;
  final Datum? selectedAsset;
  final int? selectedIndex;

  const AssetMapLoaded({
    required this.markers,
    this.selectedAsset,
    this.selectedIndex,
  });

  @override
  List<Object> get props => [markers, selectedAsset ?? '', selectedIndex ?? 0];
}

class AssetMapError extends AssetMapState {
  final String message;

  const AssetMapError(this.message);

  @override
  List<Object> get props => [message];
}

