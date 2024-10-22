import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:pyjamaapp/providers/game.dart';
import 'package:pyjamaapp/providers/wallet.dart';

List<SingleChildWidget> appProviders = [
  ChangeNotifierProvider(create: (_) => ReferralProvider()),
  ChangeNotifierProvider(create: (_) => ReferralJoinProvider()),
  ChangeNotifierProvider(create: (_) => GlobalGameProvider()),
  ChangeNotifierProvider(create: (_) => BrickBreakerGameProvider()),
  ChangeNotifierProvider(create: (_) => FruitNinjaGameProvider()),
  ChangeNotifierProvider(create: (_) => WalletProvider()),
];
