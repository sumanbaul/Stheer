import 'package:flutter/material.dart';

class ResponsiveHelper {
  static double getBottomNavHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // For very small screens
    if (screenWidth < 320) {
      return 60;
    }
    // For small screens
    else if (screenWidth < 360) {
      return 65;
    }
    // For medium screens
    else if (screenWidth < 400) {
      return 70;
    }
    // For large screens
    else if (screenWidth < 480) {
      return 75;
    }
    // For very large screens
    else {
      return 80;
    }
  }

  static double getIconSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 320) {
      return 18;
    } else if (screenWidth < 360) {
      return 20;
    } else if (screenWidth < 400) {
      return 22;
    } else {
      return 24;
    }
  }

  static double getFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 320) {
      return 8;
    } else if (screenWidth < 360) {
      return 9;
    } else if (screenWidth < 400) {
      return 10;
    } else {
      return 11;
    }
  }

  static EdgeInsets getPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 320) {
      return EdgeInsets.symmetric(horizontal: 4, vertical: 2);
    } else if (screenWidth < 360) {
      return EdgeInsets.symmetric(horizontal: 6, vertical: 3);
    } else if (screenWidth < 400) {
      return EdgeInsets.symmetric(horizontal: 8, vertical: 4);
    } else {
      return EdgeInsets.symmetric(horizontal: 10, vertical: 5);
    }
  }

  static EdgeInsets getItemMargin(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 320) {
      return EdgeInsets.symmetric(horizontal: 1);
    } else if (screenWidth < 360) {
      return EdgeInsets.symmetric(horizontal: 1.5);
    } else if (screenWidth < 400) {
      return EdgeInsets.symmetric(horizontal: 2);
    } else {
      return EdgeInsets.symmetric(horizontal: 2.5);
    }
  }
} 
