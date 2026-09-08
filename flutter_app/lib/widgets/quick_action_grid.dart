import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({super.key});

  final List<_QuickAction> _actions = const [
    _QuickAction(
      icon: Icons.quiz_rounded,
      label: 'Practice Test',
      color: Color(0xFF4CAF50),
      route: '/quiz',
    ),
    _QuickAction(
      icon: Icons.history_edu_rounded,
      label: 'PYQs',
      color: Color(0xFF2196F3),
      route: '/exam-prep',
    ),
    _QuickAction(
      icon: Icons.auto_awesome_rounded,
      label: 'Smart Revision',
      color: Color(0xFF9C27B0),
      route: '/quiz',
    ),
    _QuickAction(
      icon: Icons.forum_rounded,
      label: 'Doubts',
      color: Color(0xFFFF9800),
      route: '/forum',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      childAspectRatio: 0.92,
      children: List.generate(_actions.length, (index) {
        final action = _actions[index];
        return InkWell(
          onTap: () => Navigator.pushNamed(context, action.route),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(action.icon, color: action.color, size: 26),
              ),
              const SizedBox(height: 8),
              Text(
                action.label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final String route;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });
}
