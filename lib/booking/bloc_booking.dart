import 'dart:convert';


import 'package:hb_booking_mobile_app/booking/asset_by_family_model.dart';
import 'package:hb_booking_mobile_app/home/model/model_assets.dart';
import 'package:hb_booking_mobile_app/utils/base_url.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;




abstract class BookingEvent {}

class StartBooking extends BookingEvent {
  final String assetId;
  final String fromDate;
  final String toDate;
  final double totalPrice;
  final String paymentMethod;
  final String? walletId;
  final int? creditValue;
  final String? creditType;
  final String? bookingId;

  StartBooking({
    required this.assetId,
    required this.fromDate,
    required this.toDate,
    required this.totalPrice,
    required this.paymentMethod,
    this.walletId,
    this.creditValue,
    this.creditType,
    this.bookingId,
  });
}

class PaymentSuccess extends BookingEvent {}

class PaymentFailure extends BookingEvent {
  final String error;
  PaymentFailure(this.error);
}

class BlockAssetEvent extends BookingEvent {
  final String familyId;
  final String numOfItems;
  final String from;
  final String to;
  final List<Item>? items;

  BlockAssetEvent({
    required this.familyId,
    required this.numOfItems,
    required this.from,
    required this.to,
    required this.items,
  });

  @override
  List<Object?> get props => [familyId, numOfItems, from, to, items];
}

class FetchAvailableAssets extends BookingEvent {
  final String fromDate;
  final String toDate;
  final String branchId;
  final String familyId;

  FetchAvailableAssets({
    required this.fromDate,
    required this.toDate,
    required this.branchId,
    required this.familyId,
  });

  @override
  List<Object?> get props => [fromDate, toDate, branchId, familyId];
}

class FetchWalletBalance extends BookingEvent {
  final String tenantId;

  FetchWalletBalance({required this.tenantId});

  @override
  List<Object?> get props => [tenantId];
}

class CreatePaymentOrder extends BookingEvent {
  final double totalPrice;
  final String assetId;
  final String fromDate;
  final String toDate;

  CreatePaymentOrder({
    required this.totalPrice,
    required this.assetId,
    required this.fromDate,
    required this.toDate,
  });
}

class PaymentOrderCreated extends BookingEvent {
  final Map<String, dynamic> orderData;
  PaymentOrderCreated(this.orderData);
}

class PaymentOrderFailure extends BookingEvent {
  final String error;
  PaymentOrderFailure(this.error);
}

abstract class BookingState {}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {
  final String assetId;
  final String fromDate;
  final String toDate;

  BookingLoading({
    required this.assetId,
    required this.fromDate,
    required this.toDate,
  });
}

class BookingNavigationSuccess extends BookingState {}

class BookingFailure extends BookingState {
  final String error;
  BookingFailure(this.error);
}

class BlockAssetInitial extends BookingState {}

class BlockAssetLoading extends BookingState {}

class BlockAssetSuccess extends BookingState {}

class BlockAssetFailure extends BookingState {
  final String error;
  BlockAssetFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class AvailableAssetsInitial extends BookingState {}

class AvailableAssetsLoading extends BookingState {}

class AvailableAssetsLoaded extends BookingState {
  final AssetByFamilyIdModel data;

  AvailableAssetsLoaded({required this.data});

  @override
  List<Object?> get props => [data];
}

class AvailableAssetsError extends BookingState {
  final String message;

  AvailableAssetsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class WalletBalanceLoading extends BookingState {}

class WalletBalanceLoaded extends BookingState {
  final Map<String, dynamic> walletData;
  final int creditBalance;
  final String walletId;

  WalletBalanceLoaded({
    required this.walletData,
    required this.creditBalance,
    required this.walletId,
  });

  @override
  List<Object?> get props => [walletData, creditBalance, walletId];
}

class WalletBalanceError extends BookingState {
  final String message;

  WalletBalanceError({required this.message});

  @override
  List<Object?> get props => [message];
}

class PaymentOrderLoading extends BookingState {}

class PaymentOrderSuccess extends BookingState {
  final Map<String, dynamic> orderData;
  PaymentOrderSuccess(this.orderData);
}

class PaymentOrderError extends BookingState {
  final String error;
  PaymentOrderError(this.error);
}

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  late Razorpay _razorpay;

