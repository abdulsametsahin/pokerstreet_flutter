import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../services/banner_service.dart';
import '../services/api_service.dart';
import '../models/banner.dart' as BannerModel;
import '../models/personal_voucher.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/banners_section.dart';
import '../widgets/profile/balance_box.dart';
import '../widgets/profile/coupons_box.dart';
import '../widgets/profile/profile_events_section.dart';
import '../widgets/profile/profile_actions.dart';
import '../widgets/profile/profile_login_form.dart';
import '../widgets/profile/edit_profile_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<BannerModel.Banner> _banners = [];
  List<PersonalVoucher> _personalVouchers = [];

  @override
  void initState() {
    super.initState();
    // Load profile and events when page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated) {
        authProvider.getProfile();
        authProvider.getUserEvents();
        _loadBanners();
        _loadPersonalVouchers();
      }
    });
  }

  Future<void> _loadBanners() async {
    if (!mounted) return;

    try {
      final banners = await BannerService.getBanners();
      if (mounted) {
        setState(() {
          _banners = banners;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _banners = [];
        });
      }
      print('Error loading banners: $e');
    }
  }

  Future<void> _loadPersonalVouchers() async {
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated || authProvider.token == null) return;

    try {
      final response =
          await ApiService.getPersonalVouchers(authProvider.token!);
      if (mounted && response.success && response.data != null) {
        setState(() {
          _personalVouchers = response.data!;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _personalVouchers = [];
        });
      }
      print('Error loading personal vouchers: $e');
    }
  }

  void _showEditProfileDialog(BuildContext context, AuthProvider authProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return EditProfileDialog(
          user: authProvider.user!,
          authProvider: authProvider,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isAuthenticated) {
          return Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24.0,
              left: 24.0,
              right: 24.0,
              bottom: 24.0,
            ),
            child: ProfileLoginForm(authProvider: authProvider),
          );
        }

        if (authProvider.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceVariant
                        .withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context)!.loadingProfile,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.pleaseWait,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          );
        }

        if (authProvider.user != null) {
          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                authProvider.getProfile(),
                authProvider.getUserEvents(),
                _loadBanners(),
                _loadPersonalVouchers(),
              ]);
            },
            child: _buildProfileContent(context, authProvider),
          );
        }

        return _buildError(context);
      },
    );
  }

  Widget _buildProfileContent(BuildContext context, AuthProvider authProvider) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16.0,
        left: 16.0,
        right: 16.0,
        bottom: 16.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header with Edit Icon
          ProfileHeader(
            user: authProvider.user!,
            onEditProfile: () => _showEditProfileDialog(context, authProvider),
          ),
          const SizedBox(height: 24),

          // Banners Section
          BannersSection(banners: _banners),
          const SizedBox(height: 24),

          // My Events Section (improved)
          ProfileEventsSection(authProvider: authProvider),
          const SizedBox(height: 24),

          // Balance Box
          const BalanceBox(),
          const SizedBox(height: 24),

          // Coupons Box
          CouponsBox(vouchers: _personalVouchers),
          const SizedBox(height: 24),

          // Profile Actions (Delete Account, Logout)
          const ProfileActions(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error,
            size: 80,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.errorLoadingProfile,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.pleaseRetryLater,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
