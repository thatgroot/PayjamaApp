import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pyjamaapp/config.dart';
import 'package:pyjamaapp/config/linking.dart';
import 'package:pyjamaapp/providers/wallet.dart';
import 'package:pyjamaapp/screens/pyjama/character_display.dart';
import 'package:pyjamaapp/providers/game.dart';
import 'package:pyjamaapp/services/context_utility.dart';
import 'package:pyjamaapp/services/firebase.dart';
import 'package:pyjamaapp/services/hive.dart';
import 'package:pyjamaapp/services/referral_calculator.dart';
import 'package:pyjamaapp/services/referral_service.dart';
import 'package:pyjamaapp/services/solana_wallet_service.dart';
import 'package:pyjamaapp/utils/navigation.dart';
import 'package:pyjamaapp/widgets/app/Wrapper.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class ReferralsScreen extends StatefulWidget {
  static String route = "/referrals";
  const ReferralsScreen({super.key});

  @override
  State<ReferralsScreen> createState() => _ReferralsState();
}

class _ReferralsState extends State<ReferralsScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<String> _fetchReferralCode() async {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final FirestoreService firestoreService = FirestoreService();

    try {
      final doc =
          await firestoreService.getDocument("info", walletProvider.publicKey!);
      return doc.get('id') as String;
    } catch (error) {
      log("Error fetching document: $error");
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _fetchReferralCode(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Wrapper(
            title: "My Referrals",
            onBack: () => to(context, CharacterDisplayScreen.route),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final referralCode = snapshot.data ?? "";
          return Wrapper(
            title: "My Referrals",
            onBack: () => to(context, CharacterDisplayScreen.route),
            child: SingleChildScrollView(
              child: _ReferralsContent(code: referralCode),
            ),
          );
        }
      },
    );
  }
}

class ShareInviteLinkCard extends StatelessWidget {
  final VoidCallback onShare;
  final String code;

  const ShareInviteLinkCard({
    super.key,
    required this.onShare,
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    const double containerWidth = 352;
    const double imageWidth = 278;
    const double imageHeight = 156;
    const double buttonHeight = 42;
    const double borderRadius = 24.0;
    const double buttonBorderRadius = 40.0;
    const Color backgroundColor = Color(0xFF423F6B);
    const Color textColor = Color(0xFFEFF8FF);
    const Color buttonBorderColor = Colors.white;
    const Color shareButtonColor = Color(0xFF08FAFA);
    const Color shareTextColor = Color(0xFF272741);

    return Container(
      width: containerWidth,
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
                fit: BoxFit.fitHeight,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Referral code copied to clipboard'),
                ),
              );
            },
            child: Container(
              width: 278,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: buttonBorderColor),
                borderRadius: BorderRadius.circular(buttonBorderRadius),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Referral Code: $code",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w400,
                      height: 0.17,
                    ),
                  ),
                  IconButton(
                    hoverColor: Colors.black38,
                    iconSize: 24.0,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                          text:
                              "${LinkingConfig.deepLink}${WalletConfig.toReferral}?code=$code"));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Referral Link copied to clipboard'),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.copy_all_outlined,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
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
        ],
      ),
    );
  }
}

class _ReferralsContent extends StatefulWidget {
  final String code;
  const _ReferralsContent({required this.code});

  @override
  State<_ReferralsContent> createState() => _ReferralsContentState();
}

class _ReferralsContentState extends State<_ReferralsContent> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final referralProvider =
          Provider.of<ReferralProvider>(context, listen: false);
      referralProvider.loadReferralData(widget.code);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReferralProvider>(
      builder: (context, referralProvider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 36),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const EarnMorePJCCard(),
                const SizedBox(height: 32),
                ShareInviteLinkCard(
                  onShare: () async {
                    await Share.share(
                        'Join Pyjama Runner using my referral code: ${widget.code}');
                  },
                  code: widget.code,
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
                              name: referral['name'] ?? "unknown",
                              level: 'Depth ${referral['level'] ?? 1}',
                              avatar: "assets/icons/navigation/profile.png",
                              badge: "assets/images/pyjama/pyjama.png",
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class EarnMorePJCCard extends StatefulWidget {
  const EarnMorePJCCard({super.key});

  @override
  State<EarnMorePJCCard> createState() => _EarnMorePJCCardState();
}

class _EarnMorePJCCardState extends State<EarnMorePJCCard> {
  double totalEarnings = 0;
  @override
  void initState() {
    super.initState();

    fetchScores();
  }

  void fetchScores() async {
    var levelScores = await HiveService.getLevlScores();
    final referralProvider =
        Provider.of<ReferralProvider>(ContextUtility.context!, listen: false);
    ReferralService s = ReferralService();
    var data = await s.getPerLevelReferrals(referralProvider.referrals);
    var rewardData = {
      "gameScores": {
        1: GameScore(
          levels: levelScores[GameNames.brickBreaker.toString()] ?? {},
        ),
        2: GameScore(
          levels: levelScores[GameNames.fruitNinja.toString()] ?? {},
        ),
        3: GameScore(
          levels: levelScores[GameNames.runner.toString()] ?? {},
        ),
      },
      "nftsHeld": 2,
      "tokensHeld": 1500,
      "referralsPerLevel": data,
    };

    log("reward data $rewardData");

    RewardCalculator calculator = RewardCalculator(
      gameScores: {
        1: GameScore(
          levels: levelScores[GameNames.brickBreaker.toString()] ?? {},
        ),
        2: GameScore(
          levels: levelScores[GameNames.fruitNinja.toString()] ?? {},
        ),
        3: GameScore(
          levels: levelScores[GameNames.runner.toString()] ?? {},
        ),
      },
      nftsHeld: 2,
      tokensHeld: 1500,
      referralsPerLevel: data,
    );

    double rewards = calculator.calculateTotalReward();
    // {
    //     GameNames.runner.toString():
    //         gameScoresData[GameNames.runner.toString()]!,
    //     GameNames.brickBreaker.toString():
    //         gameScoresData[GameNames.brickBreaker.toString()]!,
    //     GameNames.fruitNinja.toString():
    //         gameScoresData[GameNames.fruitNinja.toString()]!,
    //   };
    setState(() {
      totalEarnings = rewards;
    });
  }

  @override
  Widget build(BuildContext context) {
    const double containerWidth = 177;
    const double imageHeight = 177;
    const Color textColor = Colors.white;

    const textStyle = TextStyle(
      color: textColor,
      fontSize: 18,
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
          SizedBox(height: 24),
          GestureDetector(
            onTap: () async {
              SolanaWalletService solanaWalletService = SolanaWalletService();
              await solanaWalletService.transferFn();
            },
            child: Container(
              width: 160,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: ShapeDecoration(
                color: const Color(0x26B1B1B1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    "assets/images/pyjama/pyjama.png",
                    width: 26,
                    height: 26,
                  ),
                  Text(
                    "Withdraw Tokens",
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
