import 'package:hb_booking_mobile_app/authentication/bloc_login.dart';
import 'package:hb_booking_mobile_app/authentication/forgot/bloc_forgot.dart';
import 'package:hb_booking_mobile_app/authentication/forgot/event_forgot.dart';
import 'package:hb_booking_mobile_app/authentication/forgot/state_forgot.dart';
import 'package:hb_booking_mobile_app/authentication/screen_login.dart';
import 'package:hb_booking_mobile_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/constants.dart';

/*class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {

  TextEditingController _npController = TextEditingController();
  TextEditingController _ccpController = TextEditingController();


  bool obscurePwd1 = true;
  bool obscurePwd2 = true;
  bool obscurePwd3 = true;

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: Stack(
        children: [
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 30,
                ),

                ProfileLabelText("New Password"),
                TextFieldProfile(
                  _npController,
                  true,
                  "New Password",
                      (t) {},
                  password: true,
                  passwordObscure: obscurePwd2,
                  onPasswordVisibilityChange: () {
                    setState(() {
                      obscurePwd2 = !obscurePwd2;
                    });
                  },
                ),
                ProfileLabelText("Confirm password"),
                TextFieldProfile(
                  _ccpController,
                  true,
                  "Confirm Password",
                      (t) {},
                  password: true,
                  passwordObscure: obscurePwd3,
                  onPasswordVisibilityChange: () {
                    setState(() {
                      obscurePwd3 = !obscurePwd3;
                    });
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    // showDialog(
                    //     context: context,
                    //
                    //     builder: (BuildContext c) {
                    //       return ;
                    //     });
                  },
                  child: Text(
                    "Submit",
                    style: TextStyle(color: primary_color),
                  ),
                ),
                SizedBox(
                  height: 30,
                )
              ],
            ),
          ),

        ],
      ),
    );
  }

}*/

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController _npController = TextEditingController();
  TextEditingController _ccpController = TextEditingController();
  bool obscurePwd2 = true;
  bool obscurePwd3 = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
        listener: (context, state) {
          if (state is ChangePasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => LoginBloc(),
                  child: LoginScreen(),
                ),
              ),
            );// Go back after success
          } else if (state is ChangePasswordFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ProfileLabelText("New Password"),
                    TextFieldProfile(
                      _npController,
                      true,
                      "New Password",
                          (t) {},
                      password: true,
                      passwordObscure: obscurePwd2,
                      onPasswordVisibilityChange: () {
                        setState(() {
                          obscurePwd2 = !obscurePwd2;
                        });
                      },
                    ),
                    ProfileLabelText("Confirm Password"),
                    TextFieldProfile(
                      _ccpController,
                      true,
                      "Confirm Password",
                          (t) {},
                      password: true,
                      passwordObscure: obscurePwd3,
                      onPasswordVisibilityChange: () {
                        setState(() {
                          obscurePwd3 = !obscurePwd3;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        final newPassword = _npController.text.trim();
                        final confirmPassword = _ccpController.text.trim();

                        if (newPassword == confirmPassword) {
                          context.read<ForgotPasswordBloc>().add(ChangePasswordRequested(newPassword));
                        } else {
                          // Show an error message that passwords do not match
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Passwords do not match')),
                          );
                        }
                      },
                      child: Text(
                        "Submit",
                        style: TextStyle(color: primary_color),
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ProfileLabelText extends StatelessWidget{
  String text;
  ProfileLabelText(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(50,10,50,0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
              color: dark_text_color,
              fontSize: 12,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500
          ),
        ),
      ),
    );
  }

}
class TextFieldProfile extends StatefulWidget{

  String _hint; //hint text
  Function(String) _onChanged; //to get text change event
  bool password =false; //flag for obscure text
  bool email; //flag for email input type keyboard
  bool description; //flag for description height & lines
  TextEditingController? controller = TextEditingController();
  bool editable = false;
  int maxLength; //max length of text
  bool passwordObscure=false; //flag for obscure text
  Function()? onPasswordVisibilityChange = (){}; //to get password visibility event

  TextFieldProfile(this.controller,this.editable,this._hint,this._onChanged,
      {this.email = false,this.password = false,this.description=false,this.maxLength=1000,
        this.passwordObscure=false,this.onPasswordVisibilityChange});

  @override
  _TextFieldProfileState createState() => _TextFieldProfileState();
}

class _TextFieldProfileState extends State<TextFieldProfile> {

  EdgeInsetsGeometry PROFILE_TEXTFIELD_MARGIN= EdgeInsets.symmetric(horizontal: 45,vertical: 10);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: PROFILE_TEXTFIELD_MARGIN,
      height: widget.description ? 150: 50,
      child: TextField(
        enabled: widget.editable,
        textInputAction: widget.description ? null :TextInputAction.next,
        controller: widget.controller,
        onChanged: widget._onChanged,
        maxLines: widget.description? 15 : 1,
        obscureText: widget.password && widget.passwordObscure,
        keyboardType: widget.description ? TextInputType.multiline : widget.email ? TextInputType.emailAddress : TextInputType.text,
        style: TextStyle(
            fontFamily: 'Montserrat',
            color: dark_text_color,
            fontSize: 14,
            fontWeight: FontWeight.w300),
        // inputFormatters: [
        //   LengthLimitingTextInputFormatter(widget.maxLength),
        // ],
        decoration:
        widget.password ?
        InputDecoration(
          hintText: widget._hint,
          filled: true,
          suffix: Padding(
            padding: const EdgeInsets.fromLTRB(0,8,0,0),
            child: InkWell(
              onTap: (){
                widget.onPasswordVisibilityChange!();
              },  /// This is Magical Function
              child: Icon(
                widget.passwordObscure ?         /// CHeck Show & Hide.
                Icons.visibility :
                Icons.visibility_off,
                size: 18,color: border_color,
              ),
            ),
          ),
          fillColor: text_field_bg_color,
          contentPadding: DEFAULT_TEXTFIELD_CONTENT_PADDING,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DEFAULT_TEXTFIELD_BORDER_RADIUS),
            borderSide: BorderSide.none,
          ),
          hintStyle:DEFAULT_TEXTFIELD_HINT_STYLE,
        ) :
        InputDecoration(
          hintText: widget._hint,
          filled: true,
          fillColor: widget.editable ? white_color : text_field_bg_color,
          contentPadding: DEFAULT_TEXTFIELD_CONTENT_PADDING,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DEFAULT_TEXTFIELD_BORDER_RADIUS),
              // borderSide: BorderSide.none
              borderSide: widget.editable ? BorderSide(width: 1,color: border_color,style: BorderStyle.solid)
                  : BorderSide.none
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DEFAULT_TEXTFIELD_BORDER_RADIUS),
            borderSide: widget.editable ? BorderSide(width: 1,color: border_color,style: BorderStyle.solid)
                : BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DEFAULT_TEXTFIELD_BORDER_RADIUS),
            borderSide: widget.editable ? BorderSide(width: 1,color: border_color,style: BorderStyle.solid)
                : BorderSide.none,
          ),
          hintStyle:DEFAULT_TEXTFIELD_HINT_STYLE,
        ),
      ),
    );
  }
}