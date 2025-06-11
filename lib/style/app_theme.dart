import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Definisikan palet warna baru sesuai referensi
  static const Color accentColor = Color(0xFFFFC107);      
  static const Color darkBackgroundColor = Color(0xFF121212); 
  static const Color surfaceColor = Color(0xFF1E1E1E);   
  static const Color textColor = Colors.white;
  static const Color hintColor = Colors.white54;

  static ThemeData get darkTheme {
    return ThemeData(
      // Atur skema warna utama
      colorScheme: const ColorScheme.dark(
        primary: accentColor,        
        secondary: accentColor,     
        surface: surfaceColor,
        //background: darkBackgroundColor,
        onPrimary: Colors.black,    
        onSecondary: Colors.black,   
        onSurface: textColor,
        //onBackground: textColor,
      ),
      
      scaffoldBackgroundColor: darkBackgroundColor,
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.poppins().fontFamily,
      
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackgroundColor, 
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: textColor),
      ),

      inputDecorationTheme: InputDecorationTheme(
        labelStyle: const TextStyle(color: hintColor),
        floatingLabelStyle: const TextStyle(color: accentColor),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
        fillColor: Colors.transparent,
        filled: false,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.black, 
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0), 
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      cardTheme: CardTheme(
        color: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),

       snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceColor,
        contentTextStyle: const TextStyle(color: textColor),
        actionTextColor: accentColor,
      ),
    );
  }
}