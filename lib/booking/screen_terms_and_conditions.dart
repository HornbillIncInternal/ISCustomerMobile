import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hb_booking_mobile_app/utils/is_loader.dart';
class TermsAndConditionsPage extends StatefulWidget {
  const TermsAndConditionsPage({Key? key}) : super(key: key);

  @override
  State<TermsAndConditionsPage> createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  String _termsAndConditionsText = 'Loading...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTermsAndConditions();
  }

  Future<void> _loadTermsAndConditions() async {
    try {
      // Load the terms and conditions file from the assets
      final String text = await rootBundle.loadString('assets/termsandconditions.txt');
      setState(() {
        _termsAndConditionsText = text;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _termsAndConditionsText = 'Failed to load terms and conditions: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms and Conditions'),
      ),
      body: _isLoading
          ? const Center(child: OfficeLoader())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(_termsAndConditionsText),
        ),
      ),
    );
  }
}