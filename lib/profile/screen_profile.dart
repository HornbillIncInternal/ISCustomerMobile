import 'package:hb_booking_mobile_app/authentication/bloc_login.dart';
import 'package:hb_booking_mobile_app/authentication/screen_login.dart';
import 'package:hb_booking_mobile_app/profile/bloc_profile.dart';
import 'package:hb_booking_mobile_app/profile/event_profile.dart';
import 'package:hb_booking_mobile_app/profile/state_profile.dart';
import 'package:hb_booking_mobile_app/profile/support/customer_support_bloc.dart';
import 'package:hb_booking_mobile_app/profile/support/screen_customer_support.dart';
import 'package:hb_booking_mobile_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc()..add(CheckLoginStatus()),
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ProfileLoaded) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Profile'),
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 20.0),
                    CircleAvatar(
                      radius: 50.0,
                      backgroundImage: AssetImage('assets/icons/profile_picture.jpg'),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      state.username,
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      state.email,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Divider(),
                    // ListTile(
                    //   leading: Icon(Icons.edit),
                    //   title: Text('Edit Profile'),
                    //   onTap: () {
                    //     // Navigate to edit profile screen
                    //   },
                    // ),
                    // ListTile(
                    //   leading: Icon(Icons.settings),
                    //   title: Text('Settings'),
                    //   onTap: () {
                    //     // Navigate to settings screen
                    //   },
                    // ),
                    ListTile(
                      leading: Icon(Icons.call),
                      title: Text('Contact Us'),
                      onTap: () {
                        _makePhoneCall("8943524444");
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.help_center),
                      title: Text('Customer Support'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (context) => SupportBloc(),
                              child: SupportForm(branchId: "66fbc6171ba206000b392af2"),
                            ),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Logout'),
                      onTap: () {
                        context.read<ProfileBloc>().add(LogoutEvent());
                      },
                    ),
                  ],
                ),
              ),
            );
          } else if (state is ProfileLoggedOut) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                title: Text('Profile'),
              ),
              body: Center(
                child:Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/notAuthenticated.jpg', // Make sure the path is correct
                      width: 200,
                      height: 200,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (context) => LoginBloc(),
                              child: LoginScreen(),
                            ),
                          ),
                        );
                      },
                      child: Text('Login',style: TextStyle(color: primary_color),),
                    ),
                  ],
                )



              ),
            );
          } else {
            return Container(); // Handle any other possible states
          }
        },
      ),
    );
  }
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneUri';
    }
  }
}


/*class ProfileScreen extends StatelessWidget {
  final String? username;
  final String? email;

  const ProfileScreen({this.username, this.email});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc()
        ..add(CheckLoginStatus())
        ..add(UpdateProfile(
          username: username ?? 'Rinshad',
          email: email ?? 'corporateuser@example.com',
        )),
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ProfileLoaded) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Profile'),
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 20.0),
                    CircleAvatar(
                      radius: 50.0,
                      backgroundImage: AssetImage('assets/icons/profile_picture.jpg'),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      state.username,
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      state.email,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Edit Profile'),
                      onTap: () {
                        // Navigate to edit profile screen
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('Settings'),
                      onTap: () {
                        // Navigate to settings screen
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Logout'),
                      onTap: () {
                        context.read<ProfileBloc>().add(LogoutEvent());
                      },
                    ),
                  ],
                ),
              ),
            );
          } else if (state is ProfileLoggedOut) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Profile'),
              ),
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider(
                          create: (context) => LoginBloc(),
                          child: LoginScreen(),
                        ),
                      ),
                    );
                  },
                  child: Text('Login'),
                ),
              ),
            );
          } else {
            return Container(); // Handle any other possible states
          }
        },
      ),
    );
  }
}*/


// class ProfileScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => ProfileBloc()..add(CheckLoginStatus()),
//       child: BlocBuilder<ProfileBloc, ProfileState>(
//         builder: (context, state) {
//           if (state is ProfileLoading) {
//             return Center(child: CircularProgressIndicator());
//           } else if (state is ProfileLoaded) {
//             return Scaffold(
//               appBar: AppBar(
//                 title: Text('Profile'),
//               ),
//               body: SingleChildScrollView(
//                 child: Column(
//                   children: <Widget>[
//                     SizedBox(height: 20.0),
//                     CircleAvatar(
//                       radius: 50.0,
//                       backgroundImage:
//                       AssetImage('assets/icons/profile_picture.jpg'),
//                     ),
//                     SizedBox(height: 10.0),
//                     Text(
//                       state.username,
//                       style: TextStyle(
//                         fontSize: 24.0,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(height: 5.0),
//                     Text(
//                       state.email,
//                       style: TextStyle(
//                         fontSize: 16.0,
//                         color: Colors.grey,
//                       ),
//                     ),
//                     SizedBox(height: 20.0),
//                     Divider(),
//                     ListTile(
//                       leading: Icon(Icons.edit),
//                       title: Text('Edit Profile'),
//                       onTap: () {
//                         // Navigate to edit profile screen
//                       },
//                     ),
//                     ListTile(
//                       leading: Icon(Icons.settings),
//                       title: Text('Settings'),
//                       onTap: () {
//                         // Navigate to settings screen
//                       },
//                     ),
//                     ListTile(
//                       leading: Icon(Icons.logout),
//                       title: Text('Logout'),
//                       onTap: () {
//                         context.read<ProfileBloc>().add(LogoutEvent());
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           } else if (state is ProfileLoggedOut) {
//             return Scaffold(
//               appBar: AppBar(
//                 title: Text('Profile'),
//               ),
//               body: Center(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => BlocProvider(
//                           create: (context) => LoginBloc(),
//                           child: LoginScreen(),
//                         ),
//                       ),
//                     );
//
//                   },
//                   child: Text('Login'),
//                 ),
//               ),
//             );
//           } else {
//             return Container(); // Handle any other possible states
//           }
//         },
//       ),
//     );
//   }
// }
