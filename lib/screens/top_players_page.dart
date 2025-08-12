import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/top_players_provider.dart';
import '../models/top_player.dart';

class TopPlayersPage extends StatefulWidget {
  const TopPlayersPage({super.key});

  @override
  State<TopPlayersPage> createState() => _TopPlayersPageState();
}

class _TopPlayersPageState extends State<TopPlayersPage> {
  String _selectedFilterType = 'monthly'; // 'monthly', 'all_time', 'range'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TopPlayersProvider>();
      provider.loadTopPlayers();
      provider.loadAvailableMonths();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.topPlayersTitle),
      ),
      body: Consumer<TopPlayersProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoadingState(context);
          }

          if (provider.error != null) {
            return _buildErrorState(context, provider);
          }

          if (provider.players.isEmpty) {
            return _buildEmptyState(context);
          }

          return _buildPlayersList(context, provider);
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.loadingEvents,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, TopPlayersProvider provider) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.errorLoadingPlayers,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              provider.error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                provider.clearError();
                provider.loadTopPlayers();
              },
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.leaderboard_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noPlayersThisMonth,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Consumer<TopPlayersProvider>(
              builder: (context, provider, child) {
                return Text(
                  provider.monthName.isNotEmpty
                      ? 'No players found for ${provider.monthName}'
                      : l10n.noPlayersThisMonth,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayersList(BuildContext context, TopPlayersProvider provider) {
    return Column(
      children: [
        // Header with month info and filters
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              // Title row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Top Players',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${provider.totalCount} players',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.leaderboard,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Filter options
              Row(
                children: [
                  Expanded(
                    child: _buildFilterButton(
                      context,
                      'Monthly',
                      provider.monthName,
                      Icons.calendar_month,
                      _selectedFilterType == 'monthly',
                      () {
                        setState(() {
                          _selectedFilterType = 'monthly';
                        });
                        _showMonthPicker(context, provider);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFilterButton(
                      context,
                      'All Time',
                      'Overall',
                      Icons.timeline,
                      _selectedFilterType == 'all_time',
                      () {
                        setState(() {
                          _selectedFilterType = 'all_time';
                        });
                        _showAllTimeFilter(context, provider);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFilterButton(
                      context,
                      'Range',
                      'Custom',
                      Icons.date_range,
                      _selectedFilterType == 'range',
                      () {
                        setState(() {
                          _selectedFilterType = 'range';
                        });
                        _showDateRangePicker(context, provider);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Players list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.players.length,
            itemBuilder: (context, index) {
              final player = provider.players[index];
              return _buildPlayerCard(context, player, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerCard(BuildContext context, TopPlayer player, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: player.rank <= 3
              ? _getRankBorderColor(player.rank)
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: player.rank <= 3 ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Rank and Score
            Row(
              children: [
                // Large rank badge
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: _getRankGradient(context, player.rank),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _getRankBorderColor(player.rank)
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '#${player.rank}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Player info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.name,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${player.score.toStringAsFixed(1)} points',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Badges section
            if (player.badges.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: player.badges.map((badge) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _parseColor(badge.color),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color:
                              _parseColor(badge.color).withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      badge.name,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                    ),
                  );
                }).toList(),
              ),
            ],

            // Stats section
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildLargeStatItem(
                          context,
                          '${player.eventsCount}',
                          'Total Events',
                          Icons.event_note,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildLargeStatItem(
                          context,
                          '${player.top10Events}',
                          'Top 10 Finishes',
                          Icons.emoji_events,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildLargeStatItem(
                          context,
                          '${player.firstPlaceEvents}',
                          '1st Place Wins',
                          Icons.workspace_premium,
                          Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildLargeStatItem(
                          context,
                          player.averagePosition?.toStringAsFixed(1) ?? 'N/A',
                          'Avg Position',
                          Icons.trending_up,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 10,
                  ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showAllTimeFilter(BuildContext context, TopPlayersProvider provider) {
    // Load all time rankings
    provider.loadTopPlayers(type: 'all_time');
  }

  void _showDateRangePicker(
      BuildContext context, TopPlayersProvider provider) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
    );

    if (picked != null) {
      // Load range rankings
      provider.loadTopPlayers(
        type: 'range',
        startDate: picked.start.toIso8601String().split('T')[0],
        endDate: picked.end.toIso8601String().split('T')[0],
      );
    } else {
      // If user cancels, reset to monthly
      setState(() {
        _selectedFilterType = 'monthly';
      });
    }
  }

  void _showMonthPicker(
      BuildContext context, TopPlayersProvider provider) async {
    if (provider.availableMonths.isEmpty) {
      await provider.loadAvailableMonths();
    }
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Month',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: provider.availableMonths.length,
                itemBuilder: (context, index) {
                  final month = provider.availableMonths[index];
                  final isSelected = month.value == provider.selectedDate;

                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.calendar_month,
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    title: Text(
                      month.label,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                    onTap: () {
                      provider.loadTopPlayers(
                        type: 'monthly',
                        date: month.value,
                      );
                      setState(() {
                        _selectedFilterType = 'monthly';
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeStatItem(BuildContext context, String value, String label,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getRankBorderColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.grey;
    }
  }

  LinearGradient _getRankGradient(BuildContext context, int rank) {
    switch (rank) {
      case 1:
        return const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFF8C00)], // Gold
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 2:
        return const LinearGradient(
          colors: [Color(0xFFC0C0C0), Color(0xFF808080)], // Silver
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 3:
        return const LinearGradient(
          colors: [Color(0xFFCD7F32), Color(0xFF8B4513)], // Bronze
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Color _parseColor(String colorString) {
    // Remove the # if present
    String hexColor = colorString.replaceAll('#', '');

    // Add opacity if not provided
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }

    try {
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      // Fallback to primary color if parsing fails
      return Theme.of(context).colorScheme.primary;
    }
  }
}
