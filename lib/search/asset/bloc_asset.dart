import 'package:hb_booking_mobile_app/search/asset/state_asset.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'event_aseet.dart';



class SelectAssetBloc extends Bloc<SelectAssetEvent, SelectAssetState> {
  SelectAssetBloc() : super(DestinationInitial()) {
    on<AssetSelected>((event, emit) {
      emit(SelectAssetSelectionSuccess(event.assetTitle, event.assetId));
    });
  }
}

// class SelectAssetBloc extends Bloc<SelectAssetEvent, SelectAssetState> {
//   SelectAssetBloc() : super(const SelectAssetState()) {
//     on<AssetSearchChanged>((event, emit) {
//       // Optionally filter assets or update the search query
//       emit(state.copyWith(
//         searchQuery: event.query,
//         selectedAsset: null, // Reset selection when search changes
//       ));
//     });
//
//     on<AssetSelected>((event, emit) {
//       // Update the selected asset
//       emit(state.copyWith(selectedAsset: event.asset));
//     });
//   }
// }

