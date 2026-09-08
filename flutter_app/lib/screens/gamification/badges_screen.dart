import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/gamification_provider.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GamificationProvider>().loadBadges();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gam = context.watch<GamificationProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Badges')),
      body: gam.badges.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No badges yet',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete quizzes to earn badges!',
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: gam.badges.length,
              itemBuilder: (context, index) {
                final badge = gam.badges[index];
                final isEarned = gam.userBadges.contains(badge.id);

                return _BadgeCard(badge: badge, isEarned: isEarned);
              },
            ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final dynamic badge;
  final bool isEarned;

  const _BadgeCard({required this.badge, required this.isEarned});

  @override
  Widget build(BuildContext context) {
    final name = badge.name ?? '';
    final description = badge.description ?? '';
    final iconUrl = badge.iconUrl ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEarned
              ? Colors.amber.withOpacity(0.5)
              : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: isEarned ? 1 : 0.3,
            child: CircleAvatar(
              radius: 36,
              backgroundColor: isEarned
                  ? Colors.amber.withOpacity(0.2)
                  : Colors.grey.shade100,
              child: iconUrl.isNotEmpty
                  ? Image.network(iconUrl, width: 50, height: 50)
                  : Icon(
                      Icons.emoji_events_rounded,
                      size: 36,
                      color: isEarned ? Colors.amber : Colors.grey,
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
