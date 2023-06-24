import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/error_page.dart';
import 'common/loading_page.dart';
import 'features/auth/controller/auth_controller.dart';
import 'features/auth/view/login_view.dart';
import 'features/home/view/home_view.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: TwitterCloneApp()));
}

class TwitterCloneApp extends ConsumerWidget {
  const TwitterCloneApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Twitter Clone',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: ref.watch(getCurrentUserAccountProvider).when(
            data: (data) {
              if (data != null) {
                return const HomeView();
              }
              return const LoginView();
            },
            error: (error, stackTrace) => ErrorPage(error: error.toString()),
            loading: () => const LoadingPage(),
          ),
    );
  }
}
