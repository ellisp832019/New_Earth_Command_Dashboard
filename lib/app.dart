import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/app_database.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

class NewEarthCommandDashboardApp extends ConsumerWidget {
  const NewEarthCommandDashboardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(databaseReadyProvider);

    return MaterialApp.router(
      title: 'New Earth Command Dashboard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
