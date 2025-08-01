import 'package:hb_booking_mobile_app/utils/colors.dart';
import 'package:hb_booking_mobile_app/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/is_loader.dart';
import '../../asset_bloc/asset_bloc.dart';
import '../../asset_bloc/asset_event.dart';
import '../../asset_bloc/asset_state.dart';
import '../bloc_contentsheet.dart';
import '../state_contentsheet.dart';
import 'asset_card.dart';



enum LayoutType {
  mobile,
  desktop
}
class ContentSheet extends StatelessWidget {
  final EdgeInsets systemUiInsets;
  final String? location;
  final String? asset;
  final String? selectedDate;
  final String? selectedStartTime;
  final String? selectedEndTime;
  final String? selectedEndDate;
  final LayoutType layoutType;

  const ContentSheet({
    Key? key,
    required this.systemUiInsets,
    this.location,
    this.asset,
    this.selectedDate,
    this.selectedStartTime,
    this.selectedEndTime,
    this.selectedEndDate,
    this.layoutType = LayoutType.mobile,
  }) : super(key: key);

  String? _combineDateTime(String? date, String? time) {
    if (date == null) return null;
    if (time != null) return '${date}T$time';
    return date;
  }
  void _loadDefaultAssets(BuildContext context) {
    // Load default assets with minimal filters
    context.read<AssetBloc>().add(FetchAssetsEvent(
      location: 'kochi', // default location
      asset: '', // no asset filter
      startDate: null, // no date filter
      startTime: null, // no time filter
      endDate: null,
      endTime: null,
      context: context,
    ));
  }
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocBuilder<AssetBloc, AssetState>(
        builder: (context, state) {
          if (state is AssetLoading) {
            return const Center(
              child: OfficeLoader(),
            );
          } else if (state is AssetError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is AssetLoaded) {
            final assets = state.assetData.data;
            if (assets!.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/nodata.png', width: 200, height: 200),
                  const SizedBox(height: 16),

                  const Text(
                    "No results found.\n Let's refine the search for better results!",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _loadDefaultAssets(context),

                    child: const Text('Back to home',style: TextStyle(color: Colors.blueAccent),),
                  ),
                ],
              );
            }

            return layoutType == LayoutType.desktop
                ? _buildDesktopLayout(context, assets)
                : _buildMobileLayout(context, assets);
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, List assets) {
    return GridView.builder(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: assets.length,
      itemBuilder: (context, index) {
        return AssetCard(
          asset: assets[index],
          index: index,
          selectedDate:selectedDate ,
          selectedEndDate: selectedEndDate ?? selectedDate,
          selectedStartTime: selectedStartTime,
          selectedEndTime:selectedEndTime ,

        );
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context, List assets) {
    return ListView.builder(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      itemCount: assets.length,
      itemBuilder: (context, index) {
        return AssetCard(
          asset: assets[index],
          index: index,
          selectedDate: selectedDate,
          selectedEndDate:selectedEndDate ?? selectedDate ,
          selectedStartTime:selectedStartTime ,
          selectedEndTime:selectedEndTime ,

        );
      },
    );
  }
}
/*
class ContentSheet extends StatelessWidget {
  final EdgeInsets systemUiInsets;
  final String? location;
  final String? asset;
  final String? selectedDate;
  final String? selectedStartTime;
  final String? selectedEndTime;
  final String? selectedEndDate;
  final LayoutType layoutType;

  const ContentSheet({
    Key? key,
    required this.systemUiInsets,
    this.location,
    this.asset,
    this.selectedDate,
    this.selectedStartTime,
    this.selectedEndTime,
    this.selectedEndDate,
    this.layoutType = LayoutType.mobile,
  }) : super(key: key);

  // Helper method to combine date and time into ISO string for AssetCard
  String? _combineDateTime(String? date, String? time) {
    if (date == null) return null;

    if (time != null) {
      return '${date}T$time';
    } else {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocBuilder<ContentSheetBloc, ContentSheetState>(
        builder: (context, state) {
          if (state is ContentSheetLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: primary_color,
              ),
            );
          } else if (state is ContentSheetError) {
            print("ContentSheet Error: ${state.message}");
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is ContentSheetLoaded) {
            final assets = state.assetData.data;
            if (assets!.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/nodata.png',
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Oops',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Center(
                    child: const Text(
                      "No results found. Let's refine the search for better results!",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }

            // Show different layouts based on layoutType
            return layoutType == LayoutType.desktop
                ? _buildDesktopLayout(context, assets)
                : _buildMobileLayout(context, assets);
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, List assets) {
    return GridView.builder(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: assets.length,
      itemBuilder: (context, index) {
        return AssetCard(
          asset: assets[index],
          index: index,
          isoStart: _combineDateTime(selectedDate, selectedStartTime),
          isoEnd: _combineDateTime(selectedEndDate ?? selectedDate, selectedEndTime),
        );
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context, List assets) {
    return ListView.builder(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      itemCount: assets.length,
      itemBuilder: (context, index) {
        return AssetCard(
          asset: assets[index],
          index: index,
          isoStart: _combineDateTime(selectedDate, selectedStartTime),
          isoEnd: _combineDateTime(selectedEndDate ?? selectedDate, selectedEndTime),
        );
      },
    );
  }
}
*/

// enum LayoutType {
//   mobile,
//   desktop
// }
//
// class ContentSheet extends StatelessWidget {
//   final EdgeInsets systemUiInsets;
//   final String? location;
//   final String? asset;
//   final String? start;
//   final String? end;
//   final LayoutType layoutType;
//
//   const ContentSheet({
//     Key? key,
//     required this.systemUiInsets,
//     this.location,
//     this.asset,
//     this.start,
//     this.end,
//     this.layoutType = LayoutType.mobile,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: BlocBuilder<ContentSheetBloc, ContentSheetState>(
//         builder: (context, state) {
//           if (state is ContentSheetLoading) {
//             return const Center(
//               child: CircularProgressIndicator(
//                 color: primary_color,
//               ),
//             );
//           } else if (state is ContentSheetError) {
//             print("here---123");
//             return Center(child: Text('Error: ${state.message}'));
//           } else if (state is ContentSheetLoaded) {
//             final assets = state.assetData.data;
//             if (assets!.isEmpty) {
//               return Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Image.asset(
//                     'assets/images/nodata.png',
//                     width: 200,
//                     height: 200,
//                   ),
//                   const SizedBox(height: 16),
//                   const Text(
//                     'Oops',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Center(
//                     child: const Text(
//                       "No results found. Let's refine the search for better results!",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w300,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ],
//               );
//             }
//
//             // Show different layouts based on layoutType
//             return layoutType == LayoutType.desktop
//                 ? _buildDesktopLayout(context, assets)
//                 : _buildMobileLayout(context, assets);
//           } else {
//             return const Center(child: Text('No data available'));
//           }
//         },
//       ),
//     );
//   }
//
//   Widget _buildDesktopLayout(BuildContext context, List assets) {
//     return GridView.builder(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).padding.bottom,
//       ),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         childAspectRatio: 1.2,
//         crossAxisSpacing: 16,
//         mainAxisSpacing: 16,
//       ),
//       itemCount: assets.length,
//       itemBuilder: (context, index) {
//         return AssetCard(
//           asset: assets[index],
//           index: index,
//           isoStart: start,
//           isoEnd: end,
//         );
//       },
//     );
//   }
//
//   Widget _buildMobileLayout(BuildContext context, List assets) {
//     return ListView.builder(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).padding.bottom,
//       ),
//       itemCount: assets.length,
//       itemBuilder: (context, index) {
//         return AssetCard(
//           asset: assets[index],
//           index: index,
//           isoStart: start,
//           isoEnd: end,
//         );
//       },
//     );
//   }
// }








