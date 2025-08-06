import 'dart:async';
import 'dart:convert';

import 'package:hb_booking_mobile_app/home/model/model_review.dart';
import 'package:hb_booking_mobile_app/home/workspcae_detail/package_model.dart';
import 'package:hb_booking_mobile_app/home/workspcae_detail/state_workspacedetail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../utils/base_url.dart';
import '../model/model_assets.dart';
import 'event_workspacedetail.dart';

import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';

class EffectivePackagesData {
  final double? price;
  final double? effectivePrice;
  final List<EffectivePackage> packages;

  EffectivePackagesData({
    this.price,
    this.effectivePrice,
    required this.packages,
  });

  factory EffectivePackagesData.fromJson(Map<String, dynamic> json) {
    return EffectivePackagesData(
      price: json['price']?.toDouble(),
      effectivePrice: json['effectivePrice']?.toDouble(),
      packages: json['packages'] != null
          ? List<EffectivePackage>.from(json['packages'].map((x) => EffectivePackage.fromJson(x)))
          : [],
    );
  }
}

class EffectivePackage {
  final String id;
  final String type;
  final String name;
  final double rate;
  final PackageDuration duration;
  final double perUnitRate;

  EffectivePackage({
    required this.id,
    required this.type,
    required this.name,
    required this.rate,
    required this.duration,
    required this.perUnitRate,
  });

  factory EffectivePackage.fromJson(Map<String, dynamic> json) {
    return EffectivePackage(
      id: json['_id'] ?? '',
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      rate: (json['rate'] ?? 0).toDouble(),
      duration: PackageDuration.fromJson(json['duration'] ?? {}),
      perUnitRate: (json['perUnitRate'] ?? 0).toDouble(),
    );
  }
}

class PackageDuration {
  final String unit;
  final int value;

  PackageDuration({
    required this.unit,
    required this.value,
  });

  factory PackageDuration.fromJson(Map<String, dynamic> json) {
    return PackageDuration(
      unit: json['unit'] ?? '',
      value: json['value'] ?? 1,
    );
  }
}

// Cache class for effective packages data
class CachedEffectivePackagesData {
  final EffectivePackagesData data;
  final DateTime timestamp;

  CachedEffectivePackagesData(this.data, this.timestamp);

  bool get isExpired =>
      DateTime.now().difference(timestamp) > WorkspaceDetailBloc.cacheExpiry;
}


// Updated WorkspaceDetailBloc
class WorkspaceDetailBloc extends Bloc<WorkspaceDetailEvent, WorkspaceDetailState> {
  // Add caching for effective packages data
  static final Map<String, CachedEffectivePackagesData> _effectivePackagesCache = {};
  static const Duration cacheExpiry = Duration(minutes: 3);

  // Debounce timer for API calls
  Timer? _debounceTimer;

  WorkspaceDetailBloc() : super(WorkspaceDetailInitial()) {
    on<InitializeWorkspaceDetail>(_onInitializeWorkspaceDetail);
    on<UpdateDateRange>(_onUpdateDateRange);
    on<ToggleDescription>(_onToggleDescription);
    on<IncrementCount>(_onIncrementCount);
    on<DecrementCount>(_onDecrementCount);
    on<FetchEffectivePackages>(_onFetchEffectivePackages);
  }

  // FIXED: Add method to clear cache
  void clearEffectivePackagesCache() {
    _effectivePackagesCache.clear();
    print("Cleared effective packages cache");
  }

