import 'dart:convert';
import 'dart:ui' as ui;

import 'package:hb_booking_mobile_app/home/mapview/event_assetmapview.dart';
import 'package:hb_booking_mobile_app/home/mapview/state_assetmapview.dart';
import 'package:hb_booking_mobile_app/home/model/model_assets.dart';
import 'package:hb_booking_mobile_app/utils/base_url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
class AssetMapBloc extends Bloc<AssetMapEvent, AssetMapState> {
  // A map to store the original prices of markers
  final Map<String, String> markerPrices = {};

  AssetMapBloc() : super(AssetMapInitial()) {
    on<FetchAssetsEvent>(_onFetchAssets);
    on<SelectMarkerEvent>(_onSelectMarker);
  }

  Future<void> _onFetchAssets(FetchAssetsEvent event, Emitter<AssetMapState> emit) async {
    emit(AssetMapLoading());
    try {
      final assets = await fetchAssets(
          event.location,
          event.asset,
          event.startDate,
          event.startTime,
          event.endDate,
          event.endTime
      );

      // Create a map to store unique assets based on familyId
      final uniqueAssets = <String, Datum>{};

      // Populate uniqueAssets map with the first occurrence of each familyId
      for (var asset in assets!.data!) {
        uniqueAssets[asset!.familyId!] ??= asset;
      }

      // Create markers with price icons using the passed context
      final markers = await Future.wait(uniqueAssets.values.map((asset) async {
        // Use the effective price from rate instead of packages
        String priceInMap = asset.rate!.effectivePrice!.toString();
        markerPrices[asset!.familyId!] = priceInMap;

        final markerIcon = await _createPriceMarkerIcon(
          event.context,
          priceInMap,
          false, // Default markers are not selected
        );

        return Marker(
          markerId: MarkerId(asset!.familyId!), // Use familyId as the marker ID
          position: LatLng(
            asset.branch!.address!.location!.lat!,
            asset.branch!.address!.location!.lng!,
          ),
          icon: markerIcon,  // Set the custom icon with price
          onTap: () {
            add(SelectMarkerEvent(
              selectedAsset: asset,
              index: assets.data!.indexOf(asset),
              context: event.context,
            ));
          },
        );
      }).toList());

      emit(AssetMapLoaded(markers: markers.toSet()));
    } catch (e) {
      emit(AssetMapError(e.toString()));
    }
  }
/*

  Future<void> _onFetchAssets(FetchAssetsEvent event, Emitter<AssetMapState> emit) async {
    emit(AssetMapLoading());
    try {
      final assets = await fetchAssets(event.location, event.asset, event.start, event.end);

      // Create a map to store unique assets based on familyId
      final uniqueAssets = <String, Datum>{};

      // Populate uniqueAssets map with the first occurrence of each familyId
      for (var asset in assets!.data!) {
        uniqueAssets[asset!.familyId!] ??= asset;
      }

      // Create markers with price icons using the passed context
      final markers = await Future.wait(uniqueAssets.values.map((asset) async {
        // Use the effective price from rate instead of packages
        String priceInMap = asset.rate!.effectivePrice!.toString();
        markerPrices[asset!.familyId!] = priceInMap;

        final markerIcon = await _createPriceMarkerIcon(
          event.context,
          priceInMap,
          false, // Default markers are not selected
        );

        return Marker(
          markerId: MarkerId(asset!.familyId!), // Use familyId as the marker ID
          position: LatLng(
            asset.branch!.address!.location!.lat!,
            asset.branch!.address!.location!.lng!,
          ),
          icon: markerIcon,  // Set the custom icon with price
          onTap: () {
            add(SelectMarkerEvent(
              selectedAsset: asset,
              index: assets.data!.indexOf(asset),
              context: event.context,
            ));
          },
        );
      }).toList());

      emit(AssetMapLoaded(markers: markers.toSet()));
    } catch (e) {
      emit(AssetMapError(e.toString()));
    }
  }
*/

