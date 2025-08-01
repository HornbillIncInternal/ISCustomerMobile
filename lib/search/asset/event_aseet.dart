import 'package:equatable/equatable.dart';

// abstract class SelectAssetEvent extends Equatable {
//   const SelectAssetEvent();
//
//   @override
//   List<Object?> get props => [];
// }
//
// class AssetSearchChanged extends SelectAssetEvent {
//   final String query;
//
//   const AssetSearchChanged(this.query);
//
//   @override
//   List<Object?> get props => [query];
// }
//
// class AssetSelected extends SelectAssetEvent {
//   final String asset;
//
//   const AssetSelected(this.asset);
//
//   @override
//   List<Object?> get props => [asset];
// }


abstract class SelectAssetEvent extends Equatable {
  const SelectAssetEvent();

  @override
  List<Object?> get props => [];
}

class AssetSelected extends SelectAssetEvent {
  final String assetTitle;
  final String assetId;

  const AssetSelected(this.assetTitle, this.assetId);

  @override
  List<Object?> get props => [assetTitle, assetId];
}