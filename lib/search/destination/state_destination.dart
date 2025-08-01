import 'package:equatable/equatable.dart';

abstract class DestinationState extends Equatable {
  const DestinationState();

  @override
  List<Object?> get props => [];
}

class DestinationInitial extends DestinationState {}

class DestinationSelectionSuccess extends DestinationState {
  final String destination;

  const DestinationSelectionSuccess(this.destination);

  @override
  List<Object?> get props => [destination];
}
class DestinationLoading extends DestinationState {}

class DestinationBranchesLoaded extends DestinationState {
  final List<String> branches;
  const DestinationBranchesLoaded(this.branches);

  @override
  List<Object?> get props => [branches];
}

class DestinationError extends DestinationState {
  final String message;
  const DestinationError(this.message);

  @override
  List<Object?> get props => [message];
}