  Future<void> _onSelectMarker(SelectMarkerEvent event, Emitter<AssetMapState> emit) async {
    final currentState = state;
    if (currentState is AssetMapLoaded) {
      // Update the markers, setting the selected one with the special icon
      final updatedMarkers = await Future.wait(currentState.markers.map((marker) async {
        // Check if this marker is the selected one
        final isSelected = marker.markerId.value == event.selectedAsset.familyId;

        // Retrieve the original price from the map for non-selected markers
        final originalPrice = markerPrices[marker.markerId.value] ?? '0'; // Default value if not found

        // Use the effective price from rate for the selected marker
        final priceToUse = isSelected
            ? event.selectedAsset.rate!.effectivePrice!.toString()
            : originalPrice;

        // Create the correct icon for the marker
        final updatedIcon = await _createPriceMarkerIcon(
          event.context,
          priceToUse, // Pass the correct price based on selection
          isSelected, // Highlight the selected marker
        );

        // Return the marker with the updated icon
        return marker.copyWith(iconParam: updatedIcon);
      }).toList());

      // Emit the updated state with selectedAsset and selectedIndex
      emit(AssetMapLoaded(
        markers: updatedMarkers.toSet(),
        selectedAsset: event.selectedAsset,  // Update the selected asset
        selectedIndex: event.index,  // Update the selected index
      ));
    }
  }
  Future<AssetData> fetchAssets(String location, String asset, String? startDate, String? startTime, String? endDate, String? endTime) async {
    print("Date: ${startDate ?? 'not specified'} to ${endDate ?? 'not specified'}");
    print("Time: ${startTime ?? 'not specified'} to ${endTime ?? 'not specified'}");

    // Get current date if dates are not provided
    final DateTime now = DateTime.now();
    final String defaultDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Use provided dates or default to today
    final String fromDate = startDate ?? defaultDate;
    final String toDate = endDate ?? startDate ?? defaultDate;

    // Build the URL directly
    String baseUrl = '${base_url}booking/getAvailableAssetsv4';

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

    print("request to map: $fullUrl");
    print("response from map: ${response.body}");

    if (response.statusCode == 200) {
      return AssetData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load assets');
    }
  }
 /* Future<AssetData> fetchAssets(String location, String asset, String start, String end) async {
    DateTime startDateTime = DateTime.parse(start);
    DateTime endDateTime = DateTime.parse(end);

    // Formatting for date
    String startDate = intl.DateFormat('yyyy-MM-dd').format(startDateTime);
    String endDate = intl.DateFormat('yyyy-MM-dd').format(endDateTime);

    // Formatting for time
    String startTime = intl.DateFormat('HH:mm:ss').format(startDateTime);
    String endTime = intl.DateFormat('HH:mm:ss').format(endDateTime);

    print("Date: $startDate");
    print("Time: $startTime");

    Map<String, dynamic> filtersMap = {
      "location": location.toLowerCase(),
    };

    // Only add "assetTypes" if asset is not null or empty
    if (asset.isNotEmpty) {
      filtersMap["assetTypes"] = [asset];
    }

    // Encode filters as a JSON string
    String filters = jsonEncode(filtersMap);
    String encodedFilters = Uri.encodeComponent(filters);

    // Construct the full URI with all parameters
    final uri = Uri.parse(
      'https://corporate-dot-hornbill-staging.uc.r.appspot.com/booking/getAvailableAssetsv4?'
          'fromDate=$startDate&toDate=$endDate&fromTime=$startTime&toTime=$endTime&filters=$encodedFilters',
    );

    // Make the GET request
    final response = await http.get(uri);

    print("request to map: ${uri}");
    print("response from map: ${response.body}");

    if (response.statusCode == 200) {
      return AssetData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load assets');
    }
  }
*/
  Future<BitmapDescriptor> _createPriceMarkerIcon(BuildContext context, String price, bool isSelected) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(200, 100); // Adjust the size as needed

    // Draw the background based on whether the marker is selected
    final paint = Paint()
      ..color = isSelected ? Colors.black : Colors.white;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(50)); // Oval shape
    canvas.drawRRect(rrect, paint);

    // Draw the price text with the rupee symbol
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    final textStyle = TextStyle(
      color: isSelected ? Colors.white : Colors.black,
      fontSize: 40.0, // Adjust the text size as needed
    );
    textPainter.text = TextSpan(
      text: '₹$price',  // Add the rupee symbol here
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

    // Convert the canvas to an image
    final image = await recorder.endRecording().toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(bytes);
  }
}






