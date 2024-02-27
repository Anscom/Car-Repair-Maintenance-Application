import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData? currentTheme;


  setLightMode() {
    currentTheme = ThemeData(
        brightness: Brightness.light, // LightMode
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black), // Color of AppBar icons
          titleTextStyle: TextStyle(
            color: Colors.black, // Color of the AppBar title text
            fontSize: 30.0,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
          ),
        ),
          textTheme: TextTheme(
            bodyText1: TextStyle(color: Colors.black), // Set the default text color
          ),


    );
    notifyListeners();
  }

  setDarkmode() {
    currentTheme = ThemeData(
        brightness: Brightness.dark, // DarkMode
        scaffoldBackgroundColor: Color(0xFF5d5c6b),
        appBarTheme: AppBarTheme(
            backgroundColor: Colors.black,
        )
    );
    notifyListeners();
  }
}