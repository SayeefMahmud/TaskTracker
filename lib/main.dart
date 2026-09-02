import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';
import 'theme.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const DoToApp(),
    ),
  );
}

class DoToApp extends StatefulWidget {
  const DoToApp({super.key});

  @override
  State<DoToApp> createState() => _DoToAppState();
}

class _DoToAppState extends State<DoToApp> {
  bool _initialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      await taskProvider.init();
      setState(() {
        _initialized = true;
      });
    } catch (e, stack) {
      debugPrint('Initialization error: $e\n$stack');
      setState(() {
        _error = e.toString() + "\n\n" + stack.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'DoTo',
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: themeProvider.themeMode,
          home: _error != null 
            ? Scaffold(
                body: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Text('Startup Error:\n$_error', style: const TextStyle(color: Colors.red)),
                  ),
                ),
              )
            : !_initialized 
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : const HomeScreen(),
        );
      },
    );
  }
}
