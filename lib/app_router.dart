/*
import 'package:booking_hb_app/home/event_home.dart';
import 'package:booking_hb_app/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'home/bloc_home.dart';
class AppRouter {
  late final GoRouter router = GoRouter(
    routes: <GoRoute>[
   */
/*   GoRoute(
        name: 'splash',
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return SplashScreen();
        },
      ),
      GoRoute(
        name: 'landing',
        path: '/landing',
        builder: (BuildContext context, GoRouterState state) {
          return LandingPage();
        },
      ),*//*

      GoRoute(
        name: 'home',
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          final location = state.uri.queryParameters['location'];
          final asset = state.uri.queryParameters['asset'];
          final start = state.uri.queryParameters['start'];
          final end = state.uri.queryParameters['end'];

          return BlocProvider(
            create: (context) => HomeBloc()..add(InitializeHomeEvent(location, asset, start, end)),
            child: Home(
              location: location,
              asset: asset,
              start: start,
              end: end,
            ),
          );
        },
      ),
   */
/*   GoRoute(
        name: 'search-widget',
        path: '/searchwidget',
        pageBuilder: (context, state) {
          final location = state.pathParameters['location'];
          final asset = state.pathParameters['asset'];
          final start = state.pathParameters['start'];
          final end = state.pathParameters['end'];

          return CustomTransitionPage<void>(
            key: state.pageKey,
            opaque: false,
            barrierColor: appBlack.withOpacity(0.5),
            transitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return child;
            },
            child: BookingSearchfieldScreen(
              onSearch: (String? location, String? asset, String? start, String? end) {
                // Handle search
              },
              location: location,
              asset: asset,
              start: start,
              end: end,
            ),
          );
        },
      ),
      GoRoute(
        name: 'booking-success',
        path: '/booking-success',
        pageBuilder: (context, state) {
          return CustomTransitionPage<void>(
            key: state.pageKey,
            opaque: false,
            barrierColor: appBlack.withOpacity(0.5),
            transitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return child;
            },
            child: const ScreenHomeSuccess(),
          );
        },
      ),
      GoRoute(
        name: 'login',
        path: '/login',
        pageBuilder: (context, state) {
          return CustomTransitionPage<void>(
            key: state.pageKey,
            opaque: false,
            barrierColor: appBlack.withOpacity(0.5),
            transitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return child;
            },
            child: LoginScreen(),
          );
        },
      ),
      GoRoute(
        name: 'loginconfirm',
        path: '/loginconfirm',
        pageBuilder: (context, state) {
          return CustomTransitionPage<void>(
            key: state.pageKey,
            opaque: false,
            barrierColor: appBlack.withOpacity(0.5),
            transitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return child;
            },
            child: LoginConfirmationScreen(),
          );
        },
      ),
      GoRoute(
        name: 'profile',
        path: '/profile',
        pageBuilder: (context, state) {
          return CustomTransitionPage<void>(
            key: state.pageKey,
            opaque: false,
            barrierColor: appBlack.withOpacity(0.5),
            transitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return child;
            },
            child: ProfileScreen(),
          );
        },
      ),*//*

    ],
  );
}
*/
