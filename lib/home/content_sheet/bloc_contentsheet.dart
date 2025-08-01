
import 'dart:convert';
import 'package:hb_booking_mobile_app/home/content_sheet/state_contentsheet.dart';
import 'package:hb_booking_mobile_app/home/model/model_assets.dart';
import 'package:hb_booking_mobile_app/utils/base_url.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'event_contentsheet.dart';

class ContentSheetBloc extends Bloc<ContentSheetEvent, ContentSheetState> {
  ContentSheetBloc() : super(ContentSheetInitial()) {
    // Register the event handler for FetchAssets
    on<FetchAssets>((event, emit) async {
      emit(ContentSheetLoading());
      try {
        final assetData = await fetchAssets(
          location: event.location,
          asset: event.asset,
          startDate: event.startDate,
          startTime: event.startTime,
          endDate: event.endDate,
          endTime: event.endTime,
        );
        emit(ContentSheetLoaded(assetData));
      } catch (error) {
        emit(ContentSheetError(error.toString()));
      }
    });
  }

  Future<AssetData> fetchAssets({
    required String location,
    String? asset,
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
      if (asset != null && asset.isNotEmpty) {
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

    print("request to content sheet: $fullUrl");

    // Make the GET request
    final response = await http.get(uri);

    print("response from content sheet: ${response.body}");

    if (response.statusCode == 200) {
      try {
        final parsedData = AssetData.fromJson(json.decode(response.body));
        return parsedData;
      } catch (e) {
        print("Error while parsing JSON: $e");
        throw Exception('Failed to parse assets data');
      }
    } else {
      throw Exception('Failed to load assets');
    }
  }
}

// class ContentSheetBloc extends Bloc<ContentSheetEvent, ContentSheetState> {
//   ContentSheetBloc() : super(ContentSheetInitial()) {
//     // Register the event handler for FetchAssets
//     on<FetchAssets>((event, emit) async {
//       emit(ContentSheetLoading());
//       try {
//         final assetData = await fetchAssets(
//           location: event.location,
//           asset: event.asset,
//           start: event.start,
//           end: event.end,
//         );
//         emit(ContentSheetLoaded(assetData));
//       } catch (error) {
//         emit(ContentSheetError(error.toString()));
//       }
//     });
//   }
//
//   Future<AssetData> fetchAssets({
//     required String location,
//     String? asset,
//     String? start,
//     String? end,
//   }) async {
//
//     DateTime startdDateTime = DateTime.parse(start!);
//     DateTime endDateTime = DateTime.parse(end!);
//
//     // Formatting for date
//     String startdate = DateFormat('yyyy-MM-dd').format(startdDateTime);    // Formatting for date
//     String endDate = DateFormat('yyyy-MM-dd').format(endDateTime);
//
//     // Formatting for time
//     String starttime = DateFormat('HH:mm:ss').format(startdDateTime);
//     String endtime = DateFormat('HH:mm:ss').format(endDateTime);
//
//     print("Date: $startdate");
//     print("Time: $starttime");
//     // final uri = Uri.parse(
//     //     '${base_url}booking/getAvailableAssetsv2?location=${location.toLowerCase()}&type=${asset??''}&fromDate=${startdate ?? ''}&toDate=${endDate ?? ''}&fromTime=${starttime}&toTime=${endtime}');
//     // final response = await http.get(uri);
//
//     print("response from  content dfds---  ${location}");
//     print("response from  contentdfsd---  ${asset}");
//     Map<String, dynamic> filtersMap = {
//       "location": location.toLowerCase(),
//     };
//
//     // Only add "assetTypes" if asset is not null or empty
//     if (asset != null && asset.isNotEmpty) {
//       filtersMap["assetTypes"] = [asset];
//     }
//
//     // Encode filters as a JSON string
//     String filters = jsonEncode(filtersMap);
//     String encodedFilters = Uri.encodeComponent(filters);
//
//     // Construct the full URI with all parameters
//
//      final uri = Uri.parse(
//       'https://corporate-dot-hornbill-staging.uc.r.appspot.com/booking/getAvailableAssetsv4?'
//           'fromDate=$startdate&toDate=$endDate&fromTime=$starttime&toTime=$endtime&filters=$encodedFilters',
//     );
//     print("response from  content---  ${uri}");
//
//     // Make the GET request
//     final response = await http.get(uri);
// print(uri);print("response from  content--"+response.body);
//
//
//     if (response.statusCode == 200) {
//
//         final parsedData = AssetData.fromJson(json.decode(response.body));
//         return parsedData;
//         try {   } catch (e) {
//         print("Error while parsing JSON: $e");
//         throw Exception('Failed to parse assets data');
//       }
//     } else {
//       throw Exception('Failed to load assets');
//     }
//     // if (response.statusCode == 200) {
//     //   return AssetData.fromJson(json.decode(response.body));
//     // } else {
//     //   throw Exception('Failed to load assets');
//     // }
//   }
// }


