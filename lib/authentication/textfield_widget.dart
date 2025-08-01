import 'package:hb_booking_mobile_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/colors.dart';


//default textfield widgets
class TextFieldWidget extends StatefulWidget {
  String _hint; //hint text
  Function(String) _onChanged; //to get text change event
  Function(bool)? onSubmit = (a) {}; //to get search submit event
  Function()? onPasswordVisibilityChange =
      () {}; //to get password visibility event
  bool password; //flag for password input
  bool passwordObscure = false; //flag for obscure text
  bool email; //flag for email input type keyboard
  bool description; //flag for description height & lines
  bool smallDescription; //flag for description height & lines
  bool withController = false; //flag for controller
  bool noMargin = false; //flag for margin
  bool isSearch = false; //flag for search field
  int maxLength; //max length of text
  TextEditingController controller = TextEditingController();
  TextFieldWidget(this._hint, this._onChanged,
      {this.email = false,
        this.password = false,
        this.description = false,
        this.smallDescription = true,
        this.noMargin = false,
        this.onSubmit,
        this.maxLength = DEFAULT_TEXTFIELD_MAX_LENGTH,
        this.passwordObscure = false,
        this.onPasswordVisibilityChange});
  TextFieldWidget.withController(this.controller, this._hint, this._onChanged,
      {this.email = false,
        this.password = false,
        this.description = false,
        this.smallDescription = true,
        this.noMargin = false,
        this.isSearch = false,
        this.onSubmit,
        this.maxLength = DEFAULT_TEXTFIELD_MAX_LENGTH,
        this.passwordObscure = false,
        this.onPasswordVisibilityChange}) {
    withController = true;
  }

  @override
  _TextFieldWidgetState createState() => _TextFieldWidgetState();
}
class _TextFieldWidgetState extends State<TextFieldWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.password) {
      widget.passwordObscure = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.noMargin ? EdgeInsets.zero : DEFAULT_TEXTFIELD_MARGIN,
      height: widget.description
          ? (widget.smallDescription ? 100 : 200)
          : DEFAULT_TEXTFIELD_HEIGHT,
      child: TextField(
        textAlignVertical: TextAlignVertical.center,
        textInputAction:
        widget.isSearch ? TextInputAction.search : TextInputAction.next,
        onSubmitted: (s) {
          widget.onSubmit!(true);
        },
        controller: widget.withController ? widget.controller : null,
        onChanged: widget._onChanged,
        maxLines: widget.description ? (widget.smallDescription ? 5 : 20) : 1,
        obscureText: widget.password && widget.passwordObscure,
        keyboardType: widget.email
            ? TextInputType.emailAddress
            : widget.description
            ? TextInputType.multiline
            : TextInputType.text,
        style: DEFAULT_TEXTFIELD_STYLE,
        inputFormatters: [
          LengthLimitingTextInputFormatter(widget.maxLength),
        ],
        decoration: widget.password
            ? InputDecoration(
          hintText: widget._hint,
          filled: true,
          suffixIcon: InkWell(
            onTap: () {
              widget.onPasswordVisibilityChange!();
            },

            /// This is Magical Function
            child: Icon(
              widget.passwordObscure
                  ?

              /// CHeck Show & Hide.
              Icons.visibility
                  : Icons.visibility_off,
              size: 18,
              color: border_color,
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
          //   child: InkWell(
          //     onTap: () {
          //       widget.onPasswordVisibilityChange!();
          //     },
          //
          //     /// This is Magical Function
          //     child: Icon(
          //       widget.passwordObscure
          //           ?
          //
          //           /// CHeck Show & Hide.
          //           Icons.visibility
          //           : Icons.visibility_off,
          //       size: 18,
          //       color: border_color,
          //     ),
          //   ),
          // ),
          fillColor: text_field_bg_color,
          contentPadding: widget.isSearch
              ? DEFAULT_SEARCH_CONTENT_PADDING
              : DEFAULT_TEXTFIELD_CONTENT_PADDING,
          border: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(DEFAULT_TEXTFIELD_BORDER_RADIUS),
            borderSide: BorderSide.none,
          ),
          hintStyle: DEFAULT_TEXTFIELD_HINT_STYLE,
        )
            : InputDecoration(
          hintText: widget._hint,
          filled: true,
          fillColor: text_field_bg_color,
          contentPadding: widget.isSearch
              ? DEFAULT_SEARCH_CONTENT_PADDING
              : DEFAULT_TEXTFIELD_CONTENT_PADDING,
          border: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(DEFAULT_TEXTFIELD_BORDER_RADIUS),
            borderSide: BorderSide.none,
          ),
          hintStyle: DEFAULT_TEXTFIELD_HINT_STYLE,
        ),
      ),
    );
  }
}