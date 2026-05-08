import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/realtime_db_service.dart';
import 'services/notification_service.dart';
import 'utils/constants.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';
import 'utils/app_localizations.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Activer la persistance locale pour garder les données hors ligne/après redémarrage
  FirebaseDatabase.instance.setPersistenceEnabled(true);
  FirebaseDatabase.instance.setPersistenceCacheSizeBytes(10000000); // 10MB
  
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  final prefs = await SharedPreferences.getInstance();
  runApp(MediAssistApp(preferences: prefs));
  
  // Initialize notification service in the background after app starts
  NotificationService().initialize();
}

class MediAssistApp extends StatelessWidget {
  final SharedPreferences preferences;

  const MediAssistApp({super.key, required this.preferences});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ProxyProvider<AuthService, FirestoreService>(
          update: (_, auth, __) => FirestoreService(auth),
        ),
        Provider<SharedPreferences>.value(value: preferences),
        Provider<RealtimeDbService>(create: (_) => RealtimeDbService()),
        ChangeNotifierProvider(
            create: (context) => LanguageProvider(preferences)),
        ChangeNotifierProvider(
            create: (context) => ThemeProvider(preferences)),
      ],
      child: Consumer2<LanguageProvider, ThemeProvider>(
        builder: (context, languageProvider, themeProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                brightness: Brightness.light,
                primary: AppColors.primary,
                onPrimary: AppColors.white,
                primaryContainer: const Color(0xFFE0F7FA),
                onPrimaryContainer: AppColors.primaryDark,
                secondary: AppColors.secondary,
                onSecondary: AppColors.white,
                secondaryContainer: AppColors.secondaryLight.withOpacity(0.2),
                onSecondaryContainer: AppColors.secondaryDark,
                surface: AppColors.cardLight,
                surfaceTint: AppColors.primary,
                onSurface: AppColors.black,
                error: AppColors.error,
                onError: AppColors.white,
                errorContainer: AppColors.errorLight,
                onErrorContainer: AppColors.error,
              ),
              scaffoldBackgroundColor: const Color(0xFFF0FAFB),
              cardColor: AppColors.cardLight,
              cardTheme: CardThemeData(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: AppBorderRadius.lg,
                  side: BorderSide(
                    color: AppColors.grey200,
                    width: 1,
                  ),
                ),
                color: AppColors.cardLight,
                surfaceTintColor: Colors.transparent,
                shadowColor: AppColors.black.withOpacity(0.05),
              ),
              appBarTheme: AppBarTheme(
                elevation: 0,
                centerTitle: true,
                backgroundColor: AppColors.backgroundLight,
                foregroundColor: AppColors.black,
                titleTextStyle: TextStyle(
                  fontSize: AppFontSizes.titleLarge,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 2,
                highlightElevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: AppBorderRadius.circular,
                ),
              ),
              navigationBarTheme: NavigationBarThemeData(
                backgroundColor: AppColors.white,
                elevation: 8,
                surfaceTintColor: AppColors.white,
                height: 80,
                indicatorColor: AppColors.primary,
                indicatorShape: RoundedRectangleBorder(
                  borderRadius: AppBorderRadius.circular,
                ),
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    );
                  }
                  return TextStyle(
                    color: AppColors.grey400,
                    fontSize: 12,
                  );
                }),
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const IconThemeData(
                      color: AppColors.white,
                      size: 26,
                    );
                  }
                  return const IconThemeData(
                    color: AppColors.grey400,
                    size: 24,
                  );
                }),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppBorderRadius.md,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppBorderRadius.md,
                  ),
                  side: BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: AppColors.grey50,
                border: OutlineInputBorder(
                  borderRadius: AppBorderRadius.md,
                  borderSide: BorderSide(
                    color: AppColors.grey300,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppBorderRadius.md,
                  borderSide: BorderSide(
                    color: AppColors.grey300,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppBorderRadius.md,
                  borderSide: BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: AppBorderRadius.md,
                  borderSide: BorderSide(
                    color: AppColors.error,
                    width: 2,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: AppBorderRadius.md,
                  borderSide: BorderSide(
                    color: AppColors.error,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
              ),
              dialogTheme: DialogThemeData(
                elevation: 0,
              ),
              snackBarTheme: SnackBarThemeData(
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: AppBorderRadius.md,
                ),
                elevation: 0,
              ),
              dividerTheme: DividerThemeData(
                color: AppColors.grey200,
                thickness: 1,
              ),
              textTheme: TextTheme(
                displayLarge: TextStyle(
                  fontSize: AppFontSizes.displayLarge,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
                displayMedium: TextStyle(
                  fontSize: AppFontSizes.displayMedium,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
                displaySmall: TextStyle(
                  fontSize: AppFontSizes.displaySmall,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
                headlineLarge: TextStyle(
                  fontSize: AppFontSizes.headlineLarge,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
                headlineMedium: TextStyle(
                  fontSize: AppFontSizes.headlineMedium,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
                headlineSmall: TextStyle(
                  fontSize: AppFontSizes.headlineSmall,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
                titleLarge: TextStyle(
                  fontSize: AppFontSizes.titleLarge,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
                titleMedium: TextStyle(
                  fontSize: AppFontSizes.titleMedium,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
                titleSmall: TextStyle(
                  fontSize: AppFontSizes.titleSmall,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
                bodyLarge: TextStyle(
                  fontSize: AppFontSizes.bodyLarge,
                  color: AppColors.black,
                ),
                bodyMedium: TextStyle(
                  fontSize: AppFontSizes.bodyMedium,
                  color: AppColors.grey700,
                ),
                bodySmall: TextStyle(
                  fontSize: AppFontSizes.bodySmall,
                  color: AppColors.grey500,
                ),
                labelLarge: TextStyle(
                  fontSize: AppFontSizes.labelLarge,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
                labelMedium: TextStyle(
                  fontSize: AppFontSizes.labelMedium,
                  color: AppColors.grey600,
                ),
                labelSmall: TextStyle(
                  fontSize: AppFontSizes.labelSmall,
                  color: AppColors.grey500,
                ),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                brightness: Brightness.dark,
                primary: AppColors.primaryLight,
                onPrimary: AppColors.grey900,
                primaryContainer: AppColors.primaryDark,
                onPrimaryContainer: AppColors.primaryLight,
                secondary: AppColors.secondaryLight,
                onSecondary: AppColors.grey900,
                secondaryContainer: AppColors.secondaryDark,
                onSecondaryContainer: AppColors.secondaryLight,
                surface: AppColors.cardDark,
                surfaceTint: AppColors.primaryLight,
                onSurface: AppColors.grey100,
                error: AppColors.errorLight,
                onError: AppColors.grey900,
                errorContainer: AppColors.error,
                onErrorContainer: AppColors.errorLight,
              ),
              scaffoldBackgroundColor: AppColors.backgroundDark,
              cardColor: AppColors.cardDark,
            ),
            themeMode: themeProvider.themeMode,
            locale: languageProvider.locale,
            supportedLocales: const [
              Locale('fr', 'FR'),
              Locale('en', 'US'),
              Locale('ar', 'AR'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: '/',
            routes: {
              '/': (context) => Consumer<AuthService>(
                    builder: (context, authService, child) {
                      if (authService.isLoggedIn) {
                        return const HomeScreen();
                      }
                      return const LoginScreen();
                    },
                  ),
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
            },
          );
        },
      ),
    );
  }
}
