import 'package:hb_booking_mobile_app/authentication/Signup/signup_bloc.dart';
import 'package:hb_booking_mobile_app/authentication/Signup/signup_event.dart';
import 'package:hb_booking_mobile_app/authentication/Signup/signup_state.dart';
import 'package:hb_booking_mobile_app/authentication/textfield_widget.dart';
import 'package:hb_booking_mobile_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hb_booking_mobile_app/utils/is_loader.dart';


class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  bool obscurePwd = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back
          },
        ),
      ),
      body: BlocProvider(
        create: (context) => SignupBloc(),
        child: BlocConsumer<SignupBloc, SignupState>(
          listener: (context, state) {
            if (state is SignupSuccess) {
              // Navigate to login screen after successful signup
              Navigator.of(context).pop(); // Go back to login screen
            } else if (state is SignupFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          builder: (context, state) {
            if (state is SignupLoading) {
              return Center(child: OfficeLoader());
            }

            return Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Create a new account",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  SizedBox(height: 41),
                  TextFieldWidget.withController(
                    _nameController,
                    "Name",
                        (t) {},
                  ),
                  SizedBox(height: 4),
                  TextFieldWidget.withController(
                    _emailController,
                    "Email address",
                        (t) {},
                    email: true,
                  ),
                  SizedBox(height: 4),
                  TextFieldWidget.withController(
                    _pwdController,
                    "Password",
                        (t) {},
                    password: true,
                    passwordObscure: obscurePwd,
                    onPasswordVisibilityChange: () {
                      setState(() {
                        obscurePwd = !obscurePwd;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<SignupBloc>().add(SignupButtonPressed(
                        name: _nameController.text,
                        email: _emailController.text,
                        password: _pwdController.text,
                      ));
                    },
                    child: Text("Sign up", style: TextStyle(color: primary_color)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

