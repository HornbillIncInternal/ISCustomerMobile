import 'package:hb_booking_mobile_app/profile/support/customer_support_bloc.dart';
import 'package:hb_booking_mobile_app/profile/support/customer_support_event.dart';
import 'package:hb_booking_mobile_app/profile/support/customer_support_state.dart';
import 'package:hb_booking_mobile_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SupportForm extends StatefulWidget {
  final String branchId;

  const SupportForm({super.key, required this.branchId});

  @override
  _SupportFormState createState() => _SupportFormState();
}

class _SupportFormState extends State<SupportForm> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(  // Add Scaffold here
      appBar: AppBar(
        title: Text('Support Form'),
      ),
      body: BlocListener<SupportBloc, SupportState>(
        listener: (context, state) {
          if (state is SupportSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Request successfully submitted")),
            );
            Navigator.pop(context);
          } else if (state is SupportError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        child: BlocBuilder<SupportBloc, SupportState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Subject Field
                    TextFormField(
                      controller: _subjectController,
                      decoration: InputDecoration(labelText: 'Subject'),
                      validator: (value) {
                        if (value != null && value.length > 500) {
                          return 'Subject can\'t exceed 500 characters';
                        }
                        return null;
                      },
                    ),

                    // Message Field
                    TextFormField(
                      controller: _messageController,
                      decoration: InputDecoration(labelText: 'Message'),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Message is required';
                        } else if (value.length > 500) {
                          return 'Message can\'t exceed 500 characters';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 16),

                    // Submit Button
                    state is SupportLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          BlocProvider.of<SupportBloc>(context).add(
                            SubmitSupportForm(
                              branchId: widget.branchId,
                              message: _messageController.text,
                              subject: _subjectController.text,
                            ),
                          );
                        }
                      },
                      child: Text('Submit',style: TextStyle(color: primary_color,),),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
