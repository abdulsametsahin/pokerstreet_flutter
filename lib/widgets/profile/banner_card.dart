import 'package:flutter/material.dart';

import '../../models/banner.dart' as BannerModel;
import '../../screens/webview_screen.dart';

class BannerCard extends StatelessWidget {
  final BannerModel.Banner banner;
  final VoidCallback? onTap;

  const BannerCard({
    super.key,
    required this.banner,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ?? () => _handleTap(context),
        child: Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            image: banner.imageUrl != null
                ? DecorationImage(
                    image: NetworkImage(banner.imageUrl!),
                    fit: BoxFit.cover,
                    onError: (error, stackTrace) {
                      // Handle image loading error silently
                    },
                  )
                : null,
            gradient: banner.imageUrl == null
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                  )
                : null,
          ),
          child: Container(
            // Add a subtle dark overlay to ensure text readability
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.4),
                ],
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                // Title positioned on the left/center
                Positioned(
                  top: 8,
                  left: 0,
                  right: 60, // Leave space for expiry date
                  child: Text(
                    banner.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Expiry date positioned at bottom right
                if (banner.expiresAt != null)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Expires ${_formatDate(banner.expiresAt!)}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) async {
    if (banner.linkUrl != null && banner.linkUrl!.isNotEmpty) {
      // Open the link in internal webview
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WebViewScreen(
            url: banner.linkUrl!,
            title: banner.title,
          ),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Soon';
    }
  }
}
