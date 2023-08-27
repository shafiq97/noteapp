import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:notes/screen/loading.dart';
import 'package:notes/theme/app_theme.dart';
import 'package:provider/provider.dart';

import 'model/note/notifier/checklist_list.dart';
import 'model/note/notifier/main_list.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => NotesList()),
      ChangeNotifierProvider(create: (_) => ChecklistManager()),
      ChangeNotifierProvider(create: (_) => AppTheme()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isAuthenticated = false;
  bool _isLoading = true;
  String _authMessage = '';

  @override
  void initState() {
    super.initState();
    _authenticateUser();
  }

  _authenticateUser() async {
    setState(() {
      _isLoading = true;
    });
    bool isAuthenticated = await authenticateWithFingerprint();
    setState(() {
      _isAuthenticated = isAuthenticated;
      _isLoading = false;
    });
  }

  Future<bool> authenticateWithFingerprint() async {
    final LocalAuthentication auth = LocalAuthentication();
    bool canCheckBiometrics = await auth.canCheckBiometrics;

    if (!canCheckBiometrics) {
      setState(() {
        _authMessage = 'Device does not support biometrics';
      });
      return false;
    }

    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Scan your fingerprint to authenticate',
      );
    } catch (e) {
      setState(() {
        _authMessage = 'Error during authentication: $e';
      });
      print(e);
    }
    return authenticated;
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        themeMode: ThemeMode.dark,
        title: 'Notes',
        theme: ThemeData(
          brightness: Brightness.dark,
        ),
        home: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _isAuthenticated
                ? const LoadingPage()
                : Center(
                    child: Text(_authMessage.isEmpty
                        ? 'Authentication failed!'
                        : _authMessage)),
      );
}
