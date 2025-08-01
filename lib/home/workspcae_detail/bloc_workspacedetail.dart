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
/*
class WorkspaceDetailBloc extends Bloc<WorkspaceDetailEvent, WorkspaceDetailState> {
  WorkspaceDetailBloc() : super(WorkspaceDetailInitial()) {
    on<InitializeWorkspaceDetail>(_onInitializeWorkspaceDetail);
    on<UpdateDateRange>(_onUpdateDateRange);
    on<FetchAvailabilityAndUpdate>(_onFetchAvailabilityAndUpdate);
    on<ToggleDescription>(_onToggleDescription);
    on<IncrementCount>(_onIncrementCount);
    on<DecrementCount>(_onDecrementCount);
  }

  Future<void> _onInitializeWorkspaceDetail(
      InitializeWorkspaceDetail event,
      Emitter<WorkspaceDetailState> emit
      ) async {
    emit(WorkspaceDetailLoading());
    try {
      // Get initial availability from the API response
      final initialAvailableCount = event.apiResponse.availableItems!.count!;

      // Fetch fresh availability data using your slots API
      final assetId = event.apiResponse.availableItems!.items!.isNotEmpty
          ? event.apiResponse.availableItems!.items![0].assets![0].id!
          : '';

      int availableCount = initialAvailableCount;

      if (assetId.isNotEmpty) {
        try {
          final availabilityData = await fetchAvailabilityData(
            assetId: assetId,
            start: event.startDate.toIso8601String(),
            end: event.endDate.toIso8601String(),
            hasTimeSelected: false, // Initially no time is selected
          );

          // Use the computed availableItemsCount from slots
          availableCount = availabilityData.availableItemsCount ?? 0;
          print("Initial availability count from slots: $availableCount");
        } catch (e) {
          print('Failed to fetch availability: $e');
          // Use initial count as fallback
        }
      }

      // Calculate total price using effective price from rate
      final effectivePrice = event.apiResponse.rate!.effectivePrice!;

      emit(WorkspaceDetailLoaded(
        asset: event.apiResponse,
        count: event.apiResponse.availableItems!.count!,
        totalPrice: effectivePrice!.toDouble(),
        startDate: event.startDate,
        endDate: event.endDate,
        isExpanded: false,
        availableCount: availableCount,
      ));
    } catch (e) {
      emit(WorkspaceDetailError(e.toString()));
    }
  }

  Future<void> _onFetchAvailabilityAndUpdate(
      FetchAvailabilityAndUpdate event,
      Emitter<WorkspaceDetailState> emit
      ) async {
    if (state is! WorkspaceDetailLoaded) return;
    final currentState = state as WorkspaceDetailLoaded;

    // Show loading state while fetching availability
    emit(WorkspaceDetailLoading());

    try {
      // Fetch fresh availability data with time selection info using your slots API
      final availabilityData = await fetchAvailabilityData(
        assetId: event.assetId,
        start: event.startDate.toIso8601String(),
        end: event.endDate.toIso8601String(),
        hasTimeSelected: event.hasTimeSelected,
      );

      // Use the computed availableItemsCount from slots
      final availableCount = availabilityData.availableItemsCount ?? 0;
      print("Fetched availability count from slots: $availableCount");

      // Debug: Show individual asset slots
      if (availabilityData.data.isNotEmpty) {
        for (int i = 0; i < availabilityData.data.length; i++) {
          final datum = availabilityData.data[i];
          print("Asset ${i + 1}: ${datum.slots.length} slots (${datum.title})");
          for (int j = 0; j < datum.slots.length; j++) {
            final slot = datum.slots[j];
            print("  Slot ${j + 1}: ${slot.title} (${slot.availability.start} - ${slot.availability.end})");
          }
        }
      }

      // Calculate the number of days (excluding Sundays)
      final int daysCount = calculateBusinessDays(event.startDate, event.endDate);

      // Base price from the asset's rate
      final double basePrice = currentState.asset.rate!.effectivePrice!.toDouble();

      // Calculate total price based on days
      final double totalPrice = basePrice * daysCount;

      emit(WorkspaceDetailLoaded(
        asset: currentState.asset,
        count: currentState.count,
        totalPrice: totalPrice,
        startDate: event.startDate,
        endDate: event.endDate,
        isExpanded: currentState.isExpanded,
        availableCount: availableCount,
      ));
    } catch (e) {
      print('Error fetching availability: $e');
      // Emit error state or fallback to previous state with 0 availability
      emit(WorkspaceDetailLoaded(
        asset: currentState.asset,
        count: currentState.count,
        totalPrice: currentState.totalPrice,
        startDate: event.startDate,
        endDate: event.endDate,
        isExpanded: currentState.isExpanded,
        availableCount: 0, // Set to 0 on error to prevent booking
      ));
    }
  }

  void _onIncrementCount(IncrementCount event, Emitter<WorkspaceDetailState> emit) {
    if (state is WorkspaceDetailLoaded) {
      final loadedState = state as WorkspaceDetailLoaded;
      final newCount = loadedState.count + 1;
      final newTotalPrice = newCount * double.parse(loadedState.asset!.rate!.effectivePrice.toString() ?? '0.0');

      emit(WorkspaceDetailLoaded(
        asset: loadedState.asset,
        count: newCount,
        totalPrice: newTotalPrice,
        startDate: loadedState.startDate,
        endDate: loadedState.endDate,
        isExpanded: loadedState.isExpanded,
        availableCount: loadedState.availableCount,
      ));
    }
  }

  void _onDecrementCount(DecrementCount event, Emitter<WorkspaceDetailState> emit) {
    if (state is WorkspaceDetailLoaded) {
      final loadedState = state as WorkspaceDetailLoaded;
      final newCount = loadedState.count > 1 ? loadedState.count - 1 : 1;
      final newTotalPrice = newCount * double.parse(loadedState.asset!.rate!.effectivePrice.toString()  ?? '0.0');

      emit(WorkspaceDetailLoaded(
        asset: loadedState.asset,
        count: newCount,
        totalPrice: newTotalPrice,
        startDate: loadedState.startDate,
        endDate: loadedState.endDate,
        isExpanded: loadedState.isExpanded,
        availableCount: loadedState.availableCount,
      ));
    }
  }

  Future<void> _onUpdateDateRange(
      UpdateDateRange event,
      Emitter<WorkspaceDetailState> emit
      ) async {
    if (state is! WorkspaceDetailLoaded) return;
    final currentState = state as WorkspaceDetailLoaded;

    emit(WorkspaceDetailLoading());

    try {
      final availableCount = currentState.availableCount!;

      // Calculate the number of days (excluding Sundays)
      final int daysCount = calculateBusinessDays(event.startDate, event.endDate);

      // Base price from the asset's rate
      final double basePrice = currentState.asset.rate!.effectivePrice!.toDouble();

      // Calculate total price based on days
      final double totalPrice = basePrice * daysCount;

      emit(WorkspaceDetailLoaded(
        asset: currentState.asset,
        count: currentState.count,
        totalPrice: totalPrice,
        startDate: event.startDate,
        endDate: event.endDate,
        isExpanded: currentState.isExpanded,
        availableCount: availableCount,
      ));
    } catch (e) {
      emit(WorkspaceDetailError(e.toString()));
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
        availableCount: currentState.availableCount
    ));
  }

  // Helper method to calculate business days (excluding Sundays)
  int calculateBusinessDays(DateTime start, DateTime end) {
    int days = 0;
    DateTime current = DateTime(start.year, start.month, start.day);
    DateTime endDate = DateTime(end.year, end.month, end.day);

    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      if (current.weekday != DateTime.sunday) {
        days++;
      }
      current = current.add(Duration(days: 1));
    }

    return days > 0 ? days : 1; // Ensure at least 1 day
  }

  Future<AvailabilityData> fetchAvailabilityData({
    required String assetId,
    required String start,
    required String end,
    bool? hasTimeSelected,
  }) async {
    try {
      final startDateTime = DateTime.parse(start);
      final endDateTime = DateTime.parse(end);

      // Format dates
      final startDate = DateFormat('yyyy-MM-dd').format(startDateTime);
      final endDate = DateFormat('yyyy-MM-dd').format(endDateTime);

      // Check if this is a time-specific booking
      final hasTime = hasTimeSelected ?? (start.contains('T') &&
          end.contains('T') &&
          start.split('T')[1] != '00:00:00' &&
          end.split('T')[1] != '00:00:00');
      // Create filters object
      Map<String, dynamic> filters = {
        "assetTypes": [assetId]
      };

      Map<String, String> queryParams = {
        'fromDate': startDate,
        'toDate': endDate,
        'filters': jsonEncode(filters), // Convert filters to JSON string
      };

      // Only add time parameters if time is actually selected
      if (hasTime) {
        final startTime = DateFormat('HH:mm:ss').format(startDateTime);
        final endTime = DateFormat('HH:mm:ss').format(endDateTime);
        queryParams['fromTime'] = startTime;
        queryParams['toTime'] = endTime;
        print("Time-specific booking: $startTime - $endTime");
      } else {
        print("Date-only booking: No time parameters sent to API");
      }

      final uri = Uri.parse('https://corporate-dot-hornbill-staging.uc.r.appspot.com/booking/checkAssetAvailabilityv2')
          .replace(queryParameters: queryParams);

      print("Fetching availability with params: $queryParams");

      final response = await http.get(uri);
      print("Availability response - ${response.body}");

      if (response.statusCode == 200) {
        return AvailabilityData.fromJson(json.decode(response.body));
      }

      final errorBody = json.decode(response.body);
      throw Exception(errorBody['message'] ?? 'Failed to fetch availability data');
    } catch (e) {
      print('Error details: $e');
      rethrow;
    }
  }
}

*/
class WorkspaceDetailBloc extends Bloc<WorkspaceDetailEvent, WorkspaceDetailState> {
  // Add caching for availability data
  static final Map<String, CachedAvailabilityData> _availabilityCache = {};
  static const Duration cacheExpiry = Duration(minutes: 3);

  // Debounce timer for API calls
  Timer? _debounceTimer;

  WorkspaceDetailBloc() : super(WorkspaceDetailInitial()) {
    on<InitializeWorkspaceDetail>(_onInitializeWorkspaceDetail);
    on<UpdateDateRange>(_onUpdateDateRange);
    on<FetchAvailabilityAndUpdate>(_onFetchAvailabilityAndUpdate);
    on<ToggleDescription>(_onToggleDescription);
    on<IncrementCount>(_onIncrementCount);
    on<DecrementCount>(_onDecrementCount);
  }

  Future<void> _onInitializeWorkspaceDetail(
      InitializeWorkspaceDetail event,
      Emitter<WorkspaceDetailState> emit
      ) async {
    emit(WorkspaceDetailLoading());

    try {
      // Use initial count from API response immediately
      final initialAvailableCount = event.apiResponse.availableItems?.count ?? 0;
      final effectivePrice = event.apiResponse.rate?.effectivePrice?.toDouble() ?? 0.0;

      // Emit loaded state immediately with initial data
      emit(WorkspaceDetailLoaded(
        asset: event.apiResponse,
        count: initialAvailableCount,
        totalPrice: effectivePrice,
        startDate: event.startDate,
        endDate: event.endDate,
        isExpanded: false,
        availableCount: initialAvailableCount,
      ));

      // Fetch fresh availability in background (only if needed)
      _fetchAvailabilityInBackground(event, emit);

    } catch (e) {
      emit(WorkspaceDetailError(e.toString()));
    }
  }

  // Background availability fetch without blocking UI
  void _fetchAvailabilityInBackground(
      InitializeWorkspaceDetail event,
      Emitter<WorkspaceDetailState> emit
      ) async {
    try {
      final assetId = event.apiResponse.availableItems?.items?.isNotEmpty == true
          ? event.apiResponse.availableItems!.items![0].assets![0].id!
          : '';

      if (assetId.isNotEmpty) {
        final availabilityData = await fetchAvailabilityDataOptimized(
          assetId: assetId,
          start: event.startDate.toIso8601String(),
          end: event.endDate.toIso8601String(),
          hasTimeSelected: false,
        );

        // Only update if state is still loaded and data changed
        if (state is WorkspaceDetailLoaded) {
          final currentState = state as WorkspaceDetailLoaded;
          final newAvailableCount = availabilityData.availableItemsCount ?? 0;
        print("avail ---- ${availabilityData.availableItemsCount}");
          if (newAvailableCount != currentState.availableCount) {
            emit(WorkspaceDetailLoaded(
              asset: currentState.asset,
              count: currentState.count,
              totalPrice: currentState.totalPrice,
              startDate: currentState.startDate,
              endDate: currentState.endDate,
              isExpanded: currentState.isExpanded,
              availableCount: newAvailableCount,
            ));
          }
        }
      }
    } catch (e) {
      print('Background availability fetch failed: $e');
      // Don't emit error, keep current state
    }
  }

  Future<void> _onFetchAvailabilityAndUpdate(
      FetchAvailabilityAndUpdate event,
      Emitter<WorkspaceDetailState> emit
      ) async {
    if (state is! WorkspaceDetailLoaded) return;

    final currentState = state as WorkspaceDetailLoaded;

    // Cancel previous debounce timer
    _debounceTimer?.cancel();

    // Debounce rapid calls
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final availabilityData = await fetchAvailabilityDataOptimized(
          assetId: event.assetId,
          start: event.startDate.toIso8601String(),
          end: event.endDate.toIso8601String(),
          hasTimeSelected: event.hasTimeSelected,
        );

        final availableCount = availabilityData.availableItemsCount ?? 0;

        // Calculate price efficiently
        final totalPrice = _calculatePriceOptimized(
          currentState.asset,
          event.startDate,
          event.endDate,
          event.hasTimeSelected ?? false,
        );

        if (state is WorkspaceDetailLoaded) {
          emit(WorkspaceDetailLoaded(
            asset: currentState.asset,
            count: currentState.count,
            totalPrice: totalPrice,
            startDate: event.startDate,
            endDate: event.endDate,
            isExpanded: currentState.isExpanded,
            availableCount: availableCount,
          ));
        }
      } catch (e) {
        print('Error fetching availability: $e');
        // Keep current state with 0 availability on error
        emit(WorkspaceDetailLoaded(
          asset: currentState.asset,
          count: currentState.count,
          totalPrice: currentState.totalPrice,
          startDate: event.startDate,
          endDate: event.endDate,
          isExpanded: currentState.isExpanded,
          availableCount: 0,
        ));
      }
    });
  }

  // Optimized price calculation
  double _calculatePriceOptimized(
      Datum asset,
      DateTime startDate,
      DateTime endDate,
      bool hasTimeSelected
      ) {
    final basePrice = asset.rate?.effectivePrice?.toDouble() ?? 0.0;

    if (hasTimeSelected) {
      // Simple hourly calculation without complex business logic
      final hours = endDate.difference(startDate).inHours;
      return basePrice * hours.clamp(1, 24); // Clamp to reasonable range
    } else {
      // Daily calculation
      final days = _calculateBusinessDaysOptimized(startDate, endDate);
      return basePrice * days;
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
      final newCount = (loadedState.count + 1).clamp(1, loadedState.availableCount);
      final newTotalPrice = loadedState.totalPrice / loadedState.count * newCount;

      emit(WorkspaceDetailLoaded(
        asset: loadedState.asset,
        count: newCount,
        totalPrice: newTotalPrice,
        startDate: loadedState.startDate,
        endDate: loadedState.endDate,
        isExpanded: loadedState.isExpanded,
        availableCount: loadedState.availableCount,
      ));
    }
  }

  void _onDecrementCount(DecrementCount event, Emitter<WorkspaceDetailState> emit) {
    if (state is WorkspaceDetailLoaded) {
      final loadedState = state as WorkspaceDetailLoaded;
      final newCount = (loadedState.count - 1).clamp(1, loadedState.availableCount);
      final newTotalPrice = loadedState.totalPrice / loadedState.count * newCount;

      emit(WorkspaceDetailLoaded(
        asset: loadedState.asset,
        count: newCount,
        totalPrice: newTotalPrice,
        startDate: loadedState.startDate,
        endDate: loadedState.endDate,
        isExpanded: loadedState.isExpanded,
        availableCount: loadedState.availableCount,
      ));
    }
  }

  Future<void> _onUpdateDateRange(
      UpdateDateRange event,
      Emitter<WorkspaceDetailState> emit
      ) async {
    if (state is! WorkspaceDetailLoaded) return;
    final currentState = state as WorkspaceDetailLoaded;

    // Update state immediately with calculated price
    final totalPrice = _calculatePriceOptimized(
      currentState.asset,
      event.startDate,
      event.endDate,
      false, // Assume no time initially
    );

    emit(WorkspaceDetailLoaded(
      asset: currentState.asset,
      count: currentState.count,
      totalPrice: totalPrice,
      startDate: event.startDate,
      endDate: event.endDate,
      isExpanded: currentState.isExpanded,
      availableCount: currentState.availableCount,
    ));
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
        availableCount: currentState.availableCount
    ));
  }

  // Optimized availability fetch with caching
  Future<AvailabilityData> fetchAvailabilityDataOptimized({
    required String assetId,
    required String start,
    required String end,
    bool? hasTimeSelected,
  }) async {
    // Create cache key
    final cacheKey = '$assetId-$start-$end-${hasTimeSelected ?? false}';

    // Check cache first
    final cachedData = _availabilityCache[cacheKey];
    if (cachedData != null && !cachedData.isExpired) {
      return cachedData.data;
    }

    try {
      final startDateTime = DateTime.parse(start);
      final endDateTime = DateTime.parse(end);

      final startDate = DateFormat('yyyy-MM-dd').format(startDateTime);
      final endDate = DateFormat('yyyy-MM-dd').format(endDateTime);

      final hasTime = hasTimeSelected ?? (start.contains('T') &&
          end.contains('T') &&
          start.split('T')[1] != '00:00:00' &&
          end.split('T')[1] != '00:00:00');

      Map<String, dynamic> filters = {
        "assetTypes": [assetId]
      };
      print("count --uri  - ${assetId}");
      Map<String, String> queryParams = {
        'fromDate': startDate,
        'toDate': endDate,
        'filters': jsonEncode(filters),
      };

      if (hasTime) {
        final startTime = DateFormat('HH:mm:ss').format(startDateTime);
        final endTime = DateFormat('HH:mm:ss').format(endDateTime);
        queryParams['fromTime'] = startTime;
        queryParams['toTime'] = endTime;
      }

      final uri = Uri.parse('${base_url}booking/checkAssetAvailabilityv2')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Connection': 'keep-alive',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 8));
print("count --uri  - ${uri}");
      if (response.statusCode == 200) {
        final data = AvailabilityData.fromJson(json.decode(response.body));

        // Cache the result
        _availabilityCache[cacheKey] = CachedAvailabilityData(data, DateTime.now());

        // Clean old cache entries periodically
        if (_availabilityCache.length > 50) {
          _cleanCache();
        }
        print("count --uri  - ${response.body}");
        return data;
      }

      final errorBody = json.decode(response.body);
      throw Exception(errorBody['message'] ?? 'Failed to fetch availability data');
    } catch (e) {
      print('Error details: $e');
      rethrow;
    }
  }

  // Clean old cache entries
  void _cleanCache() {
    final now = DateTime.now();
    _availabilityCache.removeWhere((key, value) =>
    now.difference(value.timestamp) > cacheExpiry);
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}

// Cache class for availability data
class CachedAvailabilityData {
  final AvailabilityData data;
  final DateTime timestamp;

  CachedAvailabilityData(this.data, this.timestamp);

  bool get isExpired =>
      DateTime.now().difference(timestamp) > WorkspaceDetailBloc.cacheExpiry;
}



// Updated model for asset availability data
class AvailabilityData {
  final String status;
  final String message;
  final List<Asset> data;
  final int? availableItemsCount; // Computed from counting all slots

  AvailabilityData({
    required this.status,
    required this.message,
    required this.data,
    this.availableItemsCount,
  });

  factory AvailabilityData.fromJson(Map<String, dynamic> json) {
    List<Asset> assets = [];
    if (json['data'] != null) {
      assets = List<Asset>.from(json['data'].map((x) => Asset.fromJson(x)));
    }

    // Calculate total available items by counting all slots
    int totalAvailableItems = 0;
    for (var asset in assets) {
      totalAvailableItems += asset.slots.length;
    }

    return AvailabilityData(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: assets,
      availableItemsCount: totalAvailableItems,
    );
  }
}

class Asset {
  final String id;
  final List<String> aminities;
  final List<AssetImage> images;
  final AssetType assetType;
  final Branch branch;
  final String description;
  final String title;
  final AssetImage thumbnail;
  final String familyId;
  final String familyTitle;
  final List<Slot> slots;

  Asset({
    required this.id,
    required this.aminities,
    required this.images,
    required this.assetType,
    required this.branch,
    required this.description,
    required this.title,
    required this.thumbnail,
    required this.familyId,
    required this.familyTitle,
    required this.slots,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['_id'] ?? '',
      aminities: json['aminities'] != null
          ? List<String>.from(json['aminities'])
          : [],
      images: json['images'] != null
          ? List<AssetImage>.from(json['images'].map((x) => AssetImage.fromJson(x)))
          : [],
      assetType: AssetType.fromJson(json['assetType'] ?? {}),
      branch: Branch.fromJson(json['branch'] ?? {}),
      description: json['description'] ?? '',
      title: json['title'] ?? '',
      thumbnail: AssetImage.fromJson(json['thumbnail'] ?? {}),
      familyId: json['familyId'] ?? '',
      familyTitle: json['familyTitle'] ?? '',
      slots: json['slots'] != null
          ? List<Slot>.from(json['slots'].map((x) => Slot.fromJson(x)))
          : [],
    );
  }
}

class AssetImage {
  final String filename;
  final String originalFilename;
  final String path;
  final String mimeType;

  AssetImage({
    required this.filename,
    required this.originalFilename,
    required this.path,
    required this.mimeType,
  });

  factory AssetImage.fromJson(Map<String, dynamic> json) {
    return AssetImage(
      filename: json['filename'] ?? json['Filename'] ?? '',
      originalFilename: json['originalFilename'] ?? json['OriginalFilename'] ?? '',
      path: json['path'] ?? '',
      mimeType: json['mimeType'] ?? json['MimeType'] ?? '',
    );
  }
}

class AssetType {
  final String id;
  final List<String> additionalInputs;
  final String status;
  final String title;
  final String description;
  final AssetImage? thumbnail;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  AssetType({
    required this.id,
    required this.additionalInputs,
    required this.status,
    required this.title,
    required this.description,
    this.thumbnail,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory AssetType.fromJson(Map<String, dynamic> json) {
    return AssetType(
      id: json['_id'] ?? '',
      additionalInputs: json['additionalInputs'] != null
          ? List<String>.from(json['additionalInputs'])
          : [],
      status: json['status'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      thumbnail: json['thumbnail'] != null
          ? AssetImage.fromJson(json['thumbnail'])
          : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      version: json['__v'] ?? 0,
    );
  }
}

class Branch {
  final String id;
  final List<AssetImage> images;
  final List<AOpeningHour> openingHours;
  final List<FloorAndZone> floorsAndZones;
  final String type;
  final String status;
  final String corporateId;
  final String name;
  final String displayName;
  final String email;
  final String tel;
  final Address address;
  final String description;
  final Meta meta;
  final DateTime since;
  final int version;
  final Amenities? amenities;
  final bool? approvalForEdit;
  final String? website;
  final double averageRating;
  final int totalReviews;

  Branch({
    required this.id,
    required this.images,
    required this.openingHours,
    required this.floorsAndZones,
    required this.type,
    required this.status,
    required this.corporateId,
    required this.name,
    required this.displayName,
    required this.email,
    required this.tel,
    required this.address,
    required this.description,
    required this.meta,
    required this.since,
    required this.version,
    this.amenities,
    this.approvalForEdit,
    this.website,
    required this.averageRating,
    required this.totalReviews,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['_id'] ?? '',
      images: json['images'] != null
          ? List<AssetImage>.from(json['images'].map((x) => AssetImage.fromJson(x)))
          : [],
      openingHours: json['openingHours'] != null
          ? List<AOpeningHour>.from(json['openingHours'].map((x) => AOpeningHour.fromJson(x)))
          : [],
      floorsAndZones: json['floorsAndZones'] != null
          ? List<FloorAndZone>.from(json['floorsAndZones'].map((x) => FloorAndZone.fromJson(x)))
          : [],
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      corporateId: json['corporateId'] ?? '',
      name: json['name'] ?? '',
      displayName: json['displayName'] ?? '',
      email: json['email'] ?? '',
      tel: json['tel'] ?? '',
      address: Address.fromJson(json['address'] ?? {}),
      description: json['description'] ?? '',
      meta: Meta.fromJson(json['meta'] ?? {}),
      since: DateTime.parse(json['since'] ?? DateTime.now().toIso8601String()),
      version: json['__v'] ?? 0,
      amenities: json['aminities'] != null ? Amenities.fromJson(json['aminities']) : null,
      approvalForEdit: json['approvalForEdit'],
      website: json['website'],
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
    );
  }
}

class AOpeningHour {
  final String day;
  final bool isOpen;
  final bool allDay;
  final String from;
  final String to;

  AOpeningHour({
    required this.day,
    required this.isOpen,
    required this.allDay,
    required this.from,
    required this.to,
  });

  factory AOpeningHour.fromJson(Map<String, dynamic> json) {
    return AOpeningHour(
      day: json['day'] ?? '',
      isOpen: json['isOpen'] ?? false,
      allDay: json['allDay'] ?? false,
      from: json['from'] ?? '',
      to: json['to'] ?? '',
    );
  }
}

class FloorAndZone {
  final List<Floor> floors;
  final String name;

  FloorAndZone({
    required this.floors,
    required this.name,
  });

  factory FloorAndZone.fromJson(Map<String, dynamic> json) {
    return FloorAndZone(
      floors: json['floors'] != null
          ? List<Floor>.from(json['floors'].map((x) => Floor.fromJson(x)))
          : [],
      name: json['name'] ?? '',
    );
  }
}

class Floor {
  final String name;
  final int level;
  final List<Zone> zones;

  Floor({
    required this.name,
    required this.level,
    required this.zones,
  });

  factory Floor.fromJson(Map<String, dynamic> json) {
    return Floor(
      name: json['name'] ?? '',
      level: json['level'] ?? 0,
      zones: json['zones'] != null
          ? List<Zone>.from(json['zones'].map((x) => Zone.fromJson(x)))
          : [],
    );
  }
}

class Zone {
  final String name;

  Zone({
    required this.name,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      name: json['name'] ?? '',
    );
  }
}

class Address {
  final String name;
  final String formattedAddress;
  final List<AddressComponent> addressComponents;
  final Location location;

  Address({
    required this.name,
    required this.formattedAddress,
    required this.addressComponents,
    required this.location,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      name: json['name'] ?? '',
      formattedAddress: json['formattedAddress'] ?? '',
      addressComponents: json['address_components'] != null
          ? List<AddressComponent>.from(json['address_components'].map((x) => AddressComponent.fromJson(x)))
          : [],
      location: Location.fromJson(json['location'] ?? {}),
    );
  }
}

class AddressComponent {
  final String longName;
  final String shortName;
  final List<String> types;

  AddressComponent({
    required this.longName,
    required this.shortName,
    required this.types,
  });

  factory AddressComponent.fromJson(Map<String, dynamic> json) {
    return AddressComponent(
      longName: json['long_name'] ?? '',
      shortName: json['short_name'] ?? '',
      types: json['types'] != null ? List<String>.from(json['types']) : [],
    );
  }
}

class Location {
  final double lat;
  final double lng;

  Location({
    required this.lat,
    required this.lng,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
    );
  }
}

class Meta {
  final int stepsCompleted;

  Meta({
    required this.stepsCompleted,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      stepsCompleted: json['stepsCompleted'] ?? 0,
    );
  }
}

class Amenities {
  final bool sportsTeam;

  Amenities({
    required this.sportsTeam,
  });

  factory Amenities.fromJson(Map<String, dynamic> json) {
    return Amenities(
      sportsTeam: json['sports_team'] ?? false,
    );
  }
}

class Slot {
  final String title;
  final String id;
  final Availability availability;

  Slot({
    required this.title,
    required this.id,
    required this.availability,
  });

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      title: json['title'] ?? '',
      id: json['_id'] ?? '',
      availability: Availability.fromJson(json['availability'] ?? {}),
    );
  }
}

class Availability {
  final DateTime start;
  final DateTime end;

  Availability({
    required this.start,
    required this.end,
  });

  factory Availability.fromJson(Map<String, dynamic> json) {
    return Availability(
      start: DateTime.parse(json['start'] ?? DateTime.now().toIso8601String()),
      end: DateTime.parse(json['end'] ?? DateTime.now().toIso8601String()),
    );
  }
}