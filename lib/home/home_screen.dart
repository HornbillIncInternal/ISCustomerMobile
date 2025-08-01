import 'package:hb_booking_mobile_app/connectivity/connectivity_bloc.dart';
import 'package:hb_booking_mobile_app/connectivity/connectivity_state.dart';
import 'package:hb_booking_mobile_app/home/bloc_home.dart';
import 'package:hb_booking_mobile_app/home/content_sheet/bloc_contentsheet.dart';
import 'package:hb_booking_mobile_app/home/content_sheet/event_contentsheet.dart';
import 'package:hb_booking_mobile_app/home/content_sheet/state_contentsheet.dart';
import 'package:hb_booking_mobile_app/home/content_sheet/widget/asset_card.dart';
import 'package:hb_booking_mobile_app/home/content_sheet/widget/content_sheet.dart';
import 'package:hb_booking_mobile_app/home/event_home.dart';
import 'package:hb_booking_mobile_app/home/state_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hb_booking_mobile_app/utils/colors.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import '../widgets/app_bar.dart';
import 'asset_bloc/asset_bloc.dart';
import 'asset_bloc/asset_event.dart';
import 'asset_bloc/asset_state.dart';
import 'mapview/screen_asssetmapview.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
class ExplorePage extends StatelessWidget {
  final String? selectedLocation;
  final String? selectedAsset;
  final String? selectedDate;
  final String? selectedStartTime;
  final String? selectedEndTime;
  final String? selectedEndDate;

  const ExplorePage({
    Key? key,
    this.selectedLocation,
    this.selectedAsset,
    this.selectedDate,
    this.selectedStartTime,
    this.selectedEndTime,
    this.selectedEndDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final systemUiInsets = MediaQuery.of(context).padding;
    final String? isoStart = _combineDateTime(selectedDate, selectedStartTime);
    final String? isoEnd = _combineDateTime(selectedEndDate ?? selectedDate, selectedEndTime);

    return DefaultTabController(
      length: AppBarr.tabs.length,
      child: DefaultSheetController(
        child: Scaffold(
          extendBody: !kIsWeb,
          extendBodyBehindAppBar: !kIsWeb,
          appBar: AppBarr(
            selectedLocation: selectedLocation,
            selectedAsset: selectedAsset,
            selectedStart: isoStart,
            selectedEnd: isoEnd,
          ),
          body: BlocBuilder<ConnectivityBloc, ConnectivityState>(
            builder: (context, connectivityState) {
              if (connectivityState is DisconnectedState) {
                return _buildNoConnectionView();
              }
              return kIsWeb ? _buildWebLayout(context) : _buildMobileLayout(context);
            },
          ),
          floatingActionButton: kIsWeb ? null : const _MapButton(),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        ),
      ),
    );
  }

  String? _combineDateTime(String? date, String? time) {
    if (date == null) return null;
    if (time != null) return '${date}T$time';
    return date;
  }

  Widget _buildNoConnectionView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(65.0),
            child: Image.asset('assets/images/no_internet.png'),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;

    // Trigger asset fetch when entering this view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssetBloc>().add(FetchAssetsEvent(
        location: selectedLocation ?? 'kochi',
        asset: selectedAsset,
        startDate: selectedDate,
        startTime: selectedStartTime,
        endDate: selectedEndDate,
        endTime: selectedEndTime,
        context: context,
      ));
    });

    return Column(
      children: [
        TabBar(tabs: [Tab(text: 'Assets'), Tab(text: 'Map')]),
        Expanded(
          child: TabBarView(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                child: ContentSheet(
                  systemUiInsets: EdgeInsets.zero,
                  location: selectedLocation,
                  asset: selectedAsset,
                  selectedDate: selectedDate,
                  selectedStartTime: selectedStartTime,
                  selectedEndTime: selectedEndTime,
                  selectedEndDate: selectedEndDate,
                  layoutType: isDesktop ? LayoutType.desktop : LayoutType.mobile,
                ),
              ),
              AssetMapView(
                location: selectedLocation,
                asset: selectedAsset,
                selectedDate: selectedDate,
                selectedStartTime: selectedStartTime,
                selectedEndTime: selectedEndTime,
                selectedEndDate: selectedEndDate,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final systemUiInsets = MediaQuery.of(context).padding;

    // Trigger asset fetch when entering this view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssetBloc>().add(FetchAssetsEvent(
        location: selectedLocation ?? 'kochi',
        asset: selectedAsset,
        startDate: selectedDate,
        startTime: selectedStartTime,
        endDate: selectedEndDate,
        endTime: selectedEndTime,
        context: context,
      ));
    });

    return Stack(
      children: [
        AssetMapView(
          location: selectedLocation,
          asset: selectedAsset,
          selectedDate: selectedDate,
          selectedStartTime: selectedStartTime,
          selectedEndTime: selectedEndTime,
          selectedEndDate: selectedEndDate,
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final parentHeight = constraints.maxHeight;
            final appbarHeight = MediaQuery.of(context).padding.top;
            final handleHeight = const _ContentSheetHandle().preferredSize.height;
            final sheetHeight = parentHeight - appbarHeight + handleHeight;
            final minSheetExtent = Extent.pixels(handleHeight + systemUiInsets.bottom);

            const sheetShape = RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            );

            final sheetPhysics = BouncingSheetPhysics(
              parent: SnappingSheetPhysics(
                snappingBehavior: SnapToNearest(
                  snapTo: [minSheetExtent, const Extent.proportional(1)],
                ),
              ),
            );

            return ScrollableSheet(
              physics: sheetPhysics,
              minExtent: minSheetExtent,
              initialExtent: Extent.proportional(0.5),
              child: SizedBox(
                height: sheetHeight,
                child: Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  shape: sheetShape,
                  child: Column(
                    children: [
                      const _ContentSheetHandle(),
                      ContentSheet(
                        systemUiInsets: EdgeInsets.zero,
                        location: selectedLocation,
                        asset: selectedAsset,
                        selectedDate: selectedDate,
                        selectedStartTime: selectedStartTime,
                        selectedEndTime: selectedEndTime,
                        selectedEndDate: selectedEndDate,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}


/*class ExplorePage extends StatelessWidget {
  final String? selectedLocation;
  final String? selectedAsset;
  final String? selectedDate;
  final String? selectedStartTime;
  final String? selectedEndTime;
  final String? selectedEndDate;

  const ExplorePage({
    Key? key,
    this.selectedLocation,
    this.selectedAsset,
    this.selectedDate,
    this.selectedStartTime,
    this.selectedEndTime,
    this.selectedEndDate,
  }) : super(key: key);

  // Helper method to combine date and time into ISO string for backward compatibility
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
    final systemUiInsets = MediaQuery.of(context).padding;

    // Create ISO strings for backward compatibility with existing components
    final String? isoStart = _combineDateTime(selectedDate, selectedStartTime);
    final String? isoEnd = _combineDateTime(selectedEndDate ?? selectedDate, selectedEndTime);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ExploreTabBloc()
            ..add(InitializeExploreTabEvent(
              selectedLocation: selectedLocation,
              selectedAsset: selectedAsset,
              isoStart: isoStart,
              isoEnd: isoEnd,
            )),
        ),
        // Single AssetBloc for both map and content - replaces ContentSheetBloc and AssetMapBloc
        BlocProvider(
          create: (_) => AssetBloc()..add(FetchAssetsEvent(
            location: selectedLocation ?? 'kochi',
            asset: selectedAsset,
            startDate: selectedDate,
            startTime: selectedStartTime,
            endDate: selectedEndDate,
            endTime: selectedEndTime,
            context: context, // Pass context for map markers
          )),
        ),
      ],
      child: DefaultTabController(
        length: AppBarr.tabs.length,
        child: DefaultSheetController(
          child: Scaffold(
            extendBody: !kIsWeb,
            extendBodyBehindAppBar: !kIsWeb,
            appBar: AppBarr(
              selectedLocation: selectedLocation,
              selectedAsset: selectedAsset,
              selectedStart: isoStart,
              selectedEnd: isoEnd,
            ),
            body: BlocBuilder<ConnectivityBloc, ConnectivityState>(
              builder: (context, connectivityState) {
                if (connectivityState is DisconnectedState) {
                  return _buildNoConnectionView();
                }
                return kIsWeb ? _buildWebLayout(context) : _buildMobileLayout(context);
              },
            ),
            floatingActionButton: kIsWeb ? null : const _MapButton(),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          ),
        ),
      ),
    );
  }

  Widget _buildNoConnectionView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(65.0),
            child: Image.asset('assets/images/no_internet.png'),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;

    return Column(
      children: [
        TabBar(
          tabs: [
            Tab(text: 'Assets'),
            Tab(text: 'Map'),
          ],
        ),
        Expanded(
          child: TabBarView(
            children: [
              // Assets Tab View - Uses shared AssetBloc
              Container(
                padding: EdgeInsets.all(16),
                child: isDesktop
                    ? ContentSheet(
                  systemUiInsets: EdgeInsets.zero,
                  location: selectedLocation,
                  asset: selectedAsset,
                  selectedDate: selectedDate,
                  selectedStartTime: selectedStartTime,
                  selectedEndTime: selectedEndTime,
                  selectedEndDate: selectedEndDate,
                  layoutType: LayoutType.desktop,
                )
                    : ContentSheet(
                  systemUiInsets: EdgeInsets.zero,
                  location: selectedLocation,
                  asset: selectedAsset,
                  selectedDate: selectedDate,
                  selectedStartTime: selectedStartTime,
                  selectedEndTime: selectedEndTime,
                  selectedEndDate: selectedEndDate,
                  layoutType: LayoutType.mobile,
                ),
              ),
              // Map Tab View - Uses shared AssetBloc
              AssetMapView(
                location: selectedLocation,
                asset: selectedAsset,
                selectedDate: selectedDate,
                selectedStartTime: selectedStartTime,
                selectedEndTime: selectedEndTime,
                selectedEndDate: selectedEndDate,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final systemUiInsets = MediaQuery.of(context).padding;

    return BlocBuilder<ExploreTabBloc, ExploreTabState>(
      builder: (context, state) {
        return Stack(
          children: [
            // AssetMapView uses shared AssetBloc
            AssetMapView(
              location: selectedLocation,
              asset: selectedAsset,
              selectedDate: selectedDate,
              selectedStartTime: selectedStartTime,
              selectedEndTime: selectedEndTime,
              selectedEndDate: selectedEndDate,
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final parentHeight = constraints.maxHeight;
                final appbarHeight = MediaQuery.of(context).padding.top;
                final handleHeight = const _ContentSheetHandle().preferredSize.height;
                final sheetHeight = parentHeight - appbarHeight + handleHeight;

                final minSheetExtent = Extent.pixels(handleHeight + systemUiInsets.bottom);

                const sheetShape = RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                );

                final sheetPhysics = BouncingSheetPhysics(
                  parent: SnappingSheetPhysics(
                    snappingBehavior: SnapToNearest(
                      snapTo: [
                        minSheetExtent,
                        const Extent.proportional(1),
                      ],
                    ),
                  ),
                );

                return ScrollableSheet(
                  physics: sheetPhysics,
                  minExtent: minSheetExtent,
                  initialExtent: Extent.proportional(0.5),
                  child: SizedBox(
                    height: sheetHeight,
                    child: Card(
                      margin: EdgeInsets.zero,
                      clipBehavior: Clip.antiAlias,
                      shape: sheetShape,
                      child: Column(
                        children: [
                          const _ContentSheetHandle(),
                          // ContentSheet uses shared AssetBloc
                          ContentSheet(
                            systemUiInsets: EdgeInsets.zero,
                            location: selectedLocation,
                            asset: selectedAsset,
                            selectedDate: selectedDate,
                            selectedStartTime: selectedStartTime,
                            selectedEndTime: selectedEndTime,
                            selectedEndDate: selectedEndDate,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}*/
class _ContentSheetHandle extends StatelessWidget implements PreferredSizeWidget {
  const _ContentSheetHandle();

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return SheetDraggable(
      child: Material(
        color: Colors.transparent,
        child: SizedBox(
          height: preferredSize.height,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                buildIndicator(context),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Text(
                        'Back to home',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildIndicator(BuildContext context) {
    return Container(
      height: 6,
      width: 40,
      decoration: const ShapeDecoration(
        color: Colors.black12,
        shape: StadiumBorder(),
      ),
    );
  }
}



class _MapButton extends StatelessWidget {
  const _MapButton();

  @override
  Widget build(BuildContext context) {
    final sheetController = DefaultSheetController.of(context);

    void onPressed() {
      final metrics = sheetController.value;
      if (metrics.hasDimensions) {
        // Collapse the sheet to reveal the map behind.
        sheetController.animateTo(
          Extent.pixels(metrics.minPixels),
          curve: Curves.fastOutSlowIn,
        );
      }
    }

    final result = FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: Colors.black45,
      label: const Text(
        'Map',
        style: TextStyle(color: Colors.white),
      ),
      icon: const Icon(
        Icons.map,
        color: Colors.white,
      ),
    );

    final animation = ExtentDrivenAnimation(
      controller: sheetController,
      initialValue: 1,
      startExtent: null,
      endExtent: null,
    ).drive(CurveTween(curve: Curves.easeInExpo));

    return ScaleTransition(
      scale: animation,
      child: FadeTransition(
        opacity: animation,
        child: result,
      ),
    );
  }
}


















