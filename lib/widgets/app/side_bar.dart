import 'package:flutter/material.dart';
import 'package:pyjama_runner/screens/buy_nfts.dart';
import 'package:pyjama_runner/screens/daily_tasks.dart';
import 'package:pyjama_runner/screens/join_with_referral.dart';
import 'package:pyjama_runner/screens/my_referrals.dart';
import 'package:pyjama_runner/screens/user_profile.dart';

class SideBar extends StatelessWidget {
  final VoidCallback onClose;

  const SideBar({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF121222),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'PyjamaCoin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GestureDetector(
                      onTap: onClose,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image:
                                AssetImage('assets/images/pyjama/pyjama.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildMenuItem(
                icon: 'assets/icons/navigation/profile.png',
                title: 'Profile',
                onTap: () {
                  // Handle Profile tap
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfile(),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                icon: 'assets/icons/navigation/tasks.png',
                title: 'Daily Tasks',
                onTap: () {
                  // Handle Daily Tasks tap
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const DailyTasks()),
                  );
                },
              ),
              _buildMenuItem(
                icon: 'assets/icons/navigation/buy-nft.png',
                title: 'Buy NFTs',
                onTap: () {
                  // Handle Buy NFTs tap
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BuyNfts(),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                icon: 'assets/icons/navigation/referrals.png',
                title: 'My Referrals',
                onTap: () {
                  // Handle My Referrals tap
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyReferrals(
                        userId: "rashidiqbal",
                      ),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                icon: 'assets/icons/navigation/referrals.png',
                title: 'Join With Referrals',
                onTap: () {
                  // Handle My Referrals tap
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const JoinWithReferralScreen(
                        userId: "rashidiqbal",
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
      {required String icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Image.asset(
        icon,
        width: 24,
        height: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.white,
      ),
      onTap: onTap,
    );
  }
}
