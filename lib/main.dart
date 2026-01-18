import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/auth_provider.dart';
import 'providers/notes_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/create_note_screen.dart';
import 'screens/note_detail_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0A73FF);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          final baseLight = ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: primaryBlue, brightness: Brightness.light),
            useMaterial3: true,
          );
          final baseDark = ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: primaryBlue, brightness: Brightness.dark),
            useMaterial3: true,
          );

          final lightText = GoogleFonts.nunitoSansTextTheme(baseLight.textTheme);
          final darkText = GoogleFonts.nunitoSansTextTheme(baseDark.textTheme);

          return MaterialApp(
            title: 'Jollaly',
            debugShowCheckedModeBanner: false,
            themeMode: settings.themeMode,
            locale: settings.locale,
            supportedLocales: const [Locale('id'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: baseLight.copyWith(
              colorScheme: baseLight.colorScheme.copyWith(primary: primaryBlue),
              textTheme: lightText,
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: false,
                titleTextStyle: lightText.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: Colors.black),
                iconTheme: const IconThemeData(color: Colors.black),
              ),
              scaffoldBackgroundColor: const Color(0xFFF3F4F7),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primaryBlue, width: 2)),
              ),
              filledButtonTheme: FilledButtonThemeData(
                style: FilledButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            darkTheme: baseDark.copyWith(textTheme: darkText),

            
            initialRoute: SplashScreen.routeName, 
            
            routes: {
              SplashScreen.routeName: (_) => const SplashScreen(),
              LoginScreen.routeName: (_) => const LoginScreen(),
              RegisterScreen.routeName: (_) => const RegisterScreen(),
              HomeScreen.routeName: (_) => const HomeScreen(),
              CreateNoteScreen.routeName: (_) => const CreateNoteScreen(),
              NoteDetailScreen.routeName: (_) => const NoteDetailScreen(),
            },
          );
        },
      ),
    );
  }
}