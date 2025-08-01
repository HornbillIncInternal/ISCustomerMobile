
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hb_booking_mobile_app/home/model/model_assets.dart';
abstract class AssetEvent extends Equatable {
  const AssetEvent();

  @override
  List<Object?> get props => [];
}

class FetchAssetsEvent extends AssetEvent {
  final String location;
  final String? asset;
  final String? startDate;
  final String? startTime;
  final String? endDate;
  final String? endTime;
  final BuildContext? context; // Optional for map markers

  const FetchAssetsEvent({
    required this.location,
    this.asset,
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
    this.context,
  });

  @override
  List<Object?> get props => [location, asset, startDate, startTime, endDate, endTime, context];
}

class SelectAssetEvent extends AssetEvent {
  final Datum selectedAsset;
  final int index;
  final BuildContext context;

  const SelectAssetEvent({
    required this.selectedAsset,
    required this.index,
    required this.context,
  });

  @override
  List<Object?> get props => [selectedAsset, index, context];
}