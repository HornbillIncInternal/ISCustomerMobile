import 'package:hb_booking_mobile_app/authentication/Signup/screen_signup.dart';
import 'package:hb_booking_mobile_app/authentication/bloc_login.dart';
import 'package:hb_booking_mobile_app/authentication/event_login.dart';
import 'package:hb_booking_mobile_app/authentication/forgot/screen_forgot_password.dart';
import 'package:hb_booking_mobile_app/authentication/state_login.dart';
import 'package:hb_booking_mobile_app/authentication/textfield_widget.dart';
import 'package:hb_booking_mobile_app/connectivity/connectivity_bloc.dart';
import 'package:hb_booking_mobile_app/connectivity/connectivity_state.dart';
import 'package:hb_booking_mobile_app/home/model/model_assets.dart';
import 'package:hb_booking_mobile_app/home/workspcae_detail/screen_workspacedetail.dart';
import 'package:hb_booking_mobile_app/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hb_booking_mobile_app/utils/is_loader.dart';
import 'package:shared_preferences/shared_preferences.dart';
class LoginConfirmationScreen extends StatefulWidget {
  final Datum apiResponse;
  final int index;
  final String? selectedDate;
  final String? selectedStartTime;
  final String? selectedEndTime;
  final String? selectedEndDate;
  const LoginConfirmationScreen({
    required this.apiResponse,
    required this.index,
    this.selectedDate,
    this.selectedStartTime,
    this.selectedEndTime,
    this.selectedEndDate,
  });
  @override
  _LoginConfirmationScreenState createState() => _LoginConfirmationScreenState();
}

class _LoginConfirmationScreenState extends State<LoginConfirmationScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  bool obscurePwd = true;
  bool _remember = false;
  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  // Load remember me and email preferences
  void _loadRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? rememberMe = prefs.getBool('rememberMe');
    String? savedEmail = prefs.getString('email');

    setState(() {
      _remember = rememberMe ?? false;
      if (_remember) {
        _emailController.text = savedEmail ?? '';
      }
    });
  }

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
      body: BlocBuilder<ConnectivityBloc, ConnectivityState>(
        builder: (context, connectivityState) {
          if (connectivityState is DisconnectedState) {
            // Display no connection image when disconnected
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Padding(
                    padding: const EdgeInsets.all(45.0),
                    child: Image.asset('assets/images/no_internet.png',),
                  ),
                  SizedBox(height: 16),

                ],
              ),
            );
          }
    return BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            // Navigate back to the main screen and switch to the profile tab
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => WorkspaceDetailScreen(
                  apiResponse: widget.apiResponse,
                  index: widget.index,
                  selectedDate: widget.selectedDate,
                  selectedEndDate: widget.selectedEndDate,
                  selectedStartTime: widget.selectedStartTime,
                  selectedEndTime: widget.selectedEndTime,

                ),
              ),
                  (Route<dynamic> route) => false,
            );
          } else if (state is LoginFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          if (state is LoginLoading) {
            return Center(child: OfficeLoader());
          }

          return Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Sign in to continue",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(height: 41),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _remember = !_remember;
                          });
                        },
                        child: Container(
                          color: Colors.transparent,
                          padding: EdgeInsets.symmetric(vertical: 25, horizontal: 5),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: Duration(milliseconds: 100),
                                height: 12,
                                width: 12,
                                decoration: BoxDecoration(
                                  color: _remember ? Colors.blue : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  CupertinoIcons.check_mark,
                                  size: 10,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 7),
                              Text(
                                "Remember me",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w300,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ForgotPassword(),
                            ),
                          );
                        },
                        child: Container(
                          color: Colors.transparent,
                          padding: EdgeInsets.symmetric(vertical: 25, horizontal: 5),
                          child: Text(
                            "Forgot Password",
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w300,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.read<LoginBloc>().add(LoginButtonPressed(
                      email: _emailController.text,
                      password: _pwdController.text,
                      rememberMe: _remember,
                    ));
                  },
                  child: Text("Sign in",style: TextStyle(color: primary_color),),
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SignupScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "Don't have an account? Sign up",
                    style: TextStyle(
                      color: Colors.blue,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
  },
),
    );
  }
}