import 'package:flutter/material.dart';
import 'package:pyjama_runner/screens/CharacterDisplayScreen.dart';
import 'package:pyjama_runner/utils/navigation.dart';
import 'package:pyjama_runner/widgets/app/Wrapper.dart';

class MyReferrals extends StatelessWidget {
  const MyReferrals({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrapper(
      title: "My Referrals",
      onBack: () {
        to(context, const CharacterDisplayScreen());
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 36),
        child: ListView(
          children: const [
            EarnMorePJCCard(),
            SizedBox(height: 32),
            ShareInviteLinkCard(),
            SizedBox(height: 16),
            Text(
              'My Referrals',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
                height: 0,
              ),
            ),
            SizedBox(height: 24),
            Column(
              children: [
                ReferralTile(
                  name: 'Babar',
                  level: 'LV 2',
                  avatar: "assets/icons/navigation/profile.png",
                  badge: "assets/images/pyjama/pyjama.png",
                ),
                SizedBox(height: 10),
                ReferralTile(
                  name: 'Karim',
                  level: 'LV 3',
                  avatar: "assets/icons/navigation/profile.png",
                  badge: "assets/images/pyjama/pyjama.png",
                ),
                SizedBox(height: 10),
                ReferralTile(
                  name: 'Tariqo',
                  level: 'LV 4',
                  avatar: "assets/icons/navigation/profile.png",
                  badge: "assets/images/pyjama/pyjama.png",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EarnMorePJCCard extends StatelessWidget {
  const EarnMorePJCCard({super.key});

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
          const Text(
            'Earn More PJC',
            style: textStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ShareInviteLinkCard extends StatelessWidget {
  const ShareInviteLinkCard({super.key});

  @override
  Widget build(BuildContext context) {
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

    const textStyle = TextStyle(
      fontFamily: 'Outfit',
      fontWeight: FontWeight.w500,
      color: Colors.white,
      fontSize: 16,
      height: 0.09,
    );

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
          Container(
            width: 278,
            height: buttonHeight,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: buttonBorderColor),
              borderRadius: BorderRadius.circular(buttonBorderRadius),
            ),
            child: const Center(
              child: Text(
                'https://pyjama-coin.com/ref=PJC123',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w400,
                  height: 0.17,
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
                  child: Center(
                    child: Text(
                      'Refer',
                      textAlign: TextAlign.center,
                      style: textStyle.copyWith(fontSize: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: buttonHeight,
                  decoration: BoxDecoration(
                    color: shareButtonColor,
                    borderRadius: BorderRadius.circular(buttonBorderRadius),
                  ),
                  child: Center(
                    child: Text(
                      'Share',
                      textAlign: TextAlign.center,
                      style: textStyle.copyWith(
                        fontSize: 16,
                        color: shareTextColor,
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
