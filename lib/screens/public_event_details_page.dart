import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/event.dart';

class PublicEventDetailsPage extends StatefulWidget {
  final Event event;

  const PublicEventDetailsPage({super.key, required this.event});

  @override
  State<PublicEventDetailsPage> createState() => _PublicEventDetailsPageState();
}

class _PublicEventDetailsPageState extends State<PublicEventDetailsPage>
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.event.name,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Modern event header
                  _buildModernEventHeader(context, l10n),

                  // Top Three Players
                  _buildTopThreePlayers(),

                  // Modern Tab Bar with full width background
                  Container(
                    width: double.infinity,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      dividerHeight: 0,
                      padding: const EdgeInsets.all(4),
                      indicator: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      labelColor: colorScheme.onPrimary,
                      unselectedLabelColor: colorScheme.onSurfaceVariant,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: [
                        Tab(
                          child: Container(
                            width: double.infinity,
                            height: 48,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(l10n.info),
                              ],
                            ),
                          ),
                        ),
                        Tab(
                          child: Container(
                            width: double.infinity,
                            height: 48,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.stairs_rounded,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(l10n.blindStructure),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildModernInfoTab(),
            _buildModernBlindStructureTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildModernEventHeader(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          // Event icon and status
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.casino_rounded,
                  color: colorScheme.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              _buildModernStatusBadge(widget.event.status),
            ],
          ),

          const SizedBox(height: 20),

          // Event stats row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  Icons.groups_rounded,
                  '${widget.event.playersCount}',
                  l10n.players,
                  colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  Icons.schedule_rounded,
                  DateFormat('HH:mm').format(widget.event.startsAt),
                  l10n.startTime,
                  colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  Icons.calendar_today_rounded,
                  DateFormat('MMM dd').format(widget.event.startsAt),
                  'Date',
                  colorScheme.tertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, IconData icon, String value,
      String label, Color color) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatusBadge(String? status) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    Color textColor;
    IconData icon;
    String displayStatus = status ?? 'Unknown';

    switch (status?.toLowerCase()) {
      case 'upcoming':
        backgroundColor = colorScheme.primary;
        textColor = colorScheme.onPrimary;
        icon = Icons.schedule;
        displayStatus = 'UPCOMING';
        break;
      case 'ongoing':
      case 'in progress':
        backgroundColor = Colors.green;
        textColor = Colors.white;
        icon = Icons.play_circle_filled;
        displayStatus = 'ONGOING';
        break;
      case 'completed':
        backgroundColor = colorScheme.outline;
        textColor = colorScheme.onSurface;
        icon = Icons.check_circle;
        displayStatus = 'COMPLETED';
        break;
      case 'cancelled':
        backgroundColor = colorScheme.error;
        textColor = colorScheme.onError;
        icon = Icons.cancel;
        displayStatus = 'CANCELLED';
        break;
      default:
        backgroundColor = colorScheme.outline;
        textColor = colorScheme.onSurface;
        icon = Icons.help_outline;
        displayStatus = 'UNKNOWN';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: textColor,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            displayStatus,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopThreePlayers() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // Get top 3 participants sorted by position
    final topParticipants = widget.event.participants
        .where((p) => p.position != null && p.user != null)
        .toList()
      ..sort((a, b) => a.position!.compareTo(b.position!));

    final top3 = topParticipants.take(3).toList();

    if (top3.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events_rounded,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.topPlayers,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...top3.map((participant) {
            final position = participant.position!;
            final user = participant.user!;

            Color positionColor;
            IconData positionIcon;

            switch (position) {
              case 1:
                positionColor = const Color(0xFFFFD700); // Gold
                positionIcon = Icons.emoji_events;
                break;
              case 2:
                positionColor = const Color(0xFFC0C0C0); // Silver
                positionIcon = Icons.military_tech;
                break;
              case 3:
                positionColor = const Color(0xFFCD7F32); // Bronze
                positionIcon = Icons.workspace_premium;
                break;
              default:
                positionColor = colorScheme.primary;
                positionIcon = Icons.stars;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: positionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: positionColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: positionColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: positionColor.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$position',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    positionIcon,
                    color: positionColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      user.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
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
    );
  }

  Widget _buildModernInfoTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Details Section
          _buildInfoSection(
            context,
            l10n.eventDetails,
            Icons.info_outline_rounded,
            [
              _buildInfoRow(
                context,
                l10n.startTime,
                DateFormat('yyyy-MM-dd HH:mm').format(widget.event.startsAt),
                Icons.schedule_rounded,
              ),
              _buildInfoRow(
                context,
                l10n.status,
                widget.event.status.toUpperCase(),
                Icons.flag_rounded,
                valueColor: _getStatusColor(widget.event.status),
              ),
              _buildInfoRow(
                context,
                l10n.players,
                '${widget.event.playersCount}',
                Icons.groups_rounded,
              ),
              _buildInfoRow(
                context,
                'Active Players',
                '${widget.event.activePlayersCount}',
                Icons.person_rounded,
              ),
            ],
          ),

          // Buy-in Information
          if (widget.event.allBuyIns.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildBuyInSection(context, l10n),
          ],

          // Prize Information
          if (widget.event.prizes.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildPrizeSection(context, l10n),
          ],

          // App Prizes Information
          if (widget.event.appPrizes.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildAppPrizeSection(context, l10n),
          ],

          // Description
          if (widget.event.description != null) ...[
            const SizedBox(height: 24),
            _buildInfoSection(
              context,
              l10n.description,
              Icons.description_rounded,
              [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.event.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, IconData icon,
      List<Widget> children) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.05),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: valueColor ?? colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyInSection(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _buildInfoSection(
      context,
      l10n.buyIn,
      Icons.payments_rounded,
      [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Action',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        l10n.amount,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Chips',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
              // Data rows
              ...widget.event.allBuyIns.asMap().entries.map((entry) {
                final index = entry.key;
                final buyin = entry.value;
                final isLast = index == widget.event.allBuyIns.length - 1;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: index.isEven
                        ? Colors.transparent
                        : colorScheme.surfaceVariant.withOpacity(0.1),
                    borderRadius: isLast
                        ? const BorderRadius.vertical(
                            bottom: Radius.circular(12))
                        : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          buyin.action,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          buyin.price,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          buyin.chips,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrizeSection(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _buildInfoSection(
      context,
      l10n.prizes,
      Icons.emoji_events_rounded,
      [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        l10n.position,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        l10n.amount,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Type',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
              // Data rows
              ...widget.event.prizes.asMap().entries.map((entry) {
                final index = entry.key;
                final prize = entry.value;
                final position = index + 1;
                final isLast = index == widget.event.prizes.length - 1;
                final positionColor = _getPositionColor(position);

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: index.isEven
                        ? Colors.transparent
                        : colorScheme.surfaceVariant.withOpacity(0.1),
                    borderRadius: isLast
                        ? const BorderRadius.vertical(
                            bottom: Radius.circular(12))
                        : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: positionColor,
                                borderRadius: BorderRadius.circular(12),
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
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          prize.amount != null
                              ? '€${prize.amount!.toStringAsFixed(2)}'
                              : '${prize.percentage.toStringAsFixed(1)}%',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          prize.amount != null ? 'Fixed' : 'Percentage',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppPrizeSection(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _buildInfoSection(
      context,
      'Prize Structure',
      Icons.stars_rounded,
      [
        ...widget.event.appPrizes.asMap().entries.map((entry) {
          final index = entry.key;
          final appPrize = entry.value;
          final position = index + 1;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '$position',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    appPrize.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildModernBlindStructureTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.event.levels.isNotEmpty)
            ...widget.event.levels.asMap().entries.map((entry) {
              final index = entry.key;
              final level = entry.value;
              final isBreak = level.isBreak;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isBreak
                        ? Colors.orange.withOpacity(0.3)
                        : colorScheme.outline.withOpacity(0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Row(
                    children: [
                      // Left colored bar
                      Container(
                        width: 4,
                        height: 80,
                        color: isBreak ? Colors.orange : colorScheme.primary,
                      ),

                      // Content
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Level number/icon
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isBreak
                                      ? Colors.orange.withOpacity(0.1)
                                      : colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Center(
                                  child: isBreak
                                      ? Icon(
                                          Icons.coffee_rounded,
                                          color: Colors.orange,
                                          size: 24,
                                        )
                                      : Text(
                                          '${level.levelNumber ?? index + 1}',
                                          style: TextStyle(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(width: 16),

                              // Level details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isBreak
                                          ? l10n.breakTime
                                          : '${level.smallBlind}/${level.bigBlind}',
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    if (!isBreak &&
                                        level.ante != null &&
                                        level.ante! > 0)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          '${l10n.ante}: ${level.ante}',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    if (level.description != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          level.description!,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // Duration
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceVariant
                                      .withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.timer_outlined,
                                      size: 16,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${level.duration} min',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList()
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 48,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noBlindStructureAvailable,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'ongoing':
      case 'in progress':
        return Colors.orange;
      case 'upcoming':
        return colorScheme.primary;
      case 'cancelled':
        return colorScheme.error;
      default:
        return colorScheme.outline;
    }
  }

  Color _getPositionColor(int position) {
    switch (position) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}
