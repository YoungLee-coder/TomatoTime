import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/settings.dart';

class AppTheme {
  // 主题颜色映射表
  static const Map<AppThemeColor, Color> themeColors = {
    AppThemeColor.red: Color(0xFFE53935), // 红色，番茄色
    AppThemeColor.blue: Color(0xFF1976D2), // 蓝色
    AppThemeColor.green: Color(0xFF4CAF50), // 绿色
    AppThemeColor.purple: Color(0xFF9C27B0), // 紫色
    AppThemeColor.orange: Color(0xFFFF9800), // 橙色
    AppThemeColor.teal: Color(0xFF009688), // 蓝绿色
  };

  // 获取当前主题颜色
  static Color getPrimaryColor(AppThemeColor themeColor) {
    return themeColors[themeColor] ?? themeColors[AppThemeColor.red]!;
  }

  // 获取当前主题浅色变体
  static Color getPrimaryLightColor(AppThemeColor themeColor) {
    // 浅色变体 - 根据主色生成
    final Color baseColor = getPrimaryColor(themeColor);
    return Color.lerp(baseColor, Colors.white, 0.3)!;
  }

  // 获取当前主题深色变体
  static Color getPrimaryDarkColor(AppThemeColor themeColor) {
    // 深色变体 - 根据主色生成
    final Color baseColor = getPrimaryColor(themeColor);
    return Color.lerp(baseColor, Colors.black, 0.2)!;
  }

  // 获取休息时的颜色（保持为绿色）
  static const Color accentColor = Color(0xFF81C784);

  // 获取浅色主题
  static ThemeData getLightTheme({
    AppThemeColor themeColor = AppThemeColor.red,
  }) {
    final primaryColor = getPrimaryColor(themeColor);
    final primaryLightColor = getPrimaryLightColor(themeColor);

    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
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
      ),
      scaffoldBackgroundColor: Colors.grey.shade50,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey.shade600,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          borderSide: BorderSide(color: primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade700),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade700, width: 2),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.grey.shade400;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryLightColor.withOpacity(0.5);
          }
          return Colors.grey.shade300;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        inactiveTrackColor: Colors.grey.shade300,
        thumbColor: primaryColor,
        overlayColor: primaryColor.withOpacity(0.2),
        valueIndicatorColor: primaryColor,
        valueIndicatorTextStyle: const TextStyle(color: Colors.white),
      ),
      tabBarTheme: TabBarTheme(
        labelColor: primaryColor,
        unselectedLabelColor: Colors.grey.shade600,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade200,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        primaryColor: primaryColor,
        barBackgroundColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
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

    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        primaryContainer: primaryDarkColor,
        secondary: accentColor,
        error: Colors.red.shade300,
        background: const Color(0xFF121212),
        surface: const Color(0xFF1E1E1E),
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onBackground: Colors.white,
        onSurface: Colors.white,
        onError: Colors.black,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF1E1E1E),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: primaryLightColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryLightColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryLightColor,
          side: BorderSide(color: primaryLightColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
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
          borderSide: BorderSide(color: primaryLightColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade300, width: 2),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryLightColor;
          }
          return Colors.grey;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor.withOpacity(0.5);
          }
          return Colors.grey.shade800;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryLightColor,
        inactiveTrackColor: Colors.grey.shade800,
        thumbColor: primaryLightColor,
        overlayColor: primaryLightColor.withOpacity(0.2),
        valueIndicatorColor: primaryLightColor,
        valueIndicatorTextStyle: const TextStyle(color: Colors.black),
      ),
      tabBarTheme: TabBarTheme(
        labelColor: primaryLightColor,
        unselectedLabelColor: Colors.grey,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: primaryLightColor, width: 2),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade800,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        tileColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        primaryColor: primaryLightColor,
        barBackgroundColor: Color(0xFF1E1E1E),
        scaffoldBackgroundColor: Color(0xFF121212),
        textTheme: CupertinoTextThemeData(primaryColor: primaryLightColor),
      ),
    );
  }
}
