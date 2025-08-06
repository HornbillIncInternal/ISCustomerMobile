import 'package:hb_booking_mobile_app/home/model/model_assets.dart';
import 'package:hb_booking_mobile_app/home/model/model_review.dart';
import 'package:hb_booking_mobile_app/home/workspcae_detail/bloc_workspacedetail.dart';
import 'package:hb_booking_mobile_app/home/workspcae_detail/package_model.dart';
import 'package:equatable/equatable.dart';

// States
// States
abstract class WorkspaceDetailState extends Equatable {
  const WorkspaceDetailState();

  @override
  List<Object> get props => [];
}

class WorkspaceDetailInitial extends WorkspaceDetailState {}

class WorkspaceDetailLoading extends WorkspaceDetailState {}

class WorkspaceDetailLoaded extends WorkspaceDetailState {
  final Datum asset;
  final int count;
  final double totalPrice;
  final DateTime startDate;
  final DateTime endDate;
  final bool isExpanded;
  final EffectivePackagesData? effectivePackagesData;

  const WorkspaceDetailLoaded({
    required this.asset,
    required this.count,
    required this.totalPrice,
    required this.startDate,
    required this.endDate,
    this.isExpanded = false,
    this.effectivePackagesData,
  });

  @override
  List<Object> get props => [
    asset,
    count,
    totalPrice,
    startDate,
    endDate,
    isExpanded,
    effectivePackagesData ?? '',
  ];
}

class WorkspaceDetailError extends WorkspaceDetailState {
  final String message;

  const WorkspaceDetailError(this.message);

  @override
  List<Object> get props => [message];
}