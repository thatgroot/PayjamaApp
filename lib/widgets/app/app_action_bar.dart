import 'package:flutter/material.dart';

class ActionItem {
  final IconData icon; // The type for icon is strictly IconData
  final VoidCallback
      action; // The type for action is a function that returns void

  ActionItem({
    required this.icon,
    required this.action,
  });
}

class AppActionBar extends StatelessWidget {
  final List<ActionItem> actions;
  final bool showBalance;
  final String balance;

  const AppActionBar(
      {super.key,
      this.showBalance = true,
      required this.actions,
      this.balance = "20"});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          !showBalance ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
      crossAxisAlignment:
          !showBalance ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        !showBalance
            ? Container()
            : Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/app/balance_bg.png"),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Image.asset(
                        "assets/images/app/pcoin.png",
                        width: 48,
                        fit: BoxFit.cover,
                      ),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 6),
                    Container(
                      height: 64,
                      width: 42, // Set a fixed width for the container
                      alignment:
                          Alignment.center, // Align the text in the center
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          8,
                        ), // Optional: rounding the corners
                      ),
                      child: Text(
                        balance,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Rubik',
                          fontWeight: FontWeight.w600,
                          height: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: Image.asset("assets/images/app/add_green.png"),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
        Row(
          children: actions.map((actionItem) {
            return GestureDetector(
              onTap: actionItem.action, // Trigger the action
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset("assets/images/app/blue_block.png"),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Icon(
                      actionItem.icon, // Display the icon
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
