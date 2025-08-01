abstract class SignupEvent {}

class SignupButtonPressed extends SignupEvent {
  final String name;
  final String email;
  final String password;

  SignupButtonPressed({required this.name, required this.email, required this.password});
}
