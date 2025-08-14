import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/event.dart';

class PublicEventDetailsBottomSheet extends StatefulWidget {
  final Event event;

  const PublicEventDetailsBottomSheet({super.key, required this.event});

  @override
  State<PublicEventDetailsBottomSheet> createState() =>
      _PublicEventDetailsBottomSheetState();
}

class _PublicEventDetailsBottomSheetState
    extends State<PublicEventDetailsBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Event title and status
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Text(
                  widget.event.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                _buildStatusBadge(widget.event.status),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Top Three Players
          _buildTopThreePlayers(),

          // Tab Bar
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: AppLocalizations.of(context)!.info),
              Tab(text: AppLocalizations.of(context)!.blindStructure),
            ],
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
          ),

          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInfoTab(),
                _buildBlindStructureTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Additional event details
          Text(
            AppLocalizations.of(context)!.eventDetails,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 12),

          Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(3),
            },
            border: TableBorder.all(color: Colors.grey[200]!),
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.grey[100]),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      AppLocalizations.of(context)!.startTime,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      DateFormat('yyyy-MM-dd HH:mm')
                          .format(widget.event.startsAt),
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Status',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(widget.event.status.toUpperCase()),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Players',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${widget.event.playersCount}'),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Active Players',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${widget.event.activePlayersCount}'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Buy-in Information (Table)
          if (widget.event.allBuyIns.isNotEmpty) ...[
            Text(
              AppLocalizations.of(context)!.buyIn,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
              },
              border: TableBorder.all(color: Colors.grey[200]!),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[100]),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Action',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(AppLocalizations.of(context)!.amount,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Chips',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                ...widget.event.allBuyIns.map((buyin) => TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(buyin.action),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(buyin.price),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(buyin.chips),
                        ),
                      ],
                    )),
              ],
            ),
            const SizedBox(height: 24),
          ],
          // Prize Information (Table)
          if (widget.event.prizes.isNotEmpty) ...[
            Text(
              AppLocalizations.of(context)!.prizes,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
              },
              border: TableBorder.all(color: Colors.grey[200]!),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[100]),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        AppLocalizations.of(context)!.position,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        AppLocalizations.of(context)!.amount,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Type',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                ...widget.event.prizes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final prize = entry.value;
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${index + 1}'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          prize.amount != null
                              ? '€${prize.amount!.toStringAsFixed(2)}'
                              : '${prize.percentage.toStringAsFixed(1)}%',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          prize.amount != null ? 'Fixed' : 'Percentage',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
            const SizedBox(height: 24),
          ],

          // App Prizes Information (Table)
          if (widget.event.appPrizes.isNotEmpty) ...[
            Text(
              'Prize Structure',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(5),
              },
              border: TableBorder.all(color: Colors.grey[200]!),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[100]),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '#',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Description',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                ...widget.event.appPrizes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final appPrize = entry.value;
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${index + 1}'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          appPrize.description,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
            const SizedBox(height: 24),
          ],

          if (widget.event.description != null) ...[
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.description,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(widget.event.description!),
          ],
        ],
      ),
    );
  }

  Widget _buildBlindStructureTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.blindStructure,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          if (widget.event.levels.isNotEmpty)
            ...widget.event.levels.asMap().entries.map((entry) {
              final index = entry.key;
              final level = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: level.isBreak ? Colors.orange[50] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: level.isBreak
                          ? Colors.orange[200]!
                          : Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: level.isBreak
                            ? Colors.orange
                            : Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: level.isBreak
                            ? const Icon(
                                Icons.coffee,
                                color: Colors.white,
                                size: 20,
                              )
                            : Text(
                                '${level.levelNumber ?? index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
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
                            level.isBreak
                                ? 'Break'
                                : '${level.smallBlind}/${level.bigBlind}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (!level.isBreak &&
                              level.ante != null &&
                              level.ante! > 0)
                            Text(
                              '${AppLocalizations.of(context)!.ante}: ${level.ante}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          if (level.description != null)
                            Text(
                              level.description!,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      '${level.duration} min',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }).toList()
          else
            Center(
              child: Text(
                AppLocalizations.of(context)!.noBlindStructureAvailable,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopThreePlayers() {
    // Get top 3 participants sorted by position
    final topParticipants = widget.event.participants
        .where((p) => p.position != null && p.user != null)
        .toList()
      ..sort((a, b) => a.position!.compareTo(b.position!));

    final top3 = topParticipants.take(3).toList();

    if (top3.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Players',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...top3.map((participant) {
              final position = participant.position!;
              final user = participant.user!;

              Color color = position == 1
                  ? Colors.amber
                  : position == 2
                      ? Colors.grey[400]!
                      : Colors.brown[400]!;

              IconData icon = position == 1
                  ? Icons.emoji_events
                  : position == 2
                      ? Icons.military_tech
                      : Icons.workspace_premium;

              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: color,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 24,
                      height: 20,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '$position',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color backgroundColor;
    String displayStatus = status ?? 'Unknown';

    switch (status?.toLowerCase()) {
      case 'upcoming':
        backgroundColor = Colors.blue;
        break;
      case 'ongoing':
        backgroundColor = Colors.green;
        break;
      case 'completed':
        backgroundColor = Colors.grey;
        break;
      case 'cancelled':
        backgroundColor = Colors.red;
        break;
      default:
        backgroundColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayStatus.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
