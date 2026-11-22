import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/catalog_provider.dart';
import 'screens/home_shell.dart';
import 'services/catalog_repository.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final catalogRepository = InMemoryCatalogRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CatalogProvider(repository: catalogRepository),
        ),
      ],
      child: const WaksheAgrotechApp(),
    ),
  );
}

/// Root application widget for Wakshe Agrotech
class WaksheAgrotechApp extends StatelessWidget {
  const WaksheAgrotechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wakshe Agrotech | Farm Tools & Equipment',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeShell(),
    );
  }
}