  Future<void> _onInitializeWorkspaceDetail(
      InitializeWorkspaceDetail event,
      Emitter<WorkspaceDetailState> emit
      ) async {
    emit(WorkspaceDetailLoading());

    try {
      print("InitializeWorkspaceDetail - apiResponse: ${event.apiResponse}");
      print("InitializeWorkspaceDetail - familyId: ${event.apiResponse.familyId}");
      print("InitializeWorkspaceDetail - hasTimeSelected: ${event.hasTimeSelected}");

      // Use initial count from API response immediately
      final initialAvailableCount = event.apiResponse.availableItems?.count ?? 0;
      final effectivePrice = event.apiResponse.rate?.effectivePrice?.toDouble() ?? 0.0;

      // Try to fetch effective packages immediately
      EffectivePackagesData? effectivePackagesData;
      final familyId = event.apiResponse.familyId;

      if (familyId != null && familyId.isNotEmpty) {
        try {
          effectivePackagesData = await fetchEffectivePackages(
            familyId: familyId,
            fromDate: event.startDate,
            toDate: event.endDate,
            hasTimeSelected: event.hasTimeSelected, // FIXED: Use the correct parameter
          );
          print("Successfully fetched effective packages during initialization");
        } catch (e) {
          print('Error fetching effective packages during initialization: $e');
          // Continue with original data
        }
      } else {
        print('No familyId available for effective packages fetch');
      }

      // Calculate price with effective packages data if available
      final totalPrice = _calculatePriceOptimized(
        event.apiResponse,
        event.startDate,
        event.endDate,
        event.hasTimeSelected, // FIXED: Use the correct parameter
        effectivePackagesData?.effectivePrice?.toDouble(),
      );

      print("Initial total price calculated: $totalPrice");

      // Emit loaded state with effective packages data
      emit(WorkspaceDetailLoaded(
        asset: event.apiResponse,
        count: initialAvailableCount,
        totalPrice: totalPrice,
        startDate: event.startDate,
        endDate: event.endDate,
        isExpanded: false,
        effectivePackagesData: effectivePackagesData,
      ));

    } catch (e) {
      print('Error in InitializeWorkspaceDetail: $e');
      emit(WorkspaceDetailError(e.toString()));
    }
  }

  Future<void> _onUpdateDateRange(
      UpdateDateRange event,
      Emitter<WorkspaceDetailState> emit
      ) async {
    if (state is! WorkspaceDetailLoaded) return;
    final currentState = state as WorkspaceDetailLoaded;

    print("UpdateDateRange called:");
    print("Start: ${event.startDate}");
    print("End: ${event.endDate}");
    print("Has time selected: ${event.hasTimeSelected}");

    // FIXED: Don't use debounce timer for now - emit immediately
    try {
      // Fetch effective packages for new date range
      EffectivePackagesData? effectivePackagesData;
      if (currentState.asset.familyId != null && currentState.asset.familyId!.isNotEmpty) {
        print("Fetching effective packages for familyId: ${currentState.asset.familyId}");

        effectivePackagesData = await fetchEffectivePackages(
          familyId: currentState.asset.familyId!,
          fromDate: event.startDate,
          toDate: event.endDate,
          hasTimeSelected: event.hasTimeSelected,
        );

        print("Successfully fetched effective packages for date range update");
      }

      // Calculate price using updated effective price
      final totalPrice = _calculatePriceOptimized(
        currentState.asset,
        event.startDate,
        event.endDate,
        event.hasTimeSelected,
        effectivePackagesData?.effectivePrice?.toDouble(),
      );

      print("Updated total price: $totalPrice");

      // FIXED: Always emit state immediately
      print("=== EMITTING NEW STATE ===");
      print("Emitting WorkspaceDetailLoaded with:");
      print("- Total price: $totalPrice");
      print("- Effective packages: ${effectivePackagesData?.packages.length ?? 0}");
      print("- Effective price: ${effectivePackagesData?.effectivePrice}");

      emit(WorkspaceDetailLoaded(
        asset: currentState.asset,
        count: currentState.count,
        totalPrice: totalPrice,
        startDate: event.startDate,
        endDate: event.endDate,
        isExpanded: currentState.isExpanded,
        effectivePackagesData: effectivePackagesData,
      ));

      print("=== STATE EMITTED SUCCESSFULLY ===");

    } catch (e) {
      print('Error updating date range: $e');
      // Keep current state on error
      emit(WorkspaceDetailLoaded(
        asset: currentState.asset,
        count: currentState.count,
        totalPrice: currentState.totalPrice,
        startDate: event.startDate,
        endDate: event.endDate,
        isExpanded: currentState.isExpanded,
        effectivePackagesData: currentState.effectivePackagesData,
      ));
    }
  }

