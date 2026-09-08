import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:confetti/confetti.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/gamification_provider.dart';
import '../../providers/config_provider.dart';
import '../../models/models.dart';

class QuizScreen extends StatefulWidget {
  final String subjectId;
  final List<String> chapterIds;
  final String quizTitle;
  final int timeLimit;
  final bool negativeMarking;

  const QuizScreen({
    super.key,
    required this.subjectId,
    this.chapterIds = const [],
    this.quizTitle = 'Quiz',
    this.timeLimit = 15,
    this.negativeMarking = true,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late ConfettiController _confettiController;
  final List<String> _answers = [];

  bool get _isRevision => widget.quizTitle.contains('Revision');

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quizProv = context.read<QuizProvider>();
      if (_isRevision) {
        final auth = context.read<AuthProvider>();
        if (auth.user != null) {
          quizProv.startRevisionQuiz(auth.user!.uid);
        }
      } else {
        quizProv.startQuiz(
          subjectId: widget.subjectId,
          chapterIds: widget.chapterIds,
          limit: 10,
          timeMinutes: widget.timeLimit,
          negativeMarking: widget.negativeMarking,
        );
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProv, _) {
        if (!quizProv.isQuizActive && quizProv.questions.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.quizTitle)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!quizProv.isQuizActive && quizProv.questions.isNotEmpty) {
          return _ResultsScreen(
            quizProv: quizProv,
            quizTitle: widget.quizTitle,
            confettiController: _confettiController,
            onRestart: () {
              if (_isRevision) {
                final auth = context.read<AuthProvider>();
                if (auth.user != null) {
                  quizProv.startRevisionQuiz(auth.user!.uid);
                }
              } else {
                quizProv.startQuiz(
                  subjectId: widget.subjectId,
                  chapterIds: widget.chapterIds,
                  limit: 10,
                  timeMinutes: widget.timeLimit,
                  negativeMarking: widget.negativeMarking,
                );
              }
            },
            onHome: () => Navigator.popUntil(context, (route) => route.isFirst),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.quizTitle),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: quizProv.timeRemaining < 60
                          ? Colors.red
                          : Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(quizProv.timeRemaining),
                          style: GoogleFonts.robotoMono(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: _buildQuizBody(quizProv),
          bottomNavigationBar: _buildBottomBar(quizProv),
        );
      },
    );
  }

  Widget _buildQuizBody(QuizProvider quizProv) {
    final question = quizProv.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: quizProv.progress,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${quizProv.currentIndex + 1}/${quizProv.questions.length}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Question
          if (question.questionImageUrl.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                question.questionImageUrl,
                fit: BoxFit.contain,
                height: 200,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        question.source == 'JAC PYQ'
                            ? 'JAC ${question.year}'
                            : question.difficulty.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${question.marks} Mark',
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  question.questionText,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
                if (question.questionTextHindi.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    question.questionTextHindi,
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.6,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Options
          for (int i = 0; i < question.options.length; i++)
            _OptionButton(
              option: question.options[i],
              optionLabel: String.fromCharCode(65 + i),
              isSelected: quizProv.selectedAnswer == question.options[i].id,
              isCorrect: quizProv.answered && question.options[i].id == question.correctOption,
              isWrong: quizProv.answered &&
                  quizProv.selectedAnswer == question.options[i].id &&
                  quizProv.selectedAnswer != question.correctOption,
              disabled: quizProv.answered,
              onTap: () => quizProv.selectAnswer(question.options[i].id),
            ),
          const SizedBox(height: 16),

          // Explanation (shown after answering)
          if (quizProv.answered) ...[
            _ExplanationCard(
              isCorrect: quizProv.selectedAnswer == question.correctOption,
              explanation: question.explanation,
              explanationHindi: question.explanationHindi,
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar(QuizProvider quizProv) {
    final question = quizProv.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (quizProv.currentIndex > 0)
            OutlinedButton.icon(
              onPressed: quizProv.answered ? quizProv.previousQuestion : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please answer the question first')),
                );
              },
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Prev'),
            ),
          const Spacer(),
          if (!quizProv.answered)
            ElevatedButton(
              onPressed: quizProv.selectedAnswer == null
                  ? null
                  : () => quizProv.confirmAnswer(
                        negativeMarking: widget.negativeMarking,
                      ),
              child: const Text('Submit'),
            )
          else if (!quizProv.isLastQuestion)
            ElevatedButton.icon(
              onPressed: quizProv.nextQuestion,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Next'),
            )
          else
            ElevatedButton.icon(
              onPressed: () => _finishQuiz(quizProv),
              icon: const Icon(Icons.flag_rounded),
              label: const Text('Finish'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
        ],
      ),
    );
  }

  void _finishQuiz(QuizProvider quizProv) {
    final result = quizProv.finishQuiz();
    final auth = context.read<AuthProvider>();
    final gam = context.read<GamificationProvider>();
    final config = context.read<ConfigProvider>();

    if (auth.user != null) {
      quizProv.saveQuizResult(auth.user!.uid, widget.subjectId, result);

      // Award coins
      final quizCoins = config.coinForQuizAttempt;
      final correctBonus = (result['correctAnswers'] as int) * config.coinForCorrectAnswer;
      gam.earnCoins(auth.user!.uid, quizCoins + correctBonus, 'Quiz completed');
    }

    _confettiController..forward();
    setState(() {});
  }
}

class _OptionButton extends StatelessWidget {
  final OptionModel option;
  final String optionLabel;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final bool disabled;
  final VoidCallback onTap;

  const _OptionButton({
    required this.option,
    required this.optionLabel,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color bgColor;
    IconData? icon;

    if (isCorrect) {
      borderColor = Colors.green;
      bgColor = Colors.green.withOpacity(0.1);
      icon = Icons.check_circle_rounded;
    } else if (isWrong) {
      borderColor = Colors.red;
      bgColor = Colors.red.withOpacity(0.1);
      icon = Icons.cancel_rounded;
    } else if (isSelected) {
      borderColor = Theme.of(context).colorScheme.primary;
      bgColor = Theme.of(context).colorScheme.primary.withOpacity(0.08);
    } else {
      borderColor = Colors.grey.shade300;
      bgColor = Colors.transparent;
    }

    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  optionLabel,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option.text,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (icon != null) Icon(icon, color: borderColor),
          ],
        ),
      ),
    );
  }
}

class _ExplanationCard extends StatelessWidget {
  final bool isCorrect;
  final String explanation;
  final String explanationHindi;

  const _ExplanationCard({
    required this.isCorrect,
    required this.explanation,
    required this.explanationHindi,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_rounded, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'Correct! Great job!' : 'Here is the explanation:',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            explanation,
            style: GoogleFonts.poppins(
              fontSize: 13,
              height: 1.6,
              color: Colors.grey.shade800,
            ),
          ),
          if (explanationHindi.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              explanationHindi,
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 13,
                height: 1.6,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultsScreen extends StatelessWidget {
  final QuizProvider quizProv;
  final String quizTitle;
  final ConfettiController confettiController;

  final VoidCallback onRestart;
  final VoidCallback onHome;

  const _ResultsScreen({
    required this.quizProv,
    required this.quizTitle,
    required this.confettiController,
    required this.onRestart,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final totalQuestions = quizProv.questions.length;
    final correct = quizProv.correctCount;
    final wrong = totalQuestions - correct;
    final accuracy = totalQuestions > 0
        ? (correct / totalQuestions * 100).round()
        : 0;
    final isOutstanding = accuracy >= 80;

    // Save leaderboard data
    Future.microtask(() async {
      final authProv = context.read<AuthProvider>();
      final gamProv = context.read<GamificationProvider>();
      if (authProv.userModel != null && gamProv.gamification != null) {
        final user = authProv.userModel!;
        await gamProv.saveLeaderboardEntry(
          user,
          quizProv.score,
        );
      }
    });

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          if (isOutstanding)
            ConfettiWidget(
              confettiController: confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: true,
              numberOfParticles: 50,
            ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Text(
                  isOutstanding ? 'Outstanding!' : 'Quiz Complete!',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 24),
                CircularPercentIndicator(
                  radius: 90,
                  lineWidth: 16,
                  percent: accuracy / 100,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$accuracy%',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: isOutstanding ? Colors.green : Colors.orange,
                        ),
                      ),
                      Text(
                        'Accuracy',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  progressColor: isOutstanding ? Colors.green : Colors.orange,
                  backgroundColor: Colors.grey.shade200,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    _ResultStat(
                      icon: Icons.check_circle_rounded,
                      value: '$correct',
                      label: 'Correct',
                      color: Colors.green,
                    ),
                    _ResultStat(
                      icon: Icons.cancel_rounded,
                      value: '$wrong',
                      label: 'Wrong',
                      color: Colors.red,
                    ),
                    _ResultStat(
                      icon: Icons.star_rounded,
                      value: '${quizProv.score}',
                      label: 'Score',
                      color: Colors.amber,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                if (isOutstanding)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.emoji_events_rounded, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'You earned a badge!',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onHome,
                        icon: const Icon(Icons.home_rounded),
                        label: const Text('Home'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onRestart,
                        icon: const Icon(Icons.replay_rounded),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _ResultStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
