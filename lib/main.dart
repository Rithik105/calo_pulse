import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'auth/providers/auth_provider.dart';
import 'calorie_tracking/model/calorie_entry.dart';
import 'calorie_tracking/provider/calorie_provider.dart';
import 'calorie_tracking/repo/calorie_remote_repo.dart';
import 'calorie_tracking/repo/calorie_repo.dart';
import 'core/screen_router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  Hive.registerAdapter(CalorieEntryAdapter());

  final CalorieRepository calorieRepository = CalorieRepository();
  await calorieRepository.init();
  final CalorieRemmoteRepo calorieRemoteRepo = CalorieRemmoteRepo();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, CalorieProvider>(
          create: (_) => CalorieProvider.empty(),
          update: (_, auth, previous) {
            if (!auth.isLoggedIn) {
              previous?.clearEntries();
              return CalorieProvider.empty();
            }

            if (previous != null && previous.uid == auth.uid) {
              return previous;
            }

            return CalorieProvider(
              calorieRepository,
              calorieRemoteRepo,
              auth.uid!,
            );
          },
        ),
      ],
      child: CaloriePulse(),
    ),
  );
}

class CaloriePulse extends StatelessWidget {
  const CaloriePulse({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: ScreenRouter());
  }
}