  Future<void> _onFetchEffectivePackages(
      FetchEffectivePackages event,
      Emitter<WorkspaceDetailState> emit
      ) async {
    if (state is! WorkspaceDetailLoaded) return;

    final currentState = state as WorkspaceDetailLoaded;

    try {
      print("Manual fetch effective packages called");

      final effectivePackagesData = await fetchEffectivePackages(
        familyId: event.familyId,
        fromDate: event.fromDate,
        toDate: event.toDate,
        hasTimeSelected: event.hasTimeSelected,
      );

      // Calculate new price with updated effective price
      final totalPrice = _calculatePriceOptimized(
        currentState.asset,
        event.fromDate,
        event.toDate,
        event.hasTimeSelected,
        effectivePackagesData.effectivePrice?.toDouble(),
      );

      // Check if emit is still valid before emitting
      if (!emit.isDone) {
        emit(WorkspaceDetailLoaded(
          asset: currentState.asset,
          count: currentState.count,
          totalPrice: totalPrice,
          startDate: event.fromDate,
          endDate: event.toDate,
          isExpanded: currentState.isExpanded,
          effectivePackagesData: effectivePackagesData,
        ));
        print("Emitted state after manual effective packages fetch");
      }
    } catch (e) {
      print('Error fetching effective packages: $e');
      // Keep current state on error
    }
  }

  // Optimized price calculation with effective price parameter
  double _calculatePriceOptimized(
      Datum asset,
      DateTime startDate,
      DateTime endDate,
      bool hasTimeSelected,
      [double? effectivePrice]
      ) {
    final basePrice = effectivePrice ?? asset.rate?.effectivePrice?.toDouble() ?? 0.0;

    print("Price calculation:");
    print("Base price: $basePrice");
    print("Has time selected: $hasTimeSelected");
    print("Start: $startDate, End: $endDate");

    if (hasTimeSelected) {
      // Simple hourly calculation
      final hours = endDate.difference(startDate).inHours;
      final clampedHours = hours.clamp(1, 24);
      final totalPrice = basePrice * clampedHours;

      print("Hourly calculation: $hours hours (clamped to $clampedHours) * $basePrice = $totalPrice");
      return totalPrice;
    } else {
      // Daily calculation
      final days = _calculateBusinessDaysOptimized(startDate, endDate);
      final totalPrice = basePrice * days;

      print("Daily calculation: $days days * $basePrice = $totalPrice");
      return totalPrice;
    }
  }

  // Optimized business days calculation
  int _calculateBusinessDaysOptimized(DateTime start, DateTime end) {
    if (start.isAtSameMomentAs(end)) return 1;

    final daysDiff = end.difference(start).inDays + 1;
    if (daysDiff <= 7) {
      // For short periods, count exactly
      int businessDays = 0;
      for (int i = 0; i < daysDiff; i++) {
        final day = start.add(Duration(days: i));
        if (day.weekday != DateTime.sunday) {
          businessDays++;
        }
      }
      return businessDays.clamp(1, daysDiff);
    } else {
      // For longer periods, use approximation
      final weeks = daysDiff ~/ 7;
      final remainingDays = daysDiff % 7;
      return (weeks * 6) + remainingDays.clamp(0, 6);
    }
  }

  void _onIncrementCount(IncrementCount event, Emitter<WorkspaceDetailState> emit) {
    if (state is WorkspaceDetailLoaded) {
      final loadedState = state as WorkspaceDetailLoaded;
      final newCount = loadedState.count + 1;
      final newTotalPrice = loadedState.totalPrice / loadedState.count * newCount;

      emit(WorkspaceDetailLoaded(
        asset: loadedState.asset,
        count: newCount,
        totalPrice: newTotalPrice,
        startDate: loadedState.startDate,
        endDate: loadedState.endDate,
        isExpanded: loadedState.isExpanded,
        effectivePackagesData: loadedState.effectivePackagesData,
      ));
    }
  }

