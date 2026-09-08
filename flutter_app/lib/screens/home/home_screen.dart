import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/config_provider.dart';
import '../../providers/subject_provider.dart';
import '../../providers/gamification_provider.dart';
import '../../models/models.dart';
import '../../widgets/exam_countdown_card.dart';
import '../../widgets/notice_popup.dart';
import '../../widgets/premium_banner.dart';
import '../../widgets/streak_card.dart';
import '../../widgets/coin_balance_widget.dart';
import '../../widgets/subject_card.dart';
import '../../widgets/quick_action_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubjectProvider>().loadSubjects();
      final auth = context.read<AuthProvider>();
      if (auth.userModel != null) {
        context.read<GamificationProvider>().loadGamification(auth.userModel!);
        context.read<GamificationProvider>().updateStreak(auth.userModel!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _HomeBody(key: UniqueKey()),
          const _StudyTab(),
          const _CommunityTab(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Consumer<ConfigProvider>(
        builder: (context, config, _) {
          return BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'Study'),
              BottomNavigationBarItem(icon: Icon(Icons.forum_rounded), label: 'Forum'),
              BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
            ],
          );
        },
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverToBoxAdapter(child: _buildStreakAndCoins(context)),
          SliverToBoxAdapter(child: const NoticePopup()),
          SliverToBoxAdapter(child: _buildExamCountdown(context)),
          SliverToBoxAdapter(child: _buildBannerCarousel(context)),
          SliverToBoxAdapter(child: _buildQuickActions(context)),
          SliverToBoxAdapter(child: _buildFeaturedSubjects(context)),
          SliverToBoxAdapter(child: _buildBottomPadding()),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final config = context.watch<ConfigProvider>();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Namaste, ${auth.userModel?.displayName ?? 'Student'}!',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  config.appName,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // Notification bell
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 28),
                onPressed: () {},
              ),
              if (config.notices.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakAndCoins(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Expanded(child: StreakCard()),
          const SizedBox(width: 12),
          const Expanded(child: CoinBalanceWidget()),
        ],
      ),
    );
  }

  Widget _buildExamCountdown(BuildContext context) {
    final config = context.watch<ConfigProvider>();
    if (config.examDates.isEmpty) return const SizedBox.shrink();
    return const Padding(
      padding: EdgeInsets.only(top: 12),
      child: ExamCountdownCard(),
    );
  }

  Widget _buildBannerCarousel(BuildContext context) {
    final config = context.watch<ConfigProvider>();
    if (config.banners.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 160,
      child: PageView.builder(
        itemCount: config.banners.length,
        controller: PageController(viewportFraction: 0.9),
        itemBuilder: (context, index) {
          final banner = config.banners[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: banner['imageUrl'] ?? '',
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Center(
                    child: Icon(Icons.image,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 16),
      child: QuickActionGrid(),
    );
  }

  Widget _buildFeaturedSubjects(BuildContext context) {
    final subjectProv = context.watch<SubjectProvider>();
    final featured = subjectProv.featuredSubjects.isNotEmpty
        ? subjectProv.featuredSubjects
        : subjectProv.subjects.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subjects',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: AnimationLimiter(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: featured.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  columnCount: featured.length,
                  child: SlideAnimation(
                    horizontalOffset: 50,
                    child: FadeInAnimation(
                      child: SubjectCard(subject: featured[index]),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomPadding() => const SizedBox(height: 80);
}

class _StudyTab extends StatelessWidget {
  const _StudyTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<SubjectProvider>(
        builder: (context, subjectProv, _) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'All Subjects',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final subject = subjectProv.subjects[index];
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      child: SlideAnimation(
                        verticalOffset: 50,
                        child: FadeInAnimation(
                          child: _StudySubjectTile(subject: subject),
                        ),
                      ),
                    );
                  },
                  childCount: subjectProv.subjects.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StudySubjectTile extends StatelessWidget {
  final SubjectModel subject;
  const _StudySubjectTile({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: subject.themeColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.book_rounded, color: subject.themeColor, size: 28),
        ),
        title: Text(
          subject.name,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${subject.totalChapters} Chapters',
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: subject.themeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            subject.nameHindi,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: subject.themeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: () {
          Navigator.pushNamed(context, '/chapters', arguments: {
            'subjectId': subject.id,
            'subjectName': subject.name,
          });
        },
      ),
    );
  }
}

class _CommunityTab extends StatelessWidget {
  const _CommunityTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Community',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => Navigator.pushNamed(context, '/forum'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.forum_rounded,
                      size: 80,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'Doubts Forum',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ask questions, help peers',
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/forum'),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Open Forum'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.userModel;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundImage: user?.photoUrl.isNotEmpty == true
                  ? NetworkImage(user!.photoUrl)
                  : null,
              child: user?.photoUrl.isEmpty != false
                  ? Text(
                      (user?.displayName ?? 'S')[0].toUpperCase(),
                      style: const TextStyle(fontSize: 36),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user?.displayName ?? 'Student',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              user?.email ?? '',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            if (user?.isPremium == true)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'PREMIUM',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            const SizedBox(height: 32),
            _ProfileMenuItem(
              icon: Icons.leaderboard_rounded,
              title: 'Leaderboard',
              onTap: () => Navigator.pushNamed(context, '/leaderboard'),
            ),
            _ProfileMenuItem(
              icon: Icons.emoji_events_rounded,
              title: 'My Badges',
              onTap: () => Navigator.pushNamed(context, '/badges'),
            ),
            _ProfileMenuItem(
              icon: Icons.bookmark_rounded,
              title: 'Bookmarks',
              onTap: () => Navigator.pushNamed(context, '/bookmarks'),
            ),
            _ProfileMenuItem(
              icon: Icons.quiz_rounded,
              title: 'Quiz History',
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.date_range_rounded,
              title: 'Exam Date Sheet',
              onTap: () => Navigator.pushNamed(context, '/exam-prep'),
            ),
            _ProfileMenuItem(
              icon: Icons.translate_rounded,
              title: 'Dictionary',
              onTap: () => Navigator.pushNamed(context, '/dictionary'),
            ),
            _ProfileMenuItem(
              icon: Icons.settings_rounded,
              title: 'Settings',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => auth.signOut(),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: Text(
                  'Sign Out',
                  style: GoogleFonts.poppins(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
