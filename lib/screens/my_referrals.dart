import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pyjama_runner/screens/character_display_screen.dart';
import 'package:pyjama_runner/providers/providers.dart';
import 'package:pyjama_runner/utils/navigation.dart';
import 'package:pyjama_runner/widgets/app/Wrapper.dart';
import 'package:provider/provider.dart';

class MyReferrals extends StatelessWidget {
  final String userId;

  const MyReferrals({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          ReferralProvider()..loadReferralData("rashidiqbal" ?? userId),
      child: Wrapper(
        title: "My Referrals",
        onBack: () => to(context, const CharacterDisplayScreen()),
        child: const _MyReferralsContent(),
      ),
    );
  }
}

class _MyReferralsContent extends StatelessWidget {
  const _MyReferralsContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<ReferralProvider>(
      builder: (context, referralProvider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 36),
          child: ListView(
            children: [
              EarnMorePJCCard(totalEarnings: referralProvider.totalEarnings),
              const SizedBox(height: 32),
              ShareInviteLinkCard(
                referralCode: referralProvider.referralCode,
                onShare: referralProvider.shareReferralCode,
              ),
              const SizedBox(height: 16),
              const Text(
                'My Referrals',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  height: 0,
                ),
              ),
              const SizedBox(height: 24),
              Column(
                children: referralProvider.referrals
                    .map((referral) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ReferralTile(
                            name: referral['name'] ?? 'Unknown',
                            level: 'LV ${referral['level'] ?? 1}',
                            avatar: referral['avatar'] ??
                                "assets/icons/navigation/profile.png",
                            badge: "assets/images/pyjama/pyjama.png",
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class EarnMorePJCCard extends StatelessWidget {
  final int totalEarnings;

  const EarnMorePJCCard({super.key, required this.totalEarnings});

  @override
  Widget build(BuildContext context) {
    const double containerWidth = 177;
    const double imageHeight = 177;
    const Color textColor = Colors.white;

    const textStyle = TextStyle(
      color: textColor,
      fontSize: 24,
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w500,
      height: 1,
    );

    return SizedBox(
      width: containerWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset("assets/images/pyjama/pyjama.png", height: imageHeight),
          Text(
            'Earned $totalEarnings PJC',
            style: textStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ShareInviteLinkCard extends StatelessWidget {
  final String referralCode;
  final VoidCallback onShare;

  const ShareInviteLinkCard({
    super.key,
    required this.referralCode,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    // ... (keep the existing styling constants)
    const double containerWidth = 352;
    const double containerHeight = 369;
    const double imageWidth = 279;
    const double imageHeight = 151;
    const double buttonHeight = 47;
    const double borderRadius = 24.0;
    const double buttonBorderRadius = 40.0;
    const Color backgroundColor = Color(0xFF423F6B);
    const Color textColor = Color(0xFFEFF8FF);
    const Color buttonBorderColor = Colors.white;
    const Color shareButtonColor = Color(0xFF08FAFA);
    const Color shareTextColor = Color(0xFF272741);

    return Container(
      width: containerWidth,
      height: containerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Share your invite link',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w600,
              height: 0.07,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: imageWidth,
            height: imageHeight,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage("assets/images/pyjama/share-banner.png"),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: referralCode));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Referral code copied to clipboard')),
              );
            },
            child: Container(
              width: 278,
              height: buttonHeight,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: buttonBorderColor),
                borderRadius: BorderRadius.circular(buttonBorderRadius),
              ),
              child: Center(
                child: Text(
                  referralCode,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w400,
                    height: 0.17,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  height: buttonHeight,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(width: 2, color: buttonBorderColor),
                    borderRadius: BorderRadius.circular(buttonBorderRadius),
                  ),
                  child: const Center(
                    child: Text(
                      'Refer',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontSize: 16,
                        height: 0.09,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: onShare,
                  child: Container(
                    height: buttonHeight,
                    decoration: BoxDecoration(
                      color: shareButtonColor,
                      borderRadius: BorderRadius.circular(buttonBorderRadius),
                    ),
                    child: const Center(
                      child: Text(
                        'Share',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w500,
                          color: shareTextColor,
                          fontSize: 16,
                          height: 0.09,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ReferralTile extends StatelessWidget {
  final String name;
  final String level;
  final String avatar;
  final String badge;

  const ReferralTile({
    super.key,
    required this.name,
    required this.level,
    required this.avatar,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(avatar),
                radius: 25.0,
              ),
              const SizedBox(width: 12),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: ShapeDecoration(
              color: const Color(0x26B1B1B1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Row(
              children: [
                Image.asset(
                  badge,
                  width: 26,
                  height: 26,
                ),
                Text(
                  level,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