  void _onDecrementCount(DecrementCount event, Emitter<WorkspaceDetailState> emit) {
    if (state is WorkspaceDetailLoaded) {
      final loadedState = state as WorkspaceDetailLoaded;
      final newCount = (loadedState.count - 1).clamp(1, 999);
      final newTotalPrice = loadedState.totalPrice / loadedState.count * newCount;

      emit(WorkspaceDetailLoaded(
        asset: loadedState.asset,
        count: newCount,
        totalPrice: newTotalPrice,
        startDate: loadedState.startDate,
        endDate: loadedState.endDate,
        isExpanded: loadedState.isExpanded,
        effectivePackagesData: loadedState.effectivePackagesData,
      ));
    }
  }

  void _onToggleDescription(ToggleDescription event, Emitter<WorkspaceDetailState> emit) {
    if (state is! WorkspaceDetailLoaded) return;
    final currentState = state as WorkspaceDetailLoaded;

    emit(WorkspaceDetailLoaded(
      asset: currentState.asset,
      count: currentState.count,
      totalPrice: currentState.totalPrice,
      startDate: currentState.startDate,
      endDate: currentState.endDate,
      isExpanded: !currentState.isExpanded,
      effectivePackagesData: currentState.effectivePackagesData,
    ));
  }

  // Fetch effective packages method
  Future<EffectivePackagesData> fetchEffectivePackages({
    required String familyId,
    required DateTime fromDate,
    required DateTime toDate,
    bool hasTimeSelected = false,
  }) async {
    // Create cache key
    final cacheKey = '$familyId-${fromDate.toIso8601String()}-${toDate.toIso8601String()}-$hasTimeSelected';

    // Check cache first
    final cachedData = _effectivePackagesCache[cacheKey];
    if (cachedData != null && !cachedData.isExpired) {
      print('Using cached effective packages data for key: $cacheKey');
      return cachedData.data;
    }

    try {
      final fromDateStr = DateFormat('yyyy-MM-dd').format(fromDate);
      final toDateStr = DateFormat('yyyy-MM-dd').format(toDate);

      Map<String, String> queryParams = {
        'fromDate': fromDateStr,
        'toDate': toDateStr,
      };

      // Add time parameters if time is selected
      if (hasTimeSelected) {
        final fromTimeStr = DateFormat('HH:mm:ss').format(fromDate);
        final toTimeStr = DateFormat('HH:mm:ss').format(toDate);
        queryParams['fromTime'] = fromTimeStr;
        queryParams['toTime'] = toTimeStr;

        print("Adding time parameters to effective packages request:");
        print("fromTime: $fromTimeStr, toTime: $toTimeStr");
      }

      final uri = Uri.parse('${base_url}asset/family/$familyId/effective-packages')
          .replace(queryParameters: queryParams);

      print("Fetching effective packages from: $uri");

      final response = await http.get(
        uri,
        headers: {
          'Connection': 'keep-alive',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          // Add any required authorization headers here
        },
      ).timeout(const Duration(seconds: 8));

      print("Effective packages API response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print("Effective packages API response: ${response.body}");

        final data = EffectivePackagesData.fromJson(jsonData['data']);

        // Cache the result
        _effectivePackagesCache[cacheKey] = CachedEffectivePackagesData(data, DateTime.now());

        // Clean old cache entries periodically
        if (_effectivePackagesCache.length > 50) {
          _cleanEffectivePackagesCache();
        }

        print("Successfully parsed effective packages data:");
        print("Price: ${data.price}");
        print("Effective Price: ${data.effectivePrice}");
        print("Packages count: ${data.packages.length}");

        return data;
      } else {
        print("Effective packages API error: ${response.statusCode} - ${response.body}");
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to fetch effective packages');
      }
    } catch (e) {
      print('Error fetching effective packages: $e');
      rethrow;
    }
  }

