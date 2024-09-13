import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:pyjama_runner/screens/character_display_screen.dart';
import 'package:pyjama_runner/screens/welcome_screen.dart';
import 'package:pyjama_runner/services/context_utility.dart';
import 'package:pyjama_runner/utils/hive.dart';
import 'package:pyjama_runner/utils/navigation.dart';
import 'package:app_links/app_links.dart';

class LinkServices {
  static init() async {
    try {
      AppLinks appLinks = AppLinks();

      appLinks.uriLinkStream.listen((uri) {
        log('onAppLink: $uri');
        uniHandler(uri);
      });
    } on PlatformException catch (e) {
      log("PlatformException", error: e, name: "UniServices");
    } on FormatException catch (e) {
      log("FormatException", error: e, name: "UniServices");
    }
  }

  static uniHandler(Uri? uri) {
    log("uri: $uri", name: "UniServices");
    if (uri == null || uri.queryParameters.isEmpty) return;
    Map<String, String> params = uri.queryParameters;
    String code = params['code'] ?? "";
    log("code: $code", name: "UniServices");

    if (ContextUtility.context == null) return; // Exit if the context is null

    getData("connected").then((connected) {
      if (connected != null && connected) {
        to(ContextUtility.context!, const CharacterDisplayScreen());
      }
      saveData("connected", true);
      to(ContextUtility.context!, const WelcomeScreen());
    });
  }
}
