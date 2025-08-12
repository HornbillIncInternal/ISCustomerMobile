
import 'package:hb_booking_mobile_app/booking/asset_by_family_model.dart';
import 'package:hb_booking_mobile_app/booking/bloc_booking.dart';
import 'package:hb_booking_mobile_app/booking/screen_terms_and_conditions.dart';
import 'package:hb_booking_mobile_app/booking/succees_booking/screen_success.dart';
import 'package:hb_booking_mobile_app/home/model/model_assets.dart';
import 'package:hb_booking_mobile_app/home/workspcae_detail/package_model.dart';
import 'package:hb_booking_mobile_app/utils/colors.dart';
import 'package:hb_booking_mobile_app/utils/functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:hb_booking_mobile_app/home/model/model_assets.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ScreenHomeConfirmation extends StatefulWidget {
  final double totalPrice;
  final String selectedDate;
  final String selectedEndDate;
  final List<Map<String, String>> dateTimeRanges;
  final String assetId;
  final String familyId;
  final String assetName;
  final String deskCounter;
  final List<Item>? availableItems;
  final String assetType; // Added asset type parameter

  const ScreenHomeConfirmation({
    Key? key,
    required this.totalPrice,
    required this.dateTimeRanges,
    required this.availableItems,
    required this.assetId,
    required this.familyId,
    required this.selectedDate,
    required this.selectedEndDate,
    required this.assetName,
    required this.deskCounter,
    required this.assetType, // Added asset type
  }) : super(key: key);

  @override
  _ScreenHomeConfirmationState createState() => _ScreenHomeConfirmationState();
}

class _ScreenHomeConfirmationState extends State<ScreenHomeConfirmation> {
  String _selectedPaymentMethod = 'gateway';
  bool _termsAccepted = false;
  int _creditBalance = 0;
  String _walletId = '';
  int _requiredCredits = 0;
  bool _canUseCredits = false;
  bool _isLoadingWallet = true;

