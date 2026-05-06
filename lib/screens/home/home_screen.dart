import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme.dart';
import '../../models/report_model.dart';
import '../../services/report_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/status_badge.dart';
import '../report/report_step1_screen.dart';
import '../profile/profile_screen.dart';
import '../notifications/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;
  final _reportService = ReportService();
  final _mapController = MapController();

  // Fallback: Mabini, Central Visayas
  LatLng _userLocation = const LatLng(9.8483, 124.0532);
  bool _locationLoaded = false;

  @override
  void initState() {
    super.initState();
    NotificationService.listenToReportChanges();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;
      setState(() {
        _userLocation = LatLng(pos.latitude, pos.longitude);
        _locationLoaded = true;
      });

      // Move map to user's location
      _mapController.move(_userLocation, 15);
    } catch (_) {
      // Falls back to default silently
    }
  }

  Color _pinColor(String status) {
    switch (status) {
      case 'in_progress':
        return const Color(0xFFfb8c00);
      case 'resolved':
        return const Color(0xFF2e7d32);
      default:
        return const Color(0xFFe53935);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: IndexedStack(
        index: _currentTab,
        children: [
          _MapTab(
            reportService: _reportService,
            mapController: _mapController,
            defaultCenter: _userLocation,
            userLocation: _userLocation,
            locationLoaded: _locationLoaded,
            pinColor: _pinColor,
          ),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentTab,
        onTap: (i) => setState(() => _currentTab = i),
        onFabTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReportStep1Screen()),
        ),
      ),
    );
  }
}

class _MapTab extends StatelessWidget {
  final ReportService reportService;
  final MapController mapController;
  final LatLng defaultCenter;
  final LatLng userLocation;
  final bool locationLoaded;
  final Color Function(String) pinColor;

  const _MapTab({
    required this.reportService,
    required this.mapController,
    required this.defaultCenter,
    required this.userLocation,
    required this.locationLoaded,
    required this.pinColor,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      children: [
        // Header
        Container(
          color: Colors.white,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            left: 20,
            right: 20,
            bottom: 12,
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
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Image.asset(
                    'assets/images/waste_watch_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Waste Watcher',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A3A1A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Hello, ${user?.displayName?.split(' ').first ?? 'there'}!',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B8F6B),
                      ),
                    ),
                  ],
                ),
              ),
              StreamBuilder<int>(
                stream: NotificationService.getUnreadCount(),
                builder: (context, snapshot) {
                  final unreadCount = snapshot.data ?? 0;
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationsScreen(),
                          ),
                        ),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.green.shade100),
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: Color(0xFF1A3A1A),
                            size: 20,
                          ),
                        ),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                unreadCount > 9 ? '9+' : unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),

        // Map
        Expanded(
          child: StreamBuilder<List<ReportModel>>(
            stream: reportService.getAllReports(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Unable to load map reports\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }

              final reports = snapshot.data ?? [];

              return Stack(
                children: [
                  FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: defaultCenter,
                      initialZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.wastewatcher.app',
                      ),

                      // Waste report pins
                      MarkerLayer(
                        markers: reports
                            .map(
                              (r) => Marker(
                                point: LatLng(r.latitude, r.longitude),
                                width: 36,
                                height: 36,
                                child: GestureDetector(
                                  onTap: () => _showReportCard(context, r),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: pinColor(r.status),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),

                      // User location blue dot
                      if (locationLoaded)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: userLocation,
                              width: 48,
                              height: 48,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade600,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.4),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.person_pin_circle_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),

                  // Legend
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _LegendDot(
                            color: const Color(0xFFe53935),
                            label: 'Pending',
                          ),
                          const SizedBox(height: 6),
                          _LegendDot(
                            color: const Color(0xFFfb8c00),
                            label: 'In Progress',
                          ),
                          const SizedBox(height: 6),
                          _LegendDot(
                            color: const Color(0xFF2e7d32),
                            label: 'Resolved',
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Report count chip
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.green.shade100),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppTheme.primary,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${reports.length} reports',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A3A1A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // My location button
                  Positioned(
                    bottom: 80,
                    right: 12,
                    child: GestureDetector(
                      onTap: () => mapController.move(userLocation, 15),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.my_location_rounded,
                          color: Colors.blue.shade600,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  void _showReportCard(BuildContext context, ReportModel report) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (report.photoUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  report.photoUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${report.wasteType[0].toUpperCase()}${report.wasteType.substring(1)} Waste',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A3A1A),
                    ),
                  ),
                ),
                StatusBadge(status: report.status),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Color(0xFF6B8F6B),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    report.address,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B8F6B),
                    ),
                  ),
                ),
              ],
            ),
            if (report.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                report.description,
                style: const TextStyle(fontSize: 13, color: Color(0xFF4A6A4A)),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF4A6A4A)),
        ),
      ],
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onFabTap;

  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.onFabTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.green.shade100)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.map_outlined,
                activeIcon: Icons.map_rounded,
                label: 'Map',
                active: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: onFabTap,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profile',
                active: currentIndex == 1,
                onTap: () => onTap(1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              active ? activeIcon : icon,
              color: active ? AppTheme.primary : Colors.grey.shade400,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? AppTheme.primary : Colors.grey.shade400,
              ),
            ),
            if (active)
              Container(
                margin: const EdgeInsets.only(top: 3),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
