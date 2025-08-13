import 'package:flutter/material.dart';

import '../../models/banner.dart' as BannerModel;
import 'banner_card.dart';

class BannersSection extends StatelessWidget {
  final List<BannerModel.Banner> banners;

  const BannersSection({
    super.key,
    required this.banners,
  });

  @override
  Widget build(BuildContext context) {
    final validBanners = banners.where((banner) => banner.isValid).toList();

    if (validBanners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...validBanners
            .map(
              (banner) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BannerCard(banner: banner),
              ),
            )
            .toList(),
      ],
    );
  }
}
