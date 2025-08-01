
import 'package:equatable/equatable.dart';

abstract class DestinationEvent extends Equatable {
  const DestinationEvent();

  @override
  List<Object?> get props => [];
}

class DestinationSelected extends DestinationEvent {
  final String destination;

  const DestinationSelected(this.destination);

  @override
  List<Object?> get props => [destination];
}