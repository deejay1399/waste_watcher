import 'package:flutter/material.dart';
import '../../core/theme.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  final _faqs = const [
    {
      'question': 'How do I report waste?',
      'answer':
          'Tap the + button on the home screen, take a photo of the waste, select the waste type, and provide a description. GPS location will be automatically recorded.',
    },
    {
      'question': 'How do I earn points?',
      'answer':
          'You earn points for each report you submit. When your report is resolved by a cleanup team, you get bonus points. Redeem your points for eco-friendly rewards!',
    },
    {
      'question': 'How do I track my reports?',
      'answer':
          'Go to Profile → My Reports to see all your submitted reports. You can filter by status: Pending, In Progress, or Resolved.',
    },
    {
      'question': 'What waste types can I report?',
      'answer':
          'You can report plastic waste, metal waste, organic waste, hazardous materials, construction debris, and mixed waste.',
    },
    {
      'question': 'Will I get notified about my reports?',
      'answer':
          'Yes! You\'ll receive notifications when your report status changes. Enable notifications in your phone settings to receive alerts.',
    },
    {
      'question': 'How do I redeem my points?',
      'answer':
          'Go to Profile → Points & Rewards to see available rewards. Tap on a reward to redeem it if you have enough points.',
    },
    {
      'question': 'Is my location data private?',
      'answer':
          'Your location is used only to report waste areas. It\'s only visible to cleanup teams assigned to your report.',
    },
    {
      'question': 'Can I delete a report?',
      'answer':
          'You can\'t delete reports directly, but you can contact support if the waste has already been cleaned or the report was made by mistake.',
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
          'Help Center',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A3A1A),
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _faqs.length,
        itemBuilder: (context, index) {
          final faq = _faqs[index];
          return _FAQTile(
            question: faq['question'] as String,
            answer: faq['answer'] as String,
          );
        },
      ),
    );
  }
}

class _FAQTile extends StatefulWidget {
  final String question;
  final String answer;

  const _FAQTile({required this.question, required this.answer});

  @override
  State<_FAQTile> createState() => _FAQTileState();
}

class _FAQTileState extends State<_FAQTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _expanded ? AppTheme.primary : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Icon(
              Icons.help_outline_rounded,
              color: AppTheme.primary,
              size: 20,
            ),
            title: Text(
              widget.question,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A3A1A),
              ),
            ),
            trailing: Icon(
              _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
              color: AppTheme.primary,
            ),
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          if (_expanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.answer,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
