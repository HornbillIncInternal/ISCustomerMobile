import 'package:hb_booking_mobile_app/booking/bloc_booking.dart';
import 'package:hb_booking_mobile_app/booking/event_booking.dart';
import 'package:hb_booking_mobile_app/booking/state_booking.dart';
import 'package:hb_booking_mobile_app/bottom_navigation/landing_page.dart';
import 'package:hb_booking_mobile_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ScreenHomeSuccess extends StatefulWidget {
  const ScreenHomeSuccess({Key? key}) : super(key: key);

  @override
  State<ScreenHomeSuccess> createState() => _ScreenHomeSuccessState();
}

class _ScreenHomeSuccessState extends State<ScreenHomeSuccess> {
  String bookingIds ="";
  bool isLoading = true;

  Future<void> getId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      bookingIds = prefs.getString('blockDataIds') ?? '';
      isLoading = false;
    });
    print("success -- blockDataIds - ${bookingIds}");
  }

  @override
  void initState() {
    getId();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primary_color,)) // Show loading indicator while fetching data
          :  Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/images/success.svg',
                    width: 100.0,
                    height: 100.0,
                  ),
                  SizedBox(height: 8,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Booking id: ",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(bookingIds,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 15,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => MainScreen()),
                          (Route<dynamic> route) => false,
                    );
                  },
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all(1),
                    backgroundColor: MaterialStateProperty.all(button_bg_color),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  child: Text(
                    "Go to home page",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// class ScreenHomeSuccess extends StatelessWidget {
//   const ScreenHomeSuccess({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<BookingBloc, BookingState>(
//       listener: (context, state) {
//         if (state is BookingNavigationSuccess) {
//           Navigator.pushReplacementNamed(context, '/mainScreen');
//         }
//       },
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: Container(
//           padding: EdgeInsets.symmetric(horizontal: 15),
//           child: Stack(
//             children: [
//               Center(
//                 child: SvgPicture.asset(
//                   'assets/images/success.svg',
//                   width: 100.0,
//                   height: 100.0,
//                 ),
//               ),
//               Positioned(
//                 left: 0,
//                 right: 0,
//                 bottom: 15,
//                 child: Container(
//                   width: MediaQuery.of(context).size.width,
//                   height: 50,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // Trigger the navigation success state in the Bloc
//                       context.read<BookingBloc>().add(NavigateToHomePage());
//                     },
//                     style: ButtonStyle(
//                       elevation: MaterialStateProperty.all(1),
//                       backgroundColor: MaterialStateProperty.all(button_bg_color),
//                       shape: MaterialStateProperty.all(
//                         RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                     ),
//                     child: Text(
//                       "Go to home page",
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.white,
//                         fontFamily: 'Montserrat',
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

