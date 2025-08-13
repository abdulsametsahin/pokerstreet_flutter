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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap ?? () => _handleTap(context),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon or Image
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: banner.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          banner.imageUrl!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildDefaultIcon(context),
                        ),
                      )
                    : _buildDefaultIcon(context),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      banner.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (banner.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        banner.description!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (banner.expiresAt != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Expires ${_formatDate(banner.expiresAt!)}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultIcon(BuildContext context) {
    IconData iconData = Icons.campaign;

    if (banner.icon != null) {
      switch (banner.icon!.toLowerCase()) {
        case 'event':
          iconData = Icons.event;
          break;
        case 'gift':
          iconData = Icons.card_giftcard;
          break;
        case 'star':
          iconData = Icons.star;
          break;
        case 'celebration':
          iconData = Icons.celebration;
          break;
        case 'info':
          iconData = Icons.info;
          break;
        default:
          iconData = Icons.campaign;
      }
    }

    return Icon(
      iconData,
      color: Theme.of(context).colorScheme.primary,
      size: 24,
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
