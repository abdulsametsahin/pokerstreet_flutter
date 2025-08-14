import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/event.dart';
import '../services/api_service.dart';

class EventDetailsBottomSheet extends StatefulWidget {
  final dynamic userEvent;

  const EventDetailsBottomSheet({
    super.key,
    required this.userEvent,
  });

  @override
  State<EventDetailsBottomSheet> createState() =>
      _EventDetailsBottomSheetState();

  static Future<void> show(BuildContext context, dynamic userEvent) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EventDetailsBottomSheet(userEvent: userEvent),
    );
  }
}

class _EventDetailsBottomSheetState extends State<EventDetailsBottomSheet> {
  Event? eventDetails;
  bool isLoading = true;
  String? errorMessage;
  List<Participant> topParticipants = [];

  @override
  void initState() {
    super.initState();
    _loadEventDetails();
  }

  Future<void> _loadEventDetails() async {
    try {
      final response = await ApiService.getEventDetails(widget.userEvent.id);

      if (mounted) {
        setState(() {
          if (response.success && response.data != null) {
            eventDetails = response.data!;
            _extractTopParticipants();
            errorMessage = null;
          } else {
            errorMessage = response.message.isNotEmpty
                ? response.message
                : 'Failed to load event details';
          }
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error loading event details: $e';
          isLoading = false;
        });
      }
    }
  }

  void _extractTopParticipants() {
    if (eventDetails?.participants == null) return;

    // Filter participants with valid positions and users
    final participantsWithPosition = eventDetails!.participants
        .where((p) => p.user != null && p.finalTablePosition != null)
        .toList();

    // Sort by final table position (lower is better)
    participantsWithPosition.sort((a, b) =>
        (a.finalTablePosition ?? 999).compareTo(b.finalTablePosition ?? 999));

    // Take top 3
    topParticipants = participantsWithPosition.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.userEvent.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _buildContent(context, l10n, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, AppLocalizations l10n, ThemeData theme) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    errorMessage = null;
                  });
                  _loadEventDetails();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event status
          _buildStatusSection(l10n, theme),
          const SizedBox(height: 24),

          // User participation details
          _buildParticipationSection(l10n, theme),
          const SizedBox(height: 24),

          // Event details
          if (eventDetails != null) _buildEventDetailsSection(l10n, theme),

          // Top participants
          if (topParticipants.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildTopParticipantsSection(l10n, theme),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusSection(AppLocalizations l10n, ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildStatusChip(
          theme,
          widget.userEvent.statusDisplay,
          _getEventStatusColor(widget.userEvent.statusDisplay),
        ),
        _buildStatusChip(
          theme,
          widget.userEvent.participationStatusDisplay,
          theme.colorScheme.surfaceVariant,
          isSecondary: true,
        ),
      ],
    );
  }

  Widget _buildParticipationSection(AppLocalizations l10n, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Performance',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (widget.userEvent.participation.position != null)
            _buildDetailRow(
              l10n,
              theme,
              l10n.position,
              '#${widget.userEvent.participation.position}',
              Icons.emoji_events,
              _getPositionColor(widget.userEvent.participation.position),
            ),
          _buildDetailRow(
            l10n,
            theme,
            l10n.score,
            widget.userEvent.participation.score.toStringAsFixed(0),
            Icons.star,
          ),
          _buildDetailRow(
            l10n,
            theme,
            l10n.balance,
            '\$${widget.userEvent.participation.balance.toStringAsFixed(2)}',
            Icons.account_balance_wallet,
            widget.userEvent.participation.balance >= 0
                ? Colors.green
                : Colors.red,
          ),
          _buildDetailRow(
            l10n,
            theme,
            l10n.joinedOn,
            _formatDateTime(widget.userEvent.participation.joinedAt),
            Icons.access_time,
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetailsSection(AppLocalizations l10n, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            l10n,
            theme,
            'Status',
            eventDetails!.status,
            Icons.info,
          ),
          _buildDetailRow(
            l10n,
            theme,
            'Total Players',
            '${eventDetails!.playersCount}',
            Icons.people,
          ),
          _buildDetailRow(
            l10n,
            theme,
            'Active Players',
            '${eventDetails!.activePlayersCount}',
            Icons.person,
          ),
          if (eventDetails!.currentLevel != null)
            _buildDetailRow(
              l10n,
              theme,
              'Current Level',
              'Level ${eventDetails!.currentLevel!.levelNumber ?? 'N/A'}',
              Icons.layers,
            ),
        ],
      ),
    );
  }

  Widget _buildTopParticipantsSection(AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Players',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...topParticipants
            .map((participant) => _buildParticipantCard(participant, theme)),
      ],
    );
  }

  Widget _buildParticipantCard(Participant participant, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Position badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getPositionColor(participant.finalTablePosition!)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '#${participant.finalTablePosition}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: _getPositionColor(participant.finalTablePosition!),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Player info
          Expanded(
            child: Text(
              participant.user?.name ?? 'Unknown Player',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Trophy icon for top 3
          if (participant.finalTablePosition! <= 3)
            Icon(
              Icons.emoji_events,
              color: _getPositionColor(participant.finalTablePosition!),
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme, String status, Color backgroundColor,
      {bool isSecondary = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSecondary ? backgroundColor : backgroundColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: theme.textTheme.labelSmall?.copyWith(
          color: isSecondary
              ? theme.colorScheme.onSurfaceVariant
              : backgroundColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    AppLocalizations l10n,
    ThemeData theme,
    String label,
    String value,
    IconData icon, [
    Color? valueColor,
  ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: valueColor,
              fontWeight: valueColor != null ? FontWeight.w600 : null,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPositionColor(int position) {
    if (position == 1) return Colors.amber; // Gold
    if (position == 2) return Colors.grey; // Silver
    if (position == 3) return Colors.brown; // Bronze
    if (position <= 10) return Colors.green; // Top 10
    return Colors.blue; // Others
  }

  Color _getEventStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in progress':
        return Colors.orange;
      case 'upcoming':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(date.year, date.month, date.day);

    if (eventDate == today) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (eventDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }
}
