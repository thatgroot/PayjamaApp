class GameScore {
  final Map<int, int> levels;

  GameScore({required this.levels});
}

class RewardCalculator {
  final Map<int, GameScore> gameScores;
  final int nftsHeld;
  final int tokensHeld;
  final Map<int, int> referralsPerLevel;

  RewardCalculator({
    required this.gameScores,
    required this.nftsHeld,
    required this.tokensHeld,
    required this.referralsPerLevel,
  });

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

  double calculateNFTReward() {
    return nftsHeld * nftRewardMultiplier;
  }

  double calculateTokenReward() {
    return tokensHeld * tokenRewardMultiplier;
  }

  double calculateReferralReward() {
    double totalReferralReward = 0;
    for (int level = 1; level <= maxReferralLevel; level++) {
      totalReferralReward +=
          (referralsPerLevel[level] ?? 0) * referralRewardMultiplier;
    }
    return totalReferralReward;
  }

  double calculateTotalReward() {
    double totalBaseReward = 0;

    gameScores.forEach((gameNumber, gameScore) {
      totalBaseReward += calculateBaseReward(gameScore);
    });

    double nftReward = calculateNFTReward();
    double tokenReward = calculateTokenReward();
    double referralReward = calculateReferralReward();

    return double.parse(
      (totalBaseReward + nftReward + tokenReward + referralReward)
          .toStringAsFixed(2),
    );
  }
}
