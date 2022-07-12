import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onlinemusic/main.dart';
import 'package:onlinemusic/util/const.dart';

class ThemeService extends ChangeNotifier {
  static ThemeService? _instance;
  ThemeMode themeMode = ThemeMode.light;

  factory ThemeService() {
    return _instance ??= ThemeService._();
  }

  ThemeService._() {
    _getTheme();
  }

  void _getTheme() {
    int? themeMode = cacheBox!.get("themeMode", defaultValue: 1);
    this.themeMode = ThemeMode.values[themeMode ?? 1];
  }

  ThemeData get theme {
    if (themeMode == ThemeMode.light) {
      return light;
    } else {
      return dark;
    }
  }

  void changeTheme() {
    if (themeMode == ThemeMode.light) {
      themeMode = ThemeMode.dark;
    } else {
      themeMode = ThemeMode.light;
    }
    cacheBox!.put("themeMode", themeMode.index);
    notifyListeners();
  }

  bool get isLight {
    if (themeMode == ThemeMode.light) {
      return true;
    } else {
      return false;
    }
  }

  ThemeData get light {
    return ThemeData.light().copyWith(
      brightness: Brightness.light,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Const.kBackground,
        selectionHandleColor: Const.kBackground,
        selectionColor: Const.kBackground.withOpacity(0.1),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          primary: Const.kBackground,
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: Const.kBackground,
      ),
      dialogBackgroundColor: Const.kLight,
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Const.kLight,
            width: 1,
          ),
        ),
      ),
      cardTheme: CardTheme(
        shadowColor: Const.kBackground.withOpacity(0.5),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: Const.kLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Const.kLight,
            width: 1,
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.all(
          Const.kBackground,
        ),
        checkColor: MaterialStateProperty.all(
          Const.kLight,
        ),
      ),
      scaffoldBackgroundColor: Colors.grey.shade200,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey.shade200,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: Const.kBackground,
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
        iconTheme: IconThemeData(
          color: Const.kBackground,
        ),
      ),
    );
  }

  ThemeData get dark {
    return ThemeData.dark().copyWith(
      brightness: Brightness.dark,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Const.kWhite,
        selectionHandleColor: Const.kWhite,
        selectionColor: Const.kWhite.withOpacity(0.3),
      ),
      cardTheme: CardTheme(
        shadowColor: Const.kLight.withOpacity(0.1),
      ),
      dialogBackgroundColor: Const.kBackground,
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Const.kLight,
            width: 1,
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.all(
          Const.kLight,
        ),
        checkColor: MaterialStateProperty.all(
          Const.kBackground,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: Const.kBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Const.kLight,
            width: 1,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          primary: Const.kWhite,
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: Const.kLight,
      ),
      scaffoldBackgroundColor: Const.kBackground,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Const.kBackground,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: Const.kLight,
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
        iconTheme: IconThemeData(
          color: Const.kLight,
        ),
      ),
    );
  }
}
