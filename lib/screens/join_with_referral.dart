import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pyjama_runner/screens/character_display_screen.dart';
import 'package:pyjama_runner/services/context_utility.dart';
import 'package:pyjama_runner/providers/providers.dart';
import 'package:pyjama_runner/utils/navigation.dart';
import 'package:pyjama_runner/widgets/app/Wrapper.dart';
import 'package:provider/provider.dart';

class JoinWithReferralScreen extends StatelessWidget {
  final String userId;

  const JoinWithReferralScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReferralJoinProvider(),
      child: Wrapper(
        title: "Join with Referral",
        onBack: () => {to(context, const CharacterDisplayScreen())},
        child: _JoinWithReferralContent(userId: userId),
      ),
    );
  }
}

class _JoinWithReferralContent extends StatefulWidget {
  final String userId;

  const _JoinWithReferralContent({required this.userId});

  @override
  _JoinWithReferralContentState createState() =>
      _JoinWithReferralContentState();
}

class _JoinWithReferralContentState extends State<_JoinWithReferralContent> {
  final TextEditingController _referralCodeController = TextEditingController();

  @override
  void dispose() {
    _referralCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReferralJoinProvider>(
      builder: (context, referralJoinProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter Referral Code',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _referralCodeController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter referral code',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.content_paste, color: Colors.white),
                    onPressed: () async {
                      ClipboardData? data =
                          await Clipboard.getData(Clipboard.kTextPlain);
                      if (data != null && data.text != null) {
                        _referralCodeController.text = data.text!;
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: referralJoinProvider.isLoading
                    ? null
                    : () async {
                        if (_referralCodeController.text.isNotEmpty) {
                          bool success =
                              await referralJoinProvider.joinWithReferralCode(
                            widget.userId,
                            _referralCodeController.text,
                          );
                          if (success) {
                            // Navigate to the next screen or show success message
                            ScaffoldMessenger.of(ContextUtility.context!)
                                .showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Successfully joined with referral code!')),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color(0xFF08FAFA),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: referralJoinProvider.isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Join',
                        style: TextStyle(
                          color: Color(0xFF272741),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              if (referralJoinProvider.errorMessage.isNotEmpty)
                Text(
                  referralJoinProvider.errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to sign up without referral
                },
                child: const Text(
                  'Don\'t have a referral code? Sign up here',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
