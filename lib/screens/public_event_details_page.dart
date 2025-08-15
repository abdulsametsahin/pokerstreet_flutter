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
    final isDark = theme.brightness == Brightness.dark;

    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData icon;
    String displayStatus = status ?? 'Unknown';

    switch (status?.toLowerCase()) {
      case 'upcoming':
        backgroundColor = isDark
            ? const Color(0xFF1E3A8A).withOpacity(0.2)
            : const Color(0xFF3B82F6).withOpacity(0.1);
        borderColor = isDark
            ? const Color(0xFF3B82F6).withOpacity(0.5)
            : const Color(0xFF3B82F6).withOpacity(0.3);
        textColor = isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF);
        icon = Icons.schedule_outlined;
        displayStatus = 'PENDING';
        break;
      case 'ongoing':
      case 'in progress':
        backgroundColor = isDark
            ? const Color(0xFF059669).withOpacity(0.2)
            : const Color(0xFF10B981).withOpacity(0.1);
        borderColor = isDark
            ? const Color(0xFF10B981).withOpacity(0.5)
            : const Color(0xFF10B981).withOpacity(0.3);
        textColor = isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857);
        icon = Icons.play_circle_outline_rounded;
        displayStatus = 'LIVE';
        break;
      case 'completed':
        backgroundColor = isDark
            ? const Color(0xFF374151).withOpacity(0.3)
            : const Color(0xFF6B7280).withOpacity(0.1);
        borderColor = isDark
            ? const Color(0xFF6B7280).withOpacity(0.5)
            : const Color(0xFF6B7280).withOpacity(0.3);
        textColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF374151);
        icon = Icons.check_circle_outline_rounded;
        displayStatus = 'COMPLETED';
        break;
      case 'cancelled':
        backgroundColor = isDark
            ? const Color(0xFFDC2626).withOpacity(0.2)
            : const Color(0xFFEF4444).withOpacity(0.1);
        borderColor = isDark
            ? const Color(0xFFEF4444).withOpacity(0.5)
            : const Color(0xFFEF4444).withOpacity(0.3);
        textColor = isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626);
        icon = Icons.cancel_outlined;
        displayStatus = 'CANCELLED';
        break;
      case 'pending':
        backgroundColor = isDark
            ? const Color(0xFFB45309).withOpacity(0.2)
            : const Color(0xFFB45309).withOpacity(0.1);
        borderColor = isDark
            ? const Color(0xFFB45309).withOpacity(0.5)
            : const Color(0xFFB45309).withOpacity(0.3);
        textColor = isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309);
        icon = Icons.hourglass_empty;
        displayStatus = 'PENDING';
        break;
      default:
        debugPrint('Unknown event status: $status');
        backgroundColor = colorScheme.surfaceVariant.withOpacity(0.5);
        borderColor = colorScheme.outline.withOpacity(0.3);
        textColor = colorScheme.onSurfaceVariant;
        icon = Icons.help_outline_rounded;
        displayStatus = 'UNKNOWN';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: textColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            displayStatus,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
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

            final positionColor = _getPositionColor(position);
            IconData positionIcon;

            switch (position) {
              case 1:
                positionIcon = Icons.emoji_events_rounded;
                break;
              case 2:
                positionIcon = Icons.military_tech_rounded;
                break;
              case 3:
                positionIcon = Icons.workspace_premium_rounded;
                break;
              default:
                positionIcon = Icons.stars_rounded;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: positionColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: positionColor.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: positionColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          positionColor,
                          positionColor.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: positionColor.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$position',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    positionIcon,
                    color: positionColor,
                    size: 22,
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
    final isDark = theme.brightness == Brightness.dark;

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

              final breakColor = isDark
                  ? const Color(0xFFD97706) // Premium amber for dark mode
                  : const Color(0xFFB45309); // Elegant amber for light mode

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isBreak
                        ? breakColor.withOpacity(0.3)
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
                        color: isBreak ? breakColor : colorScheme.primary,
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
                                      ? breakColor.withOpacity(0.1)
                                      : colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Center(
                                  child: isBreak
                                      ? Icon(
                                          Icons.coffee_rounded,
                                          color: breakColor,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    switch (status.toLowerCase()) {
      case 'completed':
        return isDark ? const Color(0xFF9CA3AF) : const Color(0xFF374151);
      case 'ongoing':
      case 'in progress':
        return isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857);
      case 'upcoming':
        return isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF);
      case 'cancelled':
        return isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626);
      default:
        return isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    }
  }

  Color _getPositionColor(int position) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    switch (position) {
      case 1:
        return isDark
            ? const Color(0xFFFBBF24) // Premium gold for dark mode
            : const Color(0xFFD97706); // Elegant amber for light mode
      case 2:
        return isDark
            ? const Color(0xFFE5E7EB) // Premium silver for dark mode
            : const Color(0xFF9CA3AF); // Sophisticated gray for light mode
      case 3:
        return isDark
            ? const Color(0xFFD69E2E) // Warm bronze for dark mode
            : const Color(0xFFB45309); // Rich bronze for light mode
      default:
        return isDark
            ? const Color(0xFF6366F1) // Modern purple for dark mode
            : const Color(0xFF4F46E5); // Professional indigo for light mode
    }
  }
}
