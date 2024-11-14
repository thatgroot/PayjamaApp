import 'package:flutter/material.dart';
import 'package:pyjamaapp/screens/games.dart';
import 'package:pyjamaapp/screens/referrals_screen.dart';
import 'package:pyjamaapp/screens/web3/marketplace.dart';
import 'package:pyjamaapp/screens/account/user_profile.dart';
import 'package:pyjamaapp/services/context_utility.dart';
import 'package:pyjamaapp/utils/navigation.dart';

class MenuItem {
  final String icon;
  final String title;
  final String route;

  MenuItem({
    required this.icon,
    required this.title,
    required this.route,
  });
}

class SideBar extends StatelessWidget {
  final VoidCallback onClose;
  final List<MenuItem> menuItems = [
    MenuItem(icon: 'profile.png', title: 'Profile', route: UserProfile.route),
    MenuItem(icon: 'tasks.png', title: 'Daily Tasks', route: GamesScreen.route),
    MenuItem(icon: 'buy-nft.png', title: 'Buy NFTs', route: MarketPlace.route),
    MenuItem(
      icon: 'referrals.png',
      title: 'Referrals',
      route: ReferralsScreen.route,
    ),
  ];

  SideBar({super.key, required this.onClose});

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
                      onTap: () {
                        // onClose();
                        to(ContextUtility.context!, UserProfile.route);
                      },
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
              ...menuItems.map((item) {
                return _buildMenuItem(
                  icon: 'assets/icons/navigation/${item.icon}',
                  title: item.title,
                  onTap: () {
                    to(context, item.route);
                  },
                );
              }),
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
