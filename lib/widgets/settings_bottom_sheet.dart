import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';

class SettingsBottomSheet extends StatelessWidget {
  const SettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            l10n.settings,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),

          // Language Section
          Text(
            l10n.language,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Consumer<LocaleProvider>(
            builder: (context, localeProvider, child) {
              return Column(
                children: [
                  RadioListTile<String>(
                    title: Text(l10n.english),
                    value: 'en',
                    groupValue: localeProvider.locale.languageCode,
                    onChanged: (value) {
                      if (value != null) {
                        localeProvider.setLocale(Locale(value));
                      }
                    },
                  ),
                  RadioListTile<String>(
                    title: Text(l10n.lithuanian),
                    value: 'lt',
                    groupValue: localeProvider.locale.languageCode,
                    onChanged: (value) {
                      if (value != null) {
                        localeProvider.setLocale(Locale(value));
                      }
                    },
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 16),

          // Theme Section
          Text(
            l10n.theme,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: Text(l10n.light),
                    value: ThemeMode.light,
                    groupValue: themeProvider.themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        themeProvider.setThemeMode(value);
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text(l10n.dark),
                    value: ThemeMode.dark,
                    groupValue: themeProvider.themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        themeProvider.setThemeMode(value);
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text(l10n.system),
                    value: ThemeMode.system,
                    groupValue: themeProvider.themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        themeProvider.setThemeMode(value);
                      }
                    },
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
