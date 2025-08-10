import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../widgets/settings_bottom_sheet.dart';
import 'events_page.dart';
import 'top_players_page.dart';
import 'profile_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const EventsPage(),
    const TopPlayersPage(),
    const ProfilePage(),
  ];

  void _showSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const SettingsBottomSheet(),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: _currentIndex == 0 // Show settings only on Events page (home)
          ? AppBar(
              title: Text(l10n.eventsPageTitle),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: _showSettingsBottomSheet,
                ),
              ],
            )
          : null,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.event),
            label: l10n.events,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.leaderboard),
            label: l10n.topPlayers,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}
