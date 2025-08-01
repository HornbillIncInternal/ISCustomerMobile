import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hb_booking_mobile_app/home/model/model_assets.dart';

abstract class AssetState extends Equatable {
  const AssetState();

  @override
  List<Object?> get props => [];
}

class AssetInitial extends AssetState {}

class AssetLoading extends AssetState {}

class AssetLoaded extends AssetState {
  final AssetData assetData;
  final Set<Marker> markers;
  final Datum? selectedAsset;
  final int? selectedIndex;

  const AssetLoaded({
    required this.assetData,
    required this.markers,
    this.selectedAsset,
    this.selectedIndex,
  });

  @override
  List<Object?> get props => [assetData, markers, selectedAsset, selectedIndex];
}

class AssetError extends AssetState {
  final String message;

  const AssetError(this.message);

  @override
  List<Object?> get props => [message];
}