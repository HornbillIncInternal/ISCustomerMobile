import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hb_booking_mobile_app/utils/base_url.dart';
import 'package:hb_booking_mobile_app/utils/colors.dart';

import '../model/model_assets.dart';
import 'asset_event.dart';
import 'asset_state.dart';
import 'package:http/http.dart' as http;


class AssetBloc extends Bloc<AssetEvent, AssetState> {
  final Map<String, String> markerPrices = {};

  // Add caching for performance
  static final Map<String, CachedAssetData> _cache = {};
  static const Duration cacheExpiry = Duration(minutes: 5);

  AssetBloc() : super(AssetInitial()) {
    on<FetchAssetsEvent>(_onFetchAssets);
    on<SelectAssetEvent>(_onSelectAsset);
  }

  Future<void> _onFetchAssets(FetchAssetsEvent event, Emitter<AssetState> emit) async {
    // Create cache key
    final cacheKey = _createCacheKey(
        event.location,
        event.asset ?? '',
        event.startDate,
        event.startTime,
        event.endDate,
        event.endTime
    );

    // Check cache first for performance
    final cachedData = _cache[cacheKey];
    if (cachedData != null && !cachedData.isExpired) {
      // Emit cached data immediately
      Set<Marker> markers = {};
      if (event.context != null && cachedData.assetData.data != null) {
        markers = await _createMarkers(cachedData.assetData.data!, event.context!);
      }

      emit(AssetLoaded(
        assetData: cachedData.assetData,
        markers: markers,
      ));
      return;
    }

    emit(AssetLoading());
    try {
      final assetData = await fetchAssetsOptimized(
        location: event.location,
        asset: event.asset ?? '',
        startDate: event.startDate,
        startTime: event.startTime,
        endDate: event.endDate,
        endTime: event.endTime,
      );

      // Cache the result for performance
      _cache[cacheKey] = CachedAssetData(assetData, DateTime.now());

      // Create markers only if context is provided (for map view)
      Set<Marker> markers = {};
      if (event.context != null && assetData.data != null) {
        markers = await _createMarkers(assetData.data!, event.context!);
      }

      emit(AssetLoaded(
        assetData: assetData,
        markers: markers,
      ));
    } catch (e) {
      emit(AssetError(e.toString()));
    }
  }

  Future<void> _onSelectAsset(SelectAssetEvent event, Emitter<AssetState> emit) async {
    final currentState = state;
    if (currentState is AssetLoaded) {
      // Update markers with selection - recreate custom icons for price update
      final updatedMarkers = await Future.wait(currentState.markers.map((marker) async {
        final isSelected = marker.markerId.value == event.selectedAsset.familyId;
        final originalPrice = markerPrices[marker.markerId.value] ?? '0';
        final priceToUse = isSelected
            ? event.selectedAsset.rate!.effectivePrice!.toString()
            : originalPrice;

        // Always use custom price marker - NO default markers
        final updatedIcon = await _createPriceMarkerIcon(
          event.context,
          priceToUse,
          isSelected,
        );

        return marker.copyWith(iconParam: updatedIcon);
      }).toList());

      emit(AssetLoaded(
        assetData: currentState.assetData,
        markers: updatedMarkers.toSet(),
        selectedAsset: event.selectedAsset,
        selectedIndex: event.index,
      ));
    }
  }

  Future<Set<Marker>> _createMarkers(List<Datum?> assets, BuildContext context) async {
    // Create a map to store unique assets based on familyId
    final uniqueAssets = <String, Datum>{};

    // Populate uniqueAssets map with the first occurrence of each familyId
    for (var asset in assets) {
      if (asset?.familyId != null) {
        uniqueAssets[asset!.familyId!] ??= asset;
      }
    }

    // Create markers with custom price icons ONLY
    final markers = await Future.wait(uniqueAssets.values.map((asset) async {
      String priceInMap = asset.rate!.effectivePrice!.toString();
      markerPrices[asset.familyId!] = priceInMap;

      // Always use custom price marker
      final markerIcon = await _createPriceMarkerIcon(
        context,
        priceInMap,
        false, // Initially not selected
      );

      return Marker(
        markerId: MarkerId(asset.familyId!),
        position: LatLng(
          asset.branch!.address!.location!.lat!,
          asset.branch!.address!.location!.lng!,
        ),
        icon: markerIcon,
        onTap: () {
          add(SelectAssetEvent(
            selectedAsset: asset,
            index: assets.indexOf(asset),
            context: context,
          ));
        },
      );
    }).toList());

    return markers.toSet();
  }

  // Optimized API call with connection reuse and timeout
  Future<AssetData> fetchAssetsOptimized({
    required String location,
    required String asset,
    String? startDate,
    String? startTime,
    String? endDate,
    String? endTime,
  }) async {
    final DateTime now = DateTime.now();
    final String defaultDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final String fromDate = startDate ?? defaultDate;
    final String toDate = endDate ?? startDate ?? defaultDate;

    String baseUrl = '${base_url}booking/getAvailableAssetsv4';

    List<String> queryParts = [
      'fromDate=$fromDate',
      'toDate=$toDate',
    ];

    if (startTime != null && endTime != null) {
      queryParts.add('fromTime=$startTime');
      queryParts.add('toTime=$endTime');
    }

    if (location.isNotEmpty) {
      if (asset.isNotEmpty) {
        queryParts.add('filters={"location":"${location.toLowerCase()}","assetTypes":["$asset"]}');
      } else {
        queryParts.add('filters={"location":"${location.toLowerCase()}"}');
      }
    } else {
      queryParts.add('filters={"location":"kochi"}');
    }

    final String fullUrl = '$baseUrl?${queryParts.join('&')}';
    final uri = Uri.parse(fullUrl);

    print("Shared API request: $fullUrl");

    // Optimized HTTP client with timeout and keep-alive
    final response = await http.get(
      uri,
      headers: {
        'Connection': 'keep-alive',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    print("Shared API response: ${response.body}");

    if (response.statusCode == 200) {
      return AssetData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load assets: ${response.statusCode}');
    }
  }

  // Your ONLY marker creation method - custom price markers
  Future<BitmapDescriptor> _createPriceMarkerIcon(BuildContext context, String price, bool isSelected) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(200, 100);

    final paint = Paint()
      ..color = isSelected ? primary_color : Colors.white;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(50));
    canvas.drawRRect(rrect, paint);

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    final textStyle = TextStyle(
      color: isSelected ? Colors.white : Colors.black,
      fontSize: 40.0,
    );
    textPainter.text = TextSpan(
      text: '₹$price',
      style: textStyle,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );
    textPainter.paint(canvas, offset);

    final image = await recorder.endRecording().toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(bytes);
  }

  String _createCacheKey(String location, String asset, String? startDate,
      String? startTime, String? endDate, String? endTime) {
    return '$location-$asset-$startDate-$startTime-$endDate-$endTime';
  }

  // Clean up old cache entries
  static void cleanCache() {
    final now = DateTime.now();
    _cache.removeWhere((key, value) =>
    now.difference(value.timestamp) > cacheExpiry);
  }
}

class CachedAssetData {
  final AssetData assetData;
  final DateTime timestamp;

  CachedAssetData(this.assetData, this.timestamp);

  bool get isExpired =>
      DateTime.now().difference(timestamp) > AssetBloc.cacheExpiry;
}
/*class AssetBloc extends Bloc<AssetEvent, AssetState> {
  final Map<String, String> markerPrices = {};

  AssetBloc() : super(AssetInitial()) {
    on<FetchAssetsEvent>(_onFetchAssets);
    on<SelectAssetEvent>(_onSelectAsset);
  }

  Future<void> _onFetchAssets(FetchAssetsEvent event, Emitter<AssetState> emit) async {
    emit(AssetLoading());
    try {
      final assetData = await fetchAssets(
        location: event.location,
        asset: event.asset ?? '',
        startDate: event.startDate,
        startTime: event.startTime,
        endDate: event.endDate,
        endTime: event.endTime,
      );

      // Create markers only if context is provided (for map view)
      Set<Marker> markers = {};
      if (event.context != null && assetData.data != null) {
        markers = await _createMarkers(assetData.data!, event.context!);
      }

      emit(AssetLoaded(
        assetData: assetData,
        markers: markers,
      ));
    } catch (e) {
      emit(AssetError(e.toString()));
    }
  }

  Future<void> _onSelectAsset(SelectAssetEvent event, Emitter<AssetState> emit) async {
    final currentState = state;
    if (currentState is AssetLoaded) {
      // Update markers with selection
      final updatedMarkers = await Future.wait(currentState.markers.map((marker) async {
        final isSelected = marker.markerId.value == event.selectedAsset.familyId;
        final originalPrice = markerPrices[marker.markerId.value] ?? '0';
        final priceToUse = isSelected
            ? event.selectedAsset.rate!.effectivePrice!.toString()
            : originalPrice;

        final updatedIcon = await _createPriceMarkerIcon(
          event.context,
          priceToUse,
          isSelected,
        );

        return marker.copyWith(iconParam: updatedIcon);
      }).toList());

      emit(AssetLoaded(
        assetData: currentState.assetData,
        markers: updatedMarkers.toSet(),
        selectedAsset: event.selectedAsset,
        selectedIndex: event.index,
      ));
    }
  }

  Future<Set<Marker>> _createMarkers(List<Datum?> assets, BuildContext context) async {
    // Create a map to store unique assets based on familyId
    final uniqueAssets = <String, Datum>{};

    // Populate uniqueAssets map with the first occurrence of each familyId
    for (var asset in assets) {
      if (asset?.familyId != null) {
        uniqueAssets[asset!.familyId!] ??= asset;
      }
    }

    // Create markers with price icons
    final markers = await Future.wait(uniqueAssets.values.map((asset) async {
      String priceInMap = asset.rate!.effectivePrice!.toString();
      markerPrices[asset.familyId!] = priceInMap;

      final markerIcon = await _createPriceMarkerIcon(
        context,
        priceInMap,
        false,
      );

      return Marker(
        markerId: MarkerId(asset.familyId!),
        position: LatLng(
          asset.branch!.address!.location!.lat!,
          asset.branch!.address!.location!.lng!,
        ),
        icon: markerIcon,
        onTap: () {
          add(SelectAssetEvent(
            selectedAsset: asset,
            index: assets.indexOf(asset),
            context: context,
          ));
        },
      );
    }).toList());

    return markers.toSet();
  }

  Future<AssetData> fetchAssets({
    required String location,
    required String asset,
    String? startDate,
    String? startTime,
    String? endDate,
    String? endTime,
  }) async {
    print("Date: ${startDate ?? 'not specified'} to ${endDate ?? 'not specified'}");
    print("Time: ${startTime ?? 'not specified'} to ${endTime ?? 'not specified'}");

    // Get current date if dates are not provided
    final DateTime now = DateTime.now();
    final String defaultDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Use provided dates or default to today
    final String fromDate = startDate ?? defaultDate;
    final String toDate = endDate ?? startDate ?? defaultDate;

    // Build the URL directly
    String baseUrl = 'https://corporate-dot-hornbill-staging.uc.r.appspot.com/booking/getAvailableAssetsv4';

    // Always include required date parameters
    List<String> queryParts = [
      'fromDate=$fromDate',
      'toDate=$toDate',
    ];

    // Add time parameters if both are provided
    if (startTime != null && endTime != null) {
      queryParts.add('fromTime=$startTime');
      queryParts.add('toTime=$endTime');
    }

    // Add filters directly in the URL
    if (location.isNotEmpty) {
      if (asset.isNotEmpty) {
        queryParts.add('filters={"location":"${location.toLowerCase()}","assetTypes":["$asset"]}');
      } else {
        queryParts.add('filters={"location":"${location.toLowerCase()}"}');
      }
    } else {
      // Default filter if no location
      queryParts.add('filters={"location":"kochi"}');
    }

    // Construct the full URL
    final String fullUrl = '$baseUrl?${queryParts.join('&')}';
    final uri = Uri.parse(fullUrl);

    // Make the GET request
    final response = await http.get(uri);

    print("Shared API request: $fullUrl");
    print("Shared API response: ${response.body}");

    if (response.statusCode == 200) {
      return AssetData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load assets');
    }
  }

  Future<BitmapDescriptor> _createPriceMarkerIcon(BuildContext context, String price, bool isSelected) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(200, 100);

    final paint = Paint()
      ..color = isSelected ? primary_color : Colors.white;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(50));
    canvas.drawRRect(rrect, paint);

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    final textStyle = TextStyle(
      color: isSelected ? Colors.white : Colors.black,
      fontSize: 40.0,
    );
    textPainter.text = TextSpan(
      text: '₹$price',
      style: textStyle,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );
    textPainter.paint(canvas, offset);

    final image = await recorder.endRecording().toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(bytes);
  }
}*/
