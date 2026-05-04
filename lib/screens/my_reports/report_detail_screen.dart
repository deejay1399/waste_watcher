import 'package:flutter/material.dart';
import '../../models/report_model.dart';

class ReportDetailScreen extends StatelessWidget {
  final ReportModel report;
  const ReportDetailScreen({super.key, required this.report});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Detail — coming next!')));
}
