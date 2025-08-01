import 'package:hb_booking_mobile_app/home/model/model_assets.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';




// Events
abstract class AssetMapEvent extends Equatable {
  const AssetMapEvent();
}
class FetchAssetsEvent extends AssetMapEvent {
  final String location;
  final String asset;
  final String? startDate;
  final String? startTime; // Can be null
  final String? endDate;
  final String? endTime;   // Can be null
  final BuildContext context;

  const FetchAssetsEvent({
    required this.location,
    required this.asset,
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
    required this.context,
  });

  @override
  List<Object?> get props => [location, asset, startDate, startTime, endDate, endTime, context];
}
/*class FetchAssetsEvent extends AssetMapEvent {
  final String location;
  final String asset;
  final String start;
  final String end;
  final BuildContext context;
  const FetchAssetsEvent({
    required this.location,
    required this.asset,
    required this.start,
    required this.end,
    required this.context,
  });

  @override
  List<Object?> get props => [location, asset, start, end, context];
}*/

class SelectMarkerEvent extends AssetMapEvent {
  final Datum selectedAsset;
  final int index;
  final BuildContext context;
  const SelectMarkerEvent({
    required this.selectedAsset,
    required this.index,
    required this.context,
  });

  @override
  List<Object?> get props => [selectedAsset, index];
}