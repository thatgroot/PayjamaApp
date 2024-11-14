import 'package:flutter/material.dart';
import 'package:pyjamaapp/screens/app_screen.dart';
import 'package:pyjamaapp/services/solana_wallet_service.dart';
import 'package:pyjamaapp/utils/navigation.dart';
import 'package:pyjamaapp/widgets/app/Wrapper.dart';

class MarketPlace extends StatelessWidget {
  const MarketPlace({super.key});
  static String route = "/buy_nfts";
  @override
  Widget build(BuildContext context) {
    return Wrapper(
      title: "Buy NFTs",
      onBack: () {
        to(context, PyjamaAppScreen.route);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              searchSection(),
              const SizedBox(height: 24),
              // GridView Section
              GridView.builder(
                physics:
                    const NeverScrollableScrollPhysics(), // Disable GridView's internal scrolling
                shrinkWrap:
                    true, // Make GridView take up only the space it needs
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                  childAspectRatio: 0.59,
                ),
                itemCount: 6, // Number of items to display
                itemBuilder: (context, index) {
                  return _buildProductCard(
                    image:
                        'assets/images/pyjama/characters/shiba-pyjama-gruen-kreise.png',
                    title: 'Pyjama #${index + 1}',
                    price: '1 SOL',
                    colors: ['Pink', 'Sad', 'Blue Eyes'],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget searchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Do you have an invitation code? Enter the code below to get 10% Discount!',
          style: TextStyle(
            color: Color(0xFF08FAFA),
            fontSize: 14,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: const Color(0xFF423F6B).withAlpha(120),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter Invitation Code Here',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.43),
                      fontSize: 14,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Container(
                width: 124,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF08FAFA),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Submit',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF272741),
                    fontSize: 14,
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard({
    required String image,
    required String title,
    required String price,
    required List<String> colors,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFF423F6B).withAlpha(100),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                Positioned(
                  child: Image.asset(
                    "assets/icons/solana.png",
                    height: 24,
                    width: 24,
                  ),
                ),
                Container(
                  height: 130,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(image),
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.17),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Center(
                        child: Text(
                          price,
                          style: const TextStyle(
                            color: Color(0xFFFED127),
                            fontSize: 14,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 20, // Fixed height to avoid overflow
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: colors.map((color) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(
                          child: Text(
                            color,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 13),
                GestureDetector(
                  onTap: () async {
                    SolanaWalletService walletService = SolanaWalletService();
                    await walletService.mintFn();
                  },
                  child: Container(
                    width: 129,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF08FAFA),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Center(
                      child: Text(
                        'Buy Now',
                        style: TextStyle(
                          color: Color(0xFF272741),
                          fontSize: 14,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
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
