import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

/// Renders a premium category access badge icon.
///
/// Parameters:
/// - [isPremium] - Bool indicating if category is premium.
/// - [hasUnlocked] - Bool indicating if premium category is unlocked.
///
class PremiumCategoryAccessBadge extends StatelessWidget {
  const PremiumCategoryAccessBadge({
    super.key,
    required this.hasUnlocked,
    required this.isPremium,
  });

  final bool isPremium;
  final bool hasUnlocked;

  static const _premiumIconSize = 20.0;

  @override
  Widget build(BuildContext context) {
    return isPremium && !hasUnlocked
        ? SvgPicture.asset(
            UiUtils.getImagePath("premium_icon.svg"),
            width: _premiumIconSize,
            height: _premiumIconSize,
          )
        : const SizedBox.shrink();
  }
}
