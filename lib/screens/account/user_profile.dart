import 'package:flutter/material.dart';
import 'package:pyjamaapp/screens/app_screen.dart';
import 'package:pyjamaapp/services/hive.dart';
import 'package:pyjamaapp/services/referral_calculator.dart';
import 'package:pyjamaapp/services/solana_wallet_service.dart';
import 'package:pyjamaapp/utils/navigation.dart';
import 'package:pyjamaapp/widgets/app/wrapper.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  static String route = "/profile";

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  double earnings = 0;
  @override
  void initState() {
    super.initState();

    init();
  }

  void init() async {
    RewardCalculator calculator = RewardCalculator();
    var rewardsTotal = await calculator.calculateTokenRewards();

    setState(() {
      earnings = rewardsTotal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wrapper(
      onBack: () {
        to(context, PyjamaAppScreen.route);
      },
      title: 'My Profile',
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 56,
                backgroundImage:
                    AssetImage('assets/icons/navigation/profile.png'),
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: [
                Container(
                  height: 36,
                  width: 172,
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                    color: const Color(0x35C6C6C6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: FutureBuilder(
                      future: HiveService.getData(HiveKeys.userPublicKey),
                      initialData: "",
                      builder: (context, snapshot) {
                        var pubkey = snapshot.data as String;
                        return Text(
                          pubkey.isEmpty
                              ? ""
                              : "${pubkey.substring(0, 12)}...${pubkey.substring(pubkey.length - 4, pubkey.length - 1)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        );
                      }),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 36,
                  width: 172,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: ShapeDecoration(
                    color: const Color(0x35C6C6C6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events,
                          color: const Color(0xFFFFD33A), size: 28.0),
                      const SizedBox(width: 4),
                      Text(
                        '$earnings PJC',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 40),
            // _buildMenuItem(Icons.settings, 'Settings'),
            _buildMenuItem(Icons.exit_to_app, 'Logout', isLogout: true),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {bool isLogout = false}) {
    return GestureDetector(
      onTap: () {
        SolanaWalletService.disConnect();
      },
      child: Container(
        width: 172,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(icon,
                color: isLogout
                    ? const Color(0xFFEC5D5D)
                    : const Color(0xFFFED127)),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isLogout ? Colors.redAccent : Colors.white,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: isLogout ? Colors.redAccent : Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
