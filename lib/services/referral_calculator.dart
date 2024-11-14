import 'package:provider/provider.dart';
import 'package:pyjamaapp/providers/game.dart';
import 'package:pyjamaapp/services/context_utility.dart';
import 'package:pyjamaapp/services/hive.dart';
import 'package:pyjamaapp/services/referral_service.dart';

class GameScore {
  final Map<int, int> levels;

  GameScore({required this.levels});
}

class RewardCalculator {
  late Map<int, GameScore> gameScores;
  late int nftsHeld;
  late int tokensHeld;
  late Map<int, int> referralsPerLevel;

  static const double nftRewardMultiplier = 0.5;
  static const double tokenRewardMultiplier = 0.2;
  static const double referralRewardMultiplier = 0.1;
  static const double maxReferralLevel = 10;
  static const int maxGameLevel = 8;

  double calculateBaseReward(GameScore gameScore) {
    double totalBaseReward = 0;
    gameScore.levels.forEach((level, score) {
      double levelMultiplier = 1 + (level * 0.05);
      totalBaseReward += score * 0.1 * levelMultiplier;
    });
    return totalBaseReward;
  }

  double _calculateNFTReward() {
    return nftsHeld * nftRewardMultiplier;
  }

  double _calculateTokenReward() {
    return tokensHeld * tokenRewardMultiplier;
  }

  double _calculateReferralReward() {
    double totalReferralReward = 0;
    for (int level = 1; level <= maxReferralLevel; level++) {
      totalReferralReward +=
          (referralsPerLevel[level] ?? 0) * referralRewardMultiplier;
    }
    return totalReferralReward;
  }

  Future<double> calculateTokenRewards() async {
    var levelScores = await HiveService.getLevlScores();
    final referralProvider =
        Provider.of<ReferralProvider>(ContextUtility.context!, listen: false);
    ReferralService s = ReferralService();
    var data = await s.getPerLevelReferrals(referralProvider.referrals);

    gameScores = {
      1: GameScore(
        levels: levelScores[GameNames.brickBreaker.toString()] ?? {},
      ),
      2: GameScore(
        levels: levelScores[GameNames.fruitNinja.toString()] ?? {},
      ),
      3: GameScore(
        levels: levelScores[GameNames.runner.toString()] ?? {},
      ),
    };

    nftsHeld = 2;
    tokensHeld = 1500;
    referralsPerLevel = data;

    return _calculateTotalReward();
  }

  double _calculateTotalReward() {
    double totalBaseReward = 0;

    gameScores.forEach((gameNumber, gameScore) {
      totalBaseReward += calculateBaseReward(gameScore);
    });

    double nftReward = _calculateNFTReward();
    double tokenReward = _calculateTokenReward();
    double referralReward = _calculateReferralReward();

    return double.parse(
      (totalBaseReward + nftReward + tokenReward + referralReward)
          .toStringAsFixed(2),
    );
  }
}
