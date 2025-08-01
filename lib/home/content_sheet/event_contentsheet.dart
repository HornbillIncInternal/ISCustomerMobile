// Define the events
import 'package:equatable/equatable.dart';

abstract class ContentSheetEvent extends Equatable {
  const ContentSheetEvent();

  @override
  List<Object?> get props => [];
}

class FetchAssets extends ContentSheetEvent {
  final String location;
  final String? asset;
  final String? startDate;
  final String? startTime;
  final String? endDate;
  final String? endTime;

  const FetchAssets({
    required this.location,
    this.asset,
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
  });

  @override
  List<Object?> get props => [location, asset, startDate, startTime, endDate, endTime];
}
// abstract class ContentSheetEvent extends Equatable {
//   const ContentSheetEvent();
//
//   @override
//   List<Object?> get props => [];
// }
//
// class FetchAssets extends ContentSheetEvent {
//   final String location;
//   final String? asset;
//   final String? start;
//   final String? end;
//
//   const FetchAssets({
//     required this.location,
//     this.asset,
//     this.start,
//     this.end,
//   });
//
//   @override
//   List<Object?> get props => [location, asset, start, end];
// }


