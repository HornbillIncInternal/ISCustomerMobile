import 'package:equatable/equatable.dart';

import '../model/model_assets.dart';




/*
// Events
abstract class WorkspaceDetailEvent extends Equatable {
  const WorkspaceDetailEvent();

  @override
  List<Object> get props => [];
}

class InitializeWorkspaceDetail extends WorkspaceDetailEvent {
  final Datum apiResponse;
  final DateTime startDate;
  final DateTime endDate;

  const InitializeWorkspaceDetail({
    required this.apiResponse,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [apiResponse, startDate, endDate];
}

class UpdatePackageData extends WorkspaceDetailEvent {
  final String packageId;
  final String startDate;
  final String endDate;

  const UpdatePackageData({
    required this.packageId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [packageId, startDate, endDate];
}

class UpdateDateRange extends WorkspaceDetailEvent {
  final DateTime startDate;
  final DateTime endDate;

  const UpdateDateRange(this.startDate, this.endDate);

  @override
  List<Object> get props => [startDate, endDate];
}

class ToggleDescription extends WorkspaceDetailEvent {}*/

// Events
abstract class WorkspaceDetailEvent extends Equatable {
  const WorkspaceDetailEvent();

  @override
  List<Object> get props => [];
}

class InitializeWorkspaceDetail extends WorkspaceDetailEvent {
  final Datum apiResponse;
  final DateTime startDate;
  final DateTime endDate;

  const InitializeWorkspaceDetail({
    required this.apiResponse,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [apiResponse, startDate, endDate];
}

class UpdateDateRange extends WorkspaceDetailEvent {
  final DateTime startDate;
  final DateTime endDate;

  const UpdateDateRange(this.startDate, this.endDate);

  @override
  List<Object> get props => [startDate, endDate];
}

class ToggleDescription extends WorkspaceDetailEvent {}

class IncrementCount extends WorkspaceDetailEvent {}

class DecrementCount extends WorkspaceDetailEvent {}


class FetchAvailabilityAndUpdate extends WorkspaceDetailEvent {
  final String assetId;
  final DateTime startDate;
  final DateTime endDate;
  final bool? hasTimeSelected;

  const FetchAvailabilityAndUpdate({
    required this.assetId,
    required this.startDate,
    required this.endDate,
    this.hasTimeSelected,
  });

  @override
  List<Object> get props => [assetId, startDate, endDate, hasTimeSelected ?? false];
}
