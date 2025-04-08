import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import '../models/settings.dart';

class AppTheme {
  // 获取平台相关的字体
  static String getFontFamily() {
    if (Platform.isWindows) {
      // Windows平台使用系统自带字体，不需要额外加载字体文件
      return 'Microsoft YaHei UI';
    } else {
      return 'HMOSRegular'; // 其他平台使用原有字体
    }
  }

  // 主题颜色映射表
  static const Map<AppThemeColor, Color> themeColors = {
    AppThemeColor.red: Color(0xFFE53935), // 红色，番茄色
    AppThemeColor.blue: Color(0xFF1976D2), // 蓝色
    AppThemeColor.green: Color(0xFF4CAF50), // 绿色
    AppThemeColor.purple: Color(0xFF9C27B0), // 紫色
    AppThemeColor.orange: Color(0xFFFF9800), // 橙色
    AppThemeColor.teal: Color(0xFF009688), // 蓝绿色
  };

  // 获取主题主色调
  static Color getPrimaryColor(AppThemeColor themeColor) {
    switch (themeColor) {
      case AppThemeColor.red:
        return const Color(0xFFE57373);
      case AppThemeColor.blue:
        return const Color(0xFF64B5F6);
      case AppThemeColor.green:
        return const Color(0xFF81C784);
      case AppThemeColor.purple:
        return const Color(0xFFBA68C8);
      case AppThemeColor.orange:
        return const Color(0xFFFFB74D);
      case AppThemeColor.teal:
        return const Color(0xFF4DB6AC);
    }
  }

  // 获取主题亮色调
  static Color getPrimaryLightColor(AppThemeColor themeColor) {
    switch (themeColor) {
      case AppThemeColor.red:
        return const Color(0xFFFFCDD2);
      case AppThemeColor.blue:
        return const Color(0xFFBBDEFB);
      case AppThemeColor.green:
        return const Color(0xFFC8E6C9);
      case AppThemeColor.purple:
        return const Color(0xFFE1BEE7);
      case AppThemeColor.orange:
        return const Color(0xFFFFE0B2);
      case AppThemeColor.teal:
        return const Color(0xFFB2DFDB);
    }
  }

  // 获取主题暗色调
  static Color getPrimaryDarkColor(AppThemeColor themeColor) {
    switch (themeColor) {
      case AppThemeColor.red:
        return const Color(0xFFEF5350);
      case AppThemeColor.blue:
        return const Color(0xFF42A5F5);
      case AppThemeColor.green:
        return const Color(0xFF66BB6A);
      case AppThemeColor.purple:
        return const Color(0xFFAB47BC);
      case AppThemeColor.orange:
        return const Color(0xFFFFA726);
      case AppThemeColor.teal:
        return const Color(0xFF26A69A);
    }
  }

  // 获取强调色
  static Color getAccentColor(AppThemeColor themeColor) {
    switch (themeColor) {
      case AppThemeColor.red:
        return const Color(0xFF42A5F5); // 蓝色作为红色主题的强调色
      case AppThemeColor.blue:
        return const Color(0xFFFF7043); // 橙色作为蓝色主题的强调色
      case AppThemeColor.green:
        return const Color(0xFFAB47BC); // 紫色作为绿色主题的强调色
      case AppThemeColor.purple:
        return const Color(0xFF66BB6A); // 绿色作为紫色主题的强调色
      case AppThemeColor.orange:
        return const Color(0xFF5C6BC0); // 靛蓝色作为橙色主题的强调色
      case AppThemeColor.teal:
        return const Color(0xFFEC407A); // 粉红色作为蓝绿色主题的强调色
    }
  }

  // 获取休息时的颜色（保持为绿色）
  static const Color accentColor = Color(0xFF81C784);

  // 获取浅色主题
  static ThemeData getLightTheme({
    AppThemeColor themeColor = AppThemeColor.red,
  }) {
    final primaryColor = getPrimaryColor(themeColor);
    final primaryLightColor = getPrimaryLightColor(themeColor);
    final accentColor = getAccentColor(themeColor);

    // 创建完整的颜色方案
    final colorScheme = ColorScheme.light(
      primary: primaryColor,
      primaryContainer: primaryLightColor,
      secondary: accentColor,
      error: Colors.red.shade700,
      background: Colors.grey.shade50,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onBackground: Colors.black87,
      onSurface: Colors.black87,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: getFontFamily(),
      colorScheme: colorScheme,
      // 使用colorScheme替代单独设置primaryColor
      scaffoldBackgroundColor: colorScheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      cardTheme: CardTheme(
        color: colorScheme.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: Colors.grey.shade600,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          minimumSize: const Size(120, 50),
          elevation: 2,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          minimumSize: const Size(120, 50),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return colorScheme.primary;
          }
          return Colors.grey.shade400;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return colorScheme.primaryContainer.withOpacity(0.5);
          }
          return Colors.grey.shade300;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: Colors.grey.shade300,
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withOpacity(0.2),
        valueIndicatorColor: colorScheme.primary,
        valueIndicatorTextStyle: TextStyle(color: colorScheme.onPrimary),
      ),
      tabBarTheme: TabBarTheme(
        labelColor: colorScheme.primary,
        unselectedLabelColor: Colors.grey.shade600,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade200,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        tileColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        primaryColor: colorScheme.primary,
        barBackgroundColor: colorScheme.surface,
        scaffoldBackgroundColor: colorScheme.background,
      ),
    );
  }

  // 获取暗色主题
  static ThemeData getDarkTheme({
    AppThemeColor themeColor = AppThemeColor.red,
  }) {
    final primaryColor = getPrimaryColor(themeColor);
    final primaryDarkColor = getPrimaryDarkColor(themeColor);
    final primaryLightColor = getPrimaryLightColor(themeColor);
    final accentColor = getAccentColor(themeColor);

    // 创建完整的暗色调颜色方案
    final colorScheme = ColorScheme.dark(
      primary: primaryColor,
      primaryContainer: primaryDarkColor,
      secondary: accentColor,
      tertiary: primaryLightColor,
      error: Colors.red.shade300,
      background: const Color(0xFF121212),
      surface: const Color(0xFF1E1E1E),
      surfaceVariant: const Color(0xFF2C2C2C),
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onTertiary: Colors.white,
      onBackground: Colors.white,
      onSurface: Colors.white,
      onError: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: getFontFamily(),
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      cardTheme: CardTheme(
        color: colorScheme.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.tertiary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          minimumSize: const Size(120, 50),
          elevation: 2,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.tertiary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.tertiary,
          side: BorderSide(color: colorScheme.tertiary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          minimumSize: const Size(120, 50),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.tertiary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return colorScheme.tertiary;
          }
          return Colors.grey;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return colorScheme.primary.withOpacity(0.5);
          }
          return Colors.grey.shade800;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.tertiary,
        inactiveTrackColor: Colors.grey.shade800,
        thumbColor: colorScheme.tertiary,
        overlayColor: colorScheme.tertiary.withOpacity(0.2),
        valueIndicatorColor: colorScheme.tertiary,
        valueIndicatorTextStyle: TextStyle(color: colorScheme.onTertiary),
      ),
      tabBarTheme: TabBarTheme(
        labelColor: colorScheme.tertiary,
        unselectedLabelColor: Colors.grey,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: colorScheme.tertiary, width: 2),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade800,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        tileColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        primaryColor: colorScheme.tertiary,
        barBackgroundColor: colorScheme.surface,
        scaffoldBackgroundColor: colorScheme.background,
        textTheme: CupertinoTextThemeData(primaryColor: colorScheme.tertiary),
      ),
    );
  }
}
