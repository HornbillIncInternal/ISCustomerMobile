import 'package:equatable/equatable.dart';

import '../model/model_assets.dart';

abstract class ContentSheetState extends Equatable {
  const ContentSheetState();

  @override
  List<Object?> get props => [];
}

class ContentSheetInitial extends ContentSheetState {}

class ContentSheetLoading extends ContentSheetState {}

class ContentSheetLoaded extends ContentSheetState {
  final AssetData assetData;

  const ContentSheetLoaded(this.assetData);

  @override
  List<Object?> get props => [assetData];
}

class ContentSheetError extends ContentSheetState {
  final String message;

  const ContentSheetError(this.message);

  @override
  List<Object?> get props => [message];
}


/*
abstract class ContentSheetState extends Equatable {
  const ContentSheetState();

  @override
  List<Object> get props => [];
}

class ContentSheetInitial extends ContentSheetState {}

class ContentSheetLoading extends ContentSheetState {}

class ContentSheetLoaded extends ContentSheetState {
  final AssetData assetData;

  const ContentSheetLoaded(this.assetData);

  @override
  List<Object> get props => [assetData];
}

class ContentSheetError extends ContentSheetState {
  final String message;

  const ContentSheetError(this.message);

  @override
  List<Object> get props => [message];
}*/
