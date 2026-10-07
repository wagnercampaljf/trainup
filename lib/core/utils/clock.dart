import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef Clock = DateTime Function();

/// Fonte de tempo injetável (permite controlar "agora" em testes).
final clockProvider = Provider<Clock>((ref) => DateTime.now);