  // Clean old effective packages cache entries
  void _cleanEffectivePackagesCache() {
    final now = DateTime.now();
    final oldCount = _effectivePackagesCache.length;
    _effectivePackagesCache.removeWhere((key, value) =>
    now.difference(value.timestamp) > cacheExpiry);
    final newCount = _effectivePackagesCache.length;
    print("Cleaned effective packages cache: $oldCount -> $newCount entries");
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}

/*

import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:hb_booking_mobile_app/home/model/model_assets.dart';
import 'package:hb_booking_mobile_app/home/workspcae_detail/event_workspacedetail.dart';
import 'package:hb_booking_mobile_app/home/workspcae_detail/state_workspacedetail.dart';
import 'package:hb_booking_mobile_app/utils/constants.dart';

// Effective Packages Data Models
class EffectivePackagesData {
  final double? price;
  final double? effectivePrice;
  final List<EffectivePackage> packages;

  EffectivePackagesData({
    this.price,
    this.effectivePrice,
    required this.packages,
  });

  factory EffectivePackagesData.fromJson(Map<String, dynamic> json) {
    return EffectivePackagesData(
      price: json['price']?.toDouble(),
      effectivePrice: json['effectivePrice']?.toDouble(),
      packages: json['packages'] != null
          ? List<EffectivePackage>.from(json['packages'].map((x) => EffectivePackage.fromJson(x)))
          : [],
    );
  }
}

class EffectivePackage {
  final String id;
  final String type;
  final String name;
  final double rate;
  final PackageDuration duration;
  final double perUnitRate;

  EffectivePackage({
    required this.id,
    required this.type,
    required this.name,
    required this.rate,
    required this.duration,
    required this.perUnitRate,
  });

  factory EffectivePackage.fromJson(Map<String, dynamic> json) {
    return EffectivePackage(
      id: json['_id'] ?? '',
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      rate: (json['rate'] ?? 0).toDouble(),
      duration: PackageDuration.fromJson(json['duration'] ?? {}),
      perUnitRate: (json['perUnitRate'] ?? 0).toDouble(),
    );
  }
}

class PackageDuration {
  final String unit;
  final int value;

  PackageDuration({
    required this.unit,
    required this.value,
  });

  factory PackageDuration.fromJson(Map<String, dynamic> json) {
    return PackageDuration(
      unit: json['unit'] ?? '',
      value: json['value'] ?? 1,
    );
  }
}

// Cache class for effective packages data
class CachedEffectivePackagesData {
  final EffectivePackagesData data;
  final DateTime timestamp;

  CachedEffectivePackagesData(this.data, this.timestamp);

  bool get isExpired =>
      DateTime.now().difference(timestamp) > WorkspaceDetailBloc.cacheExpiry;
}



// Updated WorkspaceDetailBloc
class WorkspaceDetailBloc extends Bloc<WorkspaceDetailEvent, WorkspaceDetailState> {
  // Add caching for effective packages data
  static final Map<String, CachedEffectivePackagesData> _effectivePackagesCache = {};
  static const Duration cacheExpiry = Duration(minutes: 3);

  // Debounce timer for API calls
  Timer? _debounceTimer;

  WorkspaceDetailBloc() : super(WorkspaceDetailInitial()) {
    on<InitializeWorkspaceDetail>(_onInitializeWorkspaceDetail);
    on<UpdateDateRange>(_onUpdateDateRange);
    on<ToggleDescription>(_onToggleDescription);
    on<IncrementCount>(_onIncrementCount);
    on<DecrementCount>(_onDecrementCount);
    on<FetchEffectivePackages>(_onFetchEffectivePackages);
  }

  // FIXED: Add method to clear cache
  void clearEffectivePackagesCache() {
    _effectivePackagesCache.clear();
    print("Cleared effective packages cache");
  }

  Future<void> _onInitializeWorkspaceDetail(
      InitializeWorkspaceDetail event,
      Emitter<WorkspaceDetailState> emit
      ) async {
    emit(WorkspaceDetailLoading());

    try {
      print("InitializeWorkspaceDetail - apiResponse: ${event.apiResponse}");
      print("InitializeWorkspaceDetail - familyId: ${event.apiResponse.familyId}");
      print("InitializeWorkspaceDetail - hasTimeSelected: ${event.hasTimeSelected}");

      // Use initial count from API response immediately
      final initialAvailableCount = event.apiResponse.availableItems?.count ?? 0;
      final effectivePrice = event.apiResponse.rate?.effectivePrice?.toDouble() ?? 0.0;

      // Try to fetch effective packages immediately
      EffectivePackagesData? effectivePackagesData;
      final familyId = event.apiResponse.familyId;

      if (familyId != null && familyId.isNotEmpty) {
        try {
          effectivePackagesData = await fetchEffectivePackages(
            familyId: familyId,
            fromDate: event.startDate,
            toDate: event.endDate,
            hasTimeSelected: event.hasTimeSelected, // FIXED: Use the correct parameter
          );
          print("Successfully fetched effective packages during initialization");
        } catch (e) {
          print('Error fetching effective packages during initialization: $e');
          // Continue with original data
        }
      } else {
        print('No familyId available for effective packages fetch');
      }

      // Calculate price with effective packages data if available
      final totalPrice = _calculatePriceOptimized(
        event.apiResponse,
        event.startDate,
        event.endDate,
        event.hasTimeSelected, // FIXED: Use the correct parameter
        effectivePackagesData?.effectivePrice?.toDouble(),
      );

      print("Initial total price calculated: $totalPrice");

      // Emit loaded state with effective packages data
      emit(WorkspaceDetailLoaded(
        asset: event.apiResponse,
        count: initialAvailableCount,
        totalPrice: totalPrice,
        startDate: event.startDate,
        endDate: event.endDate,
        isExpanded: false,
        effectivePackagesData: effectivePackagesData,
      ));

    } catch (e) {
      print('Error in InitializeWorkspaceDetail: $e');
      emit(WorkspaceDetailError(e.toString()));
    }
  }

  Future<void> _onUpdateDateRange(
      UpdateDateRange event,
      Emitter<WorkspaceDetailState> emit
      ) async {
    if (state is! WorkspaceDetailLoaded) return;
    final currentState = state as WorkspaceDetailLoaded;

    print("UpdateDateRange called:");
    print("Start: ${event.startDate}");
    print("End: ${event.endDate}");
    print("Has time selected: ${event.hasTimeSelected}");

    // Cancel previous debounce timer
    _debounceTimer?.cancel();

    // Start new debounce timer
    _debounceTimer = Timer(Duration(milliseconds: 500), () async {
      try {
        // Fetch effective packages for new date range
        EffectivePackagesData? effectivePackagesData;
        if (currentState.asset.familyId != null && currentState.asset.familyId!.isNotEmpty) {
          print("Fetching effective packages for familyId: ${currentState.asset.familyId}");

          effectivePackagesData = await fetchEffectivePackages(
            familyId: currentState.asset.familyId!,
            fromDate: event.startDate,
            toDate: event.endDate,
            hasTimeSelected: event.hasTimeSelected,
          );

          print("Successfully fetched effective packages for date range update");
        }

        // Calculate price using updated effective price
        final totalPrice = _calculatePriceOptimized(
          currentState.asset,
          event.startDate,
          event.endDate,
          event.hasTimeSelected,
          effectivePackagesData?.effectivePrice?.toDouble(),
        );

        print("Updated total price: $totalPrice");

        // Check if emit is still valid before emitting
        if (!emit.isDone) {
          emit(WorkspaceDetailLoaded(
            asset: currentState.asset,
            count: currentState.count,
            totalPrice: totalPrice,
            startDate: event.startDate,
            endDate: event.endDate,
            isExpanded: currentState.isExpanded,
            effectivePackagesData: effectivePackagesData,
          ));
          print("Emitted updated state with effective packages");
        }
      } catch (e) {
        print('Error updating date range: $e');
        // Keep current state on error - only emit if still valid
        if (!emit.isDone) {
          emit(WorkspaceDetailLoaded(
            asset: currentState.asset,
            count: currentState.count,
            totalPrice: currentState.totalPrice,
            startDate: event.startDate,
            endDate: event.endDate,
            isExpanded: currentState.isExpanded,
            effectivePackagesData: currentState.effectivePackagesData,
          ));
        }
      }
    });
  }

  Future<void> _onFetchEffectivePackages(
      FetchEffectivePackages event,
      Emitter<WorkspaceDetailState> emit
      ) async {
    if (state is! WorkspaceDetailLoaded) return;

    final currentState = state as WorkspaceDetailLoaded;

    try {
      print("Manual fetch effective packages called");

      final effectivePackagesData = await fetchEffectivePackages(
        familyId: event.familyId,
        fromDate: event.fromDate,
        toDate: event.toDate,
        hasTimeSelected: event.hasTimeSelected,
      );

      // Calculate new price with updated effective price
      final totalPrice = _calculatePriceOptimized(
        currentState.asset,
        event.fromDate,
        event.toDate,
        event.hasTimeSelected,
        effectivePackagesData.effectivePrice?.toDouble(),
      );

      // Check if emit is still valid before emitting
      if (!emit.isDone) {
        emit(WorkspaceDetailLoaded(
          asset: currentState.asset,
          count: currentState.count,
          totalPrice: totalPrice,
          startDate: event.fromDate,
          endDate: event.toDate,
          isExpanded: currentState.isExpanded,
          effectivePackagesData: effectivePackagesData,
        ));
        print("Emitted state after manual effective packages fetch");
      }
    } catch (e) {
      print('Error fetching effective packages: $e');
      // Keep current state on error
    }
  }

  // Optimized price calculation with effective price parameter
  double _calculatePriceOptimized(
      Datum asset,
      DateTime startDate,
      DateTime endDate,
      bool hasTimeSelected,
      [double? effectivePrice]
      ) {
    final basePrice = effectivePrice ?? asset.rate?.effectivePrice?.toDouble() ?? 0.0;

    print("Price calculation:");
    print("Base price: $basePrice");
    print("Has time selected: $hasTimeSelected");
    print("Start: $startDate, End: $endDate");

    if (hasTimeSelected) {
      // Simple hourly calculation
      final hours = endDate.difference(startDate).inHours;
      final clampedHours = hours.clamp(1, 24);
      final totalPrice = basePrice * clampedHours;

      print("Hourly calculation: $hours hours (clamped to $clampedHours) * $basePrice = $totalPrice");
      return totalPrice;
    } else {
      // Daily calculation
      final days = _calculateBusinessDaysOptimized(startDate, endDate);
      final totalPrice = basePrice * days;

      print("Daily calculation: $days days * $basePrice = $totalPrice");
      return totalPrice;
    }
  }

  // Optimized business days calculation
  int _calculateBusinessDaysOptimized(DateTime start, DateTime end) {
    if (start.isAtSameMomentAs(end)) return 1;

    final daysDiff = end.difference(start).inDays + 1;
    if (daysDiff <= 7) {
      // For short periods, count exactly
      int businessDays = 0;
      for (int i = 0; i < daysDiff; i++) {
        final day = start.add(Duration(days: i));
        if (day.weekday != DateTime.sunday) {
          businessDays++;
        }
      }
      return businessDays.clamp(1, daysDiff);
    } else {
      // For longer periods, use approximation
      final weeks = daysDiff ~/ 7;
      final remainingDays = daysDiff % 7;
      return (weeks * 6) + remainingDays.clamp(0, 6);
    }
  }

  void _onIncrementCount(IncrementCount event, Emitter<WorkspaceDetailState> emit) {
    if (state is WorkspaceDetailLoaded) {
      final loadedState = state as WorkspaceDetailLoaded;
      final newCount = loadedState.count + 1;
      final newTotalPrice = loadedState.totalPrice / loadedState.count * newCount;

      emit(WorkspaceDetailLoaded(
        asset: loadedState.asset,
        count: newCount,
        totalPrice: newTotalPrice,
        startDate: loadedState.startDate,
        endDate: loadedState.endDate,
        isExpanded: loadedState.isExpanded,
        effectivePackagesData: loadedState.effectivePackagesData,
      ));
    }
  }

  void _onDecrementCount(DecrementCount event, Emitter<WorkspaceDetailState> emit) {
    if (state is WorkspaceDetailLoaded) {
      final loadedState = state as WorkspaceDetailLoaded;
      final newCount = (loadedState.count - 1).clamp(1, 999);
      final newTotalPrice = loadedState.totalPrice / loadedState.count * newCount;

      emit(WorkspaceDetailLoaded(
        asset: loadedState.asset,
        count: newCount,
        totalPrice: newTotalPrice,
        startDate: loadedState.startDate,
        endDate: loadedState.endDate,
        isExpanded: loadedState.isExpanded,
        effectivePackagesData: loadedState.effectivePackagesData,
      ));
    }
  }

  void _onToggleDescription(ToggleDescription event, Emitter<WorkspaceDetailState> emit) {
    if (state is! WorkspaceDetailLoaded) return;
    final currentState = state as WorkspaceDetailLoaded;

    emit(WorkspaceDetailLoaded(
      asset: currentState.asset,
      count: currentState.count,
      totalPrice: currentState.totalPrice,
      startDate: currentState.startDate,
      endDate: currentState.endDate,
      isExpanded: !currentState.isExpanded,
      effectivePackagesData: currentState.effectivePackagesData,
    ));
  }

  // Fetch effective packages method
  Future<EffectivePackagesData> fetchEffectivePackages({
    required String familyId,
    required DateTime fromDate,
    required DateTime toDate,
    bool hasTimeSelected = false,
  }) async {
    // Create cache key
    final cacheKey = '$familyId-${fromDate.toIso8601String()}-${toDate.toIso8601String()}-$hasTimeSelected';

    // Check cache first
    final cachedData = _effectivePackagesCache[cacheKey];
    if (cachedData != null && !cachedData.isExpired) {
      print('Using cached effective packages data for key: $cacheKey');
      return cachedData.data;
    }

    try {
      final fromDateStr = DateFormat('yyyy-MM-dd').format(fromDate);
      final toDateStr = DateFormat('yyyy-MM-dd').format(toDate);

      Map<String, String> queryParams = {
        'fromDate': fromDateStr,
        'toDate': toDateStr,
      };

      // Add time parameters if time is selected
      if (hasTimeSelected) {
        final fromTimeStr = DateFormat('HH:mm:ss').format(fromDate);
        final toTimeStr = DateFormat('HH:mm:ss').format(toDate);
        queryParams['fromTime'] = fromTimeStr;
        queryParams['toTime'] = toTimeStr;

        print("Adding time parameters to effective packages request:");
        print("fromTime: $fromTimeStr, toTime: $toTimeStr");
      }

      final uri = Uri.parse('${base_url}asset/family/$familyId/effective-packages')
          .replace(queryParameters: queryParams);

      print("Fetching effective packages from: $uri");

      final response = await http.get(
        uri,
        headers: {
          'Connection': 'keep-alive',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          // Add any required authorization headers here
        },
      ).timeout(const Duration(seconds: 8));

      print("Effective packages API response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print("Effective packages API response: ${response.body}");

        final data = EffectivePackagesData.fromJson(jsonData['data']);

        // Cache the result
        _effectivePackagesCache[cacheKey] = CachedEffectivePackagesData(data, DateTime.now());

        // Clean old cache entries periodically
        if (_effectivePackagesCache.length > 50) {
          _cleanEffectivePackagesCache();
        }

        print("Successfully parsed effective packages data:");
        print("Price: ${data.price}");
        print("Effective Price: ${data.effectivePrice}");
        print("Packages count: ${data.packages.length}");

        return data;
      } else {
        print("Effective packages API error: ${response.statusCode} - ${response.body}");
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to fetch effective packages');
      }
    } catch (e) {
      print('Error fetching effective packages: $e');
      rethrow;
    }
  }

  // Clean old effective packages cache entries
  void _cleanEffectivePackagesCache() {
    final now = DateTime.now();
    final oldCount = _effectivePackagesCache.length;
    _effectivePackagesCache.removeWhere((key, value) =>
    now.difference(value.timestamp) > cacheExpiry);
    final newCount = _effectivePackagesCache.length;
    print("Cleaned effective packages cache: $oldCount -> $newCount entries");
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}

*/

