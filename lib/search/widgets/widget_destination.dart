import 'dart:convert';

import 'package:hb_booking_mobile_app/search/destination/bloc_destination.dart';
import 'package:hb_booking_mobile_app/search/destination/event_destination.dart';
import 'package:hb_booking_mobile_app/search/model/model_locaton.dart';
import 'package:hb_booking_mobile_app/utils/base_url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import '../../booking_steps.dart';
import '../destination/state_destination.dart';
import '../state_search.dart';

class SelectDestinationWidget extends StatefulWidget {
  final BookingStep step;
  final Function(String) onSelect;

  const SelectDestinationWidget({
    Key? key,
    required this.step,
    required this.onSelect,
  }) : super(key: key);

  @override
  _SelectDestinationWidgetState createState() => _SelectDestinationWidgetState();
}

class _SelectDestinationWidgetState extends State<SelectDestinationWidget> {
  late TextEditingController _destinationTextController;

  List<String> locations = [];
  List<BranchLocationData> _locationData = [];

  @override
  void initState() {
    super.initState();
    _destinationTextController = TextEditingController();
    fetchBranchLocations();
  }

  @override
  void dispose() {
    _destinationTextController.dispose();
    super.dispose();
  }

  // Fetch locations from the API
  Future<void> fetchBranchLocations() async {
    final response = await http.get(Uri.parse('${base_url}branch/getBranches'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List branches = data['data'];
      final locationModel = BranchLocationModel.fromJson(json.decode(response.body));
      setState(() {
        _locationData = locationModel.data ?? [];
      });
      setState(() {
        locations = branches.map((branch) => branch['name'].toString()).toList();
      });
    } else {
      // Handle error
      print("Failed to load locations");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DestinationBloc(),
      child: BlocBuilder<DestinationBloc, DestinationState>(
        builder: (context, state) {
          if (state is DestinationSelectionSuccess) {
            if (_destinationTextController.text != state.destination) {
              _destinationTextController.text = state.destination;
              // Move the cursor to the end of the text
              _destinationTextController.selection = TextSelection.fromPosition(
                TextPosition(offset: _destinationTextController.text.length),
              );
            }
          }

          return Card(
            elevation: 0.0,
            clipBehavior: Clip.antiAlias,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: widget.step == BookingStep.selectDestination ? 280 : 60,
              padding: const EdgeInsets.all(16.0),
              child: widget.step == BookingStep.selectDestination
                  ? _buildExpandedContent(context, state)
                  : _buildCollapsedContent(context, state),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context, DestinationState state) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Workspace location?',
          style: textTheme.headlineSmall!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16.0),
        TypeAheadField<String>(
          controller: _destinationTextController,
          builder: (context, controller, focusNode) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(16.0),
                hintText: 'Search location',
                prefixIcon: const Icon(Icons.search),
                hintStyle: textTheme.labelMedium,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              onChanged: (value) {
                BlocProvider.of<DestinationBloc>(context)
                    .add(DestinationSelected(value.toLowerCase()));
              },
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  BlocProvider.of<DestinationBloc>(context)
                      .add(DestinationSelected(value.toLowerCase()));
                  widget.onSelect(value);
                }
              },
            );
          },
          suggestionsCallback: (pattern) async {
            if (pattern.isEmpty) {
              return [];
            }
            return locations
                .where((location) => location.toLowerCase().contains(pattern.toLowerCase()))
                .toList();
          },
          itemBuilder: (context, String suggestion) {
            return ListTile(
              title: Text(suggestion),
            );
          },
          onSelected: (String suggestion) {
            BlocProvider.of<DestinationBloc>(context)
                .add(DestinationSelected(suggestion.toLowerCase()));
            widget.onSelect(suggestion);
          },
          debounceDuration: const Duration(milliseconds: 300),
        ),
        const SizedBox(height: 16.0),
        SizedBox(
          height: 128,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            scrollDirection: Axis.horizontal,
            itemCount: _locationData.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  BlocProvider.of<DestinationBloc>(context)
                      .add(DestinationSelected(_locationData[index]!.name!));
                  widget.onSelect(_locationData[index]!.name!);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: state is DestinationSelectionSuccess &&
                          state.destination == _locationData[index]!.name!
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
                        child: _locationData[index].images != null && _locationData[index].images!.isNotEmpty
                            ? Image.network(
                          _locationData[index].images!.first.path!,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        )
                            : Icon(Icons.image_outlined,color: Colors.black, size: 100),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          _locationData[index]!.name!,
                          style: textTheme.bodySmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: state is DestinationSelectionSuccess &&
                                state.destination == _locationData[index]!.name!
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

  Widget _buildCollapsedContent(BuildContext context, DestinationState state) {
    final textTheme = Theme.of(context).textTheme;
    String selectedDestination = '';

    if (state is DestinationSelectionSuccess) {
      selectedDestination = state.destination;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Where',
          style: textTheme.bodyMedium,
        ),
        Text(
          selectedDestination.isEmpty ? '' : selectedDestination,
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }
}



// import 'dart:convert';
//
// import 'package:hb_booking_mobile_app/search/destination/bloc_destination.dart';
// import 'package:hb_booking_mobile_app/search/destination/event_destination.dart';
// import 'package:hb_booking_mobile_app/search/model/model_locaton.dart';
// import 'package:hb_booking_mobile_app/utils/base_url.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:http/http.dart' as http;
// import '../../booking_steps.dart';
// import '../destination/state_destination.dart';
// import '../state_search.dart';
//
//
// class SelectDestinationWidget extends StatefulWidget {
//   final BookingStep step;
//   final Function(String) onSelect;
//
//   const SelectDestinationWidget({
//     Key? key,
//     required this.step,
//     required this.onSelect,
//   }) : super(key: key);
//
//   @override
//   _SelectDestinationWidgetState createState() => _SelectDestinationWidgetState();
// }
//
// class _SelectDestinationWidgetState extends State<SelectDestinationWidget> {
//   late TextEditingController _destinationTextController;
//
// /*
//   @override
//   void initState() {
//     super.initState();
//     _destinationTextController = TextEditingController();
//   }
//
//   @override
//   void dispose() {
//     _destinationTextController.dispose();
//     super.dispose();
//   }
// */
//   List<String> locations = [];
//   List<BranchLocationData> _locationData = [];
//   @override
//   void initState() {
//     super.initState();
//     _destinationTextController = TextEditingController();
//     fetchBranchLocations();
//   }
//
//   @override
//   void dispose() {
//     _destinationTextController.dispose();
//     super.dispose();
//   }
//
//   // Fetch locations from the API
//   Future<void> fetchBranchLocations() async {
//     final response = await http.get(Uri.parse('${base_url}branch/getBranches'));
//
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       final List branches = data['data'];
//       final locationModel = BranchLocationModel.fromJson(json.decode(response.body));
//       setState(() {
//         _locationData = locationModel.data ?? [];
//       });
//       setState(() {
//         locations = branches.map((branch) => branch['name'].toString()).toList();
//       });
//     } else {
//       // Handle error
//       print("Failed to load locations");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => DestinationBloc(),
//       child: BlocBuilder<DestinationBloc, DestinationState>(
//         builder: (context, state) {
//           if (state is DestinationSelectionSuccess) {
//             if (_destinationTextController.text != state.destination) {
//               _destinationTextController.text = state.destination;
//               // Move the cursor to the end of the text
//               _destinationTextController.selection = TextSelection.fromPosition(
//                 TextPosition(offset: _destinationTextController.text.length),
//               );
//             }
//           }
//
//           return Card(
//             elevation: 0.0,
//             clipBehavior: Clip.antiAlias,
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 300),
//               height: widget.step == BookingStep.selectDestination ? 280 : 60,
//               padding: const EdgeInsets.all(16.0),
//               child: widget.step == BookingStep.selectDestination
//                   ? _buildExpandedContent(context, state)
//                   : _buildCollapsedContent(context, state),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildExpandedContent(BuildContext context, DestinationState state) {
//     final textTheme = Theme.of(context).textTheme;
//
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Workspace location?',
//           style: textTheme.headlineSmall!.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 16.0),
//         TypeAheadField<String>(
//           suggestionsCallback: (pattern) async {
//             if (pattern.isEmpty) {
//               return [];
//             }
//             return locations
//                 .where((location) => location.toLowerCase().contains(pattern.toLowerCase()))
//                 .toList();
//           },
//           itemBuilder: (context, String suggestion) {
//             return ListTile(
//               title: Text(suggestion),
//             );
//           },
//           onSuggestionSelected: (String suggestion) {
//             BlocProvider.of<DestinationBloc>(context)
//                 .add(DestinationSelected(suggestion.toLowerCase()));
//             widget.onSelect(suggestion);
//           },
//           debounceDuration: const Duration(milliseconds: 300),
//           textFieldConfiguration: TextFieldConfiguration(
//             controller: _destinationTextController,
//             decoration: InputDecoration(
//               contentPadding: const EdgeInsets.all(16.0),
//               hintText: 'Search location',
//               prefixIcon: const Icon(Icons.search),
//               hintStyle: textTheme.labelMedium,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(16.0),
//               ),
//             ),
//             onChanged: (value) {
//               BlocProvider.of<DestinationBloc>(context)
//                   .add(DestinationSelected(value.toLowerCase()));
//             },
//             onSubmitted: (value) {
//               if (value.isNotEmpty) {
//                 BlocProvider.of<DestinationBloc>(context)
//                     .add(DestinationSelected(value.toLowerCase()));
//                 widget.onSelect(value);
//               }
//             },
//           ),
//         ),
//         const SizedBox(height: 16.0),
//         SizedBox(
//           height: 128,
//           child: ListView.builder(
//             padding: EdgeInsets.zero,
//             scrollDirection: Axis.horizontal,
//             itemCount: _locationData.length,
//             itemBuilder: (context, index) {
//               return GestureDetector(
//                 onTap: () {
//                   BlocProvider.of<DestinationBloc>(context)
//                       .add(DestinationSelected(_locationData[index]!.name!));
//                   widget.onSelect(_locationData[index]!.name!);
//                 },
//                 child: Container(
//                   margin: const EdgeInsets.only(right: 8.0),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(16.0),
//                     border: Border.all(
//                       color: state is DestinationSelectionSuccess &&
//                           state.destination == _locationData[index]!.name!
//                           ? Theme.of(context).primaryColor
//                           : Colors.transparent,
//                       width: 2,
//                     ),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // ClipRRect(
//                       //   borderRadius: BorderRadius.circular(16.0),
//                       //   child: Image.asset(
//                       //     'assets/images/im2.jpeg',
//                       //     height: 100,
//                       //     width: 100,
//                       //     fit: BoxFit.cover,
//                       //   ),
//                       // ),
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(16.0),
//                         child: _locationData[index].images != null && _locationData[index].images!.isNotEmpty
//                             ? Image.network(
//                           _locationData[index].images!.first.path!,
//                           height: 100,
//                           width: 100,
//                           fit: BoxFit.cover,
//                         )
//                             : Icon(Icons.image_outlined,color: Colors.black, size: 100),
//                 ),
//
//                       const SizedBox(height: 8),
//                       Padding(
//                         padding: const EdgeInsets.only(left: 8.0),
//                         child: Text(
//                           _locationData[index]!.name!,
//                           style: textTheme.bodySmall!.copyWith(
//                             fontWeight: FontWeight.bold,
//                             color: state is DestinationSelectionSuccess &&
//                                 state.destination == locations[index]
//                                 ? Theme.of(context).primaryColor
//                                 : Colors.black,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildCollapsedContent(BuildContext context, DestinationState state) {
//     final textTheme = Theme.of(context).textTheme;
//     String selectedDestination = '';
//
//     if (state is DestinationSelectionSuccess) {
//       selectedDestination = state.destination;
//     }
//
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           'Where', // Display the selected destination
//           style: textTheme.bodyMedium,
//         ),
//         Text(
//           selectedDestination.isEmpty ? '' : selectedDestination, // Display the selected destination
//           style: textTheme.bodyMedium,
//         ),
//       ],
//     );
//   }
// }
//
//
//
//
//
//
//
