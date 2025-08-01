
import 'dart:convert';

import 'package:hb_booking_mobile_app/search/model/model_assettype.dart';
import 'package:hb_booking_mobile_app/utils/base_url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../asset/bloc_asset.dart';
import '../asset/event_aseet.dart';
import '../asset/state_asset.dart';
import '../state_search.dart';
import 'package:http/http.dart' as http;
class SelectAssetWidget extends StatefulWidget {
  final BookingStep step;
  final Function(String) onSelect;

  const SelectAssetWidget({
    Key? key,
    required this.step,
    required this.onSelect,
  }) : super(key: key);

  @override
  _SelectAssetWidgetState createState() => _SelectAssetWidgetState();
}

class _SelectAssetWidgetState extends State<SelectAssetWidget> {
  late TextEditingController _assetTextController;
  String? _selectedDropdownValue;
  List<AssetTypeModelData> _assetTypes = [];

  @override
  void initState() {
    super.initState();
    _assetTextController = TextEditingController();
    _fetchAssetTypes();
  }

  @override
  void dispose() {
    _assetTextController.dispose();
    super.dispose();
  }

  Future<void> _fetchAssetTypes() async {
    final response = await http.get(
      Uri.parse('${base_url}getAssetTypes'),
    );
    if (response.statusCode == 200) {
      final assetTypeModel = AssetTypeModel.fromJson(json.decode(response.body));
      setState(() {
        _assetTypes = assetTypeModel.data ?? [];
      });
    } else {
      // Handle error
      print("Failed to load asset types");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SelectAssetBloc(),
      child: BlocBuilder<SelectAssetBloc, SelectAssetState>(
        builder: (context, state) {
          if (state is SelectAssetSelectionSuccess) {
            if (_assetTextController.text != state.assetTitle) {
              _assetTextController.text = state.assetTitle;
              _selectedDropdownValue = state.assetTitle;
              _assetTextController.selection = TextSelection.fromPosition(
                TextPosition(offset: _assetTextController.text.length),
              );
            }
          }

          return Card(
            elevation: 0.0,
            clipBehavior: Clip.antiAlias,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: widget.step == BookingStep.selectGuests ? 300 : 60,
              padding: const EdgeInsets.all(16.0),
              child: widget.step == BookingStep.selectGuests
                  ? _buildExpandedContent(context, state)
                  : _buildCollapsedContent(context, state),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context, SelectAssetState state) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type of Workspace?',
          style: textTheme.headlineSmall!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16.0),
        DropdownButtonFormField<String>(
          value: _selectedDropdownValue,
          items: _assetTypes.map((AssetTypeModelData asset) {
            return DropdownMenuItem<String>(
              value: asset.title,
              child: Text(asset.title ?? ''),
            );
          }).toList(),
          onChanged: (newValue) {
            final selectedAsset = _assetTypes.firstWhere((asset) => asset.sId == newValue);
            setState(() {
              _selectedDropdownValue = newValue;
              _assetTextController.text = newValue ?? '';
            });
            if (newValue != null) {
              BlocProvider.of<SelectAssetBloc>(context)
                  .add(AssetSelected(newValue, selectedAsset.sId!));
              widget.onSelect(newValue); // Modify if you want to pass assetId here as well
            }
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(16.0),
            hintText: 'Select workspace type',
            hintStyle: textTheme.labelMedium,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
        ),
  /*      DropdownButtonFormField<String>(
          value: _selectedDropdownValue,
          items: _assetTypes.map((AssetTypeModelData asset) {
            return DropdownMenuItem<String>(
              value: asset.title,
              child: Text(asset.title ?? ''),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedDropdownValue = newValue;
              _assetTextController.text = newValue ?? '';
            });
            if (newValue != null) {
              BlocProvider.of<SelectAssetBloc>(context)
                  .add(AssetSelected(newValue.toLowerCase()));
              widget.onSelect(newValue);
            }
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(16.0),
            hintText: 'Select workspace type',
            hintStyle: textTheme.labelMedium,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
        ),*/
        const SizedBox(height: 16.0),
        SizedBox(
          height: 128,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            scrollDirection: Axis.horizontal,
            itemCount: _assetTypes.length,
            itemBuilder: (context, index) {
              final asset = _assetTypes[index];
              return GestureDetector(
                onTap: () {
                  BlocProvider.of<SelectAssetBloc>(context)
                      .add(AssetSelected(asset.title ?? '', asset.sId ?? ''));
                  widget.onSelect(asset.sId ?? ''); // Modify if you want to pass assetId here as well
                },
                // onTap: () {
                //   BlocProvider.of<SelectAssetBloc>(context)
                //       .add(AssetSelected(asset.title?.toLowerCase() ?? ''));
                //   widget.onSelect(asset.title ?? '');
                // },
                child: Container(
                  margin: const EdgeInsets.only(right: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: state is SelectAssetSelectionSuccess &&
                          state.assetTitle == asset.title
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: asset.thumbnail != null
                            ? Image.network(
                          asset.thumbnail!.path ?? '',
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        )
                            : Icon(Icons.image, size: 100),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          asset.title ?? '',
                          style: textTheme.bodySmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: state is SelectAssetSelectionSuccess &&
                                state.assetTitle == asset.title
                                ? Theme.of(context).primaryColor
                                : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsedContent(BuildContext context, SelectAssetState state) {
    final textTheme = Theme.of(context).textTheme;
    String selectedAsset = '';
    String selectedAssetId = '';
    String selectedAssetTitle = '';

    if (state is SelectAssetSelectionSuccess) {
      selectedAsset = state.assetTitle;
      selectedAssetId = state.assetId;
      selectedAssetTitle = state.assetTitle;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Workspace Type',
          style: textTheme.bodyMedium,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              selectedAsset.isEmpty ? '' : selectedAssetTitle,
              style: textTheme.bodyMedium,
            ),
            // if (selectedAssetId.isNotEmpty)
            //   Text(
            //     '$selectedAssetTitle',
            //     style: textTheme.bodySmall,
            //   ),
          ],
        ),
      ],
    );
  /*  String selectedAsset = '';

    if (state is SelectAssetSelectionSuccess) {
      selectedAsset = state.asset;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Workspace Type', // Display the selected asset type
          style: textTheme.bodyMedium,
        ),
        Text(
          selectedAsset.isEmpty ? '' : selectedAsset, // Display the selected asset type
          style: textTheme.bodyMedium,
        ),
      ],
    );*/
  }
}


/*
class SelectAssetWidget extends StatefulWidget {
  final BookingStep step;
  final Function(String) onSelect;

  const SelectAssetWidget({
    Key? key,
    required this.step,
    required this.onSelect,
  }) : super(key: key);

  @override
  _SelectAssetWidgetState createState() => _SelectAssetWidgetState();
}

class _SelectAssetWidgetState extends State<SelectAssetWidget> {
  late TextEditingController _assetTextController;
  String? _selectedDropdownValue;

  @override
  void initState() {
    super.initState();
    _assetTextController = TextEditingController();
  }

  @override
  void dispose() {
    _assetTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SelectAssetBloc(),
      child: BlocBuilder<SelectAssetBloc, SelectAssetState>(
        builder: (context, state) {
          if (state is SelectAssetSelectionSuccess) {
            if (_assetTextController.text != state.asset) {
              _assetTextController.text = state.asset;
              _selectedDropdownValue = state.asset;
              _assetTextController.selection = TextSelection.fromPosition(
                TextPosition(offset: _assetTextController.text.length),
              );
            }
          }

          return Card(
            elevation: 0.0,
            clipBehavior: Clip.antiAlias,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: widget.step == BookingStep.selectGuests ? 300 : 60,
              padding: const EdgeInsets.all(16.0),
              child: widget.step == BookingStep.selectGuests
                  ? _buildExpandedContent(context, state)
                  : _buildCollapsedContent(context, state),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context, SelectAssetState state) {
    final textTheme = Theme.of(context).textTheme;
    final List<String> assetTypes = [

      "desk",
      "meeting room",
      "conference room",
      "cabin",

    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type of Workspace?',
          style: textTheme.headlineSmall!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16.0),
        // TypeAheadField<String>(
        //   suggestionsCallback: (pattern) async {
        //     if (pattern.isEmpty) {
        //       return [];
        //     }
        //     return assetTypes
        //         .where((type) => type.toLowerCase().contains(pattern.toLowerCase()))
        //         .toList();
        //   },
        //   itemBuilder: (context, String suggestion) {
        //     return ListTile(
        //       title: Text(suggestion),
        //     );
        //   },
        //   onSuggestionSelected: (String suggestion) {
        //     BlocProvider.of<SelectAssetBloc>(context)
        //         .add(AssetSelected(suggestion.toLowerCase()));
        //     widget.onSelect(suggestion);
        //   },
        //   debounceDuration: const Duration(milliseconds: 300),
        //   textFieldConfiguration: TextFieldConfiguration(
        //     controller: _assetTextController,
        //     decoration: InputDecoration(
        //       contentPadding: const EdgeInsets.all(16.0),
        //       hintText: 'Search workspace',
        //       prefixIcon: const Icon(Icons.search),
        //       hintStyle: textTheme.labelMedium,
        //       border: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(16.0),
        //       ),
        //     ),
        //     onChanged: (value) {
        //       BlocProvider.of<SelectAssetBloc>(context)
        //           .add(AssetSelected(value.toLowerCase()));
        //     },
        //     onSubmitted: (value) {
        //       if (value.isNotEmpty) {
        //         BlocProvider.of<SelectAssetBloc>(context)
        //             .add(AssetSelected(value.toLowerCase()));
        //         widget.onSelect(value);
        //       }
        //     },
        //   ),
        // ),
        // const SizedBox(height: 16.0),
        DropdownButtonFormField<String>(
          value: _selectedDropdownValue,
          items: assetTypes.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedDropdownValue = newValue;
              _assetTextController.text = newValue ?? '';
            });
            if (newValue != null) {
              BlocProvider.of<SelectAssetBloc>(context)
                  .add(AssetSelected(newValue.toLowerCase()));
              widget.onSelect(newValue);
            }
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(16.0),
            hintText: 'Select workspace type',
           // prefixIcon: const Icon(Icons.arrow_drop_down),
            hintStyle: textTheme.labelMedium,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
        ),
        const SizedBox(height: 16.0),
        SizedBox(
          height: 128,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            scrollDirection: Axis.horizontal,
            itemCount: assetTypes.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  BlocProvider.of<SelectAssetBloc>(context)
                      .add(AssetSelected(assetTypes[index]));
                  widget.onSelect(assetTypes[index]);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: state is SelectAssetSelectionSuccess &&
                          state.asset == assetTypes[index]
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Image.asset(
                          'assets/images/im3.jpg',
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          assetTypes[index],
                          style: textTheme.bodySmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: state is SelectAssetSelectionSuccess &&
                                state.asset == assetTypes[index]
                                ? Theme.of(context).primaryColor
                                : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsedContent(BuildContext context, SelectAssetState state) {
    final textTheme = Theme.of(context).textTheme;
    String selectedAsset = '';

    if (state is SelectAssetSelectionSuccess) {
      selectedAsset = state.asset;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Workspce Type', // Display the selected asset type
          style: textTheme.bodyMedium,
        ),
        Text(
          selectedAsset.isEmpty ? '' : selectedAsset, // Display the selected asset type
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }
}
*/



















