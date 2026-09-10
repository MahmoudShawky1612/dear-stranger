import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/register_page.dart';
import '../../features/letters/feed_page.dart';
import '../../features/letters/send_letter_page.dart';
import '../../features/letters/my_letters_page.dart';
import '../../features/letters/claimed_letters_page.dart';
import '../../features/letters/letter_detail_page.dart';
import '../../features/users/profile_page.dart';
import '../../features/users/settings_page.dart';
import '../../features/users/user_search_page.dart';

GoRouter buildRouter(AuthProvider auth) => GoRouter(
      refreshListenable: auth,
      initialLocation: '/',
      redirect: (context, state) {
        if (auth.status == AuthStatus.loading) return null;
        final loggedIn  = auth.isAuthenticated;
        final loc       = state.matchedLocation;
        final guestOnly = loc == '/login' || loc == '/register';
        final needsAuth = const ['/letters/new', '/letters/mine', '/letters/claimed', '/settings']
                .any((p) => loc.startsWith(p)) ||
            RegExp(r'^/letters/\d+$').hasMatch(loc);
        if (needsAuth && !loggedIn) return '/login';
        if (guestOnly && loggedIn)  return '/';
        return null;
      },
      routes: [
        GoRoute(path: '/',                 builder: (_, __) => const FeedPage()),
        GoRoute(path: '/login',            builder: (_, __) => const LoginPage()),
        GoRoute(path: '/register',         builder: (_, __) => const RegisterPage()),
        GoRoute(path: '/letters/new',      builder: (_, __) => const SendLetterPage()),
        GoRoute(path: '/letters/mine',     builder: (_, __) => const MyLettersPage()),
        GoRoute(path: '/letters/claimed',  builder: (_, __) => const ClaimedLettersPage()),
        GoRoute(
          path: '/letters/:id',
          builder: (_, s) => LetterDetailPage(letterId: int.parse(s.pathParameters['id']!)),
        ),
        GoRoute(
          path: '/search',
          builder: (_, s) => UserSearchPage(initialQuery: s.uri.queryParameters['q'] ?? ''),
        ),
        GoRoute(
          path: '/profile/:username',
          builder: (_, s) => ProfilePage(username: s.pathParameters['username']!),
        ),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
      ],
    );
