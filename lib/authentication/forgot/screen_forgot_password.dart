import 'package:hb_booking_mobile_app/authentication/forgot/bloc_forgot.dart';
import 'package:hb_booking_mobile_app/authentication/forgot/event_forgot.dart';
import 'package:hb_booking_mobile_app/authentication/forgot/otp_popup.dart';
import 'package:hb_booking_mobile_app/authentication/forgot/state_forgot.dart';
import 'package:hb_booking_mobile_app/authentication/textfield_widget.dart';
import 'package:hb_booking_mobile_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/is_loader.dart';



class ForgotPassword extends StatelessWidget {
  const ForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForgotPasswordBloc(),
      child: ForgotPasswordForm(),
    );
  }
}

class ForgotPasswordForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();

    return BlocProvider(
        create: (context) => ForgotPasswordBloc(),
      child: Scaffold(
        body: BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
            listener: (context, state) {
              if (state is ForgotPasswordSuccess) {
                // Show success dialog or OTP popup
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return OtpPopup();
                  },
                );
              } else if (state is ForgotPasswordFailure) {
                // Show error message using a SnackBar or dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error)),
                );
              }
            },
          builder: (context, state) {
            return Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Text(
                        "Forgot Password",
                        style: TextStyle(
                            color: dark_text_color,
                            fontSize: 20,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w700
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.clip,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 50),
                    TextFieldWidget.withController(
                      emailController,
                      "Email address",
                          (t) {},
                      email: true,
                    ),

                    SizedBox(height: 20,),
                    state is ForgotPasswordLoading
                        ? OfficeLoader()
                        :   ElevatedButton(
                      onPressed: () {
                        final email = emailController.text.trim();
                        context.read<ForgotPasswordBloc>().add(ForgotPasswordRequested(email));

                      },
                      child: Text(
                        "Send Otp",
                        style: TextStyle(color: primary_color),
                      ),
                    ),
                    // TextField(
                    //   controller: emailController,
                    //   decoration: InputDecoration(labelText: "Email"),
                    // ),

                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}


/*
class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  "Forgot Password",
                  style: TextStyle(
                      color: dark_text_color,
                      fontSize: 20,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.clip,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 50,),
              TextFieldWidget("Email ", (e){
                setState(() {});
              },email: true,),
              SizedBox(height: 20,),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                      context: context,

                      builder: (BuildContext c) {
                        return OtpPopup();
                      });
                },
                child: Text(
                  "Send Otp",
                  style: TextStyle(color: primary_color),
                ),
              ),
              // ButtonPrimary(Languages.of(context)!.send, (){
              //   if(_emailText.isEmpty || checkEmail(_emailText)){
              //     showToast(Languages.of(context)!.invalid_email);
              //   } else if(!ConnectionStatus().getConnectionStatus()){
              //     showToast(Languages.of(context)!.no_network);
              //   } else{
              //     hideKeyboard(context);
              //     _provider.forgotPassword(_emailText,context);
              //   }
              // })
            ],
          ),
          Positioned(
            left: 20,
            top: 20,
            child: SafeArea(
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios,color: primary_color,),
                onPressed: () { Navigator.pop(context); },
              ),
            ),
          ),

        ],
      ),
    );
  }
}
*/
