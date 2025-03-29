import 'dart:io';
import 'package:fcai_student_login/models/store.dart';
import 'package:fcai_student_login/screens/splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'database/database_helper.dart';
import 'providers/user_provider.dart';
import 'providers/store_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if running on supported platforms (Windows or Android)
  if (!kIsWeb && (Platform.isWindows || Platform.isAndroid)) {
    // Initialize the database
    await DatabaseHelper.initDatabase();

    String email = await DatabaseHelper.getLoggedIn();

    // Initialize Hive
    final appDocumentDir =
        await path_provider.getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);

    // Register Hive adapters
    Hive.registerAdapter(StoreAdapter());

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (ctx) => UserProvider(email)),
          ChangeNotifierProvider(create: (ctx) => StoreProvider()),
        ],
        child: const MainApp(),
      ),
    );
  } else {
    // Run a simplified app for unsupported platforms
    runApp(const UnsupportedPlatformApp());
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      // Close the database when the app is terminated
      DatabaseHelper.closeDatabase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (ctx, userProvider, _) {
        if (userProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        return MaterialApp(
          title: 'Student App',
          theme: ThemeData(
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
            ),
            primarySwatch: Colors.green,
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.white,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.green,
              primary: Colors.green,
            ),
            platform:
                Platform.isWindows
                    ? TargetPlatform.windows
                    : TargetPlatform.android,
          ),
          debugShowCheckedModeBanner: false,

          home: SplashScreen(),
        );
      },
    );
  }
}

class UnsupportedPlatformApp extends StatelessWidget {
  const UnsupportedPlatformApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student App',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.error_outline, size: 80, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Unsupported Platform',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'This app is only supported on Windows and Android.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
