import 'package:flutter/material.dart';

/// Small logo mark (the swirl/treble-clef graphic, cropped from the full
/// wordmark — see `assets/images/logo_icon.png`) for the leading slot of
/// a top-level screen's AppBar.
class AppLogoIcon extends StatelessWidget {
  const AppLogoIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset('assets/images/logo_icon.png'),
      ),
    );
  }
}
