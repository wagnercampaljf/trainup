import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../body_measurements/data/body_measurement_repository.dart';
import '../../body_measurements/domain/body_metric.dart';
import '../domain/sex.dart';

/// Dados editáveis do perfil.
class ProfileInput {
  const ProfileInput({
    required this.name,
    required this.heightCm,
    this.birthDate,
    this.sex,
  });

  final String name;
  final double heightCm;
  final DateTime? birthDate;
  final Sex? sex;
}

class ProfileRepository {
  ProfileRepository(this._db);

  final AppDatabase _db;

  Stream<UserProfile?> watchProfile() =>
      _db.select(_db.userProfiles).watchSingleOrNull();

  Future<UserProfile?> getProfile() =>
      _db.select(_db.userProfiles).getSingleOrNull();

  Future<bool> hasProfile() async => await getProfile() != null;

  Future<void> saveProfile(ProfileInput input) async {
    if (input.name.trim().isEmpty) throw ArgumentError('Nome obrigatório');
    if (!input.heightCm.isFinite ||
        input.heightCm < 50 ||
        input.heightCm > 272) {
      throw ArgumentError('Altura inválida');
    }
    final birth = input.birthDate;
    if (birth != null && birth.isAfter(DateTime.now())) {
      throw ArgumentError('Data de nascimento no futuro');
    }
    await _db
        .into(_db.userProfiles)
        .insertOnConflictUpdate(
          UserProfilesCompanion(
            id: const Value(1),
            name: Value(input.name.trim()),
            // O app não coleta e-mail (minimização de dados). A coluna existe
            // por compatibilidade e é limpa ao salvar o perfil.
            email: const Value(''),
            heightCm: Value(input.heightCm),
            birthDate: Value(birth),
            sex: Value(input.sex),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  /// Primeiro acesso: perfil + medição inicial numa única transação.
  Future<void> completeOnboarding(
    ProfileInput profile,
    BodyMeasurementInput measurement,
  ) => _db.transaction(() async {
    await saveProfile(profile);
    await BodyMeasurementRepository(_db).create(measurement);
  });
}

final profileRepositoryProvider = Provider(
  (ref) => ProfileRepository(ref.watch(databaseProvider)),
);

final profileProvider = StreamProvider<UserProfile?>(
  (ref) => ref.watch(profileRepositoryProvider).watchProfile(),
);
