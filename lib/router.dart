import 'package:go_router/go_router.dart';
import 'screens/login_screen.dart';
import 'utils/api_client.dart';
import 'screens/home_screen.dart';
import 'screens/search_client_screen.dart';
import 'screens/form_step1_screen.dart';
import 'screens/form_step2_screen.dart';
import 'screens/form_step3_screen.dart';
import 'screens/form_step4_screen.dart';
import 'screens/success_screen.dart';
import 'screens/history_screen.dart';
import 'screens/client_details_screen.dart';
import 'screens/client_timeline_screen.dart';
import 'screens/add_appointment_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    final loggedIn = await ApiClient.isLoggedIn();
    final loggingIn = state.matchedLocation == '/login';
    if (!loggedIn && !loggingIn) return '/login';
    if (loggedIn && loggingIn) return '/';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
    GoRoute(path: '/', builder: (c, s) => const HomeScreen()),
    GoRoute(path: '/search', builder: (c, s) => const SearchClientScreen()),
    GoRoute(path: '/history', builder: (c, s) => const HistoryScreen()),
    GoRoute(path: '/success', builder: (c, s) => const SuccessScreen()),

    // Multi-step form — pass data as `extra` map
    GoRoute(
      path: '/new/step1',
      builder: (c, s) => FormStep1Screen(
        initialData: (s.extra as Map<String, dynamic>?) ?? {},
      ),
    ),
    GoRoute(
      path: '/new/step2',
      builder: (c, s) => FormStep2Screen(
        step1Data: (s.extra as Map<String, dynamic>?) ?? {},
      ),
    ),
    GoRoute(
      path: '/new/step3',
      builder: (c, s) => FormStep3Screen(
        prevData: (s.extra as Map<String, dynamic>?) ?? {},
      ),
    ),
    GoRoute(
      path: '/new/step4',
      builder: (c, s) => FormStep4Screen(
        prevData: (s.extra as Map<String, dynamic>?) ?? {},
      ),
    ),

    // Client routes
    GoRoute(
      path: '/client/:id',
      builder: (c, s) => ClientDetailsScreen(clientId: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/client/:id/timeline',
      builder: (c, s) => ClientTimelineScreen(clientId: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/client/:id/appointment/new',
      builder: (c, s) => AddAppointmentScreen(clientId: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/client/:id/appointment/:apptId/edit',
      builder: (c, s) => AddAppointmentScreen(
        clientId: s.pathParameters['id']!,
        appointmentId: s.pathParameters['apptId']!,
      ),
    ),
  ],
);