  BookingBloc() : super(BookingInitial()) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (response) {
      add(PaymentSuccess());
    });
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (response) {
      add(PaymentFailure(response.message ?? 'Payment failed'));
    });

    on<StartBooking>(_onStartBooking);
    on<BlockAssetEvent>(_onBlockAsset);
    on<PaymentSuccess>(_onPaymentSuccess);
    on<PaymentFailure>(_onPaymentFailure);
    on<FetchAvailableAssets>(_onFetchAvailableAssets);
    on<FetchWalletBalance>(_onFetchWalletBalance);
    on<CreatePaymentOrder>(_onCreatePaymentOrder);
    on<PaymentOrderCreated>(_onPaymentOrderCreated);
    on<PaymentOrderFailure>(_onPaymentOrderFailure);
  }

  // Fetch wallet balance
  Future<void> _onFetchWalletBalance(FetchWalletBalance event, Emitter<BookingState> emit) async {
    emit(WalletBalanceLoading());

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken') ?? '';

      final response = await http.get(
        Uri.parse('${base_url}wallet/tenant/${event.tenantId}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print("Wallet balance response: ${response.statusCode}");
      print("Wallet balance body: ${response.body}");

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true && responseBody['data'] != null) {
          final walletData = responseBody['data'];
          final balance = walletData['balance'];

          int creditBalance = 0;
          String walletId = walletData['_id'] ?? '';

          if (balance != null && balance is List && balance.isNotEmpty) {
            final inventoryCredits = balance.firstWhere(
                  (item) => item['_id'] == 'INVENTORY_CREDITS',
              orElse: () => null,
            );

            if (inventoryCredits != null) {
              creditBalance = inventoryCredits['balance'] ?? 0;
            }
          }

          emit(WalletBalanceLoaded(
            walletData: walletData,
            creditBalance: creditBalance,
            walletId: walletId,
          ));
        } else {
          emit(WalletBalanceError( message: responseBody['message'] ?? 'Failed to fetch wallet balance'));
        }
      } else {
        final responseBody = jsonDecode(response.body);
        final errorMessage = responseBody['message'] ?? 'Failed to fetch wallet balance';
        emit(WalletBalanceError( message: 'errorMessage'));
      }
    } catch (e) {
      emit(WalletBalanceError( message: "An error occurred: ${e.toString()}",));
    }
  }

  // Updated start booking with credit points support
  Future<void> _onStartBooking(StartBooking event, Emitter<BookingState> emit) async {
    print("Starting booking with payment method: ${event.paymentMethod}");

    emit(BookingLoading(
      assetId: event.assetId,
      fromDate: event.fromDate,
      toDate: event.toDate,
    ));

    if (event.paymentMethod == 'credits') {
      // Handle credit points payment
      await _processCreditsPayment(event, emit);
    } else if (event.paymentMethod == 'wallet') {
      // Handle wallet payment logic here
      emit(BookingNavigationSuccess());
    } else {
      // Create payment order for gateway payment
      add(CreatePaymentOrder(
        totalPrice: event.totalPrice,
        assetId: event.assetId,
        fromDate: event.fromDate,
        toDate: event.toDate,
      ));
    }
  }

  Future<void> _processCreditsPayment(StartBooking event, Emitter<BookingState> emit) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken') ?? '';

      print("🔵 [DEBUG] Starting credit payment process");
      print("🔵 [DEBUG] Booking ID: ${event.bookingId}");
      print("🔵 [DEBUG] Wallet ID: ${event.walletId}");
      print("🔵 [DEBUG] Credit Value: ${event.creditValue}");
      print("🔵 [DEBUG] Credit Type: ${event.creditType}");
      print("🔵 [DEBUG] Access Token: ${accessToken.isNotEmpty ? 'Present' : 'Missing'}");

      final requestBody = {
        'bookingId': event.bookingId,
        'paymentMethod': 'credits',
        'walletId': event.walletId,
        'creditValue': event.creditValue,
        'creditType': event.creditType,
      };

      print("🔵 [DEBUG] Request URL: ${base_url}booking/confirmBookingv3");
      print("🔵 [DEBUG] Request Body: ${jsonEncode(requestBody)}");

      final response = await http.put(
        Uri.parse('${base_url}booking/confirmBookingv3'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
      );

      print("🟢 [DEBUG] Credits payment response status: ${response.statusCode}");
      print("🟢 [DEBUG] Credits payment response headers: ${response.headers}");
      print("🟢 [DEBUG] Credits payment response body: ${response.body}");

      if (response.statusCode == 200) {
        print("✅ [DEBUG] Credit payment successful - emitting BookingNavigationSuccess");
        emit(BookingNavigationSuccess());
      } else {
        print("❌ [DEBUG] Credit payment failed with status: ${response.statusCode}");
        try {
          final responseBody = jsonDecode(response.body);
          final errorMessage = responseBody['message'] ?? 'Failed to process credits payment';
          print("❌ [DEBUG] Error message from API: $errorMessage");
          emit(BookingFailure(errorMessage));
        } catch (parseError) {
          print("❌ [DEBUG] Error parsing response body: $parseError");
          emit(BookingFailure("Failed to process credits payment. Status: ${response.statusCode}"));
        }
      }
    } catch (e) {
      print("💥 [DEBUG] Exception in _processCreditsPayment: $e");
      print("💥 [DEBUG] Exception type: ${e.runtimeType}");
      emit(BookingFailure("Error processing credits payment: ${e.toString()}"));
    }
  }
  // All other existing methods remain the same
  Future<void> _onCreatePaymentOrder(CreatePaymentOrder event, Emitter<BookingState> emit) async {
    emit(PaymentOrderLoading());

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken') ?? '';
      final email = prefs.getString('email') ?? '';
      final userId = prefs.getString('userid') ?? '';
      final userName = prefs.getString('username') ?? '';

      final totalAmountWithTax = event.totalPrice + (event.totalPrice * 0.18);
      final amountInPaise = (totalAmountWithTax * 100).toInt();

      final response = await http.post(
        Uri.parse('${base_url}payment/order/create'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'amount': amountInPaise,
          'userId': userId,
          'email': email,
          'name': userName,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true && responseBody['data'] != null) {
          add(PaymentOrderCreated(responseBody['data']));
        } else {
          add(PaymentOrderFailure(responseBody['message'] ?? 'Failed to create payment order'));
        }
      } else {
        final responseBody = jsonDecode(response.body);
        final errorMessage = responseBody['message'] ?? 'Failed to create payment order';
        add(PaymentOrderFailure(errorMessage));
      }
    } catch (e) {
      add(PaymentOrderFailure("An error occurred: ${e.toString()}"));
    }
  }

  Future<void> _onPaymentOrderCreated(PaymentOrderCreated event, Emitter<BookingState> emit) async {
    emit(PaymentOrderSuccess(event.orderData));

    try {
      final orderData = event.orderData;
      final amount = orderData['amount'];
      final orderId = orderData['orderId'];
      final userData = orderData['user'];

      if (amount == null || orderId == null || userData == null) {
        emit(BookingFailure("Invalid order data"));
        return;
      }

      final userName = userData['name'] ?? 'Guest';
      final userEmail = userData['email'] ?? '';
      final userId = userData['userId'] ?? '';
      // prod
      //rzp_live_VZdGe9Nto5EdYM
      //stag
      //rzp_test_QmvKqYwU6DtqeK
      var options = {
        'key': 'rzp_live_VZdGe9Nto5EdYM',
        'amount': amount,
        'currency': 'INR',
        'name': 'Innerspace Coworking',
        'order_id': orderId,
        'prefill': {
          'name': userName,
          'email': userEmail,

        },
        'theme': {'color': '#ff8c42'},
        'notes': {
          'email': userEmail,
          'name': userName,
          'userId': userId,
        },
        'external': {'wallets': ['paytm']}
      };

      _razorpay.open(options);
    } catch (e) {
      emit(BookingFailure("An error occurred while opening Razorpay: ${e.toString()}"));
    }
  }

  void _onPaymentOrderFailure(PaymentOrderFailure event, Emitter<BookingState> emit) {
    emit(BookingFailure(event.error));
  }

  Future<void> _onFetchAvailableAssets(FetchAvailableAssets event, Emitter<BookingState> emit) async {
    emit(AvailableAssetsLoading());
    try {
      final response = await http.get(
        Uri.parse(
          '${base_url}booking/getAvailableAssetsByFamilyId?fromDate=${event.fromDate}&toDate=${event.toDate}&branchId=${event.branchId}&familyId=${event.familyId}',
        ),
      );
      if (response.statusCode == 200) {
        final data = AssetByFamilyIdModel.fromJson(json.decode(response.body));
        emit(AvailableAssetsLoaded(data: data));
      } else {
        emit(AvailableAssetsError(message: 'Failed to fetch assets'));
      }
    } catch (e) {
      emit(AvailableAssetsError(message: e.toString()));
    }
  }

  Future<void> _onPaymentSuccess(PaymentSuccess event, Emitter<BookingState> emit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';
    final bookingIds = prefs.getString('blockDataIds') ?? '';

    try {
      final response = await http.put(
        Uri.parse('${base_url}booking/confirmBookingv3'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'bookingId': bookingIds,
          'paymentMethod': 'upi',

        }),
      );

      if (response.statusCode == 200) {
        emit(BookingNavigationSuccess());
      } else {
        final responseBody = jsonDecode(response.body);
        final errorMessage = responseBody['message'] ?? 'Failed to create booking';
        emit(BookingFailure(errorMessage));
      }
    } catch (e) {
      emit(BookingFailure("Error confirming booking: ${e.toString()}"));
    }
  }

  void _onPaymentFailure(PaymentFailure event, Emitter<BookingState> emit) {
    emit(BookingFailure(event.error));
  }

  String timeStringToHHMMSS(String timeString) {
    // Split by '.' to remove milliseconds if present
    String timeWithoutMs = timeString.split('.')[0];

    // Split by ':' to get hours, minutes, seconds
    List<String> parts = timeWithoutMs.split(':');

    if (parts.length >= 3) {
      String hours = parts[0].padLeft(2, '0');
      String minutes = parts[1].padLeft(2, '0');
      String seconds = parts[2].padLeft(2, '0');

      return '$hours:$minutes:$seconds';
    }

    return '00:00:00'; // Default for invalid format
  }
  Future<void> _onBlockAsset(BlockAssetEvent event, Emitter<BookingState> emit) async {
    emit(BlockAssetLoading());

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';
    List<String> fparts = event.from.split(' ');
    List<String> tparts = event.to.split(' ');


    String fdate = fparts[0];
    String ftime = fparts[1];
    String tdate = tparts[0];
    String ttime = tparts[1];

    try {
      final response = await http.put(
        Uri.parse('${base_url}booking/blockAssetsv3'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'assets': event.items,
          'fromDate': fdate,
          'toDate': tdate,
          'fromTime': timeStringToHHMMSS(ftime),
          'toTime': timeStringToHHMMSS(ttime)
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        String blockDataId = '';

        if (responseBody['data'] != null && responseBody['data'].isNotEmpty) {
          blockDataId = responseBody['data']['bookingId'];
        }
        await prefs.setString('blockDataIds', blockDataId);
        emit(BlockAssetSuccess());
      } else {
        final responseBody = jsonDecode(response.body);
        final errorMessage = responseBody['message'] ?? 'Asset not available';
        emit(BlockAssetFailure(errorMessage));
      }
    } catch (e) {
      emit(BlockAssetFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _razorpay.clear();
    return super.close();
  }
}

/*
// Updated BookingBloc class
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  late Razorpay _razorpay;

  BookingBloc() : super(BookingInitial()) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (response) {
      add(PaymentSuccess()); // Trigger the PaymentSuccess event
    });
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (response) {
      add(PaymentFailure(response.message ?? 'Payment failed'));
    });

    on<StartBooking>(_onStartBooking);
    on<BlockAssetEvent>(_onBlockAsset);
    on<PaymentSuccess>(_onPaymentSuccess);
    on<PaymentFailure>(_onPaymentFailure);
    on<FetchAvailableAssets>(_onFetchAvailableAssets);
    on<CreatePaymentOrder>(_onCreatePaymentOrder);
    on<PaymentOrderCreated>(_onPaymentOrderCreated);
    on<PaymentOrderFailure>(_onPaymentOrderFailure);
  }

  // Updated _onStartBooking method
  Future<void> _onStartBooking(StartBooking event, Emitter<BookingState> emit) async {
    print("Here weeeee");

    emit(BookingLoading(
      assetId: event.assetId,
      fromDate: event.fromDate,
      toDate: event.toDate,
    ));

    if (event.paymentMethod == 'wallet') {
      // Handle wallet payment logic here
      emit(BookingNavigationSuccess()); // For now, just simulate a success
    } else {
      // First create payment order before initiating Razorpay
      add(CreatePaymentOrder(
        totalPrice: event.totalPrice,
        assetId: event.assetId,
        fromDate: event.fromDate,
        toDate: event.toDate,
      ));
    }
  }

  // New method to create payment order
  Future<void> _onCreatePaymentOrder(CreatePaymentOrder event, Emitter<BookingState> emit) async {
    emit(PaymentOrderLoading());

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken') ?? '';

      // Fetch user data from SharedPreferences
      final email = prefs.getString('email') ?? '';
      final userId = prefs.getString('userid') ?? '';
      final userName = prefs.getString('username') ?? '';

      final totalAmountWithTax = event.totalPrice + (event.totalPrice * 0.18);
      final amountInPaise = (totalAmountWithTax * 100).toInt();

      final response = await http.post(
        Uri.parse('${base_url}payment/order/create'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'amount': amountInPaise,
          'userId': userId,
          'email': email,
          'name': userName,
        }),
      );

      print("Payment order creation response: ${response.statusCode}");
      print("Payment order creation body: ${response.body}");

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true && responseBody['data'] != null) {
          add(PaymentOrderCreated(responseBody['data']));
        } else {
          add(PaymentOrderFailure(responseBody['message'] ?? 'Failed to create payment order'));
        }
      } else {
        final responseBody = jsonDecode(response.body);
        final errorMessage = responseBody['message'] ?? 'Failed to create payment order';
        add(PaymentOrderFailure(errorMessage));
      }
    } catch (e) {
      add(PaymentOrderFailure("An error occurred: ${e.toString()}"));
    }
  }
  Future<void> _onPaymentOrderCreated(PaymentOrderCreated event, Emitter<BookingState> emit) async {
    emit(PaymentOrderSuccess(event.orderData));

    try {
      // Now initiate Razorpay with the order data
      final orderData = event.orderData;

      // Debug: Print the complete order data
      print("📋 [DEBUG] Complete order data: $orderData");

      // Safely extract values with null checks
      final amount = orderData['amount'];
      final orderId = orderData['orderId'];
      final userData = orderData['user'];

      print("💰 [DEBUG] Amount: $amount");
      print("🆔 [DEBUG] Order ID: $orderId");
      print("👤 [DEBUG] User data: $userData");

      // Validate required fields
      if (amount == null) {
        emit(BookingFailure("Amount not found in order data"));
        return;
      }

      if (orderId == null || orderId.isEmpty) {
        emit(BookingFailure("Order ID not found in order data"));
        return;
      }

      if (userData == null) {
        emit(BookingFailure("User data not found in order data"));
        return;
      }

      // Safely extract user data
      final userName = userData['name'] ?? 'Guest';
      final userEmail = userData['email'] ?? '';
      final userId = userData['userId'] ?? '';

      print("👤 [DEBUG] User Name: $userName");
      print("📧 [DEBUG] User Email: $userEmail");
      print("🆔 [DEBUG] User ID: $userId");

      var options = {
        'key': 'rzp_test_ahRn5Z8LtMvcAB', // Your actual key
        'amount': amount, // Amount in paise from API response
        'currency': 'INR',
        'name': 'Innerspace Coworking',
        'order_id': orderId, // Order ID from API response
        'prefill': {
          'name': userName,
          'email': userEmail,
          'contact': '8888888888',
        },
        'theme': {
          'color': '#ff8c42'
        },
        'notes': {
          'email': userEmail,
          'name': userName,
          'userId': userId,
        },
        'external': {
          'wallets': ['paytm']
        }
      };

      print("🎯 [DEBUG] Razorpay options: $options");

      // Open Razorpay
      _razorpay.open(options);
      print("✅ [DEBUG] Razorpay opened successfully");

    } catch (e) {
      print("❌ [ERROR] Error in _onPaymentOrderCreated: $e");
      emit(BookingFailure("An error occurred while opening Razorpay: ${e.toString()}"));
    }
  }
  // // Handle successful payment order creation
  // Future<void> _onPaymentOrderCreated(PaymentOrderCreated event, Emitter<BookingState> emit) async {
  //   emit(PaymentOrderSuccess(event.orderData));
  //
  //   // Now initiate Razorpay with the order data
  //   final orderData = event.orderData;
  //
  //   var options = {
  //     'key': 'rzp_test_QmvKqYwU6DtqeK', // Replace with your actual key
  //     'amount': orderData['amount'], // Amount in paise from API response
  //     'currency': 'INR',
  //     'name': 'Innerspace Coworking',
  //     'order_id': orderData['orderId'], // Order ID from API response
  //     'prefill': {
  //       'name': orderData['user']['name'],
  //       'email': orderData['user']['email'],
  //       'contact': '8888888888', // You might want to get this from user data
  //     },
  //     'theme': {
  //       'color': '#ff8c42'
  //     },
  //     'notes': {
  //       'email': orderData['user']['email'],
  //       'name': orderData['user']['name'],
  //       'userId': orderData['user']['userId'],
  //     },
  //     'external': {
  //       'wallets': ['paytm']
  //     }
  //   };
  //
  //   try {
  //     _razorpay.open(options);
  //   } catch (e) {
  //     emit(BookingFailure("An error occurred while opening Razorpay: ${e.toString()}"));
  //   }
  // }

  // Handle payment order creation failure
  void _onPaymentOrderFailure(PaymentOrderFailure event, Emitter<BookingState> emit) {
    emit(BookingFailure(event.error));
  }

  // Keep all your existing methods unchanged
  Future<void> _onFetchAvailableAssets(FetchAvailableAssets event, Emitter<BookingState> emit) async {
    emit(AvailableAssetsLoading());
    try {
      final response = await http.get(
        Uri.parse(
          '${base_url}booking/getAvailableAssetsByFamilyId?fromDate=${event.fromDate}&toDate=${event.toDate}&branchId=${event.branchId}&familyId=${event.familyId}',
        ),
      );
      if (response.statusCode == 200) {
        final data = AssetByFamilyIdModel.fromJson(json.decode(response.body));
        print("getAvailableAssetsByFamilyId resp - ${response.body}");

        emit(AvailableAssetsLoaded(data: data));
      } else {
        emit(AvailableAssetsError(message: 'Failed to fetch assets'));
      }
    } catch (e) {
      emit(AvailableAssetsError(message: e.toString()));
    }
  }


  Future<void> _onPaymentSuccess(PaymentSuccess event, Emitter<BookingState> emit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';
    print("reso-- ${accessToken}");
    final bookingIds = prefs.getString('blockDataIds') ?? '';
    print("reso--  ${bookingIds}");

    // Remove the state check - always proceed with booking confirmation
    print("book resp --${bookingIds}");
    print("Current state: ${state.runtimeType}"); // Debug current state

    try {
      final response = await http.put(
        Uri.parse('${base_url}booking/confirmBookingv3/${bookingIds}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print("book resp --${bookingIds}");
      print("book resp --${response.statusCode}");
      print("book resp --${response.body}");

      if (response.statusCode == 200) {
        print("✅ [DEBUG] Booking confirmed successfully, emitting BookingNavigationSuccess");
        emit(BookingNavigationSuccess());
      } else {
        final responseBody = jsonDecode(response.body);
        final errorMessage = responseBody['message'] ?? 'Failed to create booking';
        print("❌ [DEBUG] Booking confirmation failed: $errorMessage");
        emit(BookingFailure(errorMessage));
      }
    } catch (e) {
      print("❌ [DEBUG] Exception in booking confirmation: $e");
      emit(BookingFailure("Error confirming booking: ${e.toString()}"));
    }
  }
  void _onPaymentFailure(PaymentFailure event, Emitter<BookingState> emit) {
    emit(BookingFailure(event.error));
  }

  @override
  Future<void> close() {
    _razorpay.clear();
    return super.close();
  }

  Future<void> _onBlockAsset(BlockAssetEvent event, Emitter<BookingState> emit) async {
    emit(BlockAssetLoading());

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';
    List<String> fparts = event.from.split(' ');
    List<String> tparts = event.to.split(' ');

    String fdate = fparts[0];
    String ftime = fparts[1];
    String tdate = tparts[0];
    String ttime = tparts[1];

    print("Date: $fdate");
    print("Time: $ftime");
    print("Date: $tdate");
    print("Time: $ttime");
    print("items: ${event.items}");

    try {
      final response = await http.put(
        Uri.parse('${base_url}booking/blockAssetsv3'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'assets': event.items,
          'fromDate': fdate,
          'toDate': tdate,
          'fromTime': ftime,
          'toTime': ttime
        }),
      );

      print("reso-- blockv3 ${response.statusCode}");
      print("reso-- blockv3 ${response.body}");

      if (response.statusCode == 200) {
        print(response.body);
        final responseBody = jsonDecode(response.body);
        String blockDataId = '';

        if (responseBody['data'] != null && responseBody['data'].isNotEmpty) {
          blockDataId = responseBody['data']['bookingId'];
        }
        print("reso-- blockv3 ${blockDataId}");
        await prefs.setString('blockDataIds', blockDataId);
        emit(BlockAssetSuccess());
      } else {
        final responseBody = jsonDecode(response.body);
        final errorMessage = responseBody['message'] ?? 'Asset not available';
        emit(BlockAssetFailure(errorMessage));
      }
    } catch (e) {
      emit(BlockAssetFailure(e.toString()));
    }
  }
}
*/

/*// BookingBloc implementation
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  late Razorpay _razorpay;

  BookingBloc() : super(BookingInitial()) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (response) {
      add(PaymentSuccess()); // Trigger the PaymentSuccess event
    });
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (response) {
      add(PaymentFailure(response.message ?? 'Payment failed'));
    });

    on<StartBooking>(_onStartBooking);
    on<BlockAssetEvent>(_onBlockAsset);
    on<PaymentSuccess>(_onPaymentSuccess);
    on<PaymentFailure>(_onPaymentFailure);
    on<FetchAvailableAssets>(_onFetchAvailableAssets);
  }
  Future<void> _onFetchAvailableAssets(FetchAvailableAssets event, Emitter<BookingState> emit) async {
    emit(AvailableAssetsLoading());
    try {
      final response = await http.get(
        Uri.parse(
          '${base_url}booking/getAvailableAssetsByFamilyId?fromDate=${event.fromDate}&toDate=${event.toDate}&branchId=${event.branchId}&familyId=${event.familyId}',
        ),
      );
      if (response.statusCode == 200) {
        final data = AssetByFamilyIdModel.fromJson(json.decode(response.body));
        print("getAvailableAssetsByFamilyId resp - ${response.body}");

        emit(AvailableAssetsLoaded(data: data));
      } else {
        emit(AvailableAssetsError(message: 'Failed to fetch assets'));
      }
    } catch (e) {
      emit(AvailableAssetsError(message: e.toString()));
    }
  }
  Future<void> _onStartBooking(StartBooking event, Emitter<BookingState> emit) async {

print("Here weeeee");

    emit(BookingLoading(
      assetId: event.assetId,
      fromDate: event.fromDate,
      toDate: event.toDate,
    ));

    if (event.paymentMethod == 'wallet') {
      // Handle wallet payment logic here
      emit(BookingNavigationSuccess()); // For now, just simulate a success
    } else {
      // Handle payment gateway logic using Razorpay
      var options = {
        'key': 'rzp_test_JhvgFO9iHfiot9',
        'amount': event.totalPrice * 100*1.18,
        'name': 'Hornbill Inc',
        'description': 'Workspace',
        'prefill': {
          'contact': '8888888888',
          'email': 'test@razorpay.com'
        },
        'external': {
          'wallets': ['paytm']
        }
      };

      try {
        _razorpay.open(options);
      } catch (e) {
        emit(BookingFailure("An error occurred: ${e.toString()}"));
      }
    }
  }


  Future<void> _onPaymentSuccess(PaymentSuccess event, Emitter<BookingState> emit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken')??'';
    print("reso-- ${accessToken}");
    final bookingIds = prefs.getString('blockDataIds') ?? '';
print("reso--  ${bookingIds}");
    if (state is BookingLoading) {
      final bookingState = state as BookingLoading;

      print("book resp --${bookingIds}");
      final response = await http.put(
        Uri.parse('${base_url}booking/confirmBookingv3/${bookingIds}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':'Bearer '+accessToken,
        },
        // body: jsonEncode({
        //   'bookingIds': bookingIds.first,
        // }),
      );
      print("book resp --${bookingIds}");
      print("book resp --${response}");
      print("book resp --${response.body}");

      if (response.statusCode == 200) {
        emit(BookingNavigationSuccess()); // Emit a new state to navigate to the success screen
      } else {
        final responseBody = jsonDecode(response.body);
        final errorMessage = responseBody['message'] ?? 'Failed to create booking';
        emit(BookingFailure(errorMessage));
      }
    }
  }

  void _onPaymentFailure(PaymentFailure event, Emitter<BookingState> emit) {
    emit(BookingFailure(event.error));
  }

  @override
  Future<void> close() {
    _razorpay.clear(); // Clear the Razorpay instance
    return super.close();
  }
  Future<void> _onBlockAsset(BlockAssetEvent event, Emitter<BookingState> emit) async {
    emit(BlockAssetLoading());


      SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken') ?? '';
    List<String> fparts = event.from.split(' ');
    List<String> tparts = event.to.split(' ');

    // Extract date and time
    String fdate = fparts[0];
    String ftime = fparts[1];
    // Extract  to date and to time
    String tdate = tparts[0];
    String ttime = tparts[1];

    print("Date: $fdate");
    print("Time: $ftime");

    print("Date: $tdate");
    print("Time: $ttime");
    print("items: ${event.items}");
    try {     final response = await http.put(
        Uri.parse('${base_url}booking/blockAssetsv3'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':'Bearer '+accessToken,
        },
        body: jsonEncode({
        'assets':event.items,
          // 'packageId':event.packageId,
          'fromDate':fdate,
          'toDate':tdate,
          'fromTime':ftime,
          'toTime':ttime
          // 'familyId': event.familyId,
          // 'numOfItems': event.numOfItems,
          // 'from': event.from,
          // 'to': event.to,
        }),
      );

    print("reso-- blockv3 ${response.statusCode }");
    print("reso-- blockv3 ${response.statusCode }");

    print("reso-- blockv3 ${response.body}");
      if (response.statusCode == 200) {
        print(response.body);
        final responseBody = jsonDecode(response.body);
        // List<String> blockDataIds = [];
        String blockDataId = '';


        if (responseBody['data'] != null && responseBody['data'].isNotEmpty) {
          // Store only the first 'bookingId'
          blockDataId = responseBody['data']['bookingId'];
        //  blockDataIds.add(responseBody['data'][0]['_id']);
        }
        print("reso-- blockv3 ${blockDataId}");
        // Store the IDs in SharedPreferences
        await prefs.setString('blockDataIds', blockDataId);
        emit(BlockAssetSuccess()); // Emit success state for navigation or UI update
      } else {
        final responseBody = jsonDecode(response.body);
        final errorMessage = responseBody['message'] ?? 'Asset not available';
        emit(BlockAssetFailure(errorMessage)); // Emit failure state with error message
      }
 } catch (e) {
      emit(BlockAssetFailure(e.toString())); // Handle any other exceptions
    }
  }
}*/









