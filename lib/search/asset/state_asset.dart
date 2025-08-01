import 'package:equatable/equatable.dart';
// class SelectAssetState extends Equatable {
//   final List<String> workspaceTypes;
//   final String? selectedAsset;
//   final String searchQuery;
//   final bool isExpanded;
//
//   const SelectAssetState({
//     this.workspaceTypes = const ["Meeting room", "Desk", "Cabin"],
//     this.selectedAsset,
//     this.searchQuery = '',
//     this.isExpanded = false,
//   });
//
//   SelectAssetState copyWith({
//     List<String>? workspaceTypes,
//     String? selectedAsset,
//     String? searchQuery,
//     bool? isExpanded,
//   }) {
//     return SelectAssetState(
//       workspaceTypes: workspaceTypes ?? this.workspaceTypes,
//       selectedAsset: selectedAsset ?? this.selectedAsset,
//       searchQuery: searchQuery ?? this.searchQuery,
//       isExpanded: isExpanded ?? this.isExpanded,
//     );
//   }
//
//   @override
//   List<Object?> get props => [workspaceTypes, selectedAsset ?? '', searchQuery, isExpanded];
// }



abstract class SelectAssetState extends Equatable {
  const SelectAssetState();

  @override
  List<Object?> get props => [];
}

class DestinationInitial extends SelectAssetState {}

class SelectAssetSelectionSuccess extends SelectAssetState {
  final String assetTitle;
  final String assetId;

  const SelectAssetSelectionSuccess(this.assetTitle, this.assetId);

  @override
  List<Object?> get props => [assetTitle, assetId];
}









