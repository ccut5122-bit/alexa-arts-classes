import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/gamification_provider.dart';
import '../../providers/auth_provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _loadPeriod(_tabController.index);
      }
    });
    _loadPeriod(0);
  }

  void _loadPeriod(int index) {
    final period = index == 0 ? 'allTime' : (index == 1 ? 'weekly' : 'monthly');
    context.read<GamificationProvider>().loadLeaderboard(period: period);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gam = context.watch<GamificationProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Time'),
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Top 3 podium
          _buildPodium(gam.leaderboard.take(3).toList()),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 32),
              itemCount: gam.leaderboard.length,
              itemBuilder: (context, index) {
                if (index < 3) return const SizedBox.shrink();
                final entry = gam.leaderboard[index];
                final isMe = auth.user != null && entry['id'] == auth.user!.uid;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: entry['photoUrl']?.isNotEmpty == true
                        ? CachedNetworkImageProvider(entry['photoUrl'])
                        : null,
                    child: entry['photoUrl']?.isEmpty != false
                        ? Text('${index + 1}')
                        : null,
                  ),
                  title: Row(
                    children: [
                      Text(
                        entry['displayName'] ?? 'Student',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'YOU',
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(
                    'Level ${entry['level'] ?? 1}',
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.monetization_on_rounded,
                          color: Color(0xFFFFA000)),
                      const SizedBox(width: 4),
                      Text(
                        '${entry['coins'] ?? 0}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(List<Map<String, dynamic>> top3) {
    final colors = [Colors.amber, Colors.grey, Colors.brown.shade300];
    final heights = [150.0, 110.0, 80.0];
    final orders = [1, 0, 2]; // 2nd, 1st, 3rd

    if (top3.isEmpty) {
      return const SizedBox(height: 200);
    }

    return SizedBox(
      height: 240,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(3, (i) {
          final idx = orders[i];
          if (idx >= top3.length) return const Expanded(child: SizedBox.shrink());

          final entry = top3[idx];
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: i == 1 ? 30 : 24,
                  backgroundColor: colors[idx].withOpacity(0.2),
                  backgroundImage: entry['photoUrl']?.isNotEmpty == true
                      ? CachedNetworkImageProvider(entry['photoUrl'])
                      : null,
                  child: entry['photoUrl']?.isEmpty != false
                      ? Text(
                          '${idx + 1}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            color: colors[idx],
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 8),
                Text(
                  entry['displayName'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${entry['coins'] ?? 0} coins',
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: heights[idx],
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors[idx],
                        colors[idx].withOpacity(0.8),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${idx + 1}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: colors[idx],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
