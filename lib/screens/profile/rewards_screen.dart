import 'package:flutter/material.dart';
import '../../core/theme.dart';

class RewardsScreen extends StatelessWidget {
  final int points;
  const RewardsScreen({super.key, required this.points});

  final _rewards = const [
    {
      'name': 'Eco Bag',
      'points': 100,
      'icon': '👜',
      'desc': 'Reusable shopping bag',
    },
    {
      'name': 'Water Bottle',
      'points': 150,
      'icon': '🍶',
      'desc': 'Stainless steel bottle',
    },
    {
      'name': 'Tree Seedling',
      'points': 200,
      'icon': '🌱',
      'desc': 'Plant a tree in your area',
    },
    {
      'name': 'Certificate',
      'points': 300,
      'icon': '📜',
      'desc': 'Eco Warrior certificate',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.shade100),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: Color(0xFF1A3A1A),
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Points & Rewards',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A3A1A),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Points banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryDark, AppTheme.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Points',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$points',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          'pts',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.stars_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // How to earn
            const Text(
              'How to Earn Points',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A3A1A),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: Column(
                children: [
                  _EarnRow(
                    icon: '📸',
                    label: 'Submit a report',
                    points: '+10 pts',
                  ),
                  Divider(height: 1, indent: 56, color: Colors.green.shade50),
                  _EarnRow(
                    icon: '✅',
                    label: 'Report gets resolved',
                    points: '+20 pts',
                  ),
                  Divider(height: 1, indent: 56, color: Colors.green.shade50),
                  _EarnRow(
                    icon: '🧹',
                    label: 'Join community cleanup',
                    points: '+30 pts',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Rewards
            const Text(
              'Redeem Rewards',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A3A1A),
              ),
            ),
            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: _rewards.length,
              itemBuilder: (_, i) {
                final r = _rewards[i];
                final canRedeem = points >= (r['points'] as int);
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: canRedeem
                          ? Colors.green.shade200
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r['icon'] as String,
                        style: const TextStyle(fontSize: 32),
                      ),
                      const Spacer(),
                      Text(
                        r['name'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A3A1A),
                        ),
                      ),
                      Text(
                        r['desc'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: canRedeem
                              ? AppTheme.primaryLight
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          '${r['points']} pts',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: canRedeem
                                ? AppTheme.primary
                                : Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _EarnRow extends StatelessWidget {
  final String icon;
  final String label;
  final String points;

  const _EarnRow({
    required this.icon,
    required this.label,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A3A1A),
              ),
            ),
          ),
          Text(
            points,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
