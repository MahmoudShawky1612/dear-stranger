import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/feed_provider.dart';
import 'core/providers/notification_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthProvider _auth;
  late final LettersFeedProvider _feed;
  late final NotificationProvider _notifications;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _auth = AuthProvider();
    _feed = LettersFeedProvider();
    _notifications = NotificationProvider();
    _router = buildRouter(_auth);
    _auth.addListener(() {
      _feed.refresh(silent: true);
      if (_auth.isAuthenticated) {
        _notifications.init();
      } else {
        _notifications.disconnect();
      }
    });
    _auth.init();
  }

  @override
  void dispose() {
    _notifications.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _auth),
        ChangeNotifierProvider.value(value: _feed),
        ChangeNotifierProvider.value(value: _notifications),
      ],
      child: MaterialApp.router(
        title: 'Dear Stranger',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        routerConfig: _router,
      ),
    );
  }
}
