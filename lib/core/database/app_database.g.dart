// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    check: () => id.equals(1),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 254),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
    'birth_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Sex?, String> sex =
      GeneratedColumn<String>(
        'sex',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Sex?>($UserProfilesTable.$convertersexn);
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    false,
    check: () => ComparableExpr(heightCm).isBetweenValues(50, 272),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    id,
    name,
    email,
    birthDate,
    sex,
    heightCm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    } else if (isInserting) {
      context.missing(_heightCmMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birth_date'],
      ),
      sex: $UserProfilesTable.$convertersexn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sex'],
        ),
      ),
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      )!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Sex, String, String> $convertersex =
      const EnumNameConverter<Sex>(Sex.values);
  static JsonTypeConverter2<Sex?, String?, String?> $convertersexn =
      JsonTypeConverter2.asNullable($convertersex);
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final int id;
  final String name;
  final String email;
  final DateTime? birthDate;
  final Sex? sex;
  final double heightCm;
  const UserProfile({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.name,
    required this.email,
    this.birthDate,
    this.sex,
    required this.heightCm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['email'] = Variable<String>(email);
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<DateTime>(birthDate);
    }
    if (!nullToAbsent || sex != null) {
      map['sex'] = Variable<String>(
        $UserProfilesTable.$convertersexn.toSql(sex),
      );
    }
    map['height_cm'] = Variable<double>(heightCm);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      name: Value(name),
      email: Value(email),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      sex: sex == null && nullToAbsent ? const Value.absent() : Value(sex),
      heightCm: Value(heightCm),
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
      sex: $UserProfilesTable.$convertersexn.fromJson(
        serializer.fromJson<String?>(json['sex']),
      ),
      heightCm: serializer.fromJson<double>(json['heightCm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'sex': serializer.toJson<String?>(
        $UserProfilesTable.$convertersexn.toJson(sex),
      ),
      'heightCm': serializer.toJson<double>(heightCm),
    };
  }

  UserProfile copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    int? id,
    String? name,
    String? email,
    Value<DateTime?> birthDate = const Value.absent(),
    Value<Sex?> sex = const Value.absent(),
    double? heightCm,
  }) => UserProfile(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    birthDate: birthDate.present ? birthDate.value : this.birthDate,
    sex: sex.present ? sex.value : this.sex,
    heightCm: heightCm ?? this.heightCm,
  );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      sex: data.sex.present ? data.sex.value : this.sex,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('birthDate: $birthDate, ')
          ..write('sex: $sex, ')
          ..write('heightCm: $heightCm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    id,
    name,
    email,
    birthDate,
    sex,
    heightCm,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.birthDate == this.birthDate &&
          other.sex == this.sex &&
          other.heightCm == this.heightCm);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> id;
  final Value<String> name;
  final Value<String> email;
  final Value<DateTime?> birthDate;
  final Value<Sex?> sex;
  final Value<double> heightCm;
  const UserProfilesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.sex = const Value.absent(),
    this.heightCm = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    required String name,
    required String email,
    this.birthDate = const Value.absent(),
    this.sex = const Value.absent(),
    required double heightCm,
  }) : name = Value(name),
       email = Value(email),
       heightCm = Value(heightCm);
  static Insertable<UserProfile> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<DateTime>? birthDate,
    Expression<String>? sex,
    Expression<double>? heightCm,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (birthDate != null) 'birth_date': birthDate,
      if (sex != null) 'sex': sex,
      if (heightCm != null) 'height_cm': heightCm,
    });
  }

  UserProfilesCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? id,
    Value<String>? name,
    Value<String>? email,
    Value<DateTime?>? birthDate,
    Value<Sex?>? sex,
    Value<double>? heightCm,
  }) {
    return UserProfilesCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      birthDate: birthDate ?? this.birthDate,
      sex: sex ?? this.sex,
      heightCm: heightCm ?? this.heightCm,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(
        $UserProfilesTable.$convertersexn.toSql(sex.value),
      );
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('birthDate: $birthDate, ')
          ..write('sex: $sex, ')
          ..write('heightCm: $heightCm')
          ..write(')'))
        .toString();
  }
}

class $BodyMeasurementsTable extends BodyMeasurements
    with TableInfo<$BodyMeasurementsTable, BodyMeasurement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BodyMeasurementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    check: () => ComparableExpr(weightKg).isBetweenValues(20, 400),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyFatPercentageMeta = const VerificationMeta(
    'bodyFatPercentage',
  );
  @override
  late final GeneratedColumn<double> bodyFatPercentage =
      GeneratedColumn<double>(
        'body_fat_percentage',
        aliasedName,
        true,
        check: () => ComparableExpr(bodyFatPercentage).isBetweenValues(0, 100),
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _neckMeta = const VerificationMeta('neck');
  @override
  late final GeneratedColumn<double> neck = GeneratedColumn<double>(
    'neck',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shouldersMeta = const VerificationMeta(
    'shoulders',
  );
  @override
  late final GeneratedColumn<double> shoulders = GeneratedColumn<double>(
    'shoulders',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chestMeta = const VerificationMeta('chest');
  @override
  late final GeneratedColumn<double> chest = GeneratedColumn<double>(
    'chest',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _leftArmMeta = const VerificationMeta(
    'leftArm',
  );
  @override
  late final GeneratedColumn<double> leftArm = GeneratedColumn<double>(
    'left_arm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rightArmMeta = const VerificationMeta(
    'rightArm',
  );
  @override
  late final GeneratedColumn<double> rightArm = GeneratedColumn<double>(
    'right_arm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _leftForearmMeta = const VerificationMeta(
    'leftForearm',
  );
  @override
  late final GeneratedColumn<double> leftForearm = GeneratedColumn<double>(
    'left_forearm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rightForearmMeta = const VerificationMeta(
    'rightForearm',
  );
  @override
  late final GeneratedColumn<double> rightForearm = GeneratedColumn<double>(
    'right_forearm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _waistMeta = const VerificationMeta('waist');
  @override
  late final GeneratedColumn<double> waist = GeneratedColumn<double>(
    'waist',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _abdomenMeta = const VerificationMeta(
    'abdomen',
  );
  @override
  late final GeneratedColumn<double> abdomen = GeneratedColumn<double>(
    'abdomen',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hipsMeta = const VerificationMeta('hips');
  @override
  late final GeneratedColumn<double> hips = GeneratedColumn<double>(
    'hips',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _leftThighMeta = const VerificationMeta(
    'leftThigh',
  );
  @override
  late final GeneratedColumn<double> leftThigh = GeneratedColumn<double>(
    'left_thigh',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rightThighMeta = const VerificationMeta(
    'rightThigh',
  );
  @override
  late final GeneratedColumn<double> rightThigh = GeneratedColumn<double>(
    'right_thigh',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _leftCalfMeta = const VerificationMeta(
    'leftCalf',
  );
  @override
  late final GeneratedColumn<double> leftCalf = GeneratedColumn<double>(
    'left_calf',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rightCalfMeta = const VerificationMeta(
    'rightCalf',
  );
  @override
  late final GeneratedColumn<double> rightCalf = GeneratedColumn<double>(
    'right_calf',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    id,
    date,
    weightKg,
    bodyFatPercentage,
    neck,
    shoulders,
    chest,
    leftArm,
    rightArm,
    leftForearm,
    rightForearm,
    waist,
    abdomen,
    hips,
    leftThigh,
    rightThigh,
    leftCalf,
    rightCalf,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'body_measurements';
  @override
  VerificationContext validateIntegrity(
    Insertable<BodyMeasurement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('body_fat_percentage')) {
      context.handle(
        _bodyFatPercentageMeta,
        bodyFatPercentage.isAcceptableOrUnknown(
          data['body_fat_percentage']!,
          _bodyFatPercentageMeta,
        ),
      );
    }
    if (data.containsKey('neck')) {
      context.handle(
        _neckMeta,
        neck.isAcceptableOrUnknown(data['neck']!, _neckMeta),
      );
    }
    if (data.containsKey('shoulders')) {
      context.handle(
        _shouldersMeta,
        shoulders.isAcceptableOrUnknown(data['shoulders']!, _shouldersMeta),
      );
    }
    if (data.containsKey('chest')) {
      context.handle(
        _chestMeta,
        chest.isAcceptableOrUnknown(data['chest']!, _chestMeta),
      );
    }
    if (data.containsKey('left_arm')) {
      context.handle(
        _leftArmMeta,
        leftArm.isAcceptableOrUnknown(data['left_arm']!, _leftArmMeta),
      );
    }
    if (data.containsKey('right_arm')) {
      context.handle(
        _rightArmMeta,
        rightArm.isAcceptableOrUnknown(data['right_arm']!, _rightArmMeta),
      );
    }
    if (data.containsKey('left_forearm')) {
      context.handle(
        _leftForearmMeta,
        leftForearm.isAcceptableOrUnknown(
          data['left_forearm']!,
          _leftForearmMeta,
        ),
      );
    }
    if (data.containsKey('right_forearm')) {
      context.handle(
        _rightForearmMeta,
        rightForearm.isAcceptableOrUnknown(
          data['right_forearm']!,
          _rightForearmMeta,
        ),
      );
    }
    if (data.containsKey('waist')) {
      context.handle(
        _waistMeta,
        waist.isAcceptableOrUnknown(data['waist']!, _waistMeta),
      );
    }
    if (data.containsKey('abdomen')) {
      context.handle(
        _abdomenMeta,
        abdomen.isAcceptableOrUnknown(data['abdomen']!, _abdomenMeta),
      );
    }
    if (data.containsKey('hips')) {
      context.handle(
        _hipsMeta,
        hips.isAcceptableOrUnknown(data['hips']!, _hipsMeta),
      );
    }
    if (data.containsKey('left_thigh')) {
      context.handle(
        _leftThighMeta,
        leftThigh.isAcceptableOrUnknown(data['left_thigh']!, _leftThighMeta),
      );
    }
    if (data.containsKey('right_thigh')) {
      context.handle(
        _rightThighMeta,
        rightThigh.isAcceptableOrUnknown(data['right_thigh']!, _rightThighMeta),
      );
    }
    if (data.containsKey('left_calf')) {
      context.handle(
        _leftCalfMeta,
        leftCalf.isAcceptableOrUnknown(data['left_calf']!, _leftCalfMeta),
      );
    }
    if (data.containsKey('right_calf')) {
      context.handle(
        _rightCalfMeta,
        rightCalf.isAcceptableOrUnknown(data['right_calf']!, _rightCalfMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BodyMeasurement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BodyMeasurement(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      bodyFatPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}body_fat_percentage'],
      ),
      neck: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}neck'],
      ),
      shoulders: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}shoulders'],
      ),
      chest: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}chest'],
      ),
      leftArm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}left_arm'],
      ),
      rightArm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}right_arm'],
      ),
      leftForearm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}left_forearm'],
      ),
      rightForearm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}right_forearm'],
      ),
      waist: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}waist'],
      ),
      abdomen: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}abdomen'],
      ),
      hips: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hips'],
      ),
      leftThigh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}left_thigh'],
      ),
      rightThigh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}right_thigh'],
      ),
      leftCalf: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}left_calf'],
      ),
      rightCalf: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}right_calf'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $BodyMeasurementsTable createAlias(String alias) {
    return $BodyMeasurementsTable(attachedDatabase, alias);
  }
}

class BodyMeasurement extends DataClass implements Insertable<BodyMeasurement> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final int id;
  final DateTime date;
  final double weightKg;
  final double? bodyFatPercentage;
  final double? neck;
  final double? shoulders;
  final double? chest;
  final double? leftArm;
  final double? rightArm;
  final double? leftForearm;
  final double? rightForearm;
  final double? waist;
  final double? abdomen;
  final double? hips;
  final double? leftThigh;
  final double? rightThigh;
  final double? leftCalf;
  final double? rightCalf;
  final String? notes;
  const BodyMeasurement({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.date,
    required this.weightKg,
    this.bodyFatPercentage,
    this.neck,
    this.shoulders,
    this.chest,
    this.leftArm,
    this.rightArm,
    this.leftForearm,
    this.rightForearm,
    this.waist,
    this.abdomen,
    this.hips,
    this.leftThigh,
    this.rightThigh,
    this.leftCalf,
    this.rightCalf,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['weight_kg'] = Variable<double>(weightKg);
    if (!nullToAbsent || bodyFatPercentage != null) {
      map['body_fat_percentage'] = Variable<double>(bodyFatPercentage);
    }
    if (!nullToAbsent || neck != null) {
      map['neck'] = Variable<double>(neck);
    }
    if (!nullToAbsent || shoulders != null) {
      map['shoulders'] = Variable<double>(shoulders);
    }
    if (!nullToAbsent || chest != null) {
      map['chest'] = Variable<double>(chest);
    }
    if (!nullToAbsent || leftArm != null) {
      map['left_arm'] = Variable<double>(leftArm);
    }
    if (!nullToAbsent || rightArm != null) {
      map['right_arm'] = Variable<double>(rightArm);
    }
    if (!nullToAbsent || leftForearm != null) {
      map['left_forearm'] = Variable<double>(leftForearm);
    }
    if (!nullToAbsent || rightForearm != null) {
      map['right_forearm'] = Variable<double>(rightForearm);
    }
    if (!nullToAbsent || waist != null) {
      map['waist'] = Variable<double>(waist);
    }
    if (!nullToAbsent || abdomen != null) {
      map['abdomen'] = Variable<double>(abdomen);
    }
    if (!nullToAbsent || hips != null) {
      map['hips'] = Variable<double>(hips);
    }
    if (!nullToAbsent || leftThigh != null) {
      map['left_thigh'] = Variable<double>(leftThigh);
    }
    if (!nullToAbsent || rightThigh != null) {
      map['right_thigh'] = Variable<double>(rightThigh);
    }
    if (!nullToAbsent || leftCalf != null) {
      map['left_calf'] = Variable<double>(leftCalf);
    }
    if (!nullToAbsent || rightCalf != null) {
      map['right_calf'] = Variable<double>(rightCalf);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  BodyMeasurementsCompanion toCompanion(bool nullToAbsent) {
    return BodyMeasurementsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      date: Value(date),
      weightKg: Value(weightKg),
      bodyFatPercentage: bodyFatPercentage == null && nullToAbsent
          ? const Value.absent()
          : Value(bodyFatPercentage),
      neck: neck == null && nullToAbsent ? const Value.absent() : Value(neck),
      shoulders: shoulders == null && nullToAbsent
          ? const Value.absent()
          : Value(shoulders),
      chest: chest == null && nullToAbsent
          ? const Value.absent()
          : Value(chest),
      leftArm: leftArm == null && nullToAbsent
          ? const Value.absent()
          : Value(leftArm),
      rightArm: rightArm == null && nullToAbsent
          ? const Value.absent()
          : Value(rightArm),
      leftForearm: leftForearm == null && nullToAbsent
          ? const Value.absent()
          : Value(leftForearm),
      rightForearm: rightForearm == null && nullToAbsent
          ? const Value.absent()
          : Value(rightForearm),
      waist: waist == null && nullToAbsent
          ? const Value.absent()
          : Value(waist),
      abdomen: abdomen == null && nullToAbsent
          ? const Value.absent()
          : Value(abdomen),
      hips: hips == null && nullToAbsent ? const Value.absent() : Value(hips),
      leftThigh: leftThigh == null && nullToAbsent
          ? const Value.absent()
          : Value(leftThigh),
      rightThigh: rightThigh == null && nullToAbsent
          ? const Value.absent()
          : Value(rightThigh),
      leftCalf: leftCalf == null && nullToAbsent
          ? const Value.absent()
          : Value(leftCalf),
      rightCalf: rightCalf == null && nullToAbsent
          ? const Value.absent()
          : Value(rightCalf),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory BodyMeasurement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BodyMeasurement(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      bodyFatPercentage: serializer.fromJson<double?>(
        json['bodyFatPercentage'],
      ),
      neck: serializer.fromJson<double?>(json['neck']),
      shoulders: serializer.fromJson<double?>(json['shoulders']),
      chest: serializer.fromJson<double?>(json['chest']),
      leftArm: serializer.fromJson<double?>(json['leftArm']),
      rightArm: serializer.fromJson<double?>(json['rightArm']),
      leftForearm: serializer.fromJson<double?>(json['leftForearm']),
      rightForearm: serializer.fromJson<double?>(json['rightForearm']),
      waist: serializer.fromJson<double?>(json['waist']),
      abdomen: serializer.fromJson<double?>(json['abdomen']),
      hips: serializer.fromJson<double?>(json['hips']),
      leftThigh: serializer.fromJson<double?>(json['leftThigh']),
      rightThigh: serializer.fromJson<double?>(json['rightThigh']),
      leftCalf: serializer.fromJson<double?>(json['leftCalf']),
      rightCalf: serializer.fromJson<double?>(json['rightCalf']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'weightKg': serializer.toJson<double>(weightKg),
      'bodyFatPercentage': serializer.toJson<double?>(bodyFatPercentage),
      'neck': serializer.toJson<double?>(neck),
      'shoulders': serializer.toJson<double?>(shoulders),
      'chest': serializer.toJson<double?>(chest),
      'leftArm': serializer.toJson<double?>(leftArm),
      'rightArm': serializer.toJson<double?>(rightArm),
      'leftForearm': serializer.toJson<double?>(leftForearm),
      'rightForearm': serializer.toJson<double?>(rightForearm),
      'waist': serializer.toJson<double?>(waist),
      'abdomen': serializer.toJson<double?>(abdomen),
      'hips': serializer.toJson<double?>(hips),
      'leftThigh': serializer.toJson<double?>(leftThigh),
      'rightThigh': serializer.toJson<double?>(rightThigh),
      'leftCalf': serializer.toJson<double?>(leftCalf),
      'rightCalf': serializer.toJson<double?>(rightCalf),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  BodyMeasurement copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    int? id,
    DateTime? date,
    double? weightKg,
    Value<double?> bodyFatPercentage = const Value.absent(),
    Value<double?> neck = const Value.absent(),
    Value<double?> shoulders = const Value.absent(),
    Value<double?> chest = const Value.absent(),
    Value<double?> leftArm = const Value.absent(),
    Value<double?> rightArm = const Value.absent(),
    Value<double?> leftForearm = const Value.absent(),
    Value<double?> rightForearm = const Value.absent(),
    Value<double?> waist = const Value.absent(),
    Value<double?> abdomen = const Value.absent(),
    Value<double?> hips = const Value.absent(),
    Value<double?> leftThigh = const Value.absent(),
    Value<double?> rightThigh = const Value.absent(),
    Value<double?> leftCalf = const Value.absent(),
    Value<double?> rightCalf = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => BodyMeasurement(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    date: date ?? this.date,
    weightKg: weightKg ?? this.weightKg,
    bodyFatPercentage: bodyFatPercentage.present
        ? bodyFatPercentage.value
        : this.bodyFatPercentage,
    neck: neck.present ? neck.value : this.neck,
    shoulders: shoulders.present ? shoulders.value : this.shoulders,
    chest: chest.present ? chest.value : this.chest,
    leftArm: leftArm.present ? leftArm.value : this.leftArm,
    rightArm: rightArm.present ? rightArm.value : this.rightArm,
    leftForearm: leftForearm.present ? leftForearm.value : this.leftForearm,
    rightForearm: rightForearm.present ? rightForearm.value : this.rightForearm,
    waist: waist.present ? waist.value : this.waist,
    abdomen: abdomen.present ? abdomen.value : this.abdomen,
    hips: hips.present ? hips.value : this.hips,
    leftThigh: leftThigh.present ? leftThigh.value : this.leftThigh,
    rightThigh: rightThigh.present ? rightThigh.value : this.rightThigh,
    leftCalf: leftCalf.present ? leftCalf.value : this.leftCalf,
    rightCalf: rightCalf.present ? rightCalf.value : this.rightCalf,
    notes: notes.present ? notes.value : this.notes,
  );
  BodyMeasurement copyWithCompanion(BodyMeasurementsCompanion data) {
    return BodyMeasurement(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      bodyFatPercentage: data.bodyFatPercentage.present
          ? data.bodyFatPercentage.value
          : this.bodyFatPercentage,
      neck: data.neck.present ? data.neck.value : this.neck,
      shoulders: data.shoulders.present ? data.shoulders.value : this.shoulders,
      chest: data.chest.present ? data.chest.value : this.chest,
      leftArm: data.leftArm.present ? data.leftArm.value : this.leftArm,
      rightArm: data.rightArm.present ? data.rightArm.value : this.rightArm,
      leftForearm: data.leftForearm.present
          ? data.leftForearm.value
          : this.leftForearm,
      rightForearm: data.rightForearm.present
          ? data.rightForearm.value
          : this.rightForearm,
      waist: data.waist.present ? data.waist.value : this.waist,
      abdomen: data.abdomen.present ? data.abdomen.value : this.abdomen,
      hips: data.hips.present ? data.hips.value : this.hips,
      leftThigh: data.leftThigh.present ? data.leftThigh.value : this.leftThigh,
      rightThigh: data.rightThigh.present
          ? data.rightThigh.value
          : this.rightThigh,
      leftCalf: data.leftCalf.present ? data.leftCalf.value : this.leftCalf,
      rightCalf: data.rightCalf.present ? data.rightCalf.value : this.rightCalf,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BodyMeasurement(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('weightKg: $weightKg, ')
          ..write('bodyFatPercentage: $bodyFatPercentage, ')
          ..write('neck: $neck, ')
          ..write('shoulders: $shoulders, ')
          ..write('chest: $chest, ')
          ..write('leftArm: $leftArm, ')
          ..write('rightArm: $rightArm, ')
          ..write('leftForearm: $leftForearm, ')
          ..write('rightForearm: $rightForearm, ')
          ..write('waist: $waist, ')
          ..write('abdomen: $abdomen, ')
          ..write('hips: $hips, ')
          ..write('leftThigh: $leftThigh, ')
          ..write('rightThigh: $rightThigh, ')
          ..write('leftCalf: $leftCalf, ')
          ..write('rightCalf: $rightCalf, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    createdAt,
    updatedAt,
    id,
    date,
    weightKg,
    bodyFatPercentage,
    neck,
    shoulders,
    chest,
    leftArm,
    rightArm,
    leftForearm,
    rightForearm,
    waist,
    abdomen,
    hips,
    leftThigh,
    rightThigh,
    leftCalf,
    rightCalf,
    notes,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BodyMeasurement &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.date == this.date &&
          other.weightKg == this.weightKg &&
          other.bodyFatPercentage == this.bodyFatPercentage &&
          other.neck == this.neck &&
          other.shoulders == this.shoulders &&
          other.chest == this.chest &&
          other.leftArm == this.leftArm &&
          other.rightArm == this.rightArm &&
          other.leftForearm == this.leftForearm &&
          other.rightForearm == this.rightForearm &&
          other.waist == this.waist &&
          other.abdomen == this.abdomen &&
          other.hips == this.hips &&
          other.leftThigh == this.leftThigh &&
          other.rightThigh == this.rightThigh &&
          other.leftCalf == this.leftCalf &&
          other.rightCalf == this.rightCalf &&
          other.notes == this.notes);
}

class BodyMeasurementsCompanion extends UpdateCompanion<BodyMeasurement> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> id;
  final Value<DateTime> date;
  final Value<double> weightKg;
  final Value<double?> bodyFatPercentage;
  final Value<double?> neck;
  final Value<double?> shoulders;
  final Value<double?> chest;
  final Value<double?> leftArm;
  final Value<double?> rightArm;
  final Value<double?> leftForearm;
  final Value<double?> rightForearm;
  final Value<double?> waist;
  final Value<double?> abdomen;
  final Value<double?> hips;
  final Value<double?> leftThigh;
  final Value<double?> rightThigh;
  final Value<double?> leftCalf;
  final Value<double?> rightCalf;
  final Value<String?> notes;
  const BodyMeasurementsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.bodyFatPercentage = const Value.absent(),
    this.neck = const Value.absent(),
    this.shoulders = const Value.absent(),
    this.chest = const Value.absent(),
    this.leftArm = const Value.absent(),
    this.rightArm = const Value.absent(),
    this.leftForearm = const Value.absent(),
    this.rightForearm = const Value.absent(),
    this.waist = const Value.absent(),
    this.abdomen = const Value.absent(),
    this.hips = const Value.absent(),
    this.leftThigh = const Value.absent(),
    this.rightThigh = const Value.absent(),
    this.leftCalf = const Value.absent(),
    this.rightCalf = const Value.absent(),
    this.notes = const Value.absent(),
  });
  BodyMeasurementsCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    required DateTime date,
    required double weightKg,
    this.bodyFatPercentage = const Value.absent(),
    this.neck = const Value.absent(),
    this.shoulders = const Value.absent(),
    this.chest = const Value.absent(),
    this.leftArm = const Value.absent(),
    this.rightArm = const Value.absent(),
    this.leftForearm = const Value.absent(),
    this.rightForearm = const Value.absent(),
    this.waist = const Value.absent(),
    this.abdomen = const Value.absent(),
    this.hips = const Value.absent(),
    this.leftThigh = const Value.absent(),
    this.rightThigh = const Value.absent(),
    this.leftCalf = const Value.absent(),
    this.rightCalf = const Value.absent(),
    this.notes = const Value.absent(),
  }) : date = Value(date),
       weightKg = Value(weightKg);
  static Insertable<BodyMeasurement> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<double>? weightKg,
    Expression<double>? bodyFatPercentage,
    Expression<double>? neck,
    Expression<double>? shoulders,
    Expression<double>? chest,
    Expression<double>? leftArm,
    Expression<double>? rightArm,
    Expression<double>? leftForearm,
    Expression<double>? rightForearm,
    Expression<double>? waist,
    Expression<double>? abdomen,
    Expression<double>? hips,
    Expression<double>? leftThigh,
    Expression<double>? rightThigh,
    Expression<double>? leftCalf,
    Expression<double>? rightCalf,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (weightKg != null) 'weight_kg': weightKg,
      if (bodyFatPercentage != null) 'body_fat_percentage': bodyFatPercentage,
      if (neck != null) 'neck': neck,
      if (shoulders != null) 'shoulders': shoulders,
      if (chest != null) 'chest': chest,
      if (leftArm != null) 'left_arm': leftArm,
      if (rightArm != null) 'right_arm': rightArm,
      if (leftForearm != null) 'left_forearm': leftForearm,
      if (rightForearm != null) 'right_forearm': rightForearm,
      if (waist != null) 'waist': waist,
      if (abdomen != null) 'abdomen': abdomen,
      if (hips != null) 'hips': hips,
      if (leftThigh != null) 'left_thigh': leftThigh,
      if (rightThigh != null) 'right_thigh': rightThigh,
      if (leftCalf != null) 'left_calf': leftCalf,
      if (rightCalf != null) 'right_calf': rightCalf,
      if (notes != null) 'notes': notes,
    });
  }

  BodyMeasurementsCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? id,
    Value<DateTime>? date,
    Value<double>? weightKg,
    Value<double?>? bodyFatPercentage,
    Value<double?>? neck,
    Value<double?>? shoulders,
    Value<double?>? chest,
    Value<double?>? leftArm,
    Value<double?>? rightArm,
    Value<double?>? leftForearm,
    Value<double?>? rightForearm,
    Value<double?>? waist,
    Value<double?>? abdomen,
    Value<double?>? hips,
    Value<double?>? leftThigh,
    Value<double?>? rightThigh,
    Value<double?>? leftCalf,
    Value<double?>? rightCalf,
    Value<String?>? notes,
  }) {
    return BodyMeasurementsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      date: date ?? this.date,
      weightKg: weightKg ?? this.weightKg,
      bodyFatPercentage: bodyFatPercentage ?? this.bodyFatPercentage,
      neck: neck ?? this.neck,
      shoulders: shoulders ?? this.shoulders,
      chest: chest ?? this.chest,
      leftArm: leftArm ?? this.leftArm,
      rightArm: rightArm ?? this.rightArm,
      leftForearm: leftForearm ?? this.leftForearm,
      rightForearm: rightForearm ?? this.rightForearm,
      waist: waist ?? this.waist,
      abdomen: abdomen ?? this.abdomen,
      hips: hips ?? this.hips,
      leftThigh: leftThigh ?? this.leftThigh,
      rightThigh: rightThigh ?? this.rightThigh,
      leftCalf: leftCalf ?? this.leftCalf,
      rightCalf: rightCalf ?? this.rightCalf,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (bodyFatPercentage.present) {
      map['body_fat_percentage'] = Variable<double>(bodyFatPercentage.value);
    }
    if (neck.present) {
      map['neck'] = Variable<double>(neck.value);
    }
    if (shoulders.present) {
      map['shoulders'] = Variable<double>(shoulders.value);
    }
    if (chest.present) {
      map['chest'] = Variable<double>(chest.value);
    }
    if (leftArm.present) {
      map['left_arm'] = Variable<double>(leftArm.value);
    }
    if (rightArm.present) {
      map['right_arm'] = Variable<double>(rightArm.value);
    }
    if (leftForearm.present) {
      map['left_forearm'] = Variable<double>(leftForearm.value);
    }
    if (rightForearm.present) {
      map['right_forearm'] = Variable<double>(rightForearm.value);
    }
    if (waist.present) {
      map['waist'] = Variable<double>(waist.value);
    }
    if (abdomen.present) {
      map['abdomen'] = Variable<double>(abdomen.value);
    }
    if (hips.present) {
      map['hips'] = Variable<double>(hips.value);
    }
    if (leftThigh.present) {
      map['left_thigh'] = Variable<double>(leftThigh.value);
    }
    if (rightThigh.present) {
      map['right_thigh'] = Variable<double>(rightThigh.value);
    }
    if (leftCalf.present) {
      map['left_calf'] = Variable<double>(leftCalf.value);
    }
    if (rightCalf.present) {
      map['right_calf'] = Variable<double>(rightCalf.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BodyMeasurementsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('weightKg: $weightKg, ')
          ..write('bodyFatPercentage: $bodyFatPercentage, ')
          ..write('neck: $neck, ')
          ..write('shoulders: $shoulders, ')
          ..write('chest: $chest, ')
          ..write('leftArm: $leftArm, ')
          ..write('rightArm: $rightArm, ')
          ..write('leftForearm: $leftForearm, ')
          ..write('rightForearm: $rightForearm, ')
          ..write('waist: $waist, ')
          ..write('abdomen: $abdomen, ')
          ..write('hips: $hips, ')
          ..write('leftThigh: $leftThigh, ')
          ..write('rightThigh: $rightThigh, ')
          ..write('leftCalf: $leftCalf, ')
          ..write('rightCalf: $rightCalf, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $ExercisesTable extends Exercises
    with TableInfo<$ExercisesTable, Exercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<MuscleGroup, String> muscleGroup =
      GeneratedColumn<String>(
        'muscle_group',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MuscleGroup>($ExercisesTable.$convertermuscleGroup);
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isCustomMeta = const VerificationMeta(
    'isCustom',
  );
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    id,
    name,
    normalizedName,
    muscleGroup,
    description,
    notes,
    isActive,
    isCustom,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<Exercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('is_custom')) {
      context.handle(
        _isCustomMeta,
        isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Exercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Exercise(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      muscleGroup: $ExercisesTable.$convertermuscleGroup.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}muscle_group'],
        )!,
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      isCustom: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom'],
      )!,
    );
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MuscleGroup, String, String> $convertermuscleGroup =
      const EnumNameConverter<MuscleGroup>(MuscleGroup.values);
}

class Exercise extends DataClass implements Insertable<Exercise> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final int id;
  final String name;

  /// Nome em minúsculas, sem acentos e espaços extras. Garante unicidade.
  final String normalizedName;
  final MuscleGroup muscleGroup;
  final String? description;
  final String? notes;
  final bool isActive;
  final bool isCustom;
  const Exercise({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.name,
    required this.normalizedName,
    required this.muscleGroup,
    this.description,
    this.notes,
    required this.isActive,
    required this.isCustom,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['normalized_name'] = Variable<String>(normalizedName);
    {
      map['muscle_group'] = Variable<String>(
        $ExercisesTable.$convertermuscleGroup.toSql(muscleGroup),
      );
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['is_custom'] = Variable<bool>(isCustom);
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      name: Value(name),
      normalizedName: Value(normalizedName),
      muscleGroup: Value(muscleGroup),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isActive: Value(isActive),
      isCustom: Value(isCustom),
    );
  }

  factory Exercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Exercise(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      muscleGroup: $ExercisesTable.$convertermuscleGroup.fromJson(
        serializer.fromJson<String>(json['muscleGroup']),
      ),
      description: serializer.fromJson<String?>(json['description']),
      notes: serializer.fromJson<String?>(json['notes']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'normalizedName': serializer.toJson<String>(normalizedName),
      'muscleGroup': serializer.toJson<String>(
        $ExercisesTable.$convertermuscleGroup.toJson(muscleGroup),
      ),
      'description': serializer.toJson<String?>(description),
      'notes': serializer.toJson<String?>(notes),
      'isActive': serializer.toJson<bool>(isActive),
      'isCustom': serializer.toJson<bool>(isCustom),
    };
  }

  Exercise copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    int? id,
    String? name,
    String? normalizedName,
    MuscleGroup? muscleGroup,
    Value<String?> description = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? isActive,
    bool? isCustom,
  }) => Exercise(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
    muscleGroup: muscleGroup ?? this.muscleGroup,
    description: description.present ? description.value : this.description,
    notes: notes.present ? notes.value : this.notes,
    isActive: isActive ?? this.isActive,
    isCustom: isCustom ?? this.isCustom,
  );
  Exercise copyWithCompanion(ExercisesCompanion data) {
    return Exercise(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      muscleGroup: data.muscleGroup.present
          ? data.muscleGroup.value
          : this.muscleGroup,
      description: data.description.present
          ? data.description.value
          : this.description,
      notes: data.notes.present ? data.notes.value : this.notes,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Exercise(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('muscleGroup: $muscleGroup, ')
          ..write('description: $description, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('isCustom: $isCustom')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    id,
    name,
    normalizedName,
    muscleGroup,
    description,
    notes,
    isActive,
    isCustom,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exercise &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName &&
          other.muscleGroup == this.muscleGroup &&
          other.description == this.description &&
          other.notes == this.notes &&
          other.isActive == this.isActive &&
          other.isCustom == this.isCustom);
}

class ExercisesCompanion extends UpdateCompanion<Exercise> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> id;
  final Value<String> name;
  final Value<String> normalizedName;
  final Value<MuscleGroup> muscleGroup;
  final Value<String?> description;
  final Value<String?> notes;
  final Value<bool> isActive;
  final Value<bool> isCustom;
  const ExercisesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.muscleGroup = const Value.absent(),
    this.description = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isCustom = const Value.absent(),
  });
  ExercisesCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    required String name,
    required String normalizedName,
    required MuscleGroup muscleGroup,
    this.description = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isCustom = const Value.absent(),
  }) : name = Value(name),
       normalizedName = Value(normalizedName),
       muscleGroup = Value(muscleGroup);
  static Insertable<Exercise> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<String>? muscleGroup,
    Expression<String>? description,
    Expression<String>? notes,
    Expression<bool>? isActive,
    Expression<bool>? isCustom,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (muscleGroup != null) 'muscle_group': muscleGroup,
      if (description != null) 'description': description,
      if (notes != null) 'notes': notes,
      if (isActive != null) 'is_active': isActive,
      if (isCustom != null) 'is_custom': isCustom,
    });
  }

  ExercisesCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? id,
    Value<String>? name,
    Value<String>? normalizedName,
    Value<MuscleGroup>? muscleGroup,
    Value<String?>? description,
    Value<String?>? notes,
    Value<bool>? isActive,
    Value<bool>? isCustom,
  }) {
    return ExercisesCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (muscleGroup.present) {
      map['muscle_group'] = Variable<String>(
        $ExercisesTable.$convertermuscleGroup.toSql(muscleGroup.value),
      );
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('muscleGroup: $muscleGroup, ')
          ..write('description: $description, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('isCustom: $isCustom')
          ..write(')'))
        .toString();
  }
}

class $WorkoutPlansTable extends WorkoutPlans
    with TableInfo<$WorkoutPlansTable, WorkoutPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    id,
    name,
    description,
    isActive,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutPlan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutPlan(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $WorkoutPlansTable createAlias(String alias) {
    return $WorkoutPlansTable(attachedDatabase, alias);
  }
}

class WorkoutPlan extends DataClass implements Insertable<WorkoutPlan> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final int id;
  final String name;
  final String? description;
  final bool isActive;
  final int sortOrder;
  const WorkoutPlan({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  WorkoutPlansCompanion toCompanion(bool nullToAbsent) {
    return WorkoutPlansCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      isActive: Value(isActive),
      sortOrder: Value(sortOrder),
    );
  }

  factory WorkoutPlan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutPlan(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'isActive': serializer.toJson<bool>(isActive),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  WorkoutPlan copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    int? id,
    String? name,
    Value<String?> description = const Value.absent(),
    bool? isActive,
    int? sortOrder,
  }) => WorkoutPlan(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    isActive: isActive ?? this.isActive,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  WorkoutPlan copyWithCompanion(WorkoutPlansCompanion data) {
    return WorkoutPlan(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutPlan(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    id,
    name,
    description,
    isActive,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutPlan &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.isActive == this.isActive &&
          other.sortOrder == this.sortOrder);
}

class WorkoutPlansCompanion extends UpdateCompanion<WorkoutPlan> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<bool> isActive;
  final Value<int> sortOrder;
  const WorkoutPlansCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  WorkoutPlansCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : name = Value(name);
  static Insertable<WorkoutPlan> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<bool>? isActive,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (isActive != null) 'is_active': isActive,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  WorkoutPlansCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<bool>? isActive,
    Value<int>? sortOrder,
  }) {
    return WorkoutPlansCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutPlansCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $WorkoutPlanExercisesTable extends WorkoutPlanExercises
    with TableInfo<$WorkoutPlanExercisesTable, WorkoutPlanExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutPlanExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _workoutPlanIdMeta = const VerificationMeta(
    'workoutPlanId',
  );
  @override
  late final GeneratedColumn<int> workoutPlanId = GeneratedColumn<int>(
    'workout_plan_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workout_plans (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restSecondsMeta = const VerificationMeta(
    'restSeconds',
  );
  @override
  late final GeneratedColumn<int> restSeconds = GeneratedColumn<int>(
    'rest_seconds',
    aliasedName,
    true,
    check: () => ComparableExpr(restSeconds).isBetweenValues(0, 3600),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    id,
    workoutPlanId,
    exerciseId,
    position,
    notes,
    restSeconds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_plan_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutPlanExercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('workout_plan_id')) {
      context.handle(
        _workoutPlanIdMeta,
        workoutPlanId.isAcceptableOrUnknown(
          data['workout_plan_id']!,
          _workoutPlanIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workoutPlanIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('rest_seconds')) {
      context.handle(
        _restSecondsMeta,
        restSeconds.isAcceptableOrUnknown(
          data['rest_seconds']!,
          _restSecondsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutPlanExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutPlanExercise(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      workoutPlanId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}workout_plan_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      restSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_seconds'],
      ),
    );
  }

  @override
  $WorkoutPlanExercisesTable createAlias(String alias) {
    return $WorkoutPlanExercisesTable(attachedDatabase, alias);
  }
}

class WorkoutPlanExercise extends DataClass
    implements Insertable<WorkoutPlanExercise> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final int id;
  final int workoutPlanId;
  final int exerciseId;
  final int position;
  final String? notes;
  final int? restSeconds;
  const WorkoutPlanExercise({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.workoutPlanId,
    required this.exerciseId,
    required this.position,
    this.notes,
    this.restSeconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['id'] = Variable<int>(id);
    map['workout_plan_id'] = Variable<int>(workoutPlanId);
    map['exercise_id'] = Variable<int>(exerciseId);
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || restSeconds != null) {
      map['rest_seconds'] = Variable<int>(restSeconds);
    }
    return map;
  }

  WorkoutPlanExercisesCompanion toCompanion(bool nullToAbsent) {
    return WorkoutPlanExercisesCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      workoutPlanId: Value(workoutPlanId),
      exerciseId: Value(exerciseId),
      position: Value(position),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      restSeconds: restSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(restSeconds),
    );
  }

  factory WorkoutPlanExercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutPlanExercise(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      id: serializer.fromJson<int>(json['id']),
      workoutPlanId: serializer.fromJson<int>(json['workoutPlanId']),
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      position: serializer.fromJson<int>(json['position']),
      notes: serializer.fromJson<String?>(json['notes']),
      restSeconds: serializer.fromJson<int?>(json['restSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'id': serializer.toJson<int>(id),
      'workoutPlanId': serializer.toJson<int>(workoutPlanId),
      'exerciseId': serializer.toJson<int>(exerciseId),
      'position': serializer.toJson<int>(position),
      'notes': serializer.toJson<String?>(notes),
      'restSeconds': serializer.toJson<int?>(restSeconds),
    };
  }

  WorkoutPlanExercise copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    int? id,
    int? workoutPlanId,
    int? exerciseId,
    int? position,
    Value<String?> notes = const Value.absent(),
    Value<int?> restSeconds = const Value.absent(),
  }) => WorkoutPlanExercise(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    workoutPlanId: workoutPlanId ?? this.workoutPlanId,
    exerciseId: exerciseId ?? this.exerciseId,
    position: position ?? this.position,
    notes: notes.present ? notes.value : this.notes,
    restSeconds: restSeconds.present ? restSeconds.value : this.restSeconds,
  );
  WorkoutPlanExercise copyWithCompanion(WorkoutPlanExercisesCompanion data) {
    return WorkoutPlanExercise(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      workoutPlanId: data.workoutPlanId.present
          ? data.workoutPlanId.value
          : this.workoutPlanId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      position: data.position.present ? data.position.value : this.position,
      notes: data.notes.present ? data.notes.value : this.notes,
      restSeconds: data.restSeconds.present
          ? data.restSeconds.value
          : this.restSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutPlanExercise(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('workoutPlanId: $workoutPlanId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('position: $position, ')
          ..write('notes: $notes, ')
          ..write('restSeconds: $restSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    id,
    workoutPlanId,
    exerciseId,
    position,
    notes,
    restSeconds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutPlanExercise &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.workoutPlanId == this.workoutPlanId &&
          other.exerciseId == this.exerciseId &&
          other.position == this.position &&
          other.notes == this.notes &&
          other.restSeconds == this.restSeconds);
}

class WorkoutPlanExercisesCompanion
    extends UpdateCompanion<WorkoutPlanExercise> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> id;
  final Value<int> workoutPlanId;
  final Value<int> exerciseId;
  final Value<int> position;
  final Value<String?> notes;
  final Value<int?> restSeconds;
  const WorkoutPlanExercisesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.workoutPlanId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.position = const Value.absent(),
    this.notes = const Value.absent(),
    this.restSeconds = const Value.absent(),
  });
  WorkoutPlanExercisesCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    required int workoutPlanId,
    required int exerciseId,
    required int position,
    this.notes = const Value.absent(),
    this.restSeconds = const Value.absent(),
  }) : workoutPlanId = Value(workoutPlanId),
       exerciseId = Value(exerciseId),
       position = Value(position);
  static Insertable<WorkoutPlanExercise> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? id,
    Expression<int>? workoutPlanId,
    Expression<int>? exerciseId,
    Expression<int>? position,
    Expression<String>? notes,
    Expression<int>? restSeconds,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (workoutPlanId != null) 'workout_plan_id': workoutPlanId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (position != null) 'position': position,
      if (notes != null) 'notes': notes,
      if (restSeconds != null) 'rest_seconds': restSeconds,
    });
  }

  WorkoutPlanExercisesCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? id,
    Value<int>? workoutPlanId,
    Value<int>? exerciseId,
    Value<int>? position,
    Value<String?>? notes,
    Value<int?>? restSeconds,
  }) {
    return WorkoutPlanExercisesCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      workoutPlanId: workoutPlanId ?? this.workoutPlanId,
      exerciseId: exerciseId ?? this.exerciseId,
      position: position ?? this.position,
      notes: notes ?? this.notes,
      restSeconds: restSeconds ?? this.restSeconds,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workoutPlanId.present) {
      map['workout_plan_id'] = Variable<int>(workoutPlanId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (restSeconds.present) {
      map['rest_seconds'] = Variable<int>(restSeconds.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutPlanExercisesCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('workoutPlanId: $workoutPlanId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('position: $position, ')
          ..write('notes: $notes, ')
          ..write('restSeconds: $restSeconds')
          ..write(')'))
        .toString();
  }
}

class $WorkoutPlanSetsTable extends WorkoutPlanSets
    with TableInfo<$WorkoutPlanSetsTable, WorkoutPlanSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutPlanSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _planExerciseIdMeta = const VerificationMeta(
    'planExerciseId',
  );
  @override
  late final GeneratedColumn<int> planExerciseId = GeneratedColumn<int>(
    'plan_exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workout_plan_exercises (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repetitionsMeta = const VerificationMeta(
    'repetitions',
  );
  @override
  late final GeneratedColumn<int> repetitions = GeneratedColumn<int>(
    'repetitions',
    aliasedName,
    false,
    check: () => ComparableExpr(repetitions).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    check: () => ComparableExpr(weightKg).isBiggerOrEqualValue(0),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    planExerciseId,
    position,
    repetitions,
    weightKg,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_plan_sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutPlanSet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plan_exercise_id')) {
      context.handle(
        _planExerciseIdMeta,
        planExerciseId.isAcceptableOrUnknown(
          data['plan_exercise_id']!,
          _planExerciseIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_planExerciseIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('repetitions')) {
      context.handle(
        _repetitionsMeta,
        repetitions.isAcceptableOrUnknown(
          data['repetitions']!,
          _repetitionsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_repetitionsMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutPlanSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutPlanSet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      planExerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plan_exercise_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      repetitions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repetitions'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $WorkoutPlanSetsTable createAlias(String alias) {
    return $WorkoutPlanSetsTable(attachedDatabase, alias);
  }
}

class WorkoutPlanSet extends DataClass implements Insertable<WorkoutPlanSet> {
  final int id;
  final int planExerciseId;
  final int position;
  final int repetitions;
  final double weightKg;
  final String? notes;
  const WorkoutPlanSet({
    required this.id,
    required this.planExerciseId,
    required this.position,
    required this.repetitions,
    required this.weightKg,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['plan_exercise_id'] = Variable<int>(planExerciseId);
    map['position'] = Variable<int>(position);
    map['repetitions'] = Variable<int>(repetitions);
    map['weight_kg'] = Variable<double>(weightKg);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  WorkoutPlanSetsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutPlanSetsCompanion(
      id: Value(id),
      planExerciseId: Value(planExerciseId),
      position: Value(position),
      repetitions: Value(repetitions),
      weightKg: Value(weightKg),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory WorkoutPlanSet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutPlanSet(
      id: serializer.fromJson<int>(json['id']),
      planExerciseId: serializer.fromJson<int>(json['planExerciseId']),
      position: serializer.fromJson<int>(json['position']),
      repetitions: serializer.fromJson<int>(json['repetitions']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'planExerciseId': serializer.toJson<int>(planExerciseId),
      'position': serializer.toJson<int>(position),
      'repetitions': serializer.toJson<int>(repetitions),
      'weightKg': serializer.toJson<double>(weightKg),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  WorkoutPlanSet copyWith({
    int? id,
    int? planExerciseId,
    int? position,
    int? repetitions,
    double? weightKg,
    Value<String?> notes = const Value.absent(),
  }) => WorkoutPlanSet(
    id: id ?? this.id,
    planExerciseId: planExerciseId ?? this.planExerciseId,
    position: position ?? this.position,
    repetitions: repetitions ?? this.repetitions,
    weightKg: weightKg ?? this.weightKg,
    notes: notes.present ? notes.value : this.notes,
  );
  WorkoutPlanSet copyWithCompanion(WorkoutPlanSetsCompanion data) {
    return WorkoutPlanSet(
      id: data.id.present ? data.id.value : this.id,
      planExerciseId: data.planExerciseId.present
          ? data.planExerciseId.value
          : this.planExerciseId,
      position: data.position.present ? data.position.value : this.position,
      repetitions: data.repetitions.present
          ? data.repetitions.value
          : this.repetitions,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutPlanSet(')
          ..write('id: $id, ')
          ..write('planExerciseId: $planExerciseId, ')
          ..write('position: $position, ')
          ..write('repetitions: $repetitions, ')
          ..write('weightKg: $weightKg, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, planExerciseId, position, repetitions, weightKg, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutPlanSet &&
          other.id == this.id &&
          other.planExerciseId == this.planExerciseId &&
          other.position == this.position &&
          other.repetitions == this.repetitions &&
          other.weightKg == this.weightKg &&
          other.notes == this.notes);
}

class WorkoutPlanSetsCompanion extends UpdateCompanion<WorkoutPlanSet> {
  final Value<int> id;
  final Value<int> planExerciseId;
  final Value<int> position;
  final Value<int> repetitions;
  final Value<double> weightKg;
  final Value<String?> notes;
  const WorkoutPlanSetsCompanion({
    this.id = const Value.absent(),
    this.planExerciseId = const Value.absent(),
    this.position = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.notes = const Value.absent(),
  });
  WorkoutPlanSetsCompanion.insert({
    this.id = const Value.absent(),
    required int planExerciseId,
    required int position,
    required int repetitions,
    required double weightKg,
    this.notes = const Value.absent(),
  }) : planExerciseId = Value(planExerciseId),
       position = Value(position),
       repetitions = Value(repetitions),
       weightKg = Value(weightKg);
  static Insertable<WorkoutPlanSet> custom({
    Expression<int>? id,
    Expression<int>? planExerciseId,
    Expression<int>? position,
    Expression<int>? repetitions,
    Expression<double>? weightKg,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planExerciseId != null) 'plan_exercise_id': planExerciseId,
      if (position != null) 'position': position,
      if (repetitions != null) 'repetitions': repetitions,
      if (weightKg != null) 'weight_kg': weightKg,
      if (notes != null) 'notes': notes,
    });
  }

  WorkoutPlanSetsCompanion copyWith({
    Value<int>? id,
    Value<int>? planExerciseId,
    Value<int>? position,
    Value<int>? repetitions,
    Value<double>? weightKg,
    Value<String?>? notes,
  }) {
    return WorkoutPlanSetsCompanion(
      id: id ?? this.id,
      planExerciseId: planExerciseId ?? this.planExerciseId,
      position: position ?? this.position,
      repetitions: repetitions ?? this.repetitions,
      weightKg: weightKg ?? this.weightKg,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (planExerciseId.present) {
      map['plan_exercise_id'] = Variable<int>(planExerciseId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (repetitions.present) {
      map['repetitions'] = Variable<int>(repetitions.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutPlanSetsCompanion(')
          ..write('id: $id, ')
          ..write('planExerciseId: $planExerciseId, ')
          ..write('position: $position, ')
          ..write('repetitions: $repetitions, ')
          ..write('weightKg: $weightKg, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSessionsTable extends WorkoutSessions
    with TableInfo<$WorkoutSessionsTable, WorkoutSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _workoutPlanIdMeta = const VerificationMeta(
    'workoutPlanId',
  );
  @override
  late final GeneratedColumn<int> workoutPlanId = GeneratedColumn<int>(
    'workout_plan_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workout_plans (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _planNameSnapshotMeta = const VerificationMeta(
    'planNameSnapshot',
  );
  @override
  late final GeneratedColumn<String> planNameSnapshot = GeneratedColumn<String>(
    'plan_name_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    true,
    check: () => ComparableExpr(durationSeconds).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SessionStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SessionStatus>($WorkoutSessionsTable.$converterstatus);
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    id,
    workoutPlanId,
    planNameSnapshot,
    startedAt,
    finishedAt,
    durationSeconds,
    notes,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('workout_plan_id')) {
      context.handle(
        _workoutPlanIdMeta,
        workoutPlanId.isAcceptableOrUnknown(
          data['workout_plan_id']!,
          _workoutPlanIdMeta,
        ),
      );
    }
    if (data.containsKey('plan_name_snapshot')) {
      context.handle(
        _planNameSnapshotMeta,
        planNameSnapshot.isAcceptableOrUnknown(
          data['plan_name_snapshot']!,
          _planNameSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_planNameSnapshotMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSession(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      workoutPlanId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}workout_plan_id'],
      ),
      planNameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_name_snapshot'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      status: $WorkoutSessionsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
    );
  }

  @override
  $WorkoutSessionsTable createAlias(String alias) {
    return $WorkoutSessionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SessionStatus, String, String> $converterstatus =
      const EnumNameConverter<SessionStatus>(SessionStatus.values);
}

class WorkoutSession extends DataClass implements Insertable<WorkoutSession> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final int id;
  final int? workoutPlanId;
  final String planNameSnapshot;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final int? durationSeconds;
  final String? notes;
  final SessionStatus status;
  const WorkoutSession({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    this.workoutPlanId,
    required this.planNameSnapshot,
    required this.startedAt,
    this.finishedAt,
    this.durationSeconds,
    this.notes,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || workoutPlanId != null) {
      map['workout_plan_id'] = Variable<int>(workoutPlanId);
    }
    map['plan_name_snapshot'] = Variable<String>(planNameSnapshot);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<int>(durationSeconds);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    {
      map['status'] = Variable<String>(
        $WorkoutSessionsTable.$converterstatus.toSql(status),
      );
    }
    return map;
  }

  WorkoutSessionsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSessionsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      workoutPlanId: workoutPlanId == null && nullToAbsent
          ? const Value.absent()
          : Value(workoutPlanId),
      planNameSnapshot: Value(planNameSnapshot),
      startedAt: Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      status: Value(status),
    );
  }

  factory WorkoutSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSession(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      id: serializer.fromJson<int>(json['id']),
      workoutPlanId: serializer.fromJson<int?>(json['workoutPlanId']),
      planNameSnapshot: serializer.fromJson<String>(json['planNameSnapshot']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      durationSeconds: serializer.fromJson<int?>(json['durationSeconds']),
      notes: serializer.fromJson<String?>(json['notes']),
      status: $WorkoutSessionsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'id': serializer.toJson<int>(id),
      'workoutPlanId': serializer.toJson<int?>(workoutPlanId),
      'planNameSnapshot': serializer.toJson<String>(planNameSnapshot),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'durationSeconds': serializer.toJson<int?>(durationSeconds),
      'notes': serializer.toJson<String?>(notes),
      'status': serializer.toJson<String>(
        $WorkoutSessionsTable.$converterstatus.toJson(status),
      ),
    };
  }

  WorkoutSession copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    int? id,
    Value<int?> workoutPlanId = const Value.absent(),
    String? planNameSnapshot,
    DateTime? startedAt,
    Value<DateTime?> finishedAt = const Value.absent(),
    Value<int?> durationSeconds = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    SessionStatus? status,
  }) => WorkoutSession(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    workoutPlanId: workoutPlanId.present
        ? workoutPlanId.value
        : this.workoutPlanId,
    planNameSnapshot: planNameSnapshot ?? this.planNameSnapshot,
    startedAt: startedAt ?? this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    durationSeconds: durationSeconds.present
        ? durationSeconds.value
        : this.durationSeconds,
    notes: notes.present ? notes.value : this.notes,
    status: status ?? this.status,
  );
  WorkoutSession copyWithCompanion(WorkoutSessionsCompanion data) {
    return WorkoutSession(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      workoutPlanId: data.workoutPlanId.present
          ? data.workoutPlanId.value
          : this.workoutPlanId,
      planNameSnapshot: data.planNameSnapshot.present
          ? data.planNameSnapshot.value
          : this.planNameSnapshot,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      notes: data.notes.present ? data.notes.value : this.notes,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSession(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('workoutPlanId: $workoutPlanId, ')
          ..write('planNameSnapshot: $planNameSnapshot, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('notes: $notes, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    id,
    workoutPlanId,
    planNameSnapshot,
    startedAt,
    finishedAt,
    durationSeconds,
    notes,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSession &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.workoutPlanId == this.workoutPlanId &&
          other.planNameSnapshot == this.planNameSnapshot &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.durationSeconds == this.durationSeconds &&
          other.notes == this.notes &&
          other.status == this.status);
}

class WorkoutSessionsCompanion extends UpdateCompanion<WorkoutSession> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> id;
  final Value<int?> workoutPlanId;
  final Value<String> planNameSnapshot;
  final Value<DateTime> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<int?> durationSeconds;
  final Value<String?> notes;
  final Value<SessionStatus> status;
  const WorkoutSessionsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.workoutPlanId = const Value.absent(),
    this.planNameSnapshot = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.notes = const Value.absent(),
    this.status = const Value.absent(),
  });
  WorkoutSessionsCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.workoutPlanId = const Value.absent(),
    required String planNameSnapshot,
    required DateTime startedAt,
    this.finishedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.notes = const Value.absent(),
    required SessionStatus status,
  }) : planNameSnapshot = Value(planNameSnapshot),
       startedAt = Value(startedAt),
       status = Value(status);
  static Insertable<WorkoutSession> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? id,
    Expression<int>? workoutPlanId,
    Expression<String>? planNameSnapshot,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<int>? durationSeconds,
    Expression<String>? notes,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (workoutPlanId != null) 'workout_plan_id': workoutPlanId,
      if (planNameSnapshot != null) 'plan_name_snapshot': planNameSnapshot,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (notes != null) 'notes': notes,
      if (status != null) 'status': status,
    });
  }

  WorkoutSessionsCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? id,
    Value<int?>? workoutPlanId,
    Value<String>? planNameSnapshot,
    Value<DateTime>? startedAt,
    Value<DateTime?>? finishedAt,
    Value<int?>? durationSeconds,
    Value<String?>? notes,
    Value<SessionStatus>? status,
  }) {
    return WorkoutSessionsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      workoutPlanId: workoutPlanId ?? this.workoutPlanId,
      planNameSnapshot: planNameSnapshot ?? this.planNameSnapshot,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workoutPlanId.present) {
      map['workout_plan_id'] = Variable<int>(workoutPlanId.value);
    }
    if (planNameSnapshot.present) {
      map['plan_name_snapshot'] = Variable<String>(planNameSnapshot.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $WorkoutSessionsTable.$converterstatus.toSql(status.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('workoutPlanId: $workoutPlanId, ')
          ..write('planNameSnapshot: $planNameSnapshot, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('notes: $notes, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSessionExercisesTable extends WorkoutSessionExercises
    with TableInfo<$WorkoutSessionExercisesTable, WorkoutSessionExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSessionExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workout_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _planExerciseIdMeta = const VerificationMeta(
    'planExerciseId',
  );
  @override
  late final GeneratedColumn<int> planExerciseId = GeneratedColumn<int>(
    'plan_exercise_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workout_plan_exercises (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _exerciseNameSnapshotMeta =
      const VerificationMeta('exerciseNameSnapshot');
  @override
  late final GeneratedColumn<String> exerciseNameSnapshot =
      GeneratedColumn<String>(
        'exercise_name_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  late final GeneratedColumnWithTypeConverter<MuscleGroup, String>
  muscleGroupSnapshot =
      GeneratedColumn<String>(
        'muscle_group_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MuscleGroup>(
        $WorkoutSessionExercisesTable.$convertermuscleGroupSnapshot,
      );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restSecondsMeta = const VerificationMeta(
    'restSeconds',
  );
  @override
  late final GeneratedColumn<int> restSeconds = GeneratedColumn<int>(
    'rest_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _skippedMeta = const VerificationMeta(
    'skipped',
  );
  @override
  late final GeneratedColumn<bool> skipped = GeneratedColumn<bool>(
    'skipped',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("skipped" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    exerciseId,
    planExerciseId,
    exerciseNameSnapshot,
    muscleGroupSnapshot,
    position,
    notes,
    restSeconds,
    skipped,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_session_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutSessionExercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('plan_exercise_id')) {
      context.handle(
        _planExerciseIdMeta,
        planExerciseId.isAcceptableOrUnknown(
          data['plan_exercise_id']!,
          _planExerciseIdMeta,
        ),
      );
    }
    if (data.containsKey('exercise_name_snapshot')) {
      context.handle(
        _exerciseNameSnapshotMeta,
        exerciseNameSnapshot.isAcceptableOrUnknown(
          data['exercise_name_snapshot']!,
          _exerciseNameSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exerciseNameSnapshotMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('rest_seconds')) {
      context.handle(
        _restSecondsMeta,
        restSeconds.isAcceptableOrUnknown(
          data['rest_seconds']!,
          _restSecondsMeta,
        ),
      );
    }
    if (data.containsKey('skipped')) {
      context.handle(
        _skippedMeta,
        skipped.isAcceptableOrUnknown(data['skipped']!, _skippedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSessionExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSessionExercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_id'],
      )!,
      planExerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plan_exercise_id'],
      ),
      exerciseNameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_name_snapshot'],
      )!,
      muscleGroupSnapshot: $WorkoutSessionExercisesTable
          .$convertermuscleGroupSnapshot
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}muscle_group_snapshot'],
            )!,
          ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      restSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_seconds'],
      ),
      skipped: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}skipped'],
      )!,
    );
  }

  @override
  $WorkoutSessionExercisesTable createAlias(String alias) {
    return $WorkoutSessionExercisesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MuscleGroup, String, String>
  $convertermuscleGroupSnapshot = const EnumNameConverter<MuscleGroup>(
    MuscleGroup.values,
  );
}

class WorkoutSessionExercise extends DataClass
    implements Insertable<WorkoutSessionExercise> {
  final int id;
  final int sessionId;
  final int exerciseId;

  /// Exercício da ficha que originou este item (para "atualizar ficha").
  final int? planExerciseId;
  final String exerciseNameSnapshot;
  final MuscleGroup muscleGroupSnapshot;
  final int position;
  final String? notes;
  final int? restSeconds;
  final bool skipped;
  const WorkoutSessionExercise({
    required this.id,
    required this.sessionId,
    required this.exerciseId,
    this.planExerciseId,
    required this.exerciseNameSnapshot,
    required this.muscleGroupSnapshot,
    required this.position,
    this.notes,
    this.restSeconds,
    required this.skipped,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['exercise_id'] = Variable<int>(exerciseId);
    if (!nullToAbsent || planExerciseId != null) {
      map['plan_exercise_id'] = Variable<int>(planExerciseId);
    }
    map['exercise_name_snapshot'] = Variable<String>(exerciseNameSnapshot);
    {
      map['muscle_group_snapshot'] = Variable<String>(
        $WorkoutSessionExercisesTable.$convertermuscleGroupSnapshot.toSql(
          muscleGroupSnapshot,
        ),
      );
    }
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || restSeconds != null) {
      map['rest_seconds'] = Variable<int>(restSeconds);
    }
    map['skipped'] = Variable<bool>(skipped);
    return map;
  }

  WorkoutSessionExercisesCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSessionExercisesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      exerciseId: Value(exerciseId),
      planExerciseId: planExerciseId == null && nullToAbsent
          ? const Value.absent()
          : Value(planExerciseId),
      exerciseNameSnapshot: Value(exerciseNameSnapshot),
      muscleGroupSnapshot: Value(muscleGroupSnapshot),
      position: Value(position),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      restSeconds: restSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(restSeconds),
      skipped: Value(skipped),
    );
  }

  factory WorkoutSessionExercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSessionExercise(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      planExerciseId: serializer.fromJson<int?>(json['planExerciseId']),
      exerciseNameSnapshot: serializer.fromJson<String>(
        json['exerciseNameSnapshot'],
      ),
      muscleGroupSnapshot: $WorkoutSessionExercisesTable
          .$convertermuscleGroupSnapshot
          .fromJson(serializer.fromJson<String>(json['muscleGroupSnapshot'])),
      position: serializer.fromJson<int>(json['position']),
      notes: serializer.fromJson<String?>(json['notes']),
      restSeconds: serializer.fromJson<int?>(json['restSeconds']),
      skipped: serializer.fromJson<bool>(json['skipped']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'exerciseId': serializer.toJson<int>(exerciseId),
      'planExerciseId': serializer.toJson<int?>(planExerciseId),
      'exerciseNameSnapshot': serializer.toJson<String>(exerciseNameSnapshot),
      'muscleGroupSnapshot': serializer.toJson<String>(
        $WorkoutSessionExercisesTable.$convertermuscleGroupSnapshot.toJson(
          muscleGroupSnapshot,
        ),
      ),
      'position': serializer.toJson<int>(position),
      'notes': serializer.toJson<String?>(notes),
      'restSeconds': serializer.toJson<int?>(restSeconds),
      'skipped': serializer.toJson<bool>(skipped),
    };
  }

  WorkoutSessionExercise copyWith({
    int? id,
    int? sessionId,
    int? exerciseId,
    Value<int?> planExerciseId = const Value.absent(),
    String? exerciseNameSnapshot,
    MuscleGroup? muscleGroupSnapshot,
    int? position,
    Value<String?> notes = const Value.absent(),
    Value<int?> restSeconds = const Value.absent(),
    bool? skipped,
  }) => WorkoutSessionExercise(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    exerciseId: exerciseId ?? this.exerciseId,
    planExerciseId: planExerciseId.present
        ? planExerciseId.value
        : this.planExerciseId,
    exerciseNameSnapshot: exerciseNameSnapshot ?? this.exerciseNameSnapshot,
    muscleGroupSnapshot: muscleGroupSnapshot ?? this.muscleGroupSnapshot,
    position: position ?? this.position,
    notes: notes.present ? notes.value : this.notes,
    restSeconds: restSeconds.present ? restSeconds.value : this.restSeconds,
    skipped: skipped ?? this.skipped,
  );
  WorkoutSessionExercise copyWithCompanion(
    WorkoutSessionExercisesCompanion data,
  ) {
    return WorkoutSessionExercise(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      planExerciseId: data.planExerciseId.present
          ? data.planExerciseId.value
          : this.planExerciseId,
      exerciseNameSnapshot: data.exerciseNameSnapshot.present
          ? data.exerciseNameSnapshot.value
          : this.exerciseNameSnapshot,
      muscleGroupSnapshot: data.muscleGroupSnapshot.present
          ? data.muscleGroupSnapshot.value
          : this.muscleGroupSnapshot,
      position: data.position.present ? data.position.value : this.position,
      notes: data.notes.present ? data.notes.value : this.notes,
      restSeconds: data.restSeconds.present
          ? data.restSeconds.value
          : this.restSeconds,
      skipped: data.skipped.present ? data.skipped.value : this.skipped,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionExercise(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('planExerciseId: $planExerciseId, ')
          ..write('exerciseNameSnapshot: $exerciseNameSnapshot, ')
          ..write('muscleGroupSnapshot: $muscleGroupSnapshot, ')
          ..write('position: $position, ')
          ..write('notes: $notes, ')
          ..write('restSeconds: $restSeconds, ')
          ..write('skipped: $skipped')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    exerciseId,
    planExerciseId,
    exerciseNameSnapshot,
    muscleGroupSnapshot,
    position,
    notes,
    restSeconds,
    skipped,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSessionExercise &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.exerciseId == this.exerciseId &&
          other.planExerciseId == this.planExerciseId &&
          other.exerciseNameSnapshot == this.exerciseNameSnapshot &&
          other.muscleGroupSnapshot == this.muscleGroupSnapshot &&
          other.position == this.position &&
          other.notes == this.notes &&
          other.restSeconds == this.restSeconds &&
          other.skipped == this.skipped);
}

class WorkoutSessionExercisesCompanion
    extends UpdateCompanion<WorkoutSessionExercise> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int> exerciseId;
  final Value<int?> planExerciseId;
  final Value<String> exerciseNameSnapshot;
  final Value<MuscleGroup> muscleGroupSnapshot;
  final Value<int> position;
  final Value<String?> notes;
  final Value<int?> restSeconds;
  final Value<bool> skipped;
  const WorkoutSessionExercisesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.planExerciseId = const Value.absent(),
    this.exerciseNameSnapshot = const Value.absent(),
    this.muscleGroupSnapshot = const Value.absent(),
    this.position = const Value.absent(),
    this.notes = const Value.absent(),
    this.restSeconds = const Value.absent(),
    this.skipped = const Value.absent(),
  });
  WorkoutSessionExercisesCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required int exerciseId,
    this.planExerciseId = const Value.absent(),
    required String exerciseNameSnapshot,
    required MuscleGroup muscleGroupSnapshot,
    required int position,
    this.notes = const Value.absent(),
    this.restSeconds = const Value.absent(),
    this.skipped = const Value.absent(),
  }) : sessionId = Value(sessionId),
       exerciseId = Value(exerciseId),
       exerciseNameSnapshot = Value(exerciseNameSnapshot),
       muscleGroupSnapshot = Value(muscleGroupSnapshot),
       position = Value(position);
  static Insertable<WorkoutSessionExercise> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? exerciseId,
    Expression<int>? planExerciseId,
    Expression<String>? exerciseNameSnapshot,
    Expression<String>? muscleGroupSnapshot,
    Expression<int>? position,
    Expression<String>? notes,
    Expression<int>? restSeconds,
    Expression<bool>? skipped,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (planExerciseId != null) 'plan_exercise_id': planExerciseId,
      if (exerciseNameSnapshot != null)
        'exercise_name_snapshot': exerciseNameSnapshot,
      if (muscleGroupSnapshot != null)
        'muscle_group_snapshot': muscleGroupSnapshot,
      if (position != null) 'position': position,
      if (notes != null) 'notes': notes,
      if (restSeconds != null) 'rest_seconds': restSeconds,
      if (skipped != null) 'skipped': skipped,
    });
  }

  WorkoutSessionExercisesCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<int>? exerciseId,
    Value<int?>? planExerciseId,
    Value<String>? exerciseNameSnapshot,
    Value<MuscleGroup>? muscleGroupSnapshot,
    Value<int>? position,
    Value<String?>? notes,
    Value<int?>? restSeconds,
    Value<bool>? skipped,
  }) {
    return WorkoutSessionExercisesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      planExerciseId: planExerciseId ?? this.planExerciseId,
      exerciseNameSnapshot: exerciseNameSnapshot ?? this.exerciseNameSnapshot,
      muscleGroupSnapshot: muscleGroupSnapshot ?? this.muscleGroupSnapshot,
      position: position ?? this.position,
      notes: notes ?? this.notes,
      restSeconds: restSeconds ?? this.restSeconds,
      skipped: skipped ?? this.skipped,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (planExerciseId.present) {
      map['plan_exercise_id'] = Variable<int>(planExerciseId.value);
    }
    if (exerciseNameSnapshot.present) {
      map['exercise_name_snapshot'] = Variable<String>(
        exerciseNameSnapshot.value,
      );
    }
    if (muscleGroupSnapshot.present) {
      map['muscle_group_snapshot'] = Variable<String>(
        $WorkoutSessionExercisesTable.$convertermuscleGroupSnapshot.toSql(
          muscleGroupSnapshot.value,
        ),
      );
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (restSeconds.present) {
      map['rest_seconds'] = Variable<int>(restSeconds.value);
    }
    if (skipped.present) {
      map['skipped'] = Variable<bool>(skipped.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionExercisesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('planExerciseId: $planExerciseId, ')
          ..write('exerciseNameSnapshot: $exerciseNameSnapshot, ')
          ..write('muscleGroupSnapshot: $muscleGroupSnapshot, ')
          ..write('position: $position, ')
          ..write('notes: $notes, ')
          ..write('restSeconds: $restSeconds, ')
          ..write('skipped: $skipped')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSessionSetsTable extends WorkoutSessionSets
    with TableInfo<$WorkoutSessionSetsTable, WorkoutSessionSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSessionSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionExerciseIdMeta = const VerificationMeta(
    'sessionExerciseId',
  );
  @override
  late final GeneratedColumn<int> sessionExerciseId = GeneratedColumn<int>(
    'session_exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workout_session_exercises (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plannedRepetitionsMeta =
      const VerificationMeta('plannedRepetitions');
  @override
  late final GeneratedColumn<int> plannedRepetitions = GeneratedColumn<int>(
    'planned_repetitions',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedWeightKgMeta = const VerificationMeta(
    'plannedWeightKg',
  );
  @override
  late final GeneratedColumn<double> plannedWeightKg = GeneratedColumn<double>(
    'planned_weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repetitionsMeta = const VerificationMeta(
    'repetitions',
  );
  @override
  late final GeneratedColumn<int> repetitions = GeneratedColumn<int>(
    'repetitions',
    aliasedName,
    false,
    check: () => ComparableExpr(repetitions).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    check: () => ComparableExpr(weightKg).isBiggerOrEqualValue(0),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionExerciseId,
    position,
    plannedRepetitions,
    plannedWeightKg,
    repetitions,
    weightKg,
    completed,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_session_sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutSessionSet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_exercise_id')) {
      context.handle(
        _sessionExerciseIdMeta,
        sessionExerciseId.isAcceptableOrUnknown(
          data['session_exercise_id']!,
          _sessionExerciseIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionExerciseIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('planned_repetitions')) {
      context.handle(
        _plannedRepetitionsMeta,
        plannedRepetitions.isAcceptableOrUnknown(
          data['planned_repetitions']!,
          _plannedRepetitionsMeta,
        ),
      );
    }
    if (data.containsKey('planned_weight_kg')) {
      context.handle(
        _plannedWeightKgMeta,
        plannedWeightKg.isAcceptableOrUnknown(
          data['planned_weight_kg']!,
          _plannedWeightKgMeta,
        ),
      );
    }
    if (data.containsKey('repetitions')) {
      context.handle(
        _repetitionsMeta,
        repetitions.isAcceptableOrUnknown(
          data['repetitions']!,
          _repetitionsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_repetitionsMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSessionSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSessionSet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionExerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_exercise_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      plannedRepetitions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_repetitions'],
      ),
      plannedWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}planned_weight_kg'],
      ),
      repetitions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repetitions'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $WorkoutSessionSetsTable createAlias(String alias) {
    return $WorkoutSessionSetsTable(attachedDatabase, alias);
  }
}

class WorkoutSessionSet extends DataClass
    implements Insertable<WorkoutSessionSet> {
  final int id;
  final int sessionExerciseId;
  final int position;
  final int? plannedRepetitions;
  final double? plannedWeightKg;
  final int repetitions;
  final double weightKg;
  final bool completed;
  final DateTime? completedAt;
  const WorkoutSessionSet({
    required this.id,
    required this.sessionExerciseId,
    required this.position,
    this.plannedRepetitions,
    this.plannedWeightKg,
    required this.repetitions,
    required this.weightKg,
    required this.completed,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_exercise_id'] = Variable<int>(sessionExerciseId);
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || plannedRepetitions != null) {
      map['planned_repetitions'] = Variable<int>(plannedRepetitions);
    }
    if (!nullToAbsent || plannedWeightKg != null) {
      map['planned_weight_kg'] = Variable<double>(plannedWeightKg);
    }
    map['repetitions'] = Variable<int>(repetitions);
    map['weight_kg'] = Variable<double>(weightKg);
    map['completed'] = Variable<bool>(completed);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  WorkoutSessionSetsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSessionSetsCompanion(
      id: Value(id),
      sessionExerciseId: Value(sessionExerciseId),
      position: Value(position),
      plannedRepetitions: plannedRepetitions == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedRepetitions),
      plannedWeightKg: plannedWeightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedWeightKg),
      repetitions: Value(repetitions),
      weightKg: Value(weightKg),
      completed: Value(completed),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory WorkoutSessionSet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSessionSet(
      id: serializer.fromJson<int>(json['id']),
      sessionExerciseId: serializer.fromJson<int>(json['sessionExerciseId']),
      position: serializer.fromJson<int>(json['position']),
      plannedRepetitions: serializer.fromJson<int?>(json['plannedRepetitions']),
      plannedWeightKg: serializer.fromJson<double?>(json['plannedWeightKg']),
      repetitions: serializer.fromJson<int>(json['repetitions']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      completed: serializer.fromJson<bool>(json['completed']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionExerciseId': serializer.toJson<int>(sessionExerciseId),
      'position': serializer.toJson<int>(position),
      'plannedRepetitions': serializer.toJson<int?>(plannedRepetitions),
      'plannedWeightKg': serializer.toJson<double?>(plannedWeightKg),
      'repetitions': serializer.toJson<int>(repetitions),
      'weightKg': serializer.toJson<double>(weightKg),
      'completed': serializer.toJson<bool>(completed),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  WorkoutSessionSet copyWith({
    int? id,
    int? sessionExerciseId,
    int? position,
    Value<int?> plannedRepetitions = const Value.absent(),
    Value<double?> plannedWeightKg = const Value.absent(),
    int? repetitions,
    double? weightKg,
    bool? completed,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => WorkoutSessionSet(
    id: id ?? this.id,
    sessionExerciseId: sessionExerciseId ?? this.sessionExerciseId,
    position: position ?? this.position,
    plannedRepetitions: plannedRepetitions.present
        ? plannedRepetitions.value
        : this.plannedRepetitions,
    plannedWeightKg: plannedWeightKg.present
        ? plannedWeightKg.value
        : this.plannedWeightKg,
    repetitions: repetitions ?? this.repetitions,
    weightKg: weightKg ?? this.weightKg,
    completed: completed ?? this.completed,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  WorkoutSessionSet copyWithCompanion(WorkoutSessionSetsCompanion data) {
    return WorkoutSessionSet(
      id: data.id.present ? data.id.value : this.id,
      sessionExerciseId: data.sessionExerciseId.present
          ? data.sessionExerciseId.value
          : this.sessionExerciseId,
      position: data.position.present ? data.position.value : this.position,
      plannedRepetitions: data.plannedRepetitions.present
          ? data.plannedRepetitions.value
          : this.plannedRepetitions,
      plannedWeightKg: data.plannedWeightKg.present
          ? data.plannedWeightKg.value
          : this.plannedWeightKg,
      repetitions: data.repetitions.present
          ? data.repetitions.value
          : this.repetitions,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      completed: data.completed.present ? data.completed.value : this.completed,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionSet(')
          ..write('id: $id, ')
          ..write('sessionExerciseId: $sessionExerciseId, ')
          ..write('position: $position, ')
          ..write('plannedRepetitions: $plannedRepetitions, ')
          ..write('plannedWeightKg: $plannedWeightKg, ')
          ..write('repetitions: $repetitions, ')
          ..write('weightKg: $weightKg, ')
          ..write('completed: $completed, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionExerciseId,
    position,
    plannedRepetitions,
    plannedWeightKg,
    repetitions,
    weightKg,
    completed,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSessionSet &&
          other.id == this.id &&
          other.sessionExerciseId == this.sessionExerciseId &&
          other.position == this.position &&
          other.plannedRepetitions == this.plannedRepetitions &&
          other.plannedWeightKg == this.plannedWeightKg &&
          other.repetitions == this.repetitions &&
          other.weightKg == this.weightKg &&
          other.completed == this.completed &&
          other.completedAt == this.completedAt);
}

class WorkoutSessionSetsCompanion extends UpdateCompanion<WorkoutSessionSet> {
  final Value<int> id;
  final Value<int> sessionExerciseId;
  final Value<int> position;
  final Value<int?> plannedRepetitions;
  final Value<double?> plannedWeightKg;
  final Value<int> repetitions;
  final Value<double> weightKg;
  final Value<bool> completed;
  final Value<DateTime?> completedAt;
  const WorkoutSessionSetsCompanion({
    this.id = const Value.absent(),
    this.sessionExerciseId = const Value.absent(),
    this.position = const Value.absent(),
    this.plannedRepetitions = const Value.absent(),
    this.plannedWeightKg = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.completed = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  WorkoutSessionSetsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionExerciseId,
    required int position,
    this.plannedRepetitions = const Value.absent(),
    this.plannedWeightKg = const Value.absent(),
    required int repetitions,
    required double weightKg,
    this.completed = const Value.absent(),
    this.completedAt = const Value.absent(),
  }) : sessionExerciseId = Value(sessionExerciseId),
       position = Value(position),
       repetitions = Value(repetitions),
       weightKg = Value(weightKg);
  static Insertable<WorkoutSessionSet> custom({
    Expression<int>? id,
    Expression<int>? sessionExerciseId,
    Expression<int>? position,
    Expression<int>? plannedRepetitions,
    Expression<double>? plannedWeightKg,
    Expression<int>? repetitions,
    Expression<double>? weightKg,
    Expression<bool>? completed,
    Expression<DateTime>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionExerciseId != null) 'session_exercise_id': sessionExerciseId,
      if (position != null) 'position': position,
      if (plannedRepetitions != null) 'planned_repetitions': plannedRepetitions,
      if (plannedWeightKg != null) 'planned_weight_kg': plannedWeightKg,
      if (repetitions != null) 'repetitions': repetitions,
      if (weightKg != null) 'weight_kg': weightKg,
      if (completed != null) 'completed': completed,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  WorkoutSessionSetsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionExerciseId,
    Value<int>? position,
    Value<int?>? plannedRepetitions,
    Value<double?>? plannedWeightKg,
    Value<int>? repetitions,
    Value<double>? weightKg,
    Value<bool>? completed,
    Value<DateTime?>? completedAt,
  }) {
    return WorkoutSessionSetsCompanion(
      id: id ?? this.id,
      sessionExerciseId: sessionExerciseId ?? this.sessionExerciseId,
      position: position ?? this.position,
      plannedRepetitions: plannedRepetitions ?? this.plannedRepetitions,
      plannedWeightKg: plannedWeightKg ?? this.plannedWeightKg,
      repetitions: repetitions ?? this.repetitions,
      weightKg: weightKg ?? this.weightKg,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionExerciseId.present) {
      map['session_exercise_id'] = Variable<int>(sessionExerciseId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (plannedRepetitions.present) {
      map['planned_repetitions'] = Variable<int>(plannedRepetitions.value);
    }
    if (plannedWeightKg.present) {
      map['planned_weight_kg'] = Variable<double>(plannedWeightKg.value);
    }
    if (repetitions.present) {
      map['repetitions'] = Variable<int>(repetitions.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionSetsCompanion(')
          ..write('id: $id, ')
          ..write('sessionExerciseId: $sessionExerciseId, ')
          ..write('position: $position, ')
          ..write('plannedRepetitions: $plannedRepetitions, ')
          ..write('plannedWeightKg: $plannedWeightKg, ')
          ..write('repetitions: $repetitions, ')
          ..write('weightKg: $weightKg, ')
          ..write('completed: $completed, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    check: () => id.equals(1),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ThemePreference, String>
  themePreference = GeneratedColumn<String>(
    'theme_preference',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(ThemePreference.system.name),
  ).withConverter<ThemePreference>($AppSettingsTable.$converterthemePreference);
  static const VerificationMeta _autoStartTimerMeta = const VerificationMeta(
    'autoStartTimer',
  );
  @override
  late final GeneratedColumn<bool> autoStartTimer = GeneratedColumn<bool>(
    'auto_start_timer',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_start_timer" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _timerSoundMeta = const VerificationMeta(
    'timerSound',
  );
  @override
  late final GeneratedColumn<bool> timerSound = GeneratedColumn<bool>(
    'timer_sound',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("timer_sound" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _timerVibrationMeta = const VerificationMeta(
    'timerVibration',
  );
  @override
  late final GeneratedColumn<bool> timerVibration = GeneratedColumn<bool>(
    'timer_vibration',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("timer_vibration" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _defaultRestSecondsMeta =
      const VerificationMeta('defaultRestSeconds');
  @override
  late final GeneratedColumn<int> defaultRestSeconds = GeneratedColumn<int>(
    'default_rest_seconds',
    aliasedName,
    false,
    check: () => ComparableExpr(defaultRestSeconds).isBetweenValues(5, 3600),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(90),
  );
  static const VerificationMeta _weightIncrementKgMeta = const VerificationMeta(
    'weightIncrementKg',
  );
  @override
  late final GeneratedColumn<double> weightIncrementKg =
      GeneratedColumn<double>(
        'weight_increment_kg',
        aliasedName,
        false,
        check: () =>
            ComparableExpr(weightIncrementKg).isBetweenValues(0.25, 50),
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(2.5),
      );
  @override
  late final GeneratedColumnWithTypeConverter<WeightUnit, String> weightUnit =
      GeneratedColumn<String>(
        'weight_unit',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(WeightUnit.kg.name),
      ).withConverter<WeightUnit>($AppSettingsTable.$converterweightUnit);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    themePreference,
    autoStartTimer,
    timerSound,
    timerVibration,
    defaultRestSeconds,
    weightIncrementKg,
    weightUnit,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('auto_start_timer')) {
      context.handle(
        _autoStartTimerMeta,
        autoStartTimer.isAcceptableOrUnknown(
          data['auto_start_timer']!,
          _autoStartTimerMeta,
        ),
      );
    }
    if (data.containsKey('timer_sound')) {
      context.handle(
        _timerSoundMeta,
        timerSound.isAcceptableOrUnknown(data['timer_sound']!, _timerSoundMeta),
      );
    }
    if (data.containsKey('timer_vibration')) {
      context.handle(
        _timerVibrationMeta,
        timerVibration.isAcceptableOrUnknown(
          data['timer_vibration']!,
          _timerVibrationMeta,
        ),
      );
    }
    if (data.containsKey('default_rest_seconds')) {
      context.handle(
        _defaultRestSecondsMeta,
        defaultRestSeconds.isAcceptableOrUnknown(
          data['default_rest_seconds']!,
          _defaultRestSecondsMeta,
        ),
      );
    }
    if (data.containsKey('weight_increment_kg')) {
      context.handle(
        _weightIncrementKgMeta,
        weightIncrementKg.isAcceptableOrUnknown(
          data['weight_increment_kg']!,
          _weightIncrementKgMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      themePreference: $AppSettingsTable.$converterthemePreference.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}theme_preference'],
        )!,
      ),
      autoStartTimer: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_start_timer'],
      )!,
      timerSound: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}timer_sound'],
      )!,
      timerVibration: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}timer_vibration'],
      )!,
      defaultRestSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_rest_seconds'],
      )!,
      weightIncrementKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_increment_kg'],
      )!,
      weightUnit: $AppSettingsTable.$converterweightUnit.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}weight_unit'],
        )!,
      ),
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ThemePreference, String, String>
  $converterthemePreference = const EnumNameConverter<ThemePreference>(
    ThemePreference.values,
  );
  static JsonTypeConverter2<WeightUnit, String, String> $converterweightUnit =
      const EnumNameConverter<WeightUnit>(WeightUnit.values);
}

class AppSettingsRow extends DataClass implements Insertable<AppSettingsRow> {
  final int id;
  final ThemePreference themePreference;
  final bool autoStartTimer;
  final bool timerSound;
  final bool timerVibration;
  final int defaultRestSeconds;
  final double weightIncrementKg;
  final WeightUnit weightUnit;
  const AppSettingsRow({
    required this.id,
    required this.themePreference,
    required this.autoStartTimer,
    required this.timerSound,
    required this.timerVibration,
    required this.defaultRestSeconds,
    required this.weightIncrementKg,
    required this.weightUnit,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['theme_preference'] = Variable<String>(
        $AppSettingsTable.$converterthemePreference.toSql(themePreference),
      );
    }
    map['auto_start_timer'] = Variable<bool>(autoStartTimer);
    map['timer_sound'] = Variable<bool>(timerSound);
    map['timer_vibration'] = Variable<bool>(timerVibration);
    map['default_rest_seconds'] = Variable<int>(defaultRestSeconds);
    map['weight_increment_kg'] = Variable<double>(weightIncrementKg);
    {
      map['weight_unit'] = Variable<String>(
        $AppSettingsTable.$converterweightUnit.toSql(weightUnit),
      );
    }
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      themePreference: Value(themePreference),
      autoStartTimer: Value(autoStartTimer),
      timerSound: Value(timerSound),
      timerVibration: Value(timerVibration),
      defaultRestSeconds: Value(defaultRestSeconds),
      weightIncrementKg: Value(weightIncrementKg),
      weightUnit: Value(weightUnit),
    );
  }

  factory AppSettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsRow(
      id: serializer.fromJson<int>(json['id']),
      themePreference: $AppSettingsTable.$converterthemePreference.fromJson(
        serializer.fromJson<String>(json['themePreference']),
      ),
      autoStartTimer: serializer.fromJson<bool>(json['autoStartTimer']),
      timerSound: serializer.fromJson<bool>(json['timerSound']),
      timerVibration: serializer.fromJson<bool>(json['timerVibration']),
      defaultRestSeconds: serializer.fromJson<int>(json['defaultRestSeconds']),
      weightIncrementKg: serializer.fromJson<double>(json['weightIncrementKg']),
      weightUnit: $AppSettingsTable.$converterweightUnit.fromJson(
        serializer.fromJson<String>(json['weightUnit']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'themePreference': serializer.toJson<String>(
        $AppSettingsTable.$converterthemePreference.toJson(themePreference),
      ),
      'autoStartTimer': serializer.toJson<bool>(autoStartTimer),
      'timerSound': serializer.toJson<bool>(timerSound),
      'timerVibration': serializer.toJson<bool>(timerVibration),
      'defaultRestSeconds': serializer.toJson<int>(defaultRestSeconds),
      'weightIncrementKg': serializer.toJson<double>(weightIncrementKg),
      'weightUnit': serializer.toJson<String>(
        $AppSettingsTable.$converterweightUnit.toJson(weightUnit),
      ),
    };
  }

  AppSettingsRow copyWith({
    int? id,
    ThemePreference? themePreference,
    bool? autoStartTimer,
    bool? timerSound,
    bool? timerVibration,
    int? defaultRestSeconds,
    double? weightIncrementKg,
    WeightUnit? weightUnit,
  }) => AppSettingsRow(
    id: id ?? this.id,
    themePreference: themePreference ?? this.themePreference,
    autoStartTimer: autoStartTimer ?? this.autoStartTimer,
    timerSound: timerSound ?? this.timerSound,
    timerVibration: timerVibration ?? this.timerVibration,
    defaultRestSeconds: defaultRestSeconds ?? this.defaultRestSeconds,
    weightIncrementKg: weightIncrementKg ?? this.weightIncrementKg,
    weightUnit: weightUnit ?? this.weightUnit,
  );
  AppSettingsRow copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingsRow(
      id: data.id.present ? data.id.value : this.id,
      themePreference: data.themePreference.present
          ? data.themePreference.value
          : this.themePreference,
      autoStartTimer: data.autoStartTimer.present
          ? data.autoStartTimer.value
          : this.autoStartTimer,
      timerSound: data.timerSound.present
          ? data.timerSound.value
          : this.timerSound,
      timerVibration: data.timerVibration.present
          ? data.timerVibration.value
          : this.timerVibration,
      defaultRestSeconds: data.defaultRestSeconds.present
          ? data.defaultRestSeconds.value
          : this.defaultRestSeconds,
      weightIncrementKg: data.weightIncrementKg.present
          ? data.weightIncrementKg.value
          : this.weightIncrementKg,
      weightUnit: data.weightUnit.present
          ? data.weightUnit.value
          : this.weightUnit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsRow(')
          ..write('id: $id, ')
          ..write('themePreference: $themePreference, ')
          ..write('autoStartTimer: $autoStartTimer, ')
          ..write('timerSound: $timerSound, ')
          ..write('timerVibration: $timerVibration, ')
          ..write('defaultRestSeconds: $defaultRestSeconds, ')
          ..write('weightIncrementKg: $weightIncrementKg, ')
          ..write('weightUnit: $weightUnit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    themePreference,
    autoStartTimer,
    timerSound,
    timerVibration,
    defaultRestSeconds,
    weightIncrementKg,
    weightUnit,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsRow &&
          other.id == this.id &&
          other.themePreference == this.themePreference &&
          other.autoStartTimer == this.autoStartTimer &&
          other.timerSound == this.timerSound &&
          other.timerVibration == this.timerVibration &&
          other.defaultRestSeconds == this.defaultRestSeconds &&
          other.weightIncrementKg == this.weightIncrementKg &&
          other.weightUnit == this.weightUnit);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingsRow> {
  final Value<int> id;
  final Value<ThemePreference> themePreference;
  final Value<bool> autoStartTimer;
  final Value<bool> timerSound;
  final Value<bool> timerVibration;
  final Value<int> defaultRestSeconds;
  final Value<double> weightIncrementKg;
  final Value<WeightUnit> weightUnit;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.themePreference = const Value.absent(),
    this.autoStartTimer = const Value.absent(),
    this.timerSound = const Value.absent(),
    this.timerVibration = const Value.absent(),
    this.defaultRestSeconds = const Value.absent(),
    this.weightIncrementKg = const Value.absent(),
    this.weightUnit = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.themePreference = const Value.absent(),
    this.autoStartTimer = const Value.absent(),
    this.timerSound = const Value.absent(),
    this.timerVibration = const Value.absent(),
    this.defaultRestSeconds = const Value.absent(),
    this.weightIncrementKg = const Value.absent(),
    this.weightUnit = const Value.absent(),
  });
  static Insertable<AppSettingsRow> custom({
    Expression<int>? id,
    Expression<String>? themePreference,
    Expression<bool>? autoStartTimer,
    Expression<bool>? timerSound,
    Expression<bool>? timerVibration,
    Expression<int>? defaultRestSeconds,
    Expression<double>? weightIncrementKg,
    Expression<String>? weightUnit,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (themePreference != null) 'theme_preference': themePreference,
      if (autoStartTimer != null) 'auto_start_timer': autoStartTimer,
      if (timerSound != null) 'timer_sound': timerSound,
      if (timerVibration != null) 'timer_vibration': timerVibration,
      if (defaultRestSeconds != null)
        'default_rest_seconds': defaultRestSeconds,
      if (weightIncrementKg != null) 'weight_increment_kg': weightIncrementKg,
      if (weightUnit != null) 'weight_unit': weightUnit,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<ThemePreference>? themePreference,
    Value<bool>? autoStartTimer,
    Value<bool>? timerSound,
    Value<bool>? timerVibration,
    Value<int>? defaultRestSeconds,
    Value<double>? weightIncrementKg,
    Value<WeightUnit>? weightUnit,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      themePreference: themePreference ?? this.themePreference,
      autoStartTimer: autoStartTimer ?? this.autoStartTimer,
      timerSound: timerSound ?? this.timerSound,
      timerVibration: timerVibration ?? this.timerVibration,
      defaultRestSeconds: defaultRestSeconds ?? this.defaultRestSeconds,
      weightIncrementKg: weightIncrementKg ?? this.weightIncrementKg,
      weightUnit: weightUnit ?? this.weightUnit,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (themePreference.present) {
      map['theme_preference'] = Variable<String>(
        $AppSettingsTable.$converterthemePreference.toSql(
          themePreference.value,
        ),
      );
    }
    if (autoStartTimer.present) {
      map['auto_start_timer'] = Variable<bool>(autoStartTimer.value);
    }
    if (timerSound.present) {
      map['timer_sound'] = Variable<bool>(timerSound.value);
    }
    if (timerVibration.present) {
      map['timer_vibration'] = Variable<bool>(timerVibration.value);
    }
    if (defaultRestSeconds.present) {
      map['default_rest_seconds'] = Variable<int>(defaultRestSeconds.value);
    }
    if (weightIncrementKg.present) {
      map['weight_increment_kg'] = Variable<double>(weightIncrementKg.value);
    }
    if (weightUnit.present) {
      map['weight_unit'] = Variable<String>(
        $AppSettingsTable.$converterweightUnit.toSql(weightUnit.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('themePreference: $themePreference, ')
          ..write('autoStartTimer: $autoStartTimer, ')
          ..write('timerSound: $timerSound, ')
          ..write('timerVibration: $timerVibration, ')
          ..write('defaultRestSeconds: $defaultRestSeconds, ')
          ..write('weightIncrementKg: $weightIncrementKg, ')
          ..write('weightUnit: $weightUnit')
          ..write(')'))
        .toString();
  }
}

class $TimerStatesTable extends TimerStates
    with TableInfo<$TimerStatesTable, TimerStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimerStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    check: () => id.equals(1),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  late final GeneratedColumnWithTypeConverter<TimerStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TimerStatus>($TimerStatesTable.$converterstatus);
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMsMeta = const VerificationMeta(
    'startedAtMs',
  );
  @override
  late final GeneratedColumn<int> startedAtMs = GeneratedColumn<int>(
    'started_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _elapsedBeforeMsMeta = const VerificationMeta(
    'elapsedBeforeMs',
  );
  @override
  late final GeneratedColumn<int> elapsedBeforeMs = GeneratedColumn<int>(
    'elapsed_before_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    status,
    durationMs,
    startedAtMs,
    elapsedBeforeMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timer_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimerStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('started_at_ms')) {
      context.handle(
        _startedAtMsMeta,
        startedAtMs.isAcceptableOrUnknown(
          data['started_at_ms']!,
          _startedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('elapsed_before_ms')) {
      context.handle(
        _elapsedBeforeMsMeta,
        elapsedBeforeMs.isAcceptableOrUnknown(
          data['elapsed_before_ms']!,
          _elapsedBeforeMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimerStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimerStateRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      status: $TimerStatesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      startedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at_ms'],
      ),
      elapsedBeforeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_before_ms'],
      )!,
    );
  }

  @override
  $TimerStatesTable createAlias(String alias) {
    return $TimerStatesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TimerStatus, String, String> $converterstatus =
      const EnumNameConverter<TimerStatus>(TimerStatus.values);
}

class TimerStateRow extends DataClass implements Insertable<TimerStateRow> {
  final int id;
  final TimerStatus status;
  final int durationMs;

  /// Instante (epoch ms) em que a contagem foi iniciada/retomada.
  final int? startedAtMs;

  /// Tempo já decorrido antes do último início (acumula pausas).
  final int elapsedBeforeMs;
  const TimerStateRow({
    required this.id,
    required this.status,
    required this.durationMs,
    this.startedAtMs,
    required this.elapsedBeforeMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['status'] = Variable<String>(
        $TimerStatesTable.$converterstatus.toSql(status),
      );
    }
    map['duration_ms'] = Variable<int>(durationMs);
    if (!nullToAbsent || startedAtMs != null) {
      map['started_at_ms'] = Variable<int>(startedAtMs);
    }
    map['elapsed_before_ms'] = Variable<int>(elapsedBeforeMs);
    return map;
  }

  TimerStatesCompanion toCompanion(bool nullToAbsent) {
    return TimerStatesCompanion(
      id: Value(id),
      status: Value(status),
      durationMs: Value(durationMs),
      startedAtMs: startedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAtMs),
      elapsedBeforeMs: Value(elapsedBeforeMs),
    );
  }

  factory TimerStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimerStateRow(
      id: serializer.fromJson<int>(json['id']),
      status: $TimerStatesTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      startedAtMs: serializer.fromJson<int?>(json['startedAtMs']),
      elapsedBeforeMs: serializer.fromJson<int>(json['elapsedBeforeMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'status': serializer.toJson<String>(
        $TimerStatesTable.$converterstatus.toJson(status),
      ),
      'durationMs': serializer.toJson<int>(durationMs),
      'startedAtMs': serializer.toJson<int?>(startedAtMs),
      'elapsedBeforeMs': serializer.toJson<int>(elapsedBeforeMs),
    };
  }

  TimerStateRow copyWith({
    int? id,
    TimerStatus? status,
    int? durationMs,
    Value<int?> startedAtMs = const Value.absent(),
    int? elapsedBeforeMs,
  }) => TimerStateRow(
    id: id ?? this.id,
    status: status ?? this.status,
    durationMs: durationMs ?? this.durationMs,
    startedAtMs: startedAtMs.present ? startedAtMs.value : this.startedAtMs,
    elapsedBeforeMs: elapsedBeforeMs ?? this.elapsedBeforeMs,
  );
  TimerStateRow copyWithCompanion(TimerStatesCompanion data) {
    return TimerStateRow(
      id: data.id.present ? data.id.value : this.id,
      status: data.status.present ? data.status.value : this.status,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      startedAtMs: data.startedAtMs.present
          ? data.startedAtMs.value
          : this.startedAtMs,
      elapsedBeforeMs: data.elapsedBeforeMs.present
          ? data.elapsedBeforeMs.value
          : this.elapsedBeforeMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimerStateRow(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('durationMs: $durationMs, ')
          ..write('startedAtMs: $startedAtMs, ')
          ..write('elapsedBeforeMs: $elapsedBeforeMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, status, durationMs, startedAtMs, elapsedBeforeMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimerStateRow &&
          other.id == this.id &&
          other.status == this.status &&
          other.durationMs == this.durationMs &&
          other.startedAtMs == this.startedAtMs &&
          other.elapsedBeforeMs == this.elapsedBeforeMs);
}

class TimerStatesCompanion extends UpdateCompanion<TimerStateRow> {
  final Value<int> id;
  final Value<TimerStatus> status;
  final Value<int> durationMs;
  final Value<int?> startedAtMs;
  final Value<int> elapsedBeforeMs;
  const TimerStatesCompanion({
    this.id = const Value.absent(),
    this.status = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.startedAtMs = const Value.absent(),
    this.elapsedBeforeMs = const Value.absent(),
  });
  TimerStatesCompanion.insert({
    this.id = const Value.absent(),
    required TimerStatus status,
    required int durationMs,
    this.startedAtMs = const Value.absent(),
    this.elapsedBeforeMs = const Value.absent(),
  }) : status = Value(status),
       durationMs = Value(durationMs);
  static Insertable<TimerStateRow> custom({
    Expression<int>? id,
    Expression<String>? status,
    Expression<int>? durationMs,
    Expression<int>? startedAtMs,
    Expression<int>? elapsedBeforeMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (status != null) 'status': status,
      if (durationMs != null) 'duration_ms': durationMs,
      if (startedAtMs != null) 'started_at_ms': startedAtMs,
      if (elapsedBeforeMs != null) 'elapsed_before_ms': elapsedBeforeMs,
    });
  }

  TimerStatesCompanion copyWith({
    Value<int>? id,
    Value<TimerStatus>? status,
    Value<int>? durationMs,
    Value<int?>? startedAtMs,
    Value<int>? elapsedBeforeMs,
  }) {
    return TimerStatesCompanion(
      id: id ?? this.id,
      status: status ?? this.status,
      durationMs: durationMs ?? this.durationMs,
      startedAtMs: startedAtMs ?? this.startedAtMs,
      elapsedBeforeMs: elapsedBeforeMs ?? this.elapsedBeforeMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $TimerStatesTable.$converterstatus.toSql(status.value),
      );
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (startedAtMs.present) {
      map['started_at_ms'] = Variable<int>(startedAtMs.value);
    }
    if (elapsedBeforeMs.present) {
      map['elapsed_before_ms'] = Variable<int>(elapsedBeforeMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimerStatesCompanion(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('durationMs: $durationMs, ')
          ..write('startedAtMs: $startedAtMs, ')
          ..write('elapsedBeforeMs: $elapsedBeforeMs')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $BodyMeasurementsTable bodyMeasurements = $BodyMeasurementsTable(
    this,
  );
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $WorkoutPlansTable workoutPlans = $WorkoutPlansTable(this);
  late final $WorkoutPlanExercisesTable workoutPlanExercises =
      $WorkoutPlanExercisesTable(this);
  late final $WorkoutPlanSetsTable workoutPlanSets = $WorkoutPlanSetsTable(
    this,
  );
  late final $WorkoutSessionsTable workoutSessions = $WorkoutSessionsTable(
    this,
  );
  late final $WorkoutSessionExercisesTable workoutSessionExercises =
      $WorkoutSessionExercisesTable(this);
  late final $WorkoutSessionSetsTable workoutSessionSets =
      $WorkoutSessionSetsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $TimerStatesTable timerStates = $TimerStatesTable(this);
  late final Index idxBodyMeasurementsDate = Index(
    'idx_body_measurements_date',
    'CREATE INDEX idx_body_measurements_date ON body_measurements (date)',
  );
  late final Index idxWorkoutPlansActive = Index(
    'idx_workout_plans_active',
    'CREATE INDEX idx_workout_plans_active ON workout_plans (is_active)',
  );
  late final Index idxPlanExercisesPlan = Index(
    'idx_plan_exercises_plan',
    'CREATE INDEX idx_plan_exercises_plan ON workout_plan_exercises (workout_plan_id)',
  );
  late final Index idxPlanExercisesExercise = Index(
    'idx_plan_exercises_exercise',
    'CREATE INDEX idx_plan_exercises_exercise ON workout_plan_exercises (exercise_id)',
  );
  late final Index idxPlanSetsPlanExercise = Index(
    'idx_plan_sets_plan_exercise',
    'CREATE INDEX idx_plan_sets_plan_exercise ON workout_plan_sets (plan_exercise_id)',
  );
  late final Index idxSessionsPlan = Index(
    'idx_sessions_plan',
    'CREATE INDEX idx_sessions_plan ON workout_sessions (workout_plan_id)',
  );
  late final Index idxSessionsStartedAt = Index(
    'idx_sessions_started_at',
    'CREATE INDEX idx_sessions_started_at ON workout_sessions (started_at)',
  );
  late final Index idxSessionsStatus = Index(
    'idx_sessions_status',
    'CREATE INDEX idx_sessions_status ON workout_sessions (status)',
  );
  late final Index idxSessionExercisesSession = Index(
    'idx_session_exercises_session',
    'CREATE INDEX idx_session_exercises_session ON workout_session_exercises (session_id)',
  );
  late final Index idxSessionExercisesExercise = Index(
    'idx_session_exercises_exercise',
    'CREATE INDEX idx_session_exercises_exercise ON workout_session_exercises (exercise_id)',
  );
  late final Index idxSessionSetsSessionExercise = Index(
    'idx_session_sets_session_exercise',
    'CREATE INDEX idx_session_sets_session_exercise ON workout_session_sets (session_exercise_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userProfiles,
    bodyMeasurements,
    exercises,
    workoutPlans,
    workoutPlanExercises,
    workoutPlanSets,
    workoutSessions,
    workoutSessionExercises,
    workoutSessionSets,
    appSettings,
    timerStates,
    idxBodyMeasurementsDate,
    idxWorkoutPlansActive,
    idxPlanExercisesPlan,
    idxPlanExercisesExercise,
    idxPlanSetsPlanExercise,
    idxSessionsPlan,
    idxSessionsStartedAt,
    idxSessionsStatus,
    idxSessionExercisesSession,
    idxSessionExercisesExercise,
    idxSessionSetsSessionExercise,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workout_plans',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('workout_plan_exercises', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workout_plan_exercises',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('workout_plan_sets', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workout_plans',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('workout_sessions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workout_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('workout_session_exercises', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workout_plan_exercises',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('workout_session_exercises', kind: UpdateKind.update),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workout_session_exercises',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('workout_session_sets', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> id,
      required String name,
      required String email,
      Value<DateTime?> birthDate,
      Value<Sex?> sex,
      required double heightCm,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> id,
      Value<String> name,
      Value<String> email,
      Value<DateTime?> birthDate,
      Value<Sex?> sex,
      Value<double> heightCm,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Sex?, Sex, String> get sex =>
      $composableBuilder(
        column: $table.sex,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Sex?, String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfile,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfile,
            BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
          ),
          UserProfile,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<Sex?> sex = const Value.absent(),
                Value<double> heightCm = const Value.absent(),
              }) => UserProfilesCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                name: name,
                email: email,
                birthDate: birthDate,
                sex: sex,
                heightCm: heightCm,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                required String name,
                required String email,
                Value<DateTime?> birthDate = const Value.absent(),
                Value<Sex?> sex = const Value.absent(),
                required double heightCm,
              }) => UserProfilesCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                name: name,
                email: email,
                birthDate: birthDate,
                sex: sex,
                heightCm: heightCm,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserProfilesTable, UserProfile>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $UserProfilesTable,
                    UserProfile
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfile,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfile,
        BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
      ),
      UserProfile,
      PrefetchHooks Function()
    >;
typedef $$BodyMeasurementsTableCreateCompanionBuilder =
    BodyMeasurementsCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> id,
      required DateTime date,
      required double weightKg,
      Value<double?> bodyFatPercentage,
      Value<double?> neck,
      Value<double?> shoulders,
      Value<double?> chest,
      Value<double?> leftArm,
      Value<double?> rightArm,
      Value<double?> leftForearm,
      Value<double?> rightForearm,
      Value<double?> waist,
      Value<double?> abdomen,
      Value<double?> hips,
      Value<double?> leftThigh,
      Value<double?> rightThigh,
      Value<double?> leftCalf,
      Value<double?> rightCalf,
      Value<String?> notes,
    });
typedef $$BodyMeasurementsTableUpdateCompanionBuilder =
    BodyMeasurementsCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> id,
      Value<DateTime> date,
      Value<double> weightKg,
      Value<double?> bodyFatPercentage,
      Value<double?> neck,
      Value<double?> shoulders,
      Value<double?> chest,
      Value<double?> leftArm,
      Value<double?> rightArm,
      Value<double?> leftForearm,
      Value<double?> rightForearm,
      Value<double?> waist,
      Value<double?> abdomen,
      Value<double?> hips,
      Value<double?> leftThigh,
      Value<double?> rightThigh,
      Value<double?> leftCalf,
      Value<double?> rightCalf,
      Value<String?> notes,
    });

class $$BodyMeasurementsTableFilterComposer
    extends Composer<_$AppDatabase, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bodyFatPercentage => $composableBuilder(
    column: $table.bodyFatPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get neck => $composableBuilder(
    column: $table.neck,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get shoulders => $composableBuilder(
    column: $table.shoulders,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get chest => $composableBuilder(
    column: $table.chest,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get leftArm => $composableBuilder(
    column: $table.leftArm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rightArm => $composableBuilder(
    column: $table.rightArm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get leftForearm => $composableBuilder(
    column: $table.leftForearm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rightForearm => $composableBuilder(
    column: $table.rightForearm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get waist => $composableBuilder(
    column: $table.waist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get abdomen => $composableBuilder(
    column: $table.abdomen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hips => $composableBuilder(
    column: $table.hips,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get leftThigh => $composableBuilder(
    column: $table.leftThigh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rightThigh => $composableBuilder(
    column: $table.rightThigh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get leftCalf => $composableBuilder(
    column: $table.leftCalf,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rightCalf => $composableBuilder(
    column: $table.rightCalf,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BodyMeasurementsTableOrderingComposer
    extends Composer<_$AppDatabase, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bodyFatPercentage => $composableBuilder(
    column: $table.bodyFatPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get neck => $composableBuilder(
    column: $table.neck,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get shoulders => $composableBuilder(
    column: $table.shoulders,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get chest => $composableBuilder(
    column: $table.chest,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get leftArm => $composableBuilder(
    column: $table.leftArm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rightArm => $composableBuilder(
    column: $table.rightArm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get leftForearm => $composableBuilder(
    column: $table.leftForearm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rightForearm => $composableBuilder(
    column: $table.rightForearm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get waist => $composableBuilder(
    column: $table.waist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get abdomen => $composableBuilder(
    column: $table.abdomen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hips => $composableBuilder(
    column: $table.hips,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get leftThigh => $composableBuilder(
    column: $table.leftThigh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rightThigh => $composableBuilder(
    column: $table.rightThigh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get leftCalf => $composableBuilder(
    column: $table.leftCalf,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rightCalf => $composableBuilder(
    column: $table.rightCalf,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BodyMeasurementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get bodyFatPercentage => $composableBuilder(
    column: $table.bodyFatPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get neck =>
      $composableBuilder(column: $table.neck, builder: (column) => column);

  GeneratedColumn<double> get shoulders =>
      $composableBuilder(column: $table.shoulders, builder: (column) => column);

  GeneratedColumn<double> get chest =>
      $composableBuilder(column: $table.chest, builder: (column) => column);

  GeneratedColumn<double> get leftArm =>
      $composableBuilder(column: $table.leftArm, builder: (column) => column);

  GeneratedColumn<double> get rightArm =>
      $composableBuilder(column: $table.rightArm, builder: (column) => column);

  GeneratedColumn<double> get leftForearm => $composableBuilder(
    column: $table.leftForearm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rightForearm => $composableBuilder(
    column: $table.rightForearm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get waist =>
      $composableBuilder(column: $table.waist, builder: (column) => column);

  GeneratedColumn<double> get abdomen =>
      $composableBuilder(column: $table.abdomen, builder: (column) => column);

  GeneratedColumn<double> get hips =>
      $composableBuilder(column: $table.hips, builder: (column) => column);

  GeneratedColumn<double> get leftThigh =>
      $composableBuilder(column: $table.leftThigh, builder: (column) => column);

  GeneratedColumn<double> get rightThigh => $composableBuilder(
    column: $table.rightThigh,
    builder: (column) => column,
  );

  GeneratedColumn<double> get leftCalf =>
      $composableBuilder(column: $table.leftCalf, builder: (column) => column);

  GeneratedColumn<double> get rightCalf =>
      $composableBuilder(column: $table.rightCalf, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$BodyMeasurementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BodyMeasurementsTable,
          BodyMeasurement,
          $$BodyMeasurementsTableFilterComposer,
          $$BodyMeasurementsTableOrderingComposer,
          $$BodyMeasurementsTableAnnotationComposer,
          $$BodyMeasurementsTableCreateCompanionBuilder,
          $$BodyMeasurementsTableUpdateCompanionBuilder,
          (
            BodyMeasurement,
            BaseReferences<
              _$AppDatabase,
              $BodyMeasurementsTable,
              BodyMeasurement
            >,
          ),
          BodyMeasurement,
          PrefetchHooks Function()
        > {
  $$BodyMeasurementsTableTableManager(
    _$AppDatabase db,
    $BodyMeasurementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BodyMeasurementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BodyMeasurementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BodyMeasurementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<double?> bodyFatPercentage = const Value.absent(),
                Value<double?> neck = const Value.absent(),
                Value<double?> shoulders = const Value.absent(),
                Value<double?> chest = const Value.absent(),
                Value<double?> leftArm = const Value.absent(),
                Value<double?> rightArm = const Value.absent(),
                Value<double?> leftForearm = const Value.absent(),
                Value<double?> rightForearm = const Value.absent(),
                Value<double?> waist = const Value.absent(),
                Value<double?> abdomen = const Value.absent(),
                Value<double?> hips = const Value.absent(),
                Value<double?> leftThigh = const Value.absent(),
                Value<double?> rightThigh = const Value.absent(),
                Value<double?> leftCalf = const Value.absent(),
                Value<double?> rightCalf = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => BodyMeasurementsCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                date: date,
                weightKg: weightKg,
                bodyFatPercentage: bodyFatPercentage,
                neck: neck,
                shoulders: shoulders,
                chest: chest,
                leftArm: leftArm,
                rightArm: rightArm,
                leftForearm: leftForearm,
                rightForearm: rightForearm,
                waist: waist,
                abdomen: abdomen,
                hips: hips,
                leftThigh: leftThigh,
                rightThigh: rightThigh,
                leftCalf: leftCalf,
                rightCalf: rightCalf,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                required DateTime date,
                required double weightKg,
                Value<double?> bodyFatPercentage = const Value.absent(),
                Value<double?> neck = const Value.absent(),
                Value<double?> shoulders = const Value.absent(),
                Value<double?> chest = const Value.absent(),
                Value<double?> leftArm = const Value.absent(),
                Value<double?> rightArm = const Value.absent(),
                Value<double?> leftForearm = const Value.absent(),
                Value<double?> rightForearm = const Value.absent(),
                Value<double?> waist = const Value.absent(),
                Value<double?> abdomen = const Value.absent(),
                Value<double?> hips = const Value.absent(),
                Value<double?> leftThigh = const Value.absent(),
                Value<double?> rightThigh = const Value.absent(),
                Value<double?> leftCalf = const Value.absent(),
                Value<double?> rightCalf = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => BodyMeasurementsCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                date: date,
                weightKg: weightKg,
                bodyFatPercentage: bodyFatPercentage,
                neck: neck,
                shoulders: shoulders,
                chest: chest,
                leftArm: leftArm,
                rightArm: rightArm,
                leftForearm: leftForearm,
                rightForearm: rightForearm,
                waist: waist,
                abdomen: abdomen,
                hips: hips,
                leftThigh: leftThigh,
                rightThigh: rightThigh,
                leftCalf: leftCalf,
                rightCalf: rightCalf,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BodyMeasurementsTable, BodyMeasurement>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $BodyMeasurementsTable,
                    BodyMeasurement
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BodyMeasurementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BodyMeasurementsTable,
      BodyMeasurement,
      $$BodyMeasurementsTableFilterComposer,
      $$BodyMeasurementsTableOrderingComposer,
      $$BodyMeasurementsTableAnnotationComposer,
      $$BodyMeasurementsTableCreateCompanionBuilder,
      $$BodyMeasurementsTableUpdateCompanionBuilder,
      (
        BodyMeasurement,
        BaseReferences<_$AppDatabase, $BodyMeasurementsTable, BodyMeasurement>,
      ),
      BodyMeasurement,
      PrefetchHooks Function()
    >;
typedef $$ExercisesTableCreateCompanionBuilder = ExercisesCompanion Function({
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> id,
  required String name,
  required String normalizedName,
  required MuscleGroup muscleGroup,
  Value<String?> description,
  Value<String?> notes,
  Value<bool> isActive,
  Value<bool> isCustom,
});
typedef $$ExercisesTableUpdateCompanionBuilder = ExercisesCompanion Function({
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> id,
  Value<String> name,
  Value<String> normalizedName,
  Value<MuscleGroup> muscleGroup,
  Value<String?> description,
  Value<String?> notes,
  Value<bool> isActive,
  Value<bool> isCustom,
});

final class $$ExercisesTableReferences
    extends BaseReferences<_$AppDatabase, $ExercisesTable, Exercise> {
  $$ExercisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $WorkoutPlanExercisesTable,
    List<WorkoutPlanExercise>
  >
  _workoutPlanExercisesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.workoutPlanExercises,
        aliasName: 'exercises__id__workout_plan_exercises__exercise_id',
      );

  $$WorkoutPlanExercisesTableProcessedTableManager
  get workoutPlanExercisesRefs {
    final manager = $$WorkoutPlanExercisesTableTableManager(
      $_db,
      $_db.workoutPlanExercises,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutPlanExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $WorkoutSessionExercisesTable,
    List<WorkoutSessionExercise>
  >
  _workoutSessionExercisesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.workoutSessionExercises,
        aliasName: 'exercises__id__workout_session_exercises__exercise_id',
      );

  $$WorkoutSessionExercisesTableProcessedTableManager
  get workoutSessionExercisesRefs {
    final manager = $$WorkoutSessionExercisesTableTableManager(
      $_db,
      $_db.workoutSessionExercises,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutSessionExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MuscleGroup, MuscleGroup, String>
  get muscleGroup => $composableBuilder(
    column: $table.muscleGroup,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> workoutPlanExercisesRefs(
    Expression<bool> Function($$WorkoutPlanExercisesTableFilterComposer f) f,
  ) {
    final $$WorkoutPlanExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutPlanExercises,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutPlanExercisesTableFilterComposer(
            $db: $db,
            $table: $db.workoutPlanExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workoutSessionExercisesRefs(
    Expression<bool> Function($$WorkoutSessionExercisesTableFilterComposer f) f,
  ) {
    final $$WorkoutSessionExercisesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.workoutSessionExercises,
          getReferencedColumn: (t) => t.exerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutSessionExercisesTableFilterComposer(
                $db: $db,
                $table: $db.workoutSessionExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get muscleGroup => $composableBuilder(
    column: $table.muscleGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<MuscleGroup, String> get muscleGroup =>
      $composableBuilder(
        column: $table.muscleGroup,
        builder: (column) => column,
      );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  Expression<T> workoutPlanExercisesRefs<T extends Object>(
    Expression<T> Function($$WorkoutPlanExercisesTableAnnotationComposer a) f,
  ) {
    final $$WorkoutPlanExercisesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.workoutPlanExercises,
          getReferencedColumn: (t) => t.exerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutPlanExercisesTableAnnotationComposer(
                $db: $db,
                $table: $db.workoutPlanExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> workoutSessionExercisesRefs<T extends Object>(
    Expression<T> Function($$WorkoutSessionExercisesTableAnnotationComposer a)
    f,
  ) {
    final $$WorkoutSessionExercisesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.workoutSessionExercises,
          getReferencedColumn: (t) => t.exerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutSessionExercisesTableAnnotationComposer(
                $db: $db,
                $table: $db.workoutSessionExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExercisesTable,
          Exercise,
          $$ExercisesTableFilterComposer,
          $$ExercisesTableOrderingComposer,
          $$ExercisesTableAnnotationComposer,
          $$ExercisesTableCreateCompanionBuilder,
          $$ExercisesTableUpdateCompanionBuilder,
          (Exercise, $$ExercisesTableReferences),
          Exercise,
          PrefetchHooks Function({
            bool workoutPlanExercisesRefs,
            bool workoutSessionExercisesRefs,
          })
        > {
  $$ExercisesTableTableManager(_$AppDatabase db, $ExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<MuscleGroup> muscleGroup = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
              }) => ExercisesCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                name: name,
                normalizedName: normalizedName,
                muscleGroup: muscleGroup,
                description: description,
                notes: notes,
                isActive: isActive,
                isCustom: isCustom,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                required String name,
                required String normalizedName,
                required MuscleGroup muscleGroup,
                Value<String?> description = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
              }) => ExercisesCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                name: name,
                normalizedName: normalizedName,
                muscleGroup: muscleGroup,
                description: description,
                notes: notes,
                isActive: isActive,
                isCustom: isCustom,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExercisesTable, Exercise>(table),
                  $$ExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                workoutPlanExercisesRefs = false,
                workoutSessionExercisesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (workoutPlanExercisesRefs) db.workoutPlanExercises,
                    if (workoutSessionExercisesRefs) db.workoutSessionExercises,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (workoutPlanExercisesRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExercisesTable,
                          WorkoutPlanExercise
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._workoutPlanExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutPlanExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workoutSessionExercisesRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExercisesTable,
                          WorkoutSessionExercise
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._workoutSessionExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutSessionExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExercisesTable,
      Exercise,
      $$ExercisesTableFilterComposer,
      $$ExercisesTableOrderingComposer,
      $$ExercisesTableAnnotationComposer,
      $$ExercisesTableCreateCompanionBuilder,
      $$ExercisesTableUpdateCompanionBuilder,
      (Exercise, $$ExercisesTableReferences),
      Exercise,
      PrefetchHooks Function({
        bool workoutPlanExercisesRefs,
        bool workoutSessionExercisesRefs,
      })
    >;
typedef $$WorkoutPlansTableCreateCompanionBuilder =
    WorkoutPlansCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> id,
      required String name,
      Value<String?> description,
      Value<bool> isActive,
      Value<int> sortOrder,
    });
typedef $$WorkoutPlansTableUpdateCompanionBuilder =
    WorkoutPlansCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> id,
      Value<String> name,
      Value<String?> description,
      Value<bool> isActive,
      Value<int> sortOrder,
    });

final class $$WorkoutPlansTableReferences
    extends BaseReferences<_$AppDatabase, $WorkoutPlansTable, WorkoutPlan> {
  $$WorkoutPlansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $WorkoutPlanExercisesTable,
    List<WorkoutPlanExercise>
  >
  _workoutPlanExercisesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.workoutPlanExercises,
        aliasName: 'workout_plans__id__workout_plan_exercises__workout_plan_id',
      );

  $$WorkoutPlanExercisesTableProcessedTableManager
  get workoutPlanExercisesRefs {
    final manager = $$WorkoutPlanExercisesTableTableManager(
      $_db,
      $_db.workoutPlanExercises,
    ).filter((f) => f.workoutPlanId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutPlanExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkoutSessionsTable, List<WorkoutSession>>
  _workoutSessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workoutSessions,
    aliasName: 'workout_plans__id__workout_sessions__workout_plan_id',
  );

  $$WorkoutSessionsTableProcessedTableManager get workoutSessionsRefs {
    final manager = $$WorkoutSessionsTableTableManager(
      $_db,
      $_db.workoutSessions,
    ).filter((f) => f.workoutPlanId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutSessionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkoutPlansTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutPlansTable> {
  $$WorkoutPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> workoutPlanExercisesRefs(
    Expression<bool> Function($$WorkoutPlanExercisesTableFilterComposer f) f,
  ) {
    final $$WorkoutPlanExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutPlanExercises,
      getReferencedColumn: (t) => t.workoutPlanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutPlanExercisesTableFilterComposer(
            $db: $db,
            $table: $db.workoutPlanExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workoutSessionsRefs(
    Expression<bool> Function($$WorkoutSessionsTableFilterComposer f) f,
  ) {
    final $$WorkoutSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.workoutPlanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableFilterComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutPlansTable> {
  $$WorkoutPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutPlansTable> {
  $$WorkoutPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> workoutPlanExercisesRefs<T extends Object>(
    Expression<T> Function($$WorkoutPlanExercisesTableAnnotationComposer a) f,
  ) {
    final $$WorkoutPlanExercisesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.workoutPlanExercises,
          getReferencedColumn: (t) => t.workoutPlanId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutPlanExercisesTableAnnotationComposer(
                $db: $db,
                $table: $db.workoutPlanExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> workoutSessionsRefs<T extends Object>(
    Expression<T> Function($$WorkoutSessionsTableAnnotationComposer a) f,
  ) {
    final $$WorkoutSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.workoutPlanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutPlansTable,
          WorkoutPlan,
          $$WorkoutPlansTableFilterComposer,
          $$WorkoutPlansTableOrderingComposer,
          $$WorkoutPlansTableAnnotationComposer,
          $$WorkoutPlansTableCreateCompanionBuilder,
          $$WorkoutPlansTableUpdateCompanionBuilder,
          (WorkoutPlan, $$WorkoutPlansTableReferences),
          WorkoutPlan,
          PrefetchHooks Function({
            bool workoutPlanExercisesRefs,
            bool workoutSessionsRefs,
          })
        > {
  $$WorkoutPlansTableTableManager(_$AppDatabase db, $WorkoutPlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => WorkoutPlansCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                name: name,
                description: description,
                isActive: isActive,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => WorkoutPlansCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                name: name,
                description: description,
                isActive: isActive,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkoutPlansTable, WorkoutPlan>(table),
                  $$WorkoutPlansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                workoutPlanExercisesRefs = false,
                workoutSessionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (workoutPlanExercisesRefs) db.workoutPlanExercises,
                    if (workoutSessionsRefs) db.workoutSessions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (workoutPlanExercisesRefs)
                        await $_getPrefetchedData<
                          WorkoutPlan,
                          $WorkoutPlansTable,
                          WorkoutPlanExercise
                        >(
                          currentTable: table,
                          referencedTable: $$WorkoutPlansTableReferences
                              ._workoutPlanExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutPlansTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutPlanExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workoutPlanId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workoutSessionsRefs)
                        await $_getPrefetchedData<
                          WorkoutPlan,
                          $WorkoutPlansTable,
                          WorkoutSession
                        >(
                          currentTable: table,
                          referencedTable: $$WorkoutPlansTableReferences
                              ._workoutSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutPlansTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutSessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workoutPlanId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WorkoutPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutPlansTable,
      WorkoutPlan,
      $$WorkoutPlansTableFilterComposer,
      $$WorkoutPlansTableOrderingComposer,
      $$WorkoutPlansTableAnnotationComposer,
      $$WorkoutPlansTableCreateCompanionBuilder,
      $$WorkoutPlansTableUpdateCompanionBuilder,
      (WorkoutPlan, $$WorkoutPlansTableReferences),
      WorkoutPlan,
      PrefetchHooks Function({
        bool workoutPlanExercisesRefs,
        bool workoutSessionsRefs,
      })
    >;
typedef $$WorkoutPlanExercisesTableCreateCompanionBuilder =
    WorkoutPlanExercisesCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> id,
      required int workoutPlanId,
      required int exerciseId,
      required int position,
      Value<String?> notes,
      Value<int?> restSeconds,
    });
typedef $$WorkoutPlanExercisesTableUpdateCompanionBuilder =
    WorkoutPlanExercisesCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> id,
      Value<int> workoutPlanId,
      Value<int> exerciseId,
      Value<int> position,
      Value<String?> notes,
      Value<int?> restSeconds,
    });

final class $$WorkoutPlanExercisesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $WorkoutPlanExercisesTable,
          WorkoutPlanExercise
        > {
  $$WorkoutPlanExercisesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkoutPlansTable _workoutPlanIdTable(_$AppDatabase db) =>
      db.workoutPlans.createAlias(
        'workout_plan_exercises__workout_plan_id__workout_plans__id',
      );

  $$WorkoutPlansTableProcessedTableManager get workoutPlanId {
    final $_column = $_itemColumn<int>('workout_plan_id')!;

    final manager = $$WorkoutPlansTableTableManager(
      $_db,
      $_db.workoutPlans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutPlanIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) => db.exercises
      .createAlias('workout_plan_exercises__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$WorkoutPlanSetsTable, List<WorkoutPlanSet>>
  _workoutPlanSetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workoutPlanSets,
    aliasName:
        'workout_plan_exercises__id__workout_plan_sets__plan_exercise_id',
  );

  $$WorkoutPlanSetsTableProcessedTableManager get workoutPlanSetsRefs {
    final manager = $$WorkoutPlanSetsTableTableManager(
      $_db,
      $_db.workoutPlanSets,
    ).filter((f) => f.planExerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutPlanSetsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $WorkoutSessionExercisesTable,
    List<WorkoutSessionExercise>
  >
  _workoutSessionExercisesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.workoutSessionExercises,
        aliasName: 'workout_plan_exercises__id__workout_session_exercises__plan_exercise_id',
      );

  $$WorkoutSessionExercisesTableProcessedTableManager
  get workoutSessionExercisesRefs {
    final manager = $$WorkoutSessionExercisesTableTableManager(
      $_db,
      $_db.workoutSessionExercises,
    ).filter((f) => f.planExerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutSessionExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkoutPlanExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutPlanExercisesTable> {
  $$WorkoutPlanExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutPlansTableFilterComposer get workoutPlanId {
    final $$WorkoutPlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutPlanId,
      referencedTable: $db.workoutPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutPlansTableFilterComposer(
            $db: $db,
            $table: $db.workoutPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> workoutPlanSetsRefs(
    Expression<bool> Function($$WorkoutPlanSetsTableFilterComposer f) f,
  ) {
    final $$WorkoutPlanSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutPlanSets,
      getReferencedColumn: (t) => t.planExerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutPlanSetsTableFilterComposer(
            $db: $db,
            $table: $db.workoutPlanSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workoutSessionExercisesRefs(
    Expression<bool> Function($$WorkoutSessionExercisesTableFilterComposer f) f,
  ) {
    final $$WorkoutSessionExercisesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.workoutSessionExercises,
          getReferencedColumn: (t) => t.planExerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutSessionExercisesTableFilterComposer(
                $db: $db,
                $table: $db.workoutSessionExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$WorkoutPlanExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutPlanExercisesTable> {
  $$WorkoutPlanExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutPlansTableOrderingComposer get workoutPlanId {
    final $$WorkoutPlansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutPlanId,
      referencedTable: $db.workoutPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutPlansTableOrderingComposer(
            $db: $db,
            $table: $db.workoutPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutPlanExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutPlanExercisesTable> {
  $$WorkoutPlanExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => column,
  );

  $$WorkoutPlansTableAnnotationComposer get workoutPlanId {
    final $$WorkoutPlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutPlanId,
      referencedTable: $db.workoutPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutPlansTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> workoutPlanSetsRefs<T extends Object>(
    Expression<T> Function($$WorkoutPlanSetsTableAnnotationComposer a) f,
  ) {
    final $$WorkoutPlanSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutPlanSets,
      getReferencedColumn: (t) => t.planExerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutPlanSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutPlanSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> workoutSessionExercisesRefs<T extends Object>(
    Expression<T> Function($$WorkoutSessionExercisesTableAnnotationComposer a)
    f,
  ) {
    final $$WorkoutSessionExercisesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.workoutSessionExercises,
          getReferencedColumn: (t) => t.planExerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutSessionExercisesTableAnnotationComposer(
                $db: $db,
                $table: $db.workoutSessionExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$WorkoutPlanExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutPlanExercisesTable,
          WorkoutPlanExercise,
          $$WorkoutPlanExercisesTableFilterComposer,
          $$WorkoutPlanExercisesTableOrderingComposer,
          $$WorkoutPlanExercisesTableAnnotationComposer,
          $$WorkoutPlanExercisesTableCreateCompanionBuilder,
          $$WorkoutPlanExercisesTableUpdateCompanionBuilder,
          (WorkoutPlanExercise, $$WorkoutPlanExercisesTableReferences),
          WorkoutPlanExercise,
          PrefetchHooks Function({
            bool workoutPlanId,
            bool exerciseId,
            bool workoutPlanSetsRefs,
            bool workoutSessionExercisesRefs,
          })
        > {
  $$WorkoutPlanExercisesTableTableManager(
    _$AppDatabase db,
    $WorkoutPlanExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutPlanExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutPlanExercisesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WorkoutPlanExercisesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<int> workoutPlanId = const Value.absent(),
                Value<int> exerciseId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> restSeconds = const Value.absent(),
              }) => WorkoutPlanExercisesCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                workoutPlanId: workoutPlanId,
                exerciseId: exerciseId,
                position: position,
                notes: notes,
                restSeconds: restSeconds,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                required int workoutPlanId,
                required int exerciseId,
                required int position,
                Value<String?> notes = const Value.absent(),
                Value<int?> restSeconds = const Value.absent(),
              }) => WorkoutPlanExercisesCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                workoutPlanId: workoutPlanId,
                exerciseId: exerciseId,
                position: position,
                notes: notes,
                restSeconds: restSeconds,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkoutPlanExercisesTable, WorkoutPlanExercise>(
                    table,
                  ),
                  $$WorkoutPlanExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                workoutPlanId = false,
                exerciseId = false,
                workoutPlanSetsRefs = false,
                workoutSessionExercisesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (workoutPlanSetsRefs) db.workoutPlanSets,
                    if (workoutSessionExercisesRefs) db.workoutSessionExercises,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (workoutPlanId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.workoutPlanId,
                            referencedTable:
                                $$WorkoutPlanExercisesTableReferences
                                    ._workoutPlanIdTable(db),
                            referencedColumn:
                                $$WorkoutPlanExercisesTableReferences
                                    ._workoutPlanIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (exerciseId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.exerciseId,
                            referencedTable:
                                $$WorkoutPlanExercisesTableReferences
                                    ._exerciseIdTable(db),
                            referencedColumn:
                                $$WorkoutPlanExercisesTableReferences
                                    ._exerciseIdTable(db)
                                    .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (workoutPlanSetsRefs)
                        await $_getPrefetchedData<
                          WorkoutPlanExercise,
                          $WorkoutPlanExercisesTable,
                          WorkoutPlanSet
                        >(
                          currentTable: table,
                          referencedTable: $$WorkoutPlanExercisesTableReferences
                              ._workoutPlanSetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutPlanExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutPlanSetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.planExerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workoutSessionExercisesRefs)
                        await $_getPrefetchedData<
                          WorkoutPlanExercise,
                          $WorkoutPlanExercisesTable,
                          WorkoutSessionExercise
                        >(
                          currentTable: table,
                          referencedTable: $$WorkoutPlanExercisesTableReferences
                              ._workoutSessionExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutPlanExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutSessionExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.planExerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WorkoutPlanExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutPlanExercisesTable,
      WorkoutPlanExercise,
      $$WorkoutPlanExercisesTableFilterComposer,
      $$WorkoutPlanExercisesTableOrderingComposer,
      $$WorkoutPlanExercisesTableAnnotationComposer,
      $$WorkoutPlanExercisesTableCreateCompanionBuilder,
      $$WorkoutPlanExercisesTableUpdateCompanionBuilder,
      (WorkoutPlanExercise, $$WorkoutPlanExercisesTableReferences),
      WorkoutPlanExercise,
      PrefetchHooks Function({
        bool workoutPlanId,
        bool exerciseId,
        bool workoutPlanSetsRefs,
        bool workoutSessionExercisesRefs,
      })
    >;
typedef $$WorkoutPlanSetsTableCreateCompanionBuilder =
    WorkoutPlanSetsCompanion Function({
      Value<int> id,
      required int planExerciseId,
      required int position,
      required int repetitions,
      required double weightKg,
      Value<String?> notes,
    });
typedef $$WorkoutPlanSetsTableUpdateCompanionBuilder =
    WorkoutPlanSetsCompanion Function({
      Value<int> id,
      Value<int> planExerciseId,
      Value<int> position,
      Value<int> repetitions,
      Value<double> weightKg,
      Value<String?> notes,
    });

final class $$WorkoutPlanSetsTableReferences
    extends
        BaseReferences<_$AppDatabase, $WorkoutPlanSetsTable, WorkoutPlanSet> {
  $$WorkoutPlanSetsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkoutPlanExercisesTable _planExerciseIdTable(_$AppDatabase db) =>
      db.workoutPlanExercises.createAlias(
        'workout_plan_sets__plan_exercise_id__workout_plan_exercises__id',
      );

  $$WorkoutPlanExercisesTableProcessedTableManager get planExerciseId {
    final $_column = $_itemColumn<int>('plan_exercise_id')!;

    final manager = $$WorkoutPlanExercisesTableTableManager(
      $_db,
      $_db.workoutPlanExercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planExerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorkoutPlanSetsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutPlanSetsTable> {
  $$WorkoutPlanSetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutPlanExercisesTableFilterComposer get planExerciseId {
    final $$WorkoutPlanExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planExerciseId,
      referencedTable: $db.workoutPlanExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutPlanExercisesTableFilterComposer(
            $db: $db,
            $table: $db.workoutPlanExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutPlanSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutPlanSetsTable> {
  $$WorkoutPlanSetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutPlanExercisesTableOrderingComposer get planExerciseId {
    final $$WorkoutPlanExercisesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.planExerciseId,
          referencedTable: $db.workoutPlanExercises,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutPlanExercisesTableOrderingComposer(
                $db: $db,
                $table: $db.workoutPlanExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$WorkoutPlanSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutPlanSetsTable> {
  $$WorkoutPlanSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$WorkoutPlanExercisesTableAnnotationComposer get planExerciseId {
    final $$WorkoutPlanExercisesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.planExerciseId,
          referencedTable: $db.workoutPlanExercises,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutPlanExercisesTableAnnotationComposer(
                $db: $db,
                $table: $db.workoutPlanExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$WorkoutPlanSetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutPlanSetsTable,
          WorkoutPlanSet,
          $$WorkoutPlanSetsTableFilterComposer,
          $$WorkoutPlanSetsTableOrderingComposer,
          $$WorkoutPlanSetsTableAnnotationComposer,
          $$WorkoutPlanSetsTableCreateCompanionBuilder,
          $$WorkoutPlanSetsTableUpdateCompanionBuilder,
          (WorkoutPlanSet, $$WorkoutPlanSetsTableReferences),
          WorkoutPlanSet,
          PrefetchHooks Function({bool planExerciseId})
        > {
  $$WorkoutPlanSetsTableTableManager(
    _$AppDatabase db,
    $WorkoutPlanSetsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutPlanSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutPlanSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutPlanSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> planExerciseId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> repetitions = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => WorkoutPlanSetsCompanion(
                id: id,
                planExerciseId: planExerciseId,
                position: position,
                repetitions: repetitions,
                weightKg: weightKg,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int planExerciseId,
                required int position,
                required int repetitions,
                required double weightKg,
                Value<String?> notes = const Value.absent(),
              }) => WorkoutPlanSetsCompanion.insert(
                id: id,
                planExerciseId: planExerciseId,
                position: position,
                repetitions: repetitions,
                weightKg: weightKg,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkoutPlanSetsTable, WorkoutPlanSet>(table),
                  $$WorkoutPlanSetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({planExerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (planExerciseId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.planExerciseId,
                        referencedTable: $$WorkoutPlanSetsTableReferences
                            ._planExerciseIdTable(db),
                        referencedColumn: $$WorkoutPlanSetsTableReferences
                            ._planExerciseIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WorkoutPlanSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutPlanSetsTable,
      WorkoutPlanSet,
      $$WorkoutPlanSetsTableFilterComposer,
      $$WorkoutPlanSetsTableOrderingComposer,
      $$WorkoutPlanSetsTableAnnotationComposer,
      $$WorkoutPlanSetsTableCreateCompanionBuilder,
      $$WorkoutPlanSetsTableUpdateCompanionBuilder,
      (WorkoutPlanSet, $$WorkoutPlanSetsTableReferences),
      WorkoutPlanSet,
      PrefetchHooks Function({bool planExerciseId})
    >;
typedef $$WorkoutSessionsTableCreateCompanionBuilder =
    WorkoutSessionsCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> id,
      Value<int?> workoutPlanId,
      required String planNameSnapshot,
      required DateTime startedAt,
      Value<DateTime?> finishedAt,
      Value<int?> durationSeconds,
      Value<String?> notes,
      required SessionStatus status,
    });
typedef $$WorkoutSessionsTableUpdateCompanionBuilder =
    WorkoutSessionsCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> id,
      Value<int?> workoutPlanId,
      Value<String> planNameSnapshot,
      Value<DateTime> startedAt,
      Value<DateTime?> finishedAt,
      Value<int?> durationSeconds,
      Value<String?> notes,
      Value<SessionStatus> status,
    });

final class $$WorkoutSessionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $WorkoutSessionsTable, WorkoutSession> {
  $$WorkoutSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkoutPlansTable _workoutPlanIdTable(_$AppDatabase db) => db
      .workoutPlans
      .createAlias('workout_sessions__workout_plan_id__workout_plans__id');

  $$WorkoutPlansTableProcessedTableManager? get workoutPlanId {
    final $_column = $_itemColumn<int>('workout_plan_id');
    if ($_column == null) return null;
    final manager = $$WorkoutPlansTableTableManager(
      $_db,
      $_db.workoutPlans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutPlanIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $WorkoutSessionExercisesTable,
    List<WorkoutSessionExercise>
  >
  _workoutSessionExercisesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.workoutSessionExercises,
        aliasName:
            'workout_sessions__id__workout_session_exercises__session_id',
      );

  $$WorkoutSessionExercisesTableProcessedTableManager
  get workoutSessionExercisesRefs {
    final manager = $$WorkoutSessionExercisesTableTableManager(
      $_db,
      $_db.workoutSessionExercises,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutSessionExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkoutSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planNameSnapshot => $composableBuilder(
    column: $table.planNameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SessionStatus, SessionStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$WorkoutPlansTableFilterComposer get workoutPlanId {
    final $$WorkoutPlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutPlanId,
      referencedTable: $db.workoutPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutPlansTableFilterComposer(
            $db: $db,
            $table: $db.workoutPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> workoutSessionExercisesRefs(
    Expression<bool> Function($$WorkoutSessionExercisesTableFilterComposer f) f,
  ) {
    final $$WorkoutSessionExercisesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.workoutSessionExercises,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutSessionExercisesTableFilterComposer(
                $db: $db,
                $table: $db.workoutSessionExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$WorkoutSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planNameSnapshot => $composableBuilder(
    column: $table.planNameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutPlansTableOrderingComposer get workoutPlanId {
    final $$WorkoutPlansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutPlanId,
      referencedTable: $db.workoutPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutPlansTableOrderingComposer(
            $db: $db,
            $table: $db.workoutPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get planNameSnapshot => $composableBuilder(
    column: $table.planNameSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SessionStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$WorkoutPlansTableAnnotationComposer get workoutPlanId {
    final $$WorkoutPlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutPlanId,
      referencedTable: $db.workoutPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutPlansTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> workoutSessionExercisesRefs<T extends Object>(
    Expression<T> Function($$WorkoutSessionExercisesTableAnnotationComposer a)
    f,
  ) {
    final $$WorkoutSessionExercisesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.workoutSessionExercises,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutSessionExercisesTableAnnotationComposer(
                $db: $db,
                $table: $db.workoutSessionExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$WorkoutSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutSessionsTable,
          WorkoutSession,
          $$WorkoutSessionsTableFilterComposer,
          $$WorkoutSessionsTableOrderingComposer,
          $$WorkoutSessionsTableAnnotationComposer,
          $$WorkoutSessionsTableCreateCompanionBuilder,
          $$WorkoutSessionsTableUpdateCompanionBuilder,
          (WorkoutSession, $$WorkoutSessionsTableReferences),
          WorkoutSession,
          PrefetchHooks Function({
            bool workoutPlanId,
            bool workoutSessionExercisesRefs,
          })
        > {
  $$WorkoutSessionsTableTableManager(
    _$AppDatabase db,
    $WorkoutSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<int?> workoutPlanId = const Value.absent(),
                Value<String> planNameSnapshot = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<SessionStatus> status = const Value.absent(),
              }) => WorkoutSessionsCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                workoutPlanId: workoutPlanId,
                planNameSnapshot: planNameSnapshot,
                startedAt: startedAt,
                finishedAt: finishedAt,
                durationSeconds: durationSeconds,
                notes: notes,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<int?> workoutPlanId = const Value.absent(),
                required String planNameSnapshot,
                required DateTime startedAt,
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required SessionStatus status,
              }) => WorkoutSessionsCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                workoutPlanId: workoutPlanId,
                planNameSnapshot: planNameSnapshot,
                startedAt: startedAt,
                finishedAt: finishedAt,
                durationSeconds: durationSeconds,
                notes: notes,
                status: status,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkoutSessionsTable, WorkoutSession>(table),
                  $$WorkoutSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({workoutPlanId = false, workoutSessionExercisesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (workoutSessionExercisesRefs) db.workoutSessionExercises,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (workoutPlanId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.workoutPlanId,
                            referencedTable: $$WorkoutSessionsTableReferences
                                ._workoutPlanIdTable(db),
                            referencedColumn: $$WorkoutSessionsTableReferences
                                ._workoutPlanIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (workoutSessionExercisesRefs)
                        await $_getPrefetchedData<
                          WorkoutSession,
                          $WorkoutSessionsTable,
                          WorkoutSessionExercise
                        >(
                          currentTable: table,
                          referencedTable: $$WorkoutSessionsTableReferences
                              ._workoutSessionExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutSessionExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WorkoutSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutSessionsTable,
      WorkoutSession,
      $$WorkoutSessionsTableFilterComposer,
      $$WorkoutSessionsTableOrderingComposer,
      $$WorkoutSessionsTableAnnotationComposer,
      $$WorkoutSessionsTableCreateCompanionBuilder,
      $$WorkoutSessionsTableUpdateCompanionBuilder,
      (WorkoutSession, $$WorkoutSessionsTableReferences),
      WorkoutSession,
      PrefetchHooks Function({
        bool workoutPlanId,
        bool workoutSessionExercisesRefs,
      })
    >;
typedef $$WorkoutSessionExercisesTableCreateCompanionBuilder =
    WorkoutSessionExercisesCompanion Function({
      Value<int> id,
      required int sessionId,
      required int exerciseId,
      Value<int?> planExerciseId,
      required String exerciseNameSnapshot,
      required MuscleGroup muscleGroupSnapshot,
      required int position,
      Value<String?> notes,
      Value<int?> restSeconds,
      Value<bool> skipped,
    });
typedef $$WorkoutSessionExercisesTableUpdateCompanionBuilder =
    WorkoutSessionExercisesCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<int> exerciseId,
      Value<int?> planExerciseId,
      Value<String> exerciseNameSnapshot,
      Value<MuscleGroup> muscleGroupSnapshot,
      Value<int> position,
      Value<String?> notes,
      Value<int?> restSeconds,
      Value<bool> skipped,
    });

final class $$WorkoutSessionExercisesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $WorkoutSessionExercisesTable,
          WorkoutSessionExercise
        > {
  $$WorkoutSessionExercisesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkoutSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.workoutSessions.createAlias(
        'workout_session_exercises__session_id__workout_sessions__id',
      );

  $$WorkoutSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$WorkoutSessionsTableTableManager(
      $_db,
      $_db.workoutSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) => db.exercises
      .createAlias('workout_session_exercises__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WorkoutPlanExercisesTable _planExerciseIdTable(
    _$AppDatabase db,
  ) => db.workoutPlanExercises.createAlias(
    'workout_session_exercises__plan_exercise_id__workout_plan_exercises__id',
  );

  $$WorkoutPlanExercisesTableProcessedTableManager? get planExerciseId {
    final $_column = $_itemColumn<int>('plan_exercise_id');
    if ($_column == null) return null;
    final manager = $$WorkoutPlanExercisesTableTableManager(
      $_db,
      $_db.workoutPlanExercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planExerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$WorkoutSessionSetsTable, List<WorkoutSessionSet>>
  _workoutSessionSetsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.workoutSessionSets,
        aliasName: 'workout_session_exercises__id__workout_session_sets__session_exercise_id',
      );

  $$WorkoutSessionSetsTableProcessedTableManager get workoutSessionSetsRefs {
    final manager = $$WorkoutSessionSetsTableTableManager(
      $_db,
      $_db.workoutSessionSets,
    ).filter((f) => f.sessionExerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutSessionSetsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkoutSessionExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutSessionExercisesTable> {
  $$WorkoutSessionExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseNameSnapshot => $composableBuilder(
    column: $table.exerciseNameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MuscleGroup, MuscleGroup, String>
  get muscleGroupSnapshot => $composableBuilder(
    column: $table.muscleGroupSnapshot,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get skipped => $composableBuilder(
    column: $table.skipped,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutSessionsTableFilterComposer get sessionId {
    final $$WorkoutSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableFilterComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkoutPlanExercisesTableFilterComposer get planExerciseId {
    final $$WorkoutPlanExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planExerciseId,
      referencedTable: $db.workoutPlanExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutPlanExercisesTableFilterComposer(
            $db: $db,
            $table: $db.workoutPlanExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> workoutSessionSetsRefs(
    Expression<bool> Function($$WorkoutSessionSetsTableFilterComposer f) f,
  ) {
    final $$WorkoutSessionSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSessionSets,
      getReferencedColumn: (t) => t.sessionExerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionSetsTableFilterComposer(
            $db: $db,
            $table: $db.workoutSessionSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutSessionExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSessionExercisesTable> {
  $$WorkoutSessionExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseNameSnapshot => $composableBuilder(
    column: $table.exerciseNameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get muscleGroupSnapshot => $composableBuilder(
    column: $table.muscleGroupSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get skipped => $composableBuilder(
    column: $table.skipped,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutSessionsTableOrderingComposer get sessionId {
    final $$WorkoutSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkoutPlanExercisesTableOrderingComposer get planExerciseId {
    final $$WorkoutPlanExercisesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.planExerciseId,
          referencedTable: $db.workoutPlanExercises,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutPlanExercisesTableOrderingComposer(
                $db: $db,
                $table: $db.workoutPlanExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$WorkoutSessionExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSessionExercisesTable> {
  $$WorkoutSessionExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get exerciseNameSnapshot => $composableBuilder(
    column: $table.exerciseNameSnapshot,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<MuscleGroup, String>
  get muscleGroupSnapshot => $composableBuilder(
    column: $table.muscleGroupSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get skipped =>
      $composableBuilder(column: $table.skipped, builder: (column) => column);

  $$WorkoutSessionsTableAnnotationComposer get sessionId {
    final $$WorkoutSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkoutPlanExercisesTableAnnotationComposer get planExerciseId {
    final $$WorkoutPlanExercisesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.planExerciseId,
          referencedTable: $db.workoutPlanExercises,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutPlanExercisesTableAnnotationComposer(
                $db: $db,
                $table: $db.workoutPlanExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> workoutSessionSetsRefs<T extends Object>(
    Expression<T> Function($$WorkoutSessionSetsTableAnnotationComposer a) f,
  ) {
    final $$WorkoutSessionSetsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.workoutSessionSets,
          getReferencedColumn: (t) => t.sessionExerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutSessionSetsTableAnnotationComposer(
                $db: $db,
                $table: $db.workoutSessionSets,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$WorkoutSessionExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutSessionExercisesTable,
          WorkoutSessionExercise,
          $$WorkoutSessionExercisesTableFilterComposer,
          $$WorkoutSessionExercisesTableOrderingComposer,
          $$WorkoutSessionExercisesTableAnnotationComposer,
          $$WorkoutSessionExercisesTableCreateCompanionBuilder,
          $$WorkoutSessionExercisesTableUpdateCompanionBuilder,
          (WorkoutSessionExercise, $$WorkoutSessionExercisesTableReferences),
          WorkoutSessionExercise,
          PrefetchHooks Function({
            bool sessionId,
            bool exerciseId,
            bool planExerciseId,
            bool workoutSessionSetsRefs,
          })
        > {
  $$WorkoutSessionExercisesTableTableManager(
    _$AppDatabase db,
    $WorkoutSessionExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSessionExercisesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$WorkoutSessionExercisesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WorkoutSessionExercisesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<int> exerciseId = const Value.absent(),
                Value<int?> planExerciseId = const Value.absent(),
                Value<String> exerciseNameSnapshot = const Value.absent(),
                Value<MuscleGroup> muscleGroupSnapshot = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> restSeconds = const Value.absent(),
                Value<bool> skipped = const Value.absent(),
              }) => WorkoutSessionExercisesCompanion(
                id: id,
                sessionId: sessionId,
                exerciseId: exerciseId,
                planExerciseId: planExerciseId,
                exerciseNameSnapshot: exerciseNameSnapshot,
                muscleGroupSnapshot: muscleGroupSnapshot,
                position: position,
                notes: notes,
                restSeconds: restSeconds,
                skipped: skipped,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required int exerciseId,
                Value<int?> planExerciseId = const Value.absent(),
                required String exerciseNameSnapshot,
                required MuscleGroup muscleGroupSnapshot,
                required int position,
                Value<String?> notes = const Value.absent(),
                Value<int?> restSeconds = const Value.absent(),
                Value<bool> skipped = const Value.absent(),
              }) => WorkoutSessionExercisesCompanion.insert(
                id: id,
                sessionId: sessionId,
                exerciseId: exerciseId,
                planExerciseId: planExerciseId,
                exerciseNameSnapshot: exerciseNameSnapshot,
                muscleGroupSnapshot: muscleGroupSnapshot,
                position: position,
                notes: notes,
                restSeconds: restSeconds,
                skipped: skipped,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $WorkoutSessionExercisesTable,
                    WorkoutSessionExercise
                  >(table),
                  $$WorkoutSessionExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sessionId = false,
                exerciseId = false,
                planExerciseId = false,
                workoutSessionSetsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (workoutSessionSetsRefs) db.workoutSessionSets,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sessionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.sessionId,
                            referencedTable:
                                $$WorkoutSessionExercisesTableReferences
                                    ._sessionIdTable(db),
                            referencedColumn:
                                $$WorkoutSessionExercisesTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (exerciseId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.exerciseId,
                            referencedTable:
                                $$WorkoutSessionExercisesTableReferences
                                    ._exerciseIdTable(db),
                            referencedColumn:
                                $$WorkoutSessionExercisesTableReferences
                                    ._exerciseIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (planExerciseId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.planExerciseId,
                            referencedTable:
                                $$WorkoutSessionExercisesTableReferences
                                    ._planExerciseIdTable(db),
                            referencedColumn:
                                $$WorkoutSessionExercisesTableReferences
                                    ._planExerciseIdTable(db)
                                    .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (workoutSessionSetsRefs)
                        await $_getPrefetchedData<
                          WorkoutSessionExercise,
                          $WorkoutSessionExercisesTable,
                          WorkoutSessionSet
                        >(
                          currentTable: table,
                          referencedTable:
                              $$WorkoutSessionExercisesTableReferences
                                  ._workoutSessionSetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutSessionExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutSessionSetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionExerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WorkoutSessionExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutSessionExercisesTable,
      WorkoutSessionExercise,
      $$WorkoutSessionExercisesTableFilterComposer,
      $$WorkoutSessionExercisesTableOrderingComposer,
      $$WorkoutSessionExercisesTableAnnotationComposer,
      $$WorkoutSessionExercisesTableCreateCompanionBuilder,
      $$WorkoutSessionExercisesTableUpdateCompanionBuilder,
      (WorkoutSessionExercise, $$WorkoutSessionExercisesTableReferences),
      WorkoutSessionExercise,
      PrefetchHooks Function({
        bool sessionId,
        bool exerciseId,
        bool planExerciseId,
        bool workoutSessionSetsRefs,
      })
    >;
typedef $$WorkoutSessionSetsTableCreateCompanionBuilder =
    WorkoutSessionSetsCompanion Function({
      Value<int> id,
      required int sessionExerciseId,
      required int position,
      Value<int?> plannedRepetitions,
      Value<double?> plannedWeightKg,
      required int repetitions,
      required double weightKg,
      Value<bool> completed,
      Value<DateTime?> completedAt,
    });
typedef $$WorkoutSessionSetsTableUpdateCompanionBuilder =
    WorkoutSessionSetsCompanion Function({
      Value<int> id,
      Value<int> sessionExerciseId,
      Value<int> position,
      Value<int?> plannedRepetitions,
      Value<double?> plannedWeightKg,
      Value<int> repetitions,
      Value<double> weightKg,
      Value<bool> completed,
      Value<DateTime?> completedAt,
    });

final class $$WorkoutSessionSetsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $WorkoutSessionSetsTable,
          WorkoutSessionSet
        > {
  $$WorkoutSessionSetsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkoutSessionExercisesTable _sessionExerciseIdTable(
    _$AppDatabase db,
  ) => db.workoutSessionExercises.createAlias(
    'workout_session_sets__session_exercise_id__workout_session_exercises__id',
  );

  $$WorkoutSessionExercisesTableProcessedTableManager get sessionExerciseId {
    final $_column = $_itemColumn<int>('session_exercise_id')!;

    final manager = $$WorkoutSessionExercisesTableTableManager(
      $_db,
      $_db.workoutSessionExercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionExerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorkoutSessionSetsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutSessionSetsTable> {
  $$WorkoutSessionSetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedRepetitions => $composableBuilder(
    column: $table.plannedRepetitions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get plannedWeightKg => $composableBuilder(
    column: $table.plannedWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutSessionExercisesTableFilterComposer get sessionExerciseId {
    final $$WorkoutSessionExercisesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionExerciseId,
          referencedTable: $db.workoutSessionExercises,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutSessionExercisesTableFilterComposer(
                $db: $db,
                $table: $db.workoutSessionExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$WorkoutSessionSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSessionSetsTable> {
  $$WorkoutSessionSetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedRepetitions => $composableBuilder(
    column: $table.plannedRepetitions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get plannedWeightKg => $composableBuilder(
    column: $table.plannedWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutSessionExercisesTableOrderingComposer get sessionExerciseId {
    final $$WorkoutSessionExercisesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionExerciseId,
          referencedTable: $db.workoutSessionExercises,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutSessionExercisesTableOrderingComposer(
                $db: $db,
                $table: $db.workoutSessionExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$WorkoutSessionSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSessionSetsTable> {
  $$WorkoutSessionSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get plannedRepetitions => $composableBuilder(
    column: $table.plannedRepetitions,
    builder: (column) => column,
  );

  GeneratedColumn<double> get plannedWeightKg => $composableBuilder(
    column: $table.plannedWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  $$WorkoutSessionExercisesTableAnnotationComposer get sessionExerciseId {
    final $$WorkoutSessionExercisesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionExerciseId,
          referencedTable: $db.workoutSessionExercises,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutSessionExercisesTableAnnotationComposer(
                $db: $db,
                $table: $db.workoutSessionExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$WorkoutSessionSetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutSessionSetsTable,
          WorkoutSessionSet,
          $$WorkoutSessionSetsTableFilterComposer,
          $$WorkoutSessionSetsTableOrderingComposer,
          $$WorkoutSessionSetsTableAnnotationComposer,
          $$WorkoutSessionSetsTableCreateCompanionBuilder,
          $$WorkoutSessionSetsTableUpdateCompanionBuilder,
          (WorkoutSessionSet, $$WorkoutSessionSetsTableReferences),
          WorkoutSessionSet,
          PrefetchHooks Function({bool sessionExerciseId})
        > {
  $$WorkoutSessionSetsTableTableManager(
    _$AppDatabase db,
    $WorkoutSessionSetsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSessionSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSessionSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSessionSetsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionExerciseId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int?> plannedRepetitions = const Value.absent(),
                Value<double?> plannedWeightKg = const Value.absent(),
                Value<int> repetitions = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
              }) => WorkoutSessionSetsCompanion(
                id: id,
                sessionExerciseId: sessionExerciseId,
                position: position,
                plannedRepetitions: plannedRepetitions,
                plannedWeightKg: plannedWeightKg,
                repetitions: repetitions,
                weightKg: weightKg,
                completed: completed,
                completedAt: completedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionExerciseId,
                required int position,
                Value<int?> plannedRepetitions = const Value.absent(),
                Value<double?> plannedWeightKg = const Value.absent(),
                required int repetitions,
                required double weightKg,
                Value<bool> completed = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
              }) => WorkoutSessionSetsCompanion.insert(
                id: id,
                sessionExerciseId: sessionExerciseId,
                position: position,
                plannedRepetitions: plannedRepetitions,
                plannedWeightKg: plannedWeightKg,
                repetitions: repetitions,
                weightKg: weightKg,
                completed: completed,
                completedAt: completedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkoutSessionSetsTable, WorkoutSessionSet>(
                    table,
                  ),
                  $$WorkoutSessionSetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionExerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionExerciseId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionExerciseId,
                        referencedTable: $$WorkoutSessionSetsTableReferences
                            ._sessionExerciseIdTable(db),
                        referencedColumn: $$WorkoutSessionSetsTableReferences
                            ._sessionExerciseIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WorkoutSessionSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutSessionSetsTable,
      WorkoutSessionSet,
      $$WorkoutSessionSetsTableFilterComposer,
      $$WorkoutSessionSetsTableOrderingComposer,
      $$WorkoutSessionSetsTableAnnotationComposer,
      $$WorkoutSessionSetsTableCreateCompanionBuilder,
      $$WorkoutSessionSetsTableUpdateCompanionBuilder,
      (WorkoutSessionSet, $$WorkoutSessionSetsTableReferences),
      WorkoutSessionSet,
      PrefetchHooks Function({bool sessionExerciseId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<ThemePreference> themePreference,
      Value<bool> autoStartTimer,
      Value<bool> timerSound,
      Value<bool> timerVibration,
      Value<int> defaultRestSeconds,
      Value<double> weightIncrementKg,
      Value<WeightUnit> weightUnit,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<ThemePreference> themePreference,
      Value<bool> autoStartTimer,
      Value<bool> timerSound,
      Value<bool> timerVibration,
      Value<int> defaultRestSeconds,
      Value<double> weightIncrementKg,
      Value<WeightUnit> weightUnit,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ThemePreference, ThemePreference, String>
  get themePreference => $composableBuilder(
    column: $table.themePreference,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get autoStartTimer => $composableBuilder(
    column: $table.autoStartTimer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get timerSound => $composableBuilder(
    column: $table.timerSound,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get timerVibration => $composableBuilder(
    column: $table.timerVibration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultRestSeconds => $composableBuilder(
    column: $table.defaultRestSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightIncrementKg => $composableBuilder(
    column: $table.weightIncrementKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<WeightUnit, WeightUnit, String>
  get weightUnit => $composableBuilder(
    column: $table.weightUnit,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themePreference => $composableBuilder(
    column: $table.themePreference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoStartTimer => $composableBuilder(
    column: $table.autoStartTimer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get timerSound => $composableBuilder(
    column: $table.timerSound,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get timerVibration => $composableBuilder(
    column: $table.timerVibration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultRestSeconds => $composableBuilder(
    column: $table.defaultRestSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightIncrementKg => $composableBuilder(
    column: $table.weightIncrementKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weightUnit => $composableBuilder(
    column: $table.weightUnit,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ThemePreference, String>
  get themePreference => $composableBuilder(
    column: $table.themePreference,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get autoStartTimer => $composableBuilder(
    column: $table.autoStartTimer,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get timerSound => $composableBuilder(
    column: $table.timerSound,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get timerVibration => $composableBuilder(
    column: $table.timerVibration,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultRestSeconds => $composableBuilder(
    column: $table.defaultRestSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weightIncrementKg => $composableBuilder(
    column: $table.weightIncrementKg,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<WeightUnit, String> get weightUnit =>
      $composableBuilder(
        column: $table.weightUnit,
        builder: (column) => column,
      );
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSettingsRow,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSettingsRow,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingsRow>,
          ),
          AppSettingsRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<ThemePreference> themePreference = const Value.absent(),
                Value<bool> autoStartTimer = const Value.absent(),
                Value<bool> timerSound = const Value.absent(),
                Value<bool> timerVibration = const Value.absent(),
                Value<int> defaultRestSeconds = const Value.absent(),
                Value<double> weightIncrementKg = const Value.absent(),
                Value<WeightUnit> weightUnit = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                themePreference: themePreference,
                autoStartTimer: autoStartTimer,
                timerSound: timerSound,
                timerVibration: timerVibration,
                defaultRestSeconds: defaultRestSeconds,
                weightIncrementKg: weightIncrementKg,
                weightUnit: weightUnit,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<ThemePreference> themePreference = const Value.absent(),
                Value<bool> autoStartTimer = const Value.absent(),
                Value<bool> timerSound = const Value.absent(),
                Value<bool> timerVibration = const Value.absent(),
                Value<int> defaultRestSeconds = const Value.absent(),
                Value<double> weightIncrementKg = const Value.absent(),
                Value<WeightUnit> weightUnit = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                themePreference: themePreference,
                autoStartTimer: autoStartTimer,
                timerSound: timerSound,
                timerVibration: timerVibration,
                defaultRestSeconds: defaultRestSeconds,
                weightIncrementKg: weightIncrementKg,
                weightUnit: weightUnit,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSettingsRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AppSettingsTable,
                    AppSettingsRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSettingsRow,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSettingsRow,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingsRow>,
      ),
      AppSettingsRow,
      PrefetchHooks Function()
    >;
typedef $$TimerStatesTableCreateCompanionBuilder =
    TimerStatesCompanion Function({
      Value<int> id,
      required TimerStatus status,
      required int durationMs,
      Value<int?> startedAtMs,
      Value<int> elapsedBeforeMs,
    });
typedef $$TimerStatesTableUpdateCompanionBuilder =
    TimerStatesCompanion Function({
      Value<int> id,
      Value<TimerStatus> status,
      Value<int> durationMs,
      Value<int?> startedAtMs,
      Value<int> elapsedBeforeMs,
    });

class $$TimerStatesTableFilterComposer
    extends Composer<_$AppDatabase, $TimerStatesTable> {
  $$TimerStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TimerStatus, TimerStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAtMs => $composableBuilder(
    column: $table.startedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedBeforeMs => $composableBuilder(
    column: $table.elapsedBeforeMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TimerStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $TimerStatesTable> {
  $$TimerStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAtMs => $composableBuilder(
    column: $table.startedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedBeforeMs => $composableBuilder(
    column: $table.elapsedBeforeMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TimerStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimerStatesTable> {
  $$TimerStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TimerStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startedAtMs => $composableBuilder(
    column: $table.startedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get elapsedBeforeMs => $composableBuilder(
    column: $table.elapsedBeforeMs,
    builder: (column) => column,
  );
}

class $$TimerStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimerStatesTable,
          TimerStateRow,
          $$TimerStatesTableFilterComposer,
          $$TimerStatesTableOrderingComposer,
          $$TimerStatesTableAnnotationComposer,
          $$TimerStatesTableCreateCompanionBuilder,
          $$TimerStatesTableUpdateCompanionBuilder,
          (
            TimerStateRow,
            BaseReferences<_$AppDatabase, $TimerStatesTable, TimerStateRow>,
          ),
          TimerStateRow,
          PrefetchHooks Function()
        > {
  $$TimerStatesTableTableManager(_$AppDatabase db, $TimerStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimerStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimerStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimerStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<TimerStatus> status = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<int?> startedAtMs = const Value.absent(),
                Value<int> elapsedBeforeMs = const Value.absent(),
              }) => TimerStatesCompanion(
                id: id,
                status: status,
                durationMs: durationMs,
                startedAtMs: startedAtMs,
                elapsedBeforeMs: elapsedBeforeMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required TimerStatus status,
                required int durationMs,
                Value<int?> startedAtMs = const Value.absent(),
                Value<int> elapsedBeforeMs = const Value.absent(),
              }) => TimerStatesCompanion.insert(
                id: id,
                status: status,
                durationMs: durationMs,
                startedAtMs: startedAtMs,
                elapsedBeforeMs: elapsedBeforeMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TimerStatesTable, TimerStateRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $TimerStatesTable,
                    TimerStateRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TimerStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimerStatesTable,
      TimerStateRow,
      $$TimerStatesTableFilterComposer,
      $$TimerStatesTableOrderingComposer,
      $$TimerStatesTableAnnotationComposer,
      $$TimerStatesTableCreateCompanionBuilder,
      $$TimerStatesTableUpdateCompanionBuilder,
      (
        TimerStateRow,
        BaseReferences<_$AppDatabase, $TimerStatesTable, TimerStateRow>,
      ),
      TimerStateRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$BodyMeasurementsTableTableManager get bodyMeasurements =>
      $$BodyMeasurementsTableTableManager(_db, _db.bodyMeasurements);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db, _db.exercises);
  $$WorkoutPlansTableTableManager get workoutPlans =>
      $$WorkoutPlansTableTableManager(_db, _db.workoutPlans);
  $$WorkoutPlanExercisesTableTableManager get workoutPlanExercises =>
      $$WorkoutPlanExercisesTableTableManager(_db, _db.workoutPlanExercises);
  $$WorkoutPlanSetsTableTableManager get workoutPlanSets =>
      $$WorkoutPlanSetsTableTableManager(_db, _db.workoutPlanSets);
  $$WorkoutSessionsTableTableManager get workoutSessions =>
      $$WorkoutSessionsTableTableManager(_db, _db.workoutSessions);
  $$WorkoutSessionExercisesTableTableManager get workoutSessionExercises =>
      $$WorkoutSessionExercisesTableTableManager(
        _db,
        _db.workoutSessionExercises,
      );
  $$WorkoutSessionSetsTableTableManager get workoutSessionSets =>
      $$WorkoutSessionSetsTableTableManager(_db, _db.workoutSessionSets);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$TimerStatesTableTableManager get timerStates =>
      $$TimerStatesTableTableManager(_db, _db.timerStates);
}
