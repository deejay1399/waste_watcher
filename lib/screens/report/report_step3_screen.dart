import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/cloudinary_service.dart';
import '../../services/report_service.dart';
import '../../widgets/custom_button.dart';
import 'report_widgets.dart';
import 'report_success_screen.dart';

class ReportStep3Screen extends StatefulWidget {
  final File photo;
  final String wasteType;
  final String description;
  final double latitude;
  final double longitude;
  final String address;

  const ReportStep3Screen({
    super.key,
    required this.photo,
    required this.wasteType,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  @override
  State<ReportStep3Screen> createState() => _ReportStep3ScreenState();
}

class _ReportStep3ScreenState extends State<ReportStep3Screen> {
  bool _submitting = false;
  String _statusText = '';

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _statusText = 'Uploading photo...';
    });

    final photoUrl = await CloudinaryService.uploadImage(widget.photo);

    if (photoUrl == null) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo upload failed. Check your Cloudinary config.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _statusText = 'Saving report...');

    final id = await ReportService().submitReport(
      photoUrl: photoUrl,
      wasteType: widget.wasteType,
      description: widget.description,
      latitude: widget.latitude,
      longitude: widget.longitude,
      address: widget.address,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (id != null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ReportSuccessScreen()),
        (route) => route.isFirst,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save report. Try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
          const ReportStepper(current: 2),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Review & Submit',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A3A1A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Double-check before submitting',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 20),

                  // Photo preview
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      widget.photo,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Details card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green.shade100),
                    ),
                    child: Column(
                      children: [
                        _ReviewRow(
                          icon: Icons.delete_outline_rounded,
                          label: 'Waste type',
                          value:
                              '${widget.wasteType[0].toUpperCase()}${widget.wasteType.substring(1)}',
                        ),
                        const Divider(height: 20),
                        _ReviewRow(
                          icon: Icons.location_on_outlined,
                          label: 'Location',
                          value: widget.address.isEmpty
                              ? 'Location unavailable'
                              : widget.address,
                        ),
                        if (widget.description.isNotEmpty) ...[
                          const Divider(height: 20),
                          _ReviewRow(
                            icon: Icons.notes_rounded,
                            label: 'Description',
                            value: widget.description,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Points info
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.stars_rounded,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'You will earn +10 points for this report!',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_submitting) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.green.shade100),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _statusText,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              0,
              20,
              32 + MediaQuery.of(context).padding.bottom,
            ),
            child: CustomButton(
              label: 'Submit Report',
              loading: _submitting,
              onTap: _submit,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ReviewRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A3A1A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
