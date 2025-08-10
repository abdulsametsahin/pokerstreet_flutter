import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

class UserEventsPage extends StatefulWidget {
  const UserEventsPage({super.key});

  @override
  State<UserEventsPage> createState() => _UserEventsPageState();
}

class _UserEventsPageState extends State<UserEventsPage> {
  String _sortBy = 'date';
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myEvents),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'date',
                child: Row(
                  children: [
                    const Icon(Icons.access_time),
                    const SizedBox(width: 8),
                    Text(l10n.sortByDate),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'name',
                child: Row(
                  children: [
                    const Icon(Icons.sort_by_alpha),
                    const SizedBox(width: 8),
                    Text(l10n.sortByName),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'position',
                child: Row(
                  children: [
                    const Icon(Icons.leaderboard),
                    const SizedBox(width: 8),
                    Text(l10n.sortByPosition),
                  ],
                ),
              ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filterStatus = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    const Icon(Icons.all_inclusive),
                    const SizedBox(width: 8),
                    Text(l10n.allEvents),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'completed',
                child: Row(
                  children: [
                    const Icon(Icons.check_circle),
                    const SizedBox(width: 8),
                    Text(l10n.completed),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'in progress',
                child: Row(
                  children: [
                    const Icon(Icons.play_circle),
                    const SizedBox(width: 8),
                    Text(l10n.inProgress),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'upcoming',
                child: Row(
                  children: [
                    const Icon(Icons.schedule),
                    const SizedBox(width: 8),
                    Text(l10n.upcoming),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.eventsLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    l10n.loadingEvents,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            );
          }

          if (authProvider.userEvents.isEmpty) {
            return _buildEmptyState(context);
          }

          final filteredEvents =
              _getFilteredAndSortedEvents(authProvider.userEvents);

          return Column(
            children: [
              // Stats Header
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        context,
                        l10n.totalEvents,
                        '${authProvider.userEvents.length}',
                        Icons.event,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        l10n.averagePosition,
                        _getAveragePosition(authProvider.userEvents),
                        Icons.trending_up,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        l10n.totalBalance,
                        _getTotalBalance(authProvider.userEvents),
                        Icons.account_balance_wallet,
                      ),
                    ),
                  ],
                ),
              ),

              // Filter indicator
              if (_filterStatus != 'all' ||
                  filteredEvents.length != authProvider.userEvents.length)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceVariant
                        .withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_list,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.showingFilteredEvents(filteredEvents.length,
                            authProvider.userEvents.length),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const Spacer(),
                      if (_filterStatus != 'all')
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _filterStatus = 'all';
                            });
                          },
                          child: Row(
                            children: [
                              Text(
                                l10n.clearFilter,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.clear,
                                size: 14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              // Events List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredEvents.length,
                  itemBuilder: (context, index) {
                    final event = filteredEvents[index];
                    return _buildEventCard(context, event, index);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceVariant
                    .withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.event_busy,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noEventsFound,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noEventsDescription,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.9),
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEventCard(BuildContext context, dynamic event, int index) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _showEventDetails(context, event);
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event rank indicator
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildStatusChip(context, event.statusDisplay),
                            const SizedBox(width: 8),
                            _buildStatusChip(
                              context,
                              event.participationStatusDisplay,
                              isSecondary: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Position/Score display
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (event.participation.position != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                _getPositionColor(event.participation.position)
                                    .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.emoji_events,
                                size: 16,
                                color: _getPositionColor(
                                    event.participation.position),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '#${event.participation.position}',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: _getPositionColor(
                                          event.participation.position),
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Text(
                          l10n.score,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                        Text(
                          event.participation.score.toStringAsFixed(0),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${l10n.joinedOn}: ${_formatDate(event.participation.joinedAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  if (event.participation.balance != 0) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (event.participation.balance >= 0
                                ? Colors.green
                                : Colors.red)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            event.participation.balance >= 0
                                ? Icons.trending_up
                                : Icons.trending_down,
                            size: 14,
                            color: event.participation.balance >= 0
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '\$${event.participation.balance.toStringAsFixed(2)}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: event.participation.balance >= 0
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status,
      {bool isSecondary = false}) {
    Color backgroundColor;
    Color textColor;

    if (isSecondary) {
      backgroundColor = Theme.of(context).colorScheme.surfaceVariant;
      textColor = Theme.of(context).colorScheme.onSurfaceVariant;
    } else {
      switch (status.toLowerCase()) {
        case 'completed':
          backgroundColor = Colors.green.withOpacity(0.1);
          textColor = Colors.green;
          break;
        case 'in progress':
          backgroundColor = Colors.orange.withOpacity(0.1);
          textColor = Colors.orange;
          break;
        case 'upcoming':
          backgroundColor = Colors.blue.withOpacity(0.1);
          textColor = Colors.blue;
          break;
        default:
          backgroundColor = Theme.of(context).colorScheme.surfaceVariant;
          textColor = Theme.of(context).colorScheme.onSurfaceVariant;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  List<dynamic> _getFilteredAndSortedEvents(List<dynamic> events) {
    var filtered = events.where((event) {
      if (_filterStatus == 'all') return true;
      return event.statusDisplay.toLowerCase() == _filterStatus;
    }).toList();

    switch (_sortBy) {
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'position':
        filtered.sort((a, b) {
          if (a.participation.position == null &&
              b.participation.position == null) return 0;
          if (a.participation.position == null) return 1;
          if (b.participation.position == null) return -1;
          return a.participation.position.compareTo(b.participation.position);
        });
        break;
      case 'date':
      default:
        filtered.sort((a, b) =>
            b.participation.joinedAt.compareTo(a.participation.joinedAt));
        break;
    }

    return filtered;
  }

  String _getAveragePosition(List<dynamic> events) {
    final eventsWithPosition =
        events.where((e) => e.participation.position != null).toList();
    if (eventsWithPosition.isEmpty) return '-';

    final sum = eventsWithPosition.fold<double>(
        0.0, (sum, e) => sum + e.participation.position.toDouble());
    final average = sum / eventsWithPosition.length;
    return average.toStringAsFixed(1);
  }

  String _getTotalBalance(List<dynamic> events) {
    final totalBalance =
        events.fold(0.0, (sum, e) => sum + e.participation.balance);
    return '\$${totalBalance.toStringAsFixed(2)}';
  }

  void _showEventDetails(BuildContext context, dynamic event) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(l10n.eventStatus, event.statusDisplay),
            _buildDetailRow(
                l10n.participationStatus, event.participationStatusDisplay),
            if (event.participation.position != null)
              _buildDetailRow(
                  l10n.position, '#${event.participation.position}'),
            _buildDetailRow(
                l10n.score, event.participation.score.toStringAsFixed(0)),
            _buildDetailRow(l10n.balance,
                '\$${event.participation.balance.toStringAsFixed(2)}'),
            _buildDetailRow(
                l10n.joinedOn, _formatDate(event.participation.joinedAt)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
