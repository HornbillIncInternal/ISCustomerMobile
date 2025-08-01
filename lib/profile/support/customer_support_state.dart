/*abstract class SupportState {}

class SupportInitial extends SupportState {}

class SupportLoading extends SupportState {}

class SupportSuccess extends SupportState {
  final String message;

  SupportSuccess(this.message);
}

class SupportError extends SupportState {
  final String error;

  SupportError(this.error);
}*/
abstract class SupportState {}

class SupportInitial extends SupportState {}

class SupportLoading extends SupportState {}

class SupportSuccess extends SupportState {
  final String message;

  SupportSuccess({required this.message});
}

class SupportError extends SupportState {
  final String error;

  SupportError({required this.error});
}
