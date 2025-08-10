import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/events_provider.dart';
import '../models/event.dart';
import '../widgets/countdown_widget.dart';
import '../l10n/app_localizations.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventsProvider>().loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.events),
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Consumer<EventsProvider>(
        builder: (context, eventsProvider, child) {
          if (eventsProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (eventsProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.errorLoadingData,
                    style: theme.textTheme.titleMedium,
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
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          final runningEvents = eventsProvider.runningEvents;
          final upcomingEvents = eventsProvider.upcomingEvents;

          if (runningEvents.isEmpty && upcomingEvents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noEventsAvailable,
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.noEventsAvailableMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => eventsProvider.refreshEvents(),
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.refresh),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => eventsProvider.loadEvents(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (runningEvents.isNotEmpty) ...[
                  _buildSectionHeader(
                    l10n.liveEvents,
                    runningEvents.length,
                    Colors.green,
                    Icons.live_tv,
                    theme,
                  ),
                  const SizedBox(height: 12),
                  ...runningEvents.map((event) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildEventCard(event, l10n, theme),
                      )),
                  const SizedBox(height: 24),
                ],
                if (upcomingEvents.isNotEmpty) ...[
                  _buildSectionHeader(
                    l10n.upcomingEvents,
                    upcomingEvents.length,
                    theme.colorScheme.primary,
                    Icons.schedule,
                    theme,
                  ),
                  const SizedBox(height: 12),
                  ...upcomingEvents.map((event) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildEventCard(event, l10n, theme),
                      )),
                ],
                const SizedBox(height: 80), // Bottom padding for navigation
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    int count,
    Color color,
    IconData icon,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard(Event event, AppLocalizations l10n, ThemeData theme) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showEventDetails(event, l10n),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: event.isRunning
                          ? Colors.green.withOpacity(0.2)
                          : event.isPaused
                              ? Colors.orange.withOpacity(0.2)
                              : theme.colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: event.isRunning
                                ? Colors.green
                                : event.isPaused
                                    ? Colors.orange
                                    : theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          event.isRunning
                              ? l10n.live
                              : event.isPaused
                                  ? l10n.paused
                                  : l10n.pending,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: event.isRunning
                                ? Colors.green
                                : event.isPaused
                                    ? Colors.orange
                                    : theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (event.description.isNotEmpty) ...[
                Text(
                  event.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (event.isRunning) ...[
                if (event.currentLevel != null)
                  LevelCountdownWidget(
                    levelRemaining: event.levelRemainingDuration,
                    levelText: event.currentLevel!.blindsText,
                    isBreak: event.currentLevel!.isBreak,
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.people,
                        label: l10n.players,
                        value: '${event.activePlayersCount}',
                        theme: theme,
                      ),
                    ),
                    if (event.nextLevel != null)
                      Expanded(
                        child: _buildInfoItem(
                          icon: Icons.trending_up,
                          label: l10n.nextLevel,
                          value: event.nextLevel!.blindsText,
                          theme: theme,
                        ),
                      ),
                  ],
                ),
              ] else if (event.isPaused) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.pause_circle,
                        size: 20,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${l10n.players}: ${event.activePlayersCount}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (event.isUpcoming) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 20,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${l10n.starts}: ${_formatDateTime(event.startsAt)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
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
      builder: (context) => _EventDetailsBottomSheet(event: event, l10n: l10n),
    );
  }
}

class _EventDetailsBottomSheet extends StatelessWidget {
  final Event event;
  final AppLocalizations l10n;

  const _EventDetailsBottomSheet({
    required this.event,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.8,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: event.isRunning
                              ? Colors.green.withOpacity(0.2)
                              : theme.colorScheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          event.isRunning ? l10n.live : l10n.pending,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: event.isRunning
                                ? Colors.green
                                : theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  if (event.description.isNotEmpty) ...[
                    Text(
                      event.description,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Current level for running events
                  if (event.isRunning && event.currentLevel != null) ...[
                    LevelCountdownWidget(
                      levelRemaining: event.levelRemainingDuration,
                      levelText: event.currentLevel!.blindsText,
                      isBreak: event.currentLevel!.isBreak,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Event details
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          l10n.status,
                          event.isRunning ? l10n.running : l10n.pending,
                          theme,
                        ),
                      ),
                      Expanded(
                        child: _buildDetailItem(
                          l10n.players,
                          '${event.activePlayersCount}',
                          theme,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Start time for upcoming events
                  if (event.isUpcoming) ...[
                    _buildDetailItem(
                      l10n.startsAt,
                      _formatFullDateTime(event.startsAt),
                      theme,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Blind structure
                  if (event.levels.isNotEmpty) ...[
                    Text(
                      l10n.blindStructure,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...event.levels
                        .take(8)
                        .map((level) => _buildLevelItem(level, theme)),
                    if (event.levels.length > 8) ...[
                      const SizedBox(height: 8),
                      Text(
                        l10n.andMoreLevels(event.levels.length - 8),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLevelItem(Level level, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: level.isBreak
                  ? theme.colorScheme.secondary.withOpacity(0.2)
                  : theme.colorScheme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                level.isBreak ? 'B' : '${level.levelNumber ?? 0}',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: level.isBreak
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              level.blindsText,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${level.duration}min',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _formatFullDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