  // Function to launch Terms and Conditions URL
  Future<void> _launchTermsAndConditions() async {
    const url = 'https://hornbill-booking-system.lm.r.appspot.com/termsandconditions';
    final Uri uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Opens in external browser
        );
      } else {
        // Fallback: try to launch in in-app browser
        await launchUrl(
          uri,
          mode: LaunchMode.inAppWebView,
        );
      }
    } catch (e) {
      // Show error message if URL cannot be launched
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open Terms and Conditions. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  @override
  void initState() {
    super.initState();
    for (var dayRange in widget.dateTimeRanges) {
      print("Start: ${dayRange['start']}, End: ${dayRange['end']}");


    }

    // Calculate required credits
    _calculateRequiredCredits();

    // Set loading state if eligible for credits
    if (_isEligibleForCredits()) {
      setState(() {
        _isLoadingWallet = true;
      });
    } else {
      setState(() {
        _isLoadingWallet = false;
      });
    }
  }

  bool _isEligibleForCredits() {
    return widget.assetType.toLowerCase() == 'conference room' ||
        widget.assetType.toLowerCase() == 'meeting room';
  }

  void _calculateRequiredCredits() {
    // Calculate total hours from dateTimeRanges
    int totalHours = 0;

    for (var range in widget.dateTimeRanges) {
      DateTime startTime = DateTime.parse(range['start']!);
      DateTime endTime = DateTime.parse(range['end']!);

      // Calculate hours for this range
      int hoursInRange = endTime.difference(startTime).inHours;
      totalHours += hoursInRange;
    }

    // 1 hour = 50 points
    _requiredCredits = totalHours * 50;

    print("Total hours: $totalHours, Required credits: $_requiredCredits");
  }

  void _fetchWalletBalance(BookingBloc bloc) {
    SharedPreferences.getInstance().then((prefs) {
      final userId = prefs.getString('userid') ?? '';
      if (userId.isNotEmpty) {
        bloc.add(FetchWalletBalance(tenantId: userId));
      } else {
        setState(() {
          _isLoadingWallet = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = BookingBloc();
        // Fetch wallet balance after bloc is created
        if (_isEligibleForCredits()) {
          _fetchWalletBalance(bloc);
        }
        return bloc;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Confirm Booking'),
        ),
        body: BlocConsumer<BookingBloc, BookingState>(
          listener: (context, state) {
            print("🎯 [LISTENER] State changed to: ${state.runtimeType}");

            if (state is BookingInitial) {
              for (var dayRange in widget.dateTimeRanges) {
                print("Start: ${dayRange['start']}, End: ${dayRange['end']}");
              }
            } else if (state is WalletBalanceLoaded) {
              setState(() {
                _creditBalance = state.creditBalance;
                _walletId = state.walletId;
                _canUseCredits = _creditBalance >= _requiredCredits && _requiredCredits > 0;
                _isLoadingWallet = false;
              });
              print("Credit balance loaded: $_creditBalance, Required: $_requiredCredits, Can use: $_canUseCredits");
            } else if (state is WalletBalanceError) {
              setState(() {
                _isLoadingWallet = false;
                _canUseCredits = false;
              });
              print("Wallet balance error: ${state.message}");
            } else if (state is BookingNavigationSuccess) {
              print("✅ [LISTENER] BookingNavigationSuccess received - navigating to success screen");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ScreenHomeSuccess(),
                ),
              );
            } else if (state is BookingFailure) {
              print("❌ [LISTENER] BookingFailure: ${state.error}");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            } else if (state is BlockAssetSuccess) {
              print("✅ [LISTENER] BlockAssetSuccess - calling _confirmBooking");
              _confirmBooking(context);
            } else if (state is BlockAssetFailure) {
              print("❌ [LISTENER] BlockAssetFailure: ${state.error}");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            } else if (state is PaymentOrderLoading) {
              print("⏳ [LISTENER] PaymentOrderLoading");
            } else if (state is PaymentOrderSuccess) {
              print("✅ [LISTENER] PaymentOrderSuccess - Razorpay should open");
            } else if (state is PaymentOrderError) {
              print("❌ [LISTENER] PaymentOrderError: ${state.error}");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Booking Details Section
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0, top: 10),
                        child: Text(
                          'Booking Details',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        width: MediaQuery.of(context).size.width - 30,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                              child: Text(
                                capitalize(widget.assetName),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    color: Colors.black),
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: widget.dateTimeRanges.length,
                                itemBuilder: (context, index) {
                                  final range = widget.dateTimeRanges[index];
                                  final isFullDay = isFullDayBooking(range['start']!, range['end']!);

                                  return Container(
                                    margin: EdgeInsets.symmetric(vertical: 2, horizontal: 15),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              date(range['start'].toString()),
                                              style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 14.0,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(" - " +
                                                DateFormat('EEEE').format(DateTime.parse(range['start']!)).substring(0, 3),
                                              style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 14.0,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Only show time if it's not a full day booking
                                        if (!isFullDay)
                                          Row(
                                            children: [
                                              Text(
                                                time(range['start'].toString()),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 14.0,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              Text(" - " +
                                                  time(range['end'].toString()),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 14.0,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          )
                                        else
                                        // Show "Full Day" text for full day bookings
                                          Text(
                                            "",
                                            style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 14.0,
                                              color: Colors.grey[600],
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Note
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                        child: Text("Note: Holidays and operational hours of the branch will take effect.",
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 14.0,
                              color: Colors.orange),
                        ),
                      ),

                      // Payment Details
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0, top: 10),
                        child: Text(
                          'Payment Details',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        width: MediaQuery.of(context).size.width - 30,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow('Amount', NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(widget.totalPrice)),
                            _buildDetailRow('Tax(18%)', NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(calculateTax(widget.totalPrice))),
                            _buildDetailRow('Total Amount', NumberFormat.currency(locale: 'en_IN', symbol: '₹').format((widget.totalPrice + calculateTax(widget.totalPrice))), bold: true),
                          ],
                        ),
                      ),

                      // Payment Method Selection
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0, top: 10),
                        child: Text(
                          'Select Payment Method',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        width: MediaQuery.of(context).size.width - 30,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          children: [
                            // Online Payment Option
                            ListTile(
                              title: Text('Online payment'),
                              leading: Radio<String>(
                                value: 'gateway',
                                groupValue: _selectedPaymentMethod,
                                onChanged: (String? value) {
                                  setState(() {
                                    _selectedPaymentMethod = value!;
                                  });
                                },
                              ),
                            ),

                            // Credit Points Option - Only show if eligible and has balance
                            if (_isEligibleForCredits() && !_isLoadingWallet)
                              ListTile(
                                title: Text(
                                    _canUseCredits
                                        ? 'Credit points: $_creditBalance (Required: $_requiredCredits)'
                                        : _creditBalance > 0
                                        ? 'Credit points: $_creditBalance (Insufficient - Required: $_requiredCredits)'
                                        : 'Credit points: 0'
                                ),
                                subtitle: _canUseCredits
                                    ? null
                                    : Text(
                                  _creditBalance > 0
                                      ? 'Insufficient credits'
                                      : 'No credits available',
                                  style: TextStyle(color: Colors.red, fontSize: 12),
                                ),
                                leading: Radio<String>(
                                  value: 'credits',
                                  groupValue: _selectedPaymentMethod,
                                  onChanged: _canUseCredits ? (String? value) {
                                    setState(() {
                                      _selectedPaymentMethod = value!;
                                    });
                                  } : null,
                                ),
                              ),

                            // Loading state for wallet
                            if (_isEligibleForCredits() && _isLoadingWallet)
                              ListTile(
                                title: Text('Loading credit points...'),
                                leading: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Terms and Conditions
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 15.0),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _termsAccepted,
                              onChanged: (bool? value) {
                                setState(() {
                                  _termsAccepted = value ?? false;
                                });
                              },
                              activeColor: primary_color,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: _launchTermsAndConditions,
                                child: Text(
                                  "I agree to the Terms and Conditions",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // // Terms and Conditions
                      // Container(
                      //   margin: EdgeInsets.symmetric(horizontal: 15.0),
                      //   child: Row(
                      //     children: [
                      //       Checkbox(
                      //         value: _termsAccepted,
                      //         onChanged: (bool? value) {
                      //           setState(() {
                      //             _termsAccepted = value ?? false;
                      //           });
                      //         },
                      //         activeColor: primary_color,
                      //       ),
                      //       Expanded(
                      //         child: GestureDetector(
                      //           onTap: () {
                      //             Navigator.push(
                      //               context,
                      //               MaterialPageRoute(
                      //                 builder: (context) => const TermsAndConditionsPage(),
                      //               ),
                      //             );
                      //           },
                      //           child: Text(
                      //             "I agree to the Terms and Conditions",
                      //             style: TextStyle(
                      //               color: Colors.blue,
                      //               decoration: TextDecoration.underline,
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),

                // Confirm Booking Button
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    child: ElevatedButton(
                      onPressed: !_termsAccepted ? null : () {
                        // Convert deskCounter from String to int
                        int desksRequested = int.parse(widget.deskCounter);

                        // Initialize list to hold selected items
                        List<Item>? selectedItems;

                        if (widget.availableItems != null && widget.availableItems!.isNotEmpty) {
                          if (desksRequested == 1) {
                            // If only one desk is requested, take the first available item
                            selectedItems = [widget.availableItems!.first];
                          } else {
                            // If multiple desks are requested, take that many items
                            // but not more than available
                            int itemsToTake = min(desksRequested, widget.availableItems!.length);
                            selectedItems = widget.availableItems!.take(itemsToTake).toList();
                          }

                          // Proceed with booking only if we have items to book
                          if (selectedItems.isNotEmpty) {
                            context.read<BookingBloc>().add(
                              BlockAssetEvent(
                                familyId: widget.familyId,
                                numOfItems: selectedItems.length.toString(),
                                from: widget.selectedDate,
                                to: widget.selectedEndDate,
                                items: selectedItems,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('No items available for booking')),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('No items available for booking')),
                          );
                        }
                      },
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all(1),
                        backgroundColor: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                            if (states.contains(MaterialState.disabled)) {
                              return Colors.grey; // Disabled color
                            }
                            return primary_color; // Enabled color
                          },
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      child: state is BookingLoading || state is BlockAssetLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                        "Confirm Booking",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                // Loading Overlay
                if (state is BookingLoading ||
                    state is BlockAssetLoading ||
                    state is PaymentOrderLoading ||
                    state is WalletBalanceLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: primary_color),
                            SizedBox(height: 16),
                            Text(
                              _getLoadingMessage(state),
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _getLoadingMessage(BookingState state) {
    if (state is BlockAssetLoading) {
      return "Blocking assets...";
    } else if (state is PaymentOrderLoading) {
      return "Creating payment order...";
    } else if (state is BookingLoading) {
      return "Processing payment...";
    } else if (state is WalletBalanceLoading) {
      return "Loading wallet balance...";
    }
    return "Loading...";
  }

  List<Map<String, String>> splitDateRangeIgnoringSundays(DateTime startDate, DateTime endDate) {
    List<Map<String, String>> dateTimeRanges = [];

    DateTime currentDay = startDate;

    while (currentDay.isBefore(endDate) || currentDay.isAtSameMomentAs(endDate)) {
      if (currentDay.weekday != DateTime.sunday) {
        DateTime dayStart = DateTime(
          currentDay.year,
          currentDay.month,
          currentDay.day,
          startDate.hour,
          startDate.minute,
        );

        DateTime dayEnd = DateTime(
          currentDay.year,
          currentDay.month,
          currentDay.day,
          endDate.hour,
          endDate.minute,
        );

        dateTimeRanges.add({
          'start': dayStart.toIso8601String(),
          'end': dayEnd.toIso8601String(),
        });
      }
      currentDay = currentDay.add(Duration(days: 1));
    }

    return dateTimeRanges;
  }

  Widget _buildDetailRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 18.0 : 14.0,
              color: bold ? Colors.black : Colors.grey[800],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 20.0 : 14.0,
              color: bold ? Colors.black : Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  String date(String date) {
    DateTime now = DateTime.parse(date);
    var formatter = DateFormat('dd/MM/yy');
    return formatter.format(now);
  }

  String time(String date) {
    DateTime dateTime = DateTime.parse(date);

    // Check if this is a "full day" booking (00:00 to 23:59)
    // If start time is 00:00:00 and end time is 23:59:00, don't show time
    if (dateTime.hour == 0 && dateTime.minute == 0) {
      return ""; // Return empty string for start time when it's full day
    }
    if (dateTime.hour == 23 && dateTime.minute == 59) {
      return ""; // Return empty string for end time when it's full day
    }

    var formatter = DateFormat('hh:mm a'); // Added 'a' for AM/PM
    return formatter.format(dateTime);
  }

  bool isFullDayBooking(String startDate, String endDate) {
    DateTime start = DateTime.parse(startDate);
    DateTime end = DateTime.parse(endDate);

    return (start.hour == 0 && start.minute == 0) &&
        (end.hour == 23 && end.minute == 59);
  }

  void _confirmBooking(BuildContext context) {
    if (_selectedPaymentMethod == 'credits') {
      // Handle credit points payment
      SharedPreferences.getInstance().then((prefs) {
        final bookingId = prefs.getString('blockDataIds') ?? '';

        if (bookingId.isNotEmpty) {
          context.read<BookingBloc>().add(StartBooking(
            assetId: widget.assetId,
            fromDate: widget.selectedDate,
            toDate: widget.selectedEndDate,
            totalPrice: widget.totalPrice,
            paymentMethod: 'credits',
            walletId: _walletId,
            creditValue: _requiredCredits,
            creditType: 'INVENTORY_CREDITS',
            bookingId: bookingId,
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Booking ID not found')),
          );
        }
      });
    } else if (_selectedPaymentMethod == 'wallet') {
      // Assuming the wallet balance is zero or insufficient
      bool isBalanceSufficient = false; // Replace with actual balance check

      if (!isBalanceSufficient) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You have no sufficient balance')),
        );
        return; // Exit the method to prevent further execution
      }
    } else if (_selectedPaymentMethod == 'gateway') {
      // Handle online payment method with Razorpay
      print("Here weeeee11");
      // Proceed with the online payment
      context.read<BookingBloc>().add(StartBooking(
        assetId: widget.assetId,
        fromDate: widget.selectedDate,
        toDate: widget.selectedEndDate,
        totalPrice: widget.totalPrice,
        paymentMethod: _selectedPaymentMethod,
      ));
    } else {
      // Handle other payment methods if any
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a valid payment method')),
      );
    }
  }

  double calculateTax(double totalPrice) {
    return totalPrice * 0.18;
  }

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}


/*

class ScreenHomeConfirmation extends StatefulWidget {
  final double totalPrice;
  final String selectedDate;
  final String selectedEndDate;
  final List<Map<String, String>> dateTimeRanges ;
  final String assetId;
  final String familyId;

  // final String packageId;

  final String assetName;
  final String deskCounter;
   final List<Item>? availableItems;

  const ScreenHomeConfirmation({
    Key? key,
    required this.totalPrice,
    required this.dateTimeRanges,
required this.availableItems,
    required this.assetId,
    required this.familyId,
    // required this.packageId,
    required this.selectedDate, required this.selectedEndDate,
    required this.assetName, required this.deskCounter,
  }) : super(key: key);

  @override
  _ScreenHomeConfirmationState createState() => _ScreenHomeConfirmationState();
}

class _ScreenHomeConfirmationState extends State<ScreenHomeConfirmation> {
  String _selectedPaymentMethod = 'gateway';
  bool _termsAccepted = false;
@override
  void initState() {
  for (var dayRange in widget.dateTimeRanges) {
    print("Start: ${dayRange['start']}, End: ${dayRange['end']}");
  }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookingBloc(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Confirm Booking'),
        ),
        body:
        BlocConsumer<BookingBloc, BookingState>(
          listener: (context, state) {
            print("🎯 [LISTENER] State changed to: ${state.runtimeType}");

            if (state is BookingInitial) {
              for (var dayRange in widget.dateTimeRanges) {
                print("Start: ${dayRange['start']}, End: ${dayRange['end']}");
              }
            } else if (state is BookingNavigationSuccess) {
              print("✅ [LISTENER] BookingNavigationSuccess received - navigating to success screen");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ScreenHomeSuccess(),
                ),
              );
            } else if (state is BookingFailure) {
              print("❌ [LISTENER] BookingFailure: ${state.error}");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            } else if (state is BlockAssetSuccess) {
              print("✅ [LISTENER] BlockAssetSuccess - calling _confirmBooking");
              _confirmBooking(context);
            } else if (state is BlockAssetFailure) {
              print("❌ [LISTENER] BlockAssetFailure: ${state.error}");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            } else if (state is PaymentOrderLoading) {
              print("⏳ [LISTENER] PaymentOrderLoading");
            } else if (state is PaymentOrderSuccess) {
              print("✅ [LISTENER] PaymentOrderSuccess - Razorpay should open");
            } else if (state is PaymentOrderError) {
              print("❌ [LISTENER] PaymentOrderError: ${state.error}");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },

          builder: (context, state) {
            return Stack(
              children: [
                SingleChildScrollView( // Wrap the content with SingleChildScrollView
                  padding: EdgeInsets.only(bottom: 80), // Add bottom padding to prevent content from being hidden behind the button
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0, top: 10),
                        child: Text(
                          'Booking Details',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        width: MediaQuery.of(context).size.width - 30,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                              child: Text(capitalize(widget.assetName),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    color: Colors.black),
                              ),
                            ),

                            Expanded(
                              child: ListView.builder(
                                shrinkWrap: true,
                               // physics: NeverScrollableScrollPhysics(), // Prevents nested scrolling issues
                                itemCount: widget.dateTimeRanges.length,
                                itemBuilder: (context, index) {
                                  final range = widget.dateTimeRanges[index];
                                  final isFullDay = isFullDayBooking(range['start']!, range['end']!);

                                  return Container(
                                    margin: EdgeInsets.symmetric(vertical: 2, horizontal: 15),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              date(range['start'].toString()),
                                              style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 14.0,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(" - " +
                                                DateFormat('EEEE').format(DateTime.parse(range['start']!)).substring(0, 3),
                                              style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 14.0,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Only show time if it's not a full day booking
                                        if (!isFullDay)
                                          Row(
                                            children: [
                                              Text(
                                                time(range['start'].toString()),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 14.0,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              Text(" - " +
                                                  time(range['end'].toString()),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 14.0,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          )
                                        else
                                        // Show "Full Day" text for full day bookings
                                          Text(
                                            "",
                                            style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 14.0,
                                              color: Colors.grey[600],
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),

                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                        child: Text("Note: Holidays and operational hours of the branch will take effect.",
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 14.0,
                              color: Colors.orange),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0, top: 10),
                        child: Text(
                          'Payment Details',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        width: MediaQuery.of(context).size.width - 30,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow('Amount',NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(widget.totalPrice) ),
                            _buildDetailRow('Tax(18%)', NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(calculateTax(widget.totalPrice))),
                            _buildDetailRow('Total Amount', NumberFormat.currency(locale: 'en_IN', symbol: '₹').format((widget.totalPrice + calculateTax(widget.totalPrice))), bold: true),
                            // _buildDetailRow('Total Amount', (widget.totalPrice + calculateTax(widget.totalPrice)).toStringAsFixed(2), bold: true),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0, top: 10),
                        child: Text(
                          'Select Payment Method',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        width: MediaQuery.of(context).size.width - 30,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          children: [

                            ListTile(
                              title: Text('Online payment'),
                              leading: Radio<String>(
                                value: 'gateway',
                                groupValue: _selectedPaymentMethod,
                                onChanged: (String? value) {
                                  setState(() {
                                    _selectedPaymentMethod = value!;
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              title: Text('Credit point: 0'),
                              leading: Radio<String>(
                                value: 'wallet',
                                groupValue: _selectedPaymentMethod,
                                onChanged: (String? value) {
                                  setState(() {
                                    _selectedPaymentMethod = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 15.0),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _termsAccepted,
                              onChanged: (bool? value) {
                                setState(() {
                                  _termsAccepted = value ?? false;
                                });
                              },
                              activeColor: primary_color,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const TermsAndConditionsPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "I agree to the Terms and Conditions",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

           */
/*           Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TermsAndConditionsPage(),
                              ),
                            );
                          },
                          child: Text(
                            "Terms and Conditions",
                            style: TextStyle(
                              color: Colors.blue, // Color for the clickable text
                              decoration: TextDecoration.underline, // Underline the text to show it's clickable
                            ),
                          ),
                        ),),*//*

                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    // Update the onPressed handler in the ElevatedButton widget
                    child: ElevatedButton(
            onPressed:  !_termsAccepted ? null : () {
            // Convert deskCounter from String to int
            int desksRequested = int.parse(widget.deskCounter);

            // Initialize list to hold selected items
            List<Item>? selectedItems;

            if (widget.availableItems != null && widget.availableItems!.isNotEmpty) {
            if (desksRequested == 1) {
            // If only one desk is requested, take the first available item
            selectedItems = [widget.availableItems!.first];
            } else {
            // If multiple desks are requested, take that many items
            // but not more than available
            int itemsToTake = min(desksRequested, widget.availableItems!.length);
            selectedItems = widget.availableItems!.take(itemsToTake).toList();
            }

            // Proceed with booking only if we have items to book
            if (selectedItems.isNotEmpty) {
            context.read<BookingBloc>().add(
            BlockAssetEvent(
            familyId: widget.familyId!,
            numOfItems: selectedItems.length.toString(),
            from: widget.selectedDate,
            to: widget.selectedEndDate,
            items: selectedItems,
            // packageId: widget.packageId
            ),
            );
            } else {
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No items available for booking')),
            );
            }
            } else {
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No items available for booking')),
            );
            }
            },
            style:ButtonStyle(
              elevation: MaterialStateProperty.all(1),
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  if (states.contains(MaterialState.disabled)) {
                    return Colors.grey; // Disabled color
                  }
                  return primary_color; // Enabled color
                },
              ),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            // ButtonStyle(
            // elevation: MaterialStateProperty.all(1),
            // backgroundColor: MaterialStateProperty.all(primary_color),
            // shape: MaterialStateProperty.all(
            // RoundedRectangleBorder(
            // borderRadius: BorderRadius.circular(12),
            // ),
            // ),
            // ),
            child: state is BookingLoading && state is BlockAssetLoading
            ? CircularProgressIndicator(color: primary_color)
                : Text(
            "Confirm Booking",
            style: TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w500,
            ),
            ),
            ),
                 */
/*   ElevatedButton(
                      onPressed: () {
                        // Get only the first item if available
                        List<AvailableItemsByFamily>? firstItem;
                        if (widget.availableItems != null && widget.availableItems!.isNotEmpty) {
                          firstItem = [widget.availableItems!.first];
                        }

                        print("jnnn------ ${widget.selectedDate}---- ${widget.selectedEndDate}  ${widget.familyId!}");
                        context.read<BookingBloc>().add(
                          BlockAssetEvent(
                              familyId: widget.familyId!,
                              numOfItems: widget.deskCounter!.toString(),
                              from: widget.selectedDate,
                              to: widget.selectedEndDate,
                              items: firstItem, // Pass only the first item
                              packageId: widget.packageId
                          ),
                        );
                      },
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all(1),
                        backgroundColor: MaterialStateProperty.all(primary_color),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      child: state is BookingLoading && state is BlockAssetLoading
                          ? CircularProgressIndicator(color: primary_color)
                          : Text(
                        "Confirm Booking",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),*//*


                  ),
                ),
                if (state is BookingLoading ||
                    state is BlockAssetLoading ||
                    state is PaymentOrderLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: primary_color),
                            SizedBox(height: 16),
                            Text(
                              _getLoadingMessage(state),
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // if (state is BookingLoading)
                //   Positioned.fill(
                //     child: Container(
                //       color: Colors.black.withOpacity(0.5),
                //       child: Center(child: CircularProgressIndicator(color: primary_color,)),
                //     ),
                //   ),
              ],
            );
          },
        ),
      ),
    );
  }
  String _getLoadingMessage(BookingState state) {
    if (state is BlockAssetLoading) {
      return "Blocking assets...";
    } else if (state is PaymentOrderLoading) {
      return "Creating payment order...";
    } else if (state is BookingLoading) {
      return "Processing payment...";
    }
    return "Loading...";
  }
  List<Map<String, String>> splitDateRangeIgnoringSundays(DateTime startDate, DateTime endDate) {
    List<Map<String, String>> dateTimeRanges = [];

    DateTime currentDay = startDate;

    while (currentDay.isBefore(endDate) || currentDay.isAtSameMomentAs(endDate)) {
      if (currentDay.weekday != DateTime.sunday) {
        DateTime dayStart = DateTime(
          currentDay.year,
          currentDay.month,
          currentDay.day,
          startDate.hour,
          startDate.minute,
        );

        DateTime dayEnd = DateTime(
          currentDay.year,
          currentDay.month,
          currentDay.day,
          endDate.hour,
          endDate.minute,
        );

        dateTimeRanges.add({
          'start': dayStart.toIso8601String(),
          'end': dayEnd.toIso8601String(),
        });
      }
      currentDay = currentDay.add(Duration(days: 1));
    }

    return dateTimeRanges;
  }

  Widget _buildDetailRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 18.0 : 14.0,
              color: bold ? Colors.black : Colors.grey[800],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 20.0 : 14.0,
              color: bold ? Colors.black : Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  String date(String date) {
    DateTime now = DateTime.parse(date);
    var formatter = DateFormat('dd/MM/yy');
    return formatter.format(now);
  }

  String time(String date) {
    DateTime dateTime = DateTime.parse(date);

    // Check if this is a "full day" booking (00:00 to 23:59)
    // If start time is 00:00:00 and end time is 23:59:00, don't show time
    if (dateTime.hour == 0 && dateTime.minute == 0) {
      return ""; // Return empty string for start time when it's full day
    }
    if (dateTime.hour == 23 && dateTime.minute == 59) {
      return ""; // Return empty string for end time when it's full day
    }

    var formatter = DateFormat('hh:mm a'); // Added 'a' for AM/PM
    return formatter.format(dateTime);
  }
  bool isFullDayBooking(String startDate, String endDate) {
    DateTime start = DateTime.parse(startDate);
    DateTime end = DateTime.parse(endDate);

    return (start.hour == 0 && start.minute == 0) &&
        (end.hour == 23 && end.minute == 59);
  }
  void _confirmBooking(BuildContext context) {
    if (_selectedPaymentMethod == 'wallet') {
      // Assuming the wallet balance is zero or insufficient
      bool isBalanceSufficient = false; // Replace with actual balance check

      if (!isBalanceSufficient) {
        showToast(
          "You have no sufficient balance",

        );
        return; // Exit the method to prevent further execution
      }


    } else if (_selectedPaymentMethod == 'gateway') {
      // Handle online payment method with Razorpay
      print("Here weeeee11");
      // Proceed with the online payment
      context.read<BookingBloc>().add(StartBooking(
        assetId: widget.assetId,
        fromDate: widget.selectedDate,
        toDate: widget.selectedEndDate,
        totalPrice: widget.totalPrice,
        paymentMethod: _selectedPaymentMethod,
      ));
    } else {
      // Handle other payment methods if any
      showToast(
      "Please select a valid payment method",

      );
    }
  }
  double calculateTax(double totalPrice) {
    return totalPrice * 0.18;
  }

}
*/









