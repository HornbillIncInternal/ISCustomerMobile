// Flutter web plugin registrant file.
//
// Generated file. Do not edit.
//

// @dart = 2.13
// ignore_for_file: type=lint

import 'package:connectivity_plus/src/connectivity_plus_web.dart';
import 'package:flutter_keyboard_visibility_web/flutter_keyboard_visibility_web.dart';
import 'package:fluttertoast/fluttertoast_web.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:pointer_interceptor_web/pointer_interceptor_web.dart';
import 'package:shared_preferences_web/shared_preferences_web.dart';
import 'package:url_launcher_web/url_launcher_web.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void registerPlugins([final Registrar? pluginRegistrar]) {
  final Registrar registrar = pluginRegistrar ?? webPluginRegistrar;
  ConnectivityPlusWebPlugin.registerWith(registrar);
  FlutterKeyboardVisibilityPlugin.registerWith(registrar);
  FluttertoastWebPlugin.registerWith(registrar);
  GoogleMapsPlugin.registerWith(registrar);
  PointerInterceptorWeb.registerWith(registrar);
  SharedPreferencesPlugin.registerWith(registrar);
  UrlLauncherPlugin.registerWith(registrar);
  registrar.registerMessageHandler();
}
