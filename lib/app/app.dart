import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/app/router.dart';
import 'package:liko_auto/core/constants/app_constants.dart';
import 'package:liko_auto/core/theme/app_theme.dart';

class LikoAutoApp extends ConsumerWidget {
  const LikoAutoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: appRouter,
    );
  }
}
