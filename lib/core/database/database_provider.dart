import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// Instância única do banco. Sobrescrito em `main.dart` e nos testes.
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('databaseProvider deve ser sobrescrito'),
);
