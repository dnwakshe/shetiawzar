import 'package:flutter/material.dart';

/// Standard responsive breakpoints for Wakshe Agrotech:
/// - Mobile: width below 600px
/// - Tablet: 600px–1023px
/// - Desktop: 1024px and above
class ResponsiveBreakpoints {
  ResponsiveBreakpoints._();

  static const double mobileMax = 599.9;
  static const double tabletMin = 600.0;
  static const double desktopMin = 1024.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < tabletMin;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= tabletMin && width < desktopMin;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktopMin;
}
