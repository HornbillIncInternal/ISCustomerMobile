/*abstract class SupportEvent {}

class SubmitSupportForm extends SupportEvent {
  final String branchId;
  final String message;
  final String subject;


  SubmitSupportForm({required this.branchId,required this.message, required this.subject});
}*/
abstract class SupportEvent {}

class SubmitSupportForm extends SupportEvent {
  final String branchId;
  final String message;
  final String? subject;

  SubmitSupportForm({
    required this.branchId,
    required this.message,
    this.subject,
  });
}
