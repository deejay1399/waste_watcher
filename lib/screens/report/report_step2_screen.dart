import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../core/theme.dart';
import '../../widgets/custom_button.dart';
import 'report_widgets.dart';
import 'report_step3_screen.dart';

class ReportStep2Screen extends StatefulWidget {
  final File photo;
  const ReportStep2Screen({super.key, required this.photo});

  @override
  State<ReportStep2Screen> createState() => _ReportStep2ScreenState();
}

class _ReportStep2ScreenState extends State<ReportStep2Screen> {
  String _wasteType = 'mixed';
  final _descCtrl = TextEditingController();
  String _address = '';
  double _lat = 0;
  double _lng = 0;
  bool _loadingLocation = false;

  final _wasteTypes = [
    {'key': 'plastic', 'label': 'Plastic', 'icon': '🧴'},
    {'key': 'mixed', 'label': 'Mixed', 'icon': '🗑️'},
    {'key': 'organic', 'label': 'Organic', 'icon': '🌿'},
    {'key': 'other', 'label': 'Other', 'icon': '📦'},
  ];

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    setState(() => _loadingLocation = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _lat = pos.latitude;
      _lng = pos.longitude;

      final placemarks = await placemarkFromCoordinates(_lat, _lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        _address =
            '${p.street ?? ''}, ${p.subLocality ?? ''}, ${p.locality ?? ''}';
      }
    } catch (_) {
      _address = 'Location unavailable';
    }
    if (mounted) setState(() => _loadingLocation = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: StepAppBar(
        onBack: () => Navigator.pop(context),
        title: 'Report Waste',
      ),
      body: Column(
        children: [
          const ReportStepper(current: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A3A1A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Help us understand the problem better',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),

                  // Waste type
                  const Text(
                    'Type of waste',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A3A1A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: _wasteTypes.map((type) {
                      final isSelected = _wasteType == type['key'];
                      return Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _wasteType = type['key']!),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primary
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primary
                                    : Colors.green.shade100,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  type['icon']!,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  type['label']!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF4A7A4A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Location
                  const Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A3A1A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.green.shade100),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: AppTheme.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _loadingLocation
                              ? const Text(
                                  'Getting your location...',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF9AB89A),
                                  ),
                                )
                              : Text(
                                  _address.isEmpty
                                      ? 'Location unavailable'
                                      : _address,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF1A3A1A),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                        if (_loadingLocation)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.primary,
                            ),
                          ),
                        if (!_loadingLocation)
                          GestureDetector(
                            onTap: _getLocation,
                            child: const Icon(
                              Icons.refresh_rounded,
                              color: AppTheme.primary,
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Description (optional)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A3A1A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _descCtrl,
                    maxLines: 4,
                    maxLength: 200,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText:
                          'Describe the waste problem (e.g. size, smell, duration...)',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.green.shade100),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.green.shade100),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppTheme.primary,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: CustomButton(
              label: 'Next — Review',
              onTap: _loadingLocation
                  ? () {}
                  : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportStep3Screen(
                          photo: widget.photo,
                          wasteType: _wasteType,
                          description: _descCtrl.text.trim(),
                          latitude: _lat,
                          longitude: _lng,
                          address: _address,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
