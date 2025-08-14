import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/events_provider.dart';
import '../models/event.dart';
import '../l10n/app_localizations.dart';
import '../widgets/public_event_details_bottom_sheet.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventsProvider>().loadEvents(isInitialLoad: true);
      _startAutoRefresh();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // Helper function to get text color based on background
  Color _getTextColor(Event event, ThemeData theme,
      {bool isSecondary = false}) {
    return isSecondary
        ? theme.colorScheme.onSurfaceVariant
        : theme.colorScheme.onSurface;
  }

  // Helper function to get text shadow for better visibility
  List<Shadow> _getTextShadow(Event event) {
    return [];
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        context.read<EventsProvider>().refreshEvents();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SafeArea(child: Consumer<EventsProvider>(
      builder: (context, eventsProvider, child) {
        if (eventsProvider.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 3,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.loadingEvents,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        if (eventsProvider.error != null) {
          return Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.error.withOpacity(0.2),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 32,
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.errorLoadingData,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    eventsProvider.error!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => eventsProvider.refreshEvents(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l10n.retry),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final runningEvents = eventsProvider.runningEvents;
        final upcomingEvents = eventsProvider.upcomingEvents;
        final completedEvents = eventsProvider.completedEvents;

        if (runningEvents.isEmpty &&
            upcomingEvents.isEmpty &&
            completedEvents.isEmpty) {
          return Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.event_busy_rounded,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.noEventsAvailable,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.noEventsAvailableMessage,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () => eventsProvider.refreshEvents(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l10n.refresh),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: eventsProvider.refreshEvents,
          color: theme.colorScheme.primary,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (runningEvents.isNotEmpty) ...[
                _buildSectionHeader(
                  l10n.liveEvents,
                  runningEvents.length,
                  const Color(0xFF10B981),
                  Icons.play_circle_filled_rounded,
                  theme,
                ),
                const SizedBox(height: 16),
                ...runningEvents.map((event) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildEventCard(event, l10n, theme),
                    )),
                const SizedBox(height: 32),
              ],
              if (upcomingEvents.isNotEmpty) ...[
                _buildSectionHeader(
                  l10n.upcomingEvents,
                  upcomingEvents.length,
                  theme.colorScheme.primary,
                  Icons.schedule_rounded,
                  theme,
                ),
                const SizedBox(height: 16),
                ...upcomingEvents.map((event) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildEventCard(event, l10n, theme),
                    )),
                const SizedBox(height: 32),
              ],
              if (completedEvents.isNotEmpty) ...[
                _buildSectionHeader(
                  'Recent Events',
                  completedEvents.length,
                  theme.colorScheme.outline,
                  Icons.history_rounded,
                  theme,
                ),
                const SizedBox(height: 16),
                ...completedEvents.map((event) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildEventCard(event, l10n, theme),
                    )),
              ],
              const SizedBox(height: 100), // Bottom padding for navigation
            ],
          ),
        );
      },
    ));
  }

  Widget _buildSectionHeader(
    String title,
    int count,
    Color color,
    IconData icon,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: theme.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Event event, AppLocalizations l10n, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // White background for all events
            Positioned.fill(
              child: Container(
                color: Colors.white,
              ),
            ),
            // Border overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            // Content
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _showEventDetails(event, l10n),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Text(
                                event.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _getTextColor(event, theme),
                                  shadows: _getTextShadow(event),
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          _buildStatusBadge(event, l10n, theme),
                        ],
                      ),

                      // Description
                      if (event.description != null &&
                          event.description!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          event.description!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color:
                                _getTextColor(event, theme, isSecondary: true),
                            height: 1.4,
                            shadows: _getTextShadow(event),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Live Event Content
                      if (event.isRunning || event.isPaused) ...[
                        if (event.currentLevel != null) ...[
                          _buildLiveCountdown(event, l10n, theme),
                          const SizedBox(height: 16),
                        ],
                        _buildEventStats(event, l10n, theme),
                      ] else if (event.isUpcoming) ...[
                        _buildUpcomingInfo(event, l10n, theme),
                      ],

                      // App Info Section
                      if (event.appBuyIn != null ||
                          event.appPrizes.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildAppInfo(event, l10n, theme),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(
      Event event, AppLocalizations l10n, ThemeData theme) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (event.isRunning) {
      statusColor = const Color(0xFF10B981);
      statusText = l10n.live;
      statusIcon = Icons.radio_button_checked;
    } else if (event.isPaused) {
      statusColor = const Color(0xFFF59E0B);
      statusText = l10n.paused;
      statusIcon = Icons.pause_circle_filled;
    } else if (event.isCompleted) {
      statusColor = theme.colorScheme.outline;
      statusText = 'Completed';
      statusIcon = Icons.check_circle_rounded;
    } else if (event.isUpcoming) {
      statusColor = theme.colorScheme.primary;
      statusText = l10n.pending;
      statusIcon = Icons.schedule;
    } else {
      statusColor = theme.colorScheme.outline;
      statusText = 'Unknown';
      statusIcon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 14,
            color: statusColor,
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: theme.textTheme.labelSmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveCountdown(
      Event event, AppLocalizations l10n, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer.withOpacity(0.3),
            theme.colorScheme.primaryContainer.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              event.currentLevel!.isBreak
                  ? Icon(
                      Icons.coffee_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    )
                  : Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${event.currentLevel!.levelNumber ?? 0}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
              const SizedBox(width: 8),
              Text(
                event.currentLevel!.isBreak
                    ? l10n.breakTime
                    : l10n.currentLevel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: _getTextColor(event, theme),
                  fontWeight: FontWeight.w600,
                  shadows: _getTextShadow(event),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            event.currentLevel!.blindsText,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: _getTextColor(event, theme),
              shadows: _getTextShadow(event),
            ),
          ),
          // Break description (if available)
          if (event.currentLevel!.isBreak &&
              event.currentLevel!.description != null &&
              event.currentLevel!.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              event.currentLevel!.description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _getTextColor(event, theme, isSecondary: true),
                shadows: _getTextShadow(event),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 8),
          LevelCountdownWidget(
            levelRemaining: event.levelRemainingDuration,
            levelText: event.currentLevel!.blindsText,
            isBreak: event.currentLevel!.isBreak,
            onCountdownComplete: () {
              // Refresh events when countdown hits zero
              context.read<EventsProvider>().refreshEvents();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEventStats(Event event, AppLocalizations l10n, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              Icons.people_rounded,
              l10n.players,
              '${event.activePlayersCount}/${event.playersCount}',
              event,
              theme,
            ),
          ),
          if (event.nextLevel != null) ...[
            Container(
              width: 1,
              height: 40,
              color: theme.colorScheme.outline.withOpacity(0.2),
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),
            Expanded(
              child: _buildStatItem(
                Icons.skip_next_rounded,
                l10n.nextLevel,
                event.nextLevel!.blindsText,
                event,
                theme,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String label,
    String value,
    Event event,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: _getTextColor(event, theme, isSecondary: true),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: _getTextColor(event, theme, isSecondary: true),
                shadows: _getTextShadow(event),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: _getTextColor(event, theme),
            shadows: _getTextShadow(event),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingInfo(
      Event event, AppLocalizations l10n, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.secondary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.schedule_rounded,
              size: 20,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.starts}:',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: _getTextColor(event, theme, isSecondary: true),
                    shadows: _getTextShadow(event),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDateTime(event.startsAt),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _getTextColor(event, theme),
                    shadows: _getTextShadow(event),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfo(Event event, AppLocalizations l10n, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.tertiary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Buy-in info (first row only)
          if (event.appBuyIn != null) ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money_rounded,
                        size: 16,
                        color: _getTextColor(event, theme, isSecondary: true),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        event.appBuyIn!.action.isNotEmpty
                            ? event.appBuyIn!.action
                            : 'Buy In',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: _getTextColor(event, theme, isSecondary: true),
                          shadows: _getTextShadow(event),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${event.appBuyIn!.price} - ${event.appBuyIn!.chips}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _getTextColor(event, theme),
                      shadows: _getTextShadow(event),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Total prize pool from buy-in data
          if (event.appBuyIn != null &&
              event.appBuyIn!.totalPrizepool.isNotEmpty) ...[
            if (event.appBuyIn != null) ...[
              Container(
                width: 1,
                height: 40,
                color: theme.colorScheme.outline.withOpacity(0.2),
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.emoji_events_rounded,
                        size: 16,
                        color: _getTextColor(event, theme, isSecondary: true),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Total Prize',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: _getTextColor(event, theme, isSecondary: true),
                          shadows: _getTextShadow(event),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.appBuyIn!.totalPrizepool,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _getTextColor(event, theme),
                      shadows: _getTextShadow(event),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours.remainder(24)}h';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes.remainder(60)}m';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return AppLocalizations.of(context)!.startingSoon;
    }
  }

  void _showEventDetails(Event event, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PublicEventDetailsBottomSheet(event: event),
    );
  }
}

// Enhanced LevelCountdownWidget with callback functionality
class LevelCountdownWidget extends StatefulWidget {
  final Duration levelRemaining;
  final String levelText;
  final bool isBreak;
  final VoidCallback? onCountdownComplete;

  const LevelCountdownWidget({
    Key? key,
    required this.levelRemaining,
    required this.levelText,
    required this.isBreak,
    this.onCountdownComplete,
  }) : super(key: key);

  @override
  State<LevelCountdownWidget> createState() => _LevelCountdownWidgetState();
}

class _LevelCountdownWidgetState extends State<LevelCountdownWidget>
    with TickerProviderStateMixin {
  late Timer _timer;
  late Duration _remaining;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _remaining = widget.levelRemaining;

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _startTimer();

    // Start pulsing animation when countdown is low
    if (_remaining.inSeconds <= 60) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(LevelCountdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update remaining time when widget receives new data
    if (widget.levelRemaining != oldWidget.levelRemaining) {
      setState(() {
        _startTime = DateTime.now();
        _remaining = widget.levelRemaining;
      });

      // Restart timer if it was canceled due to countdown completion
      if (!_timer.isActive && _remaining.inSeconds > 0) {
        _startTimer();
      }

      // Restart pulsing animation if needed
      if (_remaining.inSeconds <= 60 && !_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      } else if (_remaining.inSeconds > 60 && _pulseController.isAnimating) {
        _pulseController.stop();
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          // Calculate actual remaining time based on elapsed time since start
          final elapsed = DateTime.now().difference(_startTime);
          final newRemaining = widget.levelRemaining - elapsed;

          if (newRemaining.inSeconds > 0) {
            _remaining = newRemaining;

            // Start pulsing when countdown gets low
            if (_remaining.inSeconds <= 60 && !_pulseController.isAnimating) {
              _pulseController.repeat(reverse: true);
            }
          } else {
            _remaining = Duration.zero;
            // Stop pulsing when countdown ends
            _pulseController.stop();
            timer.cancel();
            widget.onCountdownComplete?.call();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLowTime = _remaining.inSeconds <= 60;
    final isVeryLowTime = _remaining.inSeconds <= 10;

    Color timeColor = theme.colorScheme.onSurface;

    if (isVeryLowTime) {
      timeColor = const Color(0xFFDC2626); // Red for very low time
    } else if (isLowTime) {
      timeColor = const Color(0xFFF59E0B); // Orange for low time
    }

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isLowTime ? _pulseAnimation.value : 1.0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.timer_rounded,
                      color: timeColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDuration(_remaining),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: timeColor,
                        fontFeatures: [const FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                if (isLowTime) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: timeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isVeryLowTime ? 'ENDING SOON!' : 'Low Time',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: timeColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
  }
}
