import 'package:hb_booking_mobile_app/authentication/forgot/bloc_forgot.dart';
import 'package:hb_booking_mobile_app/bookings/screen_booking.dart';
import 'package:hb_booking_mobile_app/connectivity/connectivity_bloc.dart';
import 'package:hb_booking_mobile_app/connectivity/connectivity_event.dart';
import 'package:hb_booking_mobile_app/home/home_screen.dart';
import 'package:hb_booking_mobile_app/home/workspcae_detail/workspace_reviews/review_repository.dart';
import 'package:hb_booking_mobile_app/navigation/bloc_navigation.dart';
import 'package:hb_booking_mobile_app/profile/screen_profile.dart';
import 'package:hb_booking_mobile_app/screen_splash.dart';
import 'package:hb_booking_mobile_app/utils/colors.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bottom_navigation/bloc_nav.dart';
import 'bottom_navigation/landing_page.dart';
import 'home/asset_bloc/asset_bloc.dart';
import 'home/bloc_home.dart';
void main() {
  final connectivity = Connectivity();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<BottomNavigationBloc>(
          create: (_) => BottomNavigationBloc(),
        ),
        BlocProvider<ExploreTabBloc>(
          create: (_) => ExploreTabBloc(),
        ),
        BlocProvider<AssetBloc>(
          create: (_) => AssetBloc(),
        ),
        RepositoryProvider<ReviewRepository>(
          create: (context) => ReviewRepository(),
        ),
        BlocProvider<ConnectivityBloc>(
          create: (_) => ConnectivityBloc(connectivity)..add(CheckConnectivity(),
          ),),
        BlocProvider<ForgotPasswordBloc>(
          create: (_) => ForgotPasswordBloc(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Booking App',
      theme: ThemeData(
        primaryColor: primary_color,

      ),
      debugShowCheckedModeBanner: false,

      home: SplashScreen(),
    );
  }
}