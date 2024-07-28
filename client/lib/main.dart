import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';

import 'core/providers/current_user_notifier.dart';
import 'core/theme/app_pallete.dart';
import 'core/theme/theme.dart';
import 'features/auth/view/pages/signup_page.dart';
import 'features/auth/viewmodel/auth_viewmodel.dart';
import 'features/home/view/pages/home_page.dart';
import 'features/home/viewmodel/home_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);

  final container = ProviderContainer();
  await container.read(authViewModelProvider.notifier).initSharedPreferences();
  await container.read(homeViewModelProvider.notifier).initHive();
  await container.read(authViewModelProvider.notifier).getData();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserNotifierProvider);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Pallete.backgroundColor,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Pallete.backgroundColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return MaterialApp(
      title: 'Music App',
      theme: AppTheme.darkThemeMode,
      home: currentUser == null ? const SignupPage() : const HomePage(),
    );
  }
}
