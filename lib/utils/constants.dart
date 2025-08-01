import 'package:flutter/material.dart';

import 'colors.dart';


double DEFAULT_TEXTFIELD_HEIGHT = 50;
double DEFAULT_TEXTFIELD_BORDER_RADIUS = 13;
EdgeInsetsGeometry DEFAULT_TEXTFIELD_MARGIN =
EdgeInsets.symmetric(horizontal: 45);
EdgeInsetsGeometry DEFAULT_TEXTFIELD_CONTENT_PADDING =
EdgeInsets.symmetric(vertical: 16, horizontal: 25);
EdgeInsetsGeometry DEFAULT_SEARCH_CONTENT_PADDING =
EdgeInsets.fromLTRB(25, 16, 45, 16);
TextStyle DEFAULT_TEXTFIELD_STYLE = TextStyle(
    fontFamily: 'Montserrat',
    color: dark_text_color,
    fontSize: 14,
    fontWeight: FontWeight.w300);
TextStyle DEFAULT_TEXTFIELD_HINT_STYLE = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 14,
    color: hint_color,
    fontWeight: FontWeight.w300);
const DEFAULT_TEXTFIELD_MAX_LENGTH = 1000;