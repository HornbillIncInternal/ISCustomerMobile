import 'package:hb_booking_mobile_app/authentication/forgot/bloc_forgot.dart';
import 'package:hb_booking_mobile_app/authentication/forgot/change_password.dart';
import 'package:hb_booking_mobile_app/authentication/forgot/event_forgot.dart';
import 'package:hb_booking_mobile_app/authentication/forgot/state_forgot.dart';
import 'package:hb_booking_mobile_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../utils/is_loader.dart';

class OtpPopup extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  OtpPopup();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
      listener: (context, state) {
        if (state is OtpVerificationSuccess) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => ChangePassword()),
          );
        } else if (state is OtpVerificationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
        else if (state is ResendOtpSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is ResendOtpFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            Dialog(
              insetPadding: EdgeInsets.all(20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
              backgroundColor: white_color,
              child: Wrap(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 50, horizontal: 30),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Enter OTP",
                            style: TextStyle(
                              fontSize: 19,
                              color: dark_text_color,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: PinCodeTextField(
                            controller: _controller,
                            length: 6,
                            appContext: context,
                            onChanged: (v) {},
                            textStyle: TextStyle(
                              fontSize: 16,
                              color: dark_text_color,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                            ),
                            keyboardType: TextInputType.number,
                            animationType: AnimationType.scale,
                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.box,
                              activeColor: icon_disabled_color,
                              inactiveColor: icon_disabled_color,
                              selectedColor: primary_color,
                              errorBorderColor: icon_disabled_color,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            showCursor: false,
                          ),
                        ),
                        SizedBox(height: 30),
                        state is OtpVerificationLoading
                            ? OfficeLoader()
                            :     ElevatedButton(
                          onPressed: () {
                            final otp = _controller.text.trim();
                            if (otp.isNotEmpty) {
                              context.read<ForgotPasswordBloc>().add(VerifyOtpRequested(otp));
                            }
                          },
                          child:  Text(
                            "Verify",
                            style: TextStyle(color: primary_color),
                          ),
                        ),
                        SizedBox(height: 20),
                        state is ResendOtpLoading
                        ? OfficeLoader():   TextButton(
                          onPressed: () {
                            context.read<ForgotPasswordBloc>().add(ResendOtpRequested());

                          },
                          child: Text(
                            "Resend OTP",
                            style: TextStyle(
                              color: dark_text_color,
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/*class OtpPopup extends StatelessWidget{

  TextEditingController _controller = TextEditingController();

  OtpPopup();


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Dialog(
          insetPadding: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          backgroundColor: white_color,
          child: Wrap(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 50,horizontal: 30),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Enter Otp",
                        style: TextStyle(
                            fontSize: 19,
                            color: dark_text_color,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w700
                        ),
                      ),
                    ),
                    SizedBox(height: 30,),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: PinCodeTextField(
                        controller: _controller,
                        length: 6,
                        appContext: context,
                        onChanged: (v){
                        },
                        textStyle: TextStyle(
                            fontSize: 16,
                            color: dark_text_color,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500
                        ),
                        keyboardType: TextInputType.number,
                        animationType: AnimationType.scale,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          activeColor: icon_disabled_color,
                          inactiveColor: icon_disabled_color,
                          selectedColor: primary_color,
                          errorBorderColor: icon_disabled_color,
                          borderRadius: BorderRadius.circular(6),
                          // fieldHeight: 50,
                          // fieldWidth: 40,
                        ),
                        showCursor: false,
                      ),
                    ),
                    SizedBox(height: 30,),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ChangePassword(),
                          ),
                        );
                      },
                      child: Text(
                        "Verify",
                        style: TextStyle(color: primary_color),
                      ),
                    ),

                    SizedBox(height: 20,),
                    TextButton(
                        onPressed: (){

                        },
                        child: Text(
                          "Resend Otp",
                          style: TextStyle(
                              color: dark_text_color,
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              fontWeight: FontWeight.w500
                          ),
                        )
                    )
                  ],
                ),
              )
            ],
          ),
        ),


      ],
    );


  }

}*/
