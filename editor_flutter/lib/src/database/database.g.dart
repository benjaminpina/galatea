// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProjectInfoTable extends ProjectInfo
    with TableInfo<$ProjectInfoTable, ProjectInfoData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectInfoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.now().toIso8601String()),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.now().toIso8601String()),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'project_info';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProjectInfoData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProjectInfoData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectInfoData(
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
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProjectInfoTable createAlias(String alias) {
    return $ProjectInfoTable(attachedDatabase, alias);
  }
}

class ProjectInfoData extends DataClass implements Insertable<ProjectInfoData> {
  final int id;
  final String name;
  final String description;
  final String createdAt;
  final String updatedAt;
  const ProjectInfoData({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  ProjectInfoCompanion toCompanion(bool nullToAbsent) {
    return ProjectInfoCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProjectInfoData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectInfoData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  ProjectInfoData copyWith({
    int? id,
    String? name,
    String? description,
    String? createdAt,
    String? updatedAt,
  }) => ProjectInfoData(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ProjectInfoData copyWithCompanion(ProjectInfoCompanion data) {
    return ProjectInfoData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectInfoData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectInfoData &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProjectInfoCompanion extends UpdateCompanion<ProjectInfoData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> description;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  const ProjectInfoCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ProjectInfoCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<ProjectInfoData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ProjectInfoCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? description,
    Value<String>? createdAt,
    Value<String>? updatedAt,
  }) {
    return ProjectInfoCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectInfoCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $NutrientsTable extends Nutrients
    with TableInfo<$NutrientsTable, Nutrient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NutrientsTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
  List<GeneratedColumn> get $columns => [id, name, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nutrients';
  @override
  VerificationContext validateIntegrity(
    Insertable<Nutrient> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
  Nutrient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Nutrient(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $NutrientsTable createAlias(String alias) {
    return $NutrientsTable(attachedDatabase, alias);
  }
}

class Nutrient extends DataClass implements Insertable<Nutrient> {
  final int id;
  final String name;
  final int sortOrder;
  const Nutrient({
    required this.id,
    required this.name,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  NutrientsCompanion toCompanion(bool nullToAbsent) {
    return NutrientsCompanion(
      id: Value(id),
      name: Value(name),
      sortOrder: Value(sortOrder),
    );
  }

  factory Nutrient.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Nutrient(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Nutrient copyWith({int? id, String? name, int? sortOrder}) => Nutrient(
    id: id ?? this.id,
    name: name ?? this.name,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Nutrient copyWithCompanion(NutrientsCompanion data) {
    return Nutrient(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Nutrient(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Nutrient &&
          other.id == this.id &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder);
}

class NutrientsCompanion extends UpdateCompanion<Nutrient> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> sortOrder;
  const NutrientsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  NutrientsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.sortOrder = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Nutrient> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  NutrientsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? sortOrder,
  }) {
    return NutrientsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NutrientsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $SubstratesTable extends Substrates
    with TableInfo<$SubstratesTable, Substrate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubstratesTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isMixedMeta = const VerificationMeta(
    'isMixed',
  );
  @override
  late final GeneratedColumn<bool> isMixed = GeneratedColumn<bool>(
    'is_mixed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_mixed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  List<GeneratedColumn> get $columns => [id, name, color, isMixed, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'substrates';
  @override
  VerificationContext validateIntegrity(
    Insertable<Substrate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('is_mixed')) {
      context.handle(
        _isMixedMeta,
        isMixed.isAcceptableOrUnknown(data['is_mixed']!, _isMixedMeta),
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
  Substrate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Substrate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      isMixed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_mixed'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $SubstratesTable createAlias(String alias) {
    return $SubstratesTable(attachedDatabase, alias);
  }
}

class Substrate extends DataClass implements Insertable<Substrate> {
  final int id;
  final String name;
  final int color;
  final bool isMixed;
  final int sortOrder;
  const Substrate({
    required this.id,
    required this.name,
    required this.color,
    required this.isMixed,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<int>(color);
    map['is_mixed'] = Variable<bool>(isMixed);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  SubstratesCompanion toCompanion(bool nullToAbsent) {
    return SubstratesCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      isMixed: Value(isMixed),
      sortOrder: Value(sortOrder),
    );
  }

  factory Substrate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Substrate(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<int>(json['color']),
      isMixed: serializer.fromJson<bool>(json['isMixed']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<int>(color),
      'isMixed': serializer.toJson<bool>(isMixed),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Substrate copyWith({
    int? id,
    String? name,
    int? color,
    bool? isMixed,
    int? sortOrder,
  }) => Substrate(
    id: id ?? this.id,
    name: name ?? this.name,
    color: color ?? this.color,
    isMixed: isMixed ?? this.isMixed,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Substrate copyWithCompanion(SubstratesCompanion data) {
    return Substrate(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      isMixed: data.isMixed.present ? data.isMixed.value : this.isMixed,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Substrate(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('isMixed: $isMixed, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, color, isMixed, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Substrate &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.isMixed == this.isMixed &&
          other.sortOrder == this.sortOrder);
}

class SubstratesCompanion extends UpdateCompanion<Substrate> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> color;
  final Value<bool> isMixed;
  final Value<int> sortOrder;
  const SubstratesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.isMixed = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  SubstratesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.color = const Value.absent(),
    this.isMixed = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Substrate> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? color,
    Expression<bool>? isMixed,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (isMixed != null) 'is_mixed': isMixed,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  SubstratesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? color,
    Value<bool>? isMixed,
    Value<int>? sortOrder,
  }) {
    return SubstratesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      isMixed: isMixed ?? this.isMixed,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (isMixed.present) {
      map['is_mixed'] = Variable<bool>(isMixed.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubstratesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('isMixed: $isMixed, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $SubstrateCompositionsTable extends SubstrateCompositions
    with TableInfo<$SubstrateCompositionsTable, SubstrateComposition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubstrateCompositionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _mixedSubstrateIdMeta = const VerificationMeta(
    'mixedSubstrateId',
  );
  @override
  late final GeneratedColumn<int> mixedSubstrateId = GeneratedColumn<int>(
    'mixed_substrate_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES substrates (id)',
    ),
  );
  static const VerificationMeta _simpleSubstrateIdMeta = const VerificationMeta(
    'simpleSubstrateId',
  );
  @override
  late final GeneratedColumn<int> simpleSubstrateId = GeneratedColumn<int>(
    'simple_substrate_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES substrates (id)',
    ),
  );
  static const VerificationMeta _percentageMeta = const VerificationMeta(
    'percentage',
  );
  @override
  late final GeneratedColumn<int> percentage = GeneratedColumn<int>(
    'percentage',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mixedSubstrateId,
    simpleSubstrateId,
    percentage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'substrate_compositions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SubstrateComposition> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('mixed_substrate_id')) {
      context.handle(
        _mixedSubstrateIdMeta,
        mixedSubstrateId.isAcceptableOrUnknown(
          data['mixed_substrate_id']!,
          _mixedSubstrateIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mixedSubstrateIdMeta);
    }
    if (data.containsKey('simple_substrate_id')) {
      context.handle(
        _simpleSubstrateIdMeta,
        simpleSubstrateId.isAcceptableOrUnknown(
          data['simple_substrate_id']!,
          _simpleSubstrateIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_simpleSubstrateIdMeta);
    }
    if (data.containsKey('percentage')) {
      context.handle(
        _percentageMeta,
        percentage.isAcceptableOrUnknown(data['percentage']!, _percentageMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SubstrateComposition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubstrateComposition(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      mixedSubstrateId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mixed_substrate_id'],
      )!,
      simpleSubstrateId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}simple_substrate_id'],
      )!,
      percentage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}percentage'],
      )!,
    );
  }

  @override
  $SubstrateCompositionsTable createAlias(String alias) {
    return $SubstrateCompositionsTable(attachedDatabase, alias);
  }
}

class SubstrateComposition extends DataClass
    implements Insertable<SubstrateComposition> {
  final int id;
  final int mixedSubstrateId;
  final int simpleSubstrateId;
  final int percentage;
  const SubstrateComposition({
    required this.id,
    required this.mixedSubstrateId,
    required this.simpleSubstrateId,
    required this.percentage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['mixed_substrate_id'] = Variable<int>(mixedSubstrateId);
    map['simple_substrate_id'] = Variable<int>(simpleSubstrateId);
    map['percentage'] = Variable<int>(percentage);
    return map;
  }

  SubstrateCompositionsCompanion toCompanion(bool nullToAbsent) {
    return SubstrateCompositionsCompanion(
      id: Value(id),
      mixedSubstrateId: Value(mixedSubstrateId),
      simpleSubstrateId: Value(simpleSubstrateId),
      percentage: Value(percentage),
    );
  }

  factory SubstrateComposition.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubstrateComposition(
      id: serializer.fromJson<int>(json['id']),
      mixedSubstrateId: serializer.fromJson<int>(json['mixedSubstrateId']),
      simpleSubstrateId: serializer.fromJson<int>(json['simpleSubstrateId']),
      percentage: serializer.fromJson<int>(json['percentage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mixedSubstrateId': serializer.toJson<int>(mixedSubstrateId),
      'simpleSubstrateId': serializer.toJson<int>(simpleSubstrateId),
      'percentage': serializer.toJson<int>(percentage),
    };
  }

  SubstrateComposition copyWith({
    int? id,
    int? mixedSubstrateId,
    int? simpleSubstrateId,
    int? percentage,
  }) => SubstrateComposition(
    id: id ?? this.id,
    mixedSubstrateId: mixedSubstrateId ?? this.mixedSubstrateId,
    simpleSubstrateId: simpleSubstrateId ?? this.simpleSubstrateId,
    percentage: percentage ?? this.percentage,
  );
  SubstrateComposition copyWithCompanion(SubstrateCompositionsCompanion data) {
    return SubstrateComposition(
      id: data.id.present ? data.id.value : this.id,
      mixedSubstrateId: data.mixedSubstrateId.present
          ? data.mixedSubstrateId.value
          : this.mixedSubstrateId,
      simpleSubstrateId: data.simpleSubstrateId.present
          ? data.simpleSubstrateId.value
          : this.simpleSubstrateId,
      percentage: data.percentage.present
          ? data.percentage.value
          : this.percentage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubstrateComposition(')
          ..write('id: $id, ')
          ..write('mixedSubstrateId: $mixedSubstrateId, ')
          ..write('simpleSubstrateId: $simpleSubstrateId, ')
          ..write('percentage: $percentage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, mixedSubstrateId, simpleSubstrateId, percentage);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubstrateComposition &&
          other.id == this.id &&
          other.mixedSubstrateId == this.mixedSubstrateId &&
          other.simpleSubstrateId == this.simpleSubstrateId &&
          other.percentage == this.percentage);
}

class SubstrateCompositionsCompanion
    extends UpdateCompanion<SubstrateComposition> {
  final Value<int> id;
  final Value<int> mixedSubstrateId;
  final Value<int> simpleSubstrateId;
  final Value<int> percentage;
  const SubstrateCompositionsCompanion({
    this.id = const Value.absent(),
    this.mixedSubstrateId = const Value.absent(),
    this.simpleSubstrateId = const Value.absent(),
    this.percentage = const Value.absent(),
  });
  SubstrateCompositionsCompanion.insert({
    this.id = const Value.absent(),
    required int mixedSubstrateId,
    required int simpleSubstrateId,
    this.percentage = const Value.absent(),
  }) : mixedSubstrateId = Value(mixedSubstrateId),
       simpleSubstrateId = Value(simpleSubstrateId);
  static Insertable<SubstrateComposition> custom({
    Expression<int>? id,
    Expression<int>? mixedSubstrateId,
    Expression<int>? simpleSubstrateId,
    Expression<int>? percentage,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mixedSubstrateId != null) 'mixed_substrate_id': mixedSubstrateId,
      if (simpleSubstrateId != null) 'simple_substrate_id': simpleSubstrateId,
      if (percentage != null) 'percentage': percentage,
    });
  }

  SubstrateCompositionsCompanion copyWith({
    Value<int>? id,
    Value<int>? mixedSubstrateId,
    Value<int>? simpleSubstrateId,
    Value<int>? percentage,
  }) {
    return SubstrateCompositionsCompanion(
      id: id ?? this.id,
      mixedSubstrateId: mixedSubstrateId ?? this.mixedSubstrateId,
      simpleSubstrateId: simpleSubstrateId ?? this.simpleSubstrateId,
      percentage: percentage ?? this.percentage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mixedSubstrateId.present) {
      map['mixed_substrate_id'] = Variable<int>(mixedSubstrateId.value);
    }
    if (simpleSubstrateId.present) {
      map['simple_substrate_id'] = Variable<int>(simpleSubstrateId.value);
    }
    if (percentage.present) {
      map['percentage'] = Variable<int>(percentage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubstrateCompositionsCompanion(')
          ..write('id: $id, ')
          ..write('mixedSubstrateId: $mixedSubstrateId, ')
          ..write('simpleSubstrateId: $simpleSubstrateId, ')
          ..write('percentage: $percentage')
          ..write(')'))
        .toString();
  }
}

class $LociTable extends Loci with TableInfo<$LociTable, LociData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LociTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _isContinuousMeta = const VerificationMeta(
    'isContinuous',
  );
  @override
  late final GeneratedColumn<bool> isContinuous = GeneratedColumn<bool>(
    'is_continuous',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_continuous" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _dominantValueMeta = const VerificationMeta(
    'dominantValue',
  );
  @override
  late final GeneratedColumn<double> dominantValue = GeneratedColumn<double>(
    'dominant_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _recessiveValueMeta = const VerificationMeta(
    'recessiveValue',
  );
  @override
  late final GeneratedColumn<double> recessiveValue = GeneratedColumn<double>(
    'recessive_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _mutationRateDomMeta = const VerificationMeta(
    'mutationRateDom',
  );
  @override
  late final GeneratedColumn<double> mutationRateDom = GeneratedColumn<double>(
    'mutation_rate_dom',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _mutationRateRecMeta = const VerificationMeta(
    'mutationRateRec',
  );
  @override
  late final GeneratedColumn<double> mutationRateRec = GeneratedColumn<double>(
    'mutation_rate_rec',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _mutationRangeDomMeta = const VerificationMeta(
    'mutationRangeDom',
  );
  @override
  late final GeneratedColumn<double> mutationRangeDom = GeneratedColumn<double>(
    'mutation_range_dom',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _mutationRangeRecMeta = const VerificationMeta(
    'mutationRangeRec',
  );
  @override
  late final GeneratedColumn<double> mutationRangeRec = GeneratedColumn<double>(
    'mutation_range_rec',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _defaultExpressionMeta = const VerificationMeta(
    'defaultExpression',
  );
  @override
  late final GeneratedColumn<String> defaultExpression =
      GeneratedColumn<String>(
        'default_expression',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('0'),
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
    id,
    name,
    isContinuous,
    dominantValue,
    recessiveValue,
    mutationRateDom,
    mutationRateRec,
    mutationRangeDom,
    mutationRangeRec,
    defaultExpression,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'loci';
  @override
  VerificationContext validateIntegrity(
    Insertable<LociData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
    if (data.containsKey('is_continuous')) {
      context.handle(
        _isContinuousMeta,
        isContinuous.isAcceptableOrUnknown(
          data['is_continuous']!,
          _isContinuousMeta,
        ),
      );
    }
    if (data.containsKey('dominant_value')) {
      context.handle(
        _dominantValueMeta,
        dominantValue.isAcceptableOrUnknown(
          data['dominant_value']!,
          _dominantValueMeta,
        ),
      );
    }
    if (data.containsKey('recessive_value')) {
      context.handle(
        _recessiveValueMeta,
        recessiveValue.isAcceptableOrUnknown(
          data['recessive_value']!,
          _recessiveValueMeta,
        ),
      );
    }
    if (data.containsKey('mutation_rate_dom')) {
      context.handle(
        _mutationRateDomMeta,
        mutationRateDom.isAcceptableOrUnknown(
          data['mutation_rate_dom']!,
          _mutationRateDomMeta,
        ),
      );
    }
    if (data.containsKey('mutation_rate_rec')) {
      context.handle(
        _mutationRateRecMeta,
        mutationRateRec.isAcceptableOrUnknown(
          data['mutation_rate_rec']!,
          _mutationRateRecMeta,
        ),
      );
    }
    if (data.containsKey('mutation_range_dom')) {
      context.handle(
        _mutationRangeDomMeta,
        mutationRangeDom.isAcceptableOrUnknown(
          data['mutation_range_dom']!,
          _mutationRangeDomMeta,
        ),
      );
    }
    if (data.containsKey('mutation_range_rec')) {
      context.handle(
        _mutationRangeRecMeta,
        mutationRangeRec.isAcceptableOrUnknown(
          data['mutation_range_rec']!,
          _mutationRangeRecMeta,
        ),
      );
    }
    if (data.containsKey('default_expression')) {
      context.handle(
        _defaultExpressionMeta,
        defaultExpression.isAcceptableOrUnknown(
          data['default_expression']!,
          _defaultExpressionMeta,
        ),
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
  LociData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LociData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isContinuous: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_continuous'],
      )!,
      dominantValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dominant_value'],
      )!,
      recessiveValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}recessive_value'],
      )!,
      mutationRateDom: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}mutation_rate_dom'],
      )!,
      mutationRateRec: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}mutation_rate_rec'],
      )!,
      mutationRangeDom: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}mutation_range_dom'],
      )!,
      mutationRangeRec: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}mutation_range_rec'],
      )!,
      defaultExpression: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_expression'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $LociTable createAlias(String alias) {
    return $LociTable(attachedDatabase, alias);
  }
}

class LociData extends DataClass implements Insertable<LociData> {
  final int id;
  final String name;
  final bool isContinuous;
  final double dominantValue;
  final double recessiveValue;
  final double mutationRateDom;
  final double mutationRateRec;
  final double mutationRangeDom;
  final double mutationRangeRec;
  final String defaultExpression;
  final int sortOrder;
  const LociData({
    required this.id,
    required this.name,
    required this.isContinuous,
    required this.dominantValue,
    required this.recessiveValue,
    required this.mutationRateDom,
    required this.mutationRateRec,
    required this.mutationRangeDom,
    required this.mutationRangeRec,
    required this.defaultExpression,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['is_continuous'] = Variable<bool>(isContinuous);
    map['dominant_value'] = Variable<double>(dominantValue);
    map['recessive_value'] = Variable<double>(recessiveValue);
    map['mutation_rate_dom'] = Variable<double>(mutationRateDom);
    map['mutation_rate_rec'] = Variable<double>(mutationRateRec);
    map['mutation_range_dom'] = Variable<double>(mutationRangeDom);
    map['mutation_range_rec'] = Variable<double>(mutationRangeRec);
    map['default_expression'] = Variable<String>(defaultExpression);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  LociCompanion toCompanion(bool nullToAbsent) {
    return LociCompanion(
      id: Value(id),
      name: Value(name),
      isContinuous: Value(isContinuous),
      dominantValue: Value(dominantValue),
      recessiveValue: Value(recessiveValue),
      mutationRateDom: Value(mutationRateDom),
      mutationRateRec: Value(mutationRateRec),
      mutationRangeDom: Value(mutationRangeDom),
      mutationRangeRec: Value(mutationRangeRec),
      defaultExpression: Value(defaultExpression),
      sortOrder: Value(sortOrder),
    );
  }

  factory LociData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LociData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isContinuous: serializer.fromJson<bool>(json['isContinuous']),
      dominantValue: serializer.fromJson<double>(json['dominantValue']),
      recessiveValue: serializer.fromJson<double>(json['recessiveValue']),
      mutationRateDom: serializer.fromJson<double>(json['mutationRateDom']),
      mutationRateRec: serializer.fromJson<double>(json['mutationRateRec']),
      mutationRangeDom: serializer.fromJson<double>(json['mutationRangeDom']),
      mutationRangeRec: serializer.fromJson<double>(json['mutationRangeRec']),
      defaultExpression: serializer.fromJson<String>(json['defaultExpression']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'isContinuous': serializer.toJson<bool>(isContinuous),
      'dominantValue': serializer.toJson<double>(dominantValue),
      'recessiveValue': serializer.toJson<double>(recessiveValue),
      'mutationRateDom': serializer.toJson<double>(mutationRateDom),
      'mutationRateRec': serializer.toJson<double>(mutationRateRec),
      'mutationRangeDom': serializer.toJson<double>(mutationRangeDom),
      'mutationRangeRec': serializer.toJson<double>(mutationRangeRec),
      'defaultExpression': serializer.toJson<String>(defaultExpression),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  LociData copyWith({
    int? id,
    String? name,
    bool? isContinuous,
    double? dominantValue,
    double? recessiveValue,
    double? mutationRateDom,
    double? mutationRateRec,
    double? mutationRangeDom,
    double? mutationRangeRec,
    String? defaultExpression,
    int? sortOrder,
  }) => LociData(
    id: id ?? this.id,
    name: name ?? this.name,
    isContinuous: isContinuous ?? this.isContinuous,
    dominantValue: dominantValue ?? this.dominantValue,
    recessiveValue: recessiveValue ?? this.recessiveValue,
    mutationRateDom: mutationRateDom ?? this.mutationRateDom,
    mutationRateRec: mutationRateRec ?? this.mutationRateRec,
    mutationRangeDom: mutationRangeDom ?? this.mutationRangeDom,
    mutationRangeRec: mutationRangeRec ?? this.mutationRangeRec,
    defaultExpression: defaultExpression ?? this.defaultExpression,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  LociData copyWithCompanion(LociCompanion data) {
    return LociData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isContinuous: data.isContinuous.present
          ? data.isContinuous.value
          : this.isContinuous,
      dominantValue: data.dominantValue.present
          ? data.dominantValue.value
          : this.dominantValue,
      recessiveValue: data.recessiveValue.present
          ? data.recessiveValue.value
          : this.recessiveValue,
      mutationRateDom: data.mutationRateDom.present
          ? data.mutationRateDom.value
          : this.mutationRateDom,
      mutationRateRec: data.mutationRateRec.present
          ? data.mutationRateRec.value
          : this.mutationRateRec,
      mutationRangeDom: data.mutationRangeDom.present
          ? data.mutationRangeDom.value
          : this.mutationRangeDom,
      mutationRangeRec: data.mutationRangeRec.present
          ? data.mutationRangeRec.value
          : this.mutationRangeRec,
      defaultExpression: data.defaultExpression.present
          ? data.defaultExpression.value
          : this.defaultExpression,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LociData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isContinuous: $isContinuous, ')
          ..write('dominantValue: $dominantValue, ')
          ..write('recessiveValue: $recessiveValue, ')
          ..write('mutationRateDom: $mutationRateDom, ')
          ..write('mutationRateRec: $mutationRateRec, ')
          ..write('mutationRangeDom: $mutationRangeDom, ')
          ..write('mutationRangeRec: $mutationRangeRec, ')
          ..write('defaultExpression: $defaultExpression, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    isContinuous,
    dominantValue,
    recessiveValue,
    mutationRateDom,
    mutationRateRec,
    mutationRangeDom,
    mutationRangeRec,
    defaultExpression,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LociData &&
          other.id == this.id &&
          other.name == this.name &&
          other.isContinuous == this.isContinuous &&
          other.dominantValue == this.dominantValue &&
          other.recessiveValue == this.recessiveValue &&
          other.mutationRateDom == this.mutationRateDom &&
          other.mutationRateRec == this.mutationRateRec &&
          other.mutationRangeDom == this.mutationRangeDom &&
          other.mutationRangeRec == this.mutationRangeRec &&
          other.defaultExpression == this.defaultExpression &&
          other.sortOrder == this.sortOrder);
}

class LociCompanion extends UpdateCompanion<LociData> {
  final Value<int> id;
  final Value<String> name;
  final Value<bool> isContinuous;
  final Value<double> dominantValue;
  final Value<double> recessiveValue;
  final Value<double> mutationRateDom;
  final Value<double> mutationRateRec;
  final Value<double> mutationRangeDom;
  final Value<double> mutationRangeRec;
  final Value<String> defaultExpression;
  final Value<int> sortOrder;
  const LociCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isContinuous = const Value.absent(),
    this.dominantValue = const Value.absent(),
    this.recessiveValue = const Value.absent(),
    this.mutationRateDom = const Value.absent(),
    this.mutationRateRec = const Value.absent(),
    this.mutationRangeDom = const Value.absent(),
    this.mutationRangeRec = const Value.absent(),
    this.defaultExpression = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  LociCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.isContinuous = const Value.absent(),
    this.dominantValue = const Value.absent(),
    this.recessiveValue = const Value.absent(),
    this.mutationRateDom = const Value.absent(),
    this.mutationRateRec = const Value.absent(),
    this.mutationRangeDom = const Value.absent(),
    this.mutationRangeRec = const Value.absent(),
    this.defaultExpression = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : name = Value(name);
  static Insertable<LociData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<bool>? isContinuous,
    Expression<double>? dominantValue,
    Expression<double>? recessiveValue,
    Expression<double>? mutationRateDom,
    Expression<double>? mutationRateRec,
    Expression<double>? mutationRangeDom,
    Expression<double>? mutationRangeRec,
    Expression<String>? defaultExpression,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isContinuous != null) 'is_continuous': isContinuous,
      if (dominantValue != null) 'dominant_value': dominantValue,
      if (recessiveValue != null) 'recessive_value': recessiveValue,
      if (mutationRateDom != null) 'mutation_rate_dom': mutationRateDom,
      if (mutationRateRec != null) 'mutation_rate_rec': mutationRateRec,
      if (mutationRangeDom != null) 'mutation_range_dom': mutationRangeDom,
      if (mutationRangeRec != null) 'mutation_range_rec': mutationRangeRec,
      if (defaultExpression != null) 'default_expression': defaultExpression,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  LociCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<bool>? isContinuous,
    Value<double>? dominantValue,
    Value<double>? recessiveValue,
    Value<double>? mutationRateDom,
    Value<double>? mutationRateRec,
    Value<double>? mutationRangeDom,
    Value<double>? mutationRangeRec,
    Value<String>? defaultExpression,
    Value<int>? sortOrder,
  }) {
    return LociCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isContinuous: isContinuous ?? this.isContinuous,
      dominantValue: dominantValue ?? this.dominantValue,
      recessiveValue: recessiveValue ?? this.recessiveValue,
      mutationRateDom: mutationRateDom ?? this.mutationRateDom,
      mutationRateRec: mutationRateRec ?? this.mutationRateRec,
      mutationRangeDom: mutationRangeDom ?? this.mutationRangeDom,
      mutationRangeRec: mutationRangeRec ?? this.mutationRangeRec,
      defaultExpression: defaultExpression ?? this.defaultExpression,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isContinuous.present) {
      map['is_continuous'] = Variable<bool>(isContinuous.value);
    }
    if (dominantValue.present) {
      map['dominant_value'] = Variable<double>(dominantValue.value);
    }
    if (recessiveValue.present) {
      map['recessive_value'] = Variable<double>(recessiveValue.value);
    }
    if (mutationRateDom.present) {
      map['mutation_rate_dom'] = Variable<double>(mutationRateDom.value);
    }
    if (mutationRateRec.present) {
      map['mutation_rate_rec'] = Variable<double>(mutationRateRec.value);
    }
    if (mutationRangeDom.present) {
      map['mutation_range_dom'] = Variable<double>(mutationRangeDom.value);
    }
    if (mutationRangeRec.present) {
      map['mutation_range_rec'] = Variable<double>(mutationRangeRec.value);
    }
    if (defaultExpression.present) {
      map['default_expression'] = Variable<String>(defaultExpression.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LociCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isContinuous: $isContinuous, ')
          ..write('dominantValue: $dominantValue, ')
          ..write('recessiveValue: $recessiveValue, ')
          ..write('mutationRateDom: $mutationRateDom, ')
          ..write('mutationRateRec: $mutationRateRec, ')
          ..write('mutationRangeDom: $mutationRangeDom, ')
          ..write('mutationRangeRec: $mutationRangeRec, ')
          ..write('defaultExpression: $defaultExpression, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $StagesTable extends Stages with TableInfo<$StagesTable, Stage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StagesTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
  static const VerificationMeta _cyclesFormulaMeta = const VerificationMeta(
    'cyclesFormula',
  );
  @override
  late final GeneratedColumn<String> cyclesFormula = GeneratedColumn<String>(
    'cycles_formula',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('100'),
  );
  static const VerificationMeta _condition1FormulaMeta = const VerificationMeta(
    'condition1Formula',
  );
  @override
  late final GeneratedColumn<String> condition1Formula =
      GeneratedColumn<String>(
        'condition1_formula',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('0'),
      );
  static const VerificationMeta _condition1OpMeta = const VerificationMeta(
    'condition1Op',
  );
  @override
  late final GeneratedColumn<String> condition1Op = GeneratedColumn<String>(
    'condition1_op',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('>'),
  );
  static const VerificationMeta _condition1ValueMeta = const VerificationMeta(
    'condition1Value',
  );
  @override
  late final GeneratedColumn<double> condition1Value = GeneratedColumn<double>(
    'condition1_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _condition2FormulaMeta = const VerificationMeta(
    'condition2Formula',
  );
  @override
  late final GeneratedColumn<String> condition2Formula =
      GeneratedColumn<String>(
        'condition2_formula',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('0'),
      );
  static const VerificationMeta _condition2OpMeta = const VerificationMeta(
    'condition2Op',
  );
  @override
  late final GeneratedColumn<String> condition2Op = GeneratedColumn<String>(
    'condition2_op',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('>'),
  );
  static const VerificationMeta _condition2ValueMeta = const VerificationMeta(
    'condition2Value',
  );
  @override
  late final GeneratedColumn<double> condition2Value = GeneratedColumn<double>(
    'condition2_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _logicCyclesReqsMeta = const VerificationMeta(
    'logicCyclesReqs',
  );
  @override
  late final GeneratedColumn<String> logicCyclesReqs = GeneratedColumn<String>(
    'logic_cycles_reqs',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('AND'),
  );
  static const VerificationMeta _logicReqsCondsMeta = const VerificationMeta(
    'logicReqsConds',
  );
  @override
  late final GeneratedColumn<String> logicReqsConds = GeneratedColumn<String>(
    'logic_reqs_conds',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('AND'),
  );
  static const VerificationMeta _logicCond1Cond2Meta = const VerificationMeta(
    'logicCond1Cond2',
  );
  @override
  late final GeneratedColumn<String> logicCond1Cond2 = GeneratedColumn<String>(
    'logic_cond1_cond2',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('AND'),
  );
  static const VerificationMeta _linkedPrototypeIdMeta = const VerificationMeta(
    'linkedPrototypeId',
  );
  @override
  late final GeneratedColumn<int> linkedPrototypeId = GeneratedColumn<int>(
    'linked_prototype_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    sortOrder,
    cyclesFormula,
    condition1Formula,
    condition1Op,
    condition1Value,
    condition2Formula,
    condition2Op,
    condition2Value,
    logicCyclesReqs,
    logicReqsConds,
    logicCond1Cond2,
    linkedPrototypeId,
    color,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stages';
  @override
  VerificationContext validateIntegrity(
    Insertable<Stage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('cycles_formula')) {
      context.handle(
        _cyclesFormulaMeta,
        cyclesFormula.isAcceptableOrUnknown(
          data['cycles_formula']!,
          _cyclesFormulaMeta,
        ),
      );
    }
    if (data.containsKey('condition1_formula')) {
      context.handle(
        _condition1FormulaMeta,
        condition1Formula.isAcceptableOrUnknown(
          data['condition1_formula']!,
          _condition1FormulaMeta,
        ),
      );
    }
    if (data.containsKey('condition1_op')) {
      context.handle(
        _condition1OpMeta,
        condition1Op.isAcceptableOrUnknown(
          data['condition1_op']!,
          _condition1OpMeta,
        ),
      );
    }
    if (data.containsKey('condition1_value')) {
      context.handle(
        _condition1ValueMeta,
        condition1Value.isAcceptableOrUnknown(
          data['condition1_value']!,
          _condition1ValueMeta,
        ),
      );
    }
    if (data.containsKey('condition2_formula')) {
      context.handle(
        _condition2FormulaMeta,
        condition2Formula.isAcceptableOrUnknown(
          data['condition2_formula']!,
          _condition2FormulaMeta,
        ),
      );
    }
    if (data.containsKey('condition2_op')) {
      context.handle(
        _condition2OpMeta,
        condition2Op.isAcceptableOrUnknown(
          data['condition2_op']!,
          _condition2OpMeta,
        ),
      );
    }
    if (data.containsKey('condition2_value')) {
      context.handle(
        _condition2ValueMeta,
        condition2Value.isAcceptableOrUnknown(
          data['condition2_value']!,
          _condition2ValueMeta,
        ),
      );
    }
    if (data.containsKey('logic_cycles_reqs')) {
      context.handle(
        _logicCyclesReqsMeta,
        logicCyclesReqs.isAcceptableOrUnknown(
          data['logic_cycles_reqs']!,
          _logicCyclesReqsMeta,
        ),
      );
    }
    if (data.containsKey('logic_reqs_conds')) {
      context.handle(
        _logicReqsCondsMeta,
        logicReqsConds.isAcceptableOrUnknown(
          data['logic_reqs_conds']!,
          _logicReqsCondsMeta,
        ),
      );
    }
    if (data.containsKey('logic_cond1_cond2')) {
      context.handle(
        _logicCond1Cond2Meta,
        logicCond1Cond2.isAcceptableOrUnknown(
          data['logic_cond1_cond2']!,
          _logicCond1Cond2Meta,
        ),
      );
    }
    if (data.containsKey('linked_prototype_id')) {
      context.handle(
        _linkedPrototypeIdMeta,
        linkedPrototypeId.isAcceptableOrUnknown(
          data['linked_prototype_id']!,
          _linkedPrototypeIdMeta,
        ),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Stage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Stage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      cyclesFormula: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cycles_formula'],
      )!,
      condition1Formula: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}condition1_formula'],
      )!,
      condition1Op: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}condition1_op'],
      )!,
      condition1Value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}condition1_value'],
      )!,
      condition2Formula: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}condition2_formula'],
      )!,
      condition2Op: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}condition2_op'],
      )!,
      condition2Value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}condition2_value'],
      )!,
      logicCyclesReqs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logic_cycles_reqs'],
      )!,
      logicReqsConds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logic_reqs_conds'],
      )!,
      logicCond1Cond2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logic_cond1_cond2'],
      )!,
      linkedPrototypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}linked_prototype_id'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
    );
  }

  @override
  $StagesTable createAlias(String alias) {
    return $StagesTable(attachedDatabase, alias);
  }
}

class Stage extends DataClass implements Insertable<Stage> {
  final int id;
  final String name;
  final int sortOrder;
  final String cyclesFormula;
  final String condition1Formula;
  final String condition1Op;
  final double condition1Value;
  final String condition2Formula;
  final String condition2Op;
  final double condition2Value;
  final String logicCyclesReqs;
  final String logicReqsConds;
  final String logicCond1Cond2;
  final int? linkedPrototypeId;
  final int color;
  const Stage({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.cyclesFormula,
    required this.condition1Formula,
    required this.condition1Op,
    required this.condition1Value,
    required this.condition2Formula,
    required this.condition2Op,
    required this.condition2Value,
    required this.logicCyclesReqs,
    required this.logicReqsConds,
    required this.logicCond1Cond2,
    this.linkedPrototypeId,
    required this.color,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    map['cycles_formula'] = Variable<String>(cyclesFormula);
    map['condition1_formula'] = Variable<String>(condition1Formula);
    map['condition1_op'] = Variable<String>(condition1Op);
    map['condition1_value'] = Variable<double>(condition1Value);
    map['condition2_formula'] = Variable<String>(condition2Formula);
    map['condition2_op'] = Variable<String>(condition2Op);
    map['condition2_value'] = Variable<double>(condition2Value);
    map['logic_cycles_reqs'] = Variable<String>(logicCyclesReqs);
    map['logic_reqs_conds'] = Variable<String>(logicReqsConds);
    map['logic_cond1_cond2'] = Variable<String>(logicCond1Cond2);
    if (!nullToAbsent || linkedPrototypeId != null) {
      map['linked_prototype_id'] = Variable<int>(linkedPrototypeId);
    }
    map['color'] = Variable<int>(color);
    return map;
  }

  StagesCompanion toCompanion(bool nullToAbsent) {
    return StagesCompanion(
      id: Value(id),
      name: Value(name),
      sortOrder: Value(sortOrder),
      cyclesFormula: Value(cyclesFormula),
      condition1Formula: Value(condition1Formula),
      condition1Op: Value(condition1Op),
      condition1Value: Value(condition1Value),
      condition2Formula: Value(condition2Formula),
      condition2Op: Value(condition2Op),
      condition2Value: Value(condition2Value),
      logicCyclesReqs: Value(logicCyclesReqs),
      logicReqsConds: Value(logicReqsConds),
      logicCond1Cond2: Value(logicCond1Cond2),
      linkedPrototypeId: linkedPrototypeId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedPrototypeId),
      color: Value(color),
    );
  }

  factory Stage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Stage(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      cyclesFormula: serializer.fromJson<String>(json['cyclesFormula']),
      condition1Formula: serializer.fromJson<String>(json['condition1Formula']),
      condition1Op: serializer.fromJson<String>(json['condition1Op']),
      condition1Value: serializer.fromJson<double>(json['condition1Value']),
      condition2Formula: serializer.fromJson<String>(json['condition2Formula']),
      condition2Op: serializer.fromJson<String>(json['condition2Op']),
      condition2Value: serializer.fromJson<double>(json['condition2Value']),
      logicCyclesReqs: serializer.fromJson<String>(json['logicCyclesReqs']),
      logicReqsConds: serializer.fromJson<String>(json['logicReqsConds']),
      logicCond1Cond2: serializer.fromJson<String>(json['logicCond1Cond2']),
      linkedPrototypeId: serializer.fromJson<int?>(json['linkedPrototypeId']),
      color: serializer.fromJson<int>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'cyclesFormula': serializer.toJson<String>(cyclesFormula),
      'condition1Formula': serializer.toJson<String>(condition1Formula),
      'condition1Op': serializer.toJson<String>(condition1Op),
      'condition1Value': serializer.toJson<double>(condition1Value),
      'condition2Formula': serializer.toJson<String>(condition2Formula),
      'condition2Op': serializer.toJson<String>(condition2Op),
      'condition2Value': serializer.toJson<double>(condition2Value),
      'logicCyclesReqs': serializer.toJson<String>(logicCyclesReqs),
      'logicReqsConds': serializer.toJson<String>(logicReqsConds),
      'logicCond1Cond2': serializer.toJson<String>(logicCond1Cond2),
      'linkedPrototypeId': serializer.toJson<int?>(linkedPrototypeId),
      'color': serializer.toJson<int>(color),
    };
  }

  Stage copyWith({
    int? id,
    String? name,
    int? sortOrder,
    String? cyclesFormula,
    String? condition1Formula,
    String? condition1Op,
    double? condition1Value,
    String? condition2Formula,
    String? condition2Op,
    double? condition2Value,
    String? logicCyclesReqs,
    String? logicReqsConds,
    String? logicCond1Cond2,
    Value<int?> linkedPrototypeId = const Value.absent(),
    int? color,
  }) => Stage(
    id: id ?? this.id,
    name: name ?? this.name,
    sortOrder: sortOrder ?? this.sortOrder,
    cyclesFormula: cyclesFormula ?? this.cyclesFormula,
    condition1Formula: condition1Formula ?? this.condition1Formula,
    condition1Op: condition1Op ?? this.condition1Op,
    condition1Value: condition1Value ?? this.condition1Value,
    condition2Formula: condition2Formula ?? this.condition2Formula,
    condition2Op: condition2Op ?? this.condition2Op,
    condition2Value: condition2Value ?? this.condition2Value,
    logicCyclesReqs: logicCyclesReqs ?? this.logicCyclesReqs,
    logicReqsConds: logicReqsConds ?? this.logicReqsConds,
    logicCond1Cond2: logicCond1Cond2 ?? this.logicCond1Cond2,
    linkedPrototypeId: linkedPrototypeId.present
        ? linkedPrototypeId.value
        : this.linkedPrototypeId,
    color: color ?? this.color,
  );
  Stage copyWithCompanion(StagesCompanion data) {
    return Stage(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      cyclesFormula: data.cyclesFormula.present
          ? data.cyclesFormula.value
          : this.cyclesFormula,
      condition1Formula: data.condition1Formula.present
          ? data.condition1Formula.value
          : this.condition1Formula,
      condition1Op: data.condition1Op.present
          ? data.condition1Op.value
          : this.condition1Op,
      condition1Value: data.condition1Value.present
          ? data.condition1Value.value
          : this.condition1Value,
      condition2Formula: data.condition2Formula.present
          ? data.condition2Formula.value
          : this.condition2Formula,
      condition2Op: data.condition2Op.present
          ? data.condition2Op.value
          : this.condition2Op,
      condition2Value: data.condition2Value.present
          ? data.condition2Value.value
          : this.condition2Value,
      logicCyclesReqs: data.logicCyclesReqs.present
          ? data.logicCyclesReqs.value
          : this.logicCyclesReqs,
      logicReqsConds: data.logicReqsConds.present
          ? data.logicReqsConds.value
          : this.logicReqsConds,
      logicCond1Cond2: data.logicCond1Cond2.present
          ? data.logicCond1Cond2.value
          : this.logicCond1Cond2,
      linkedPrototypeId: data.linkedPrototypeId.present
          ? data.linkedPrototypeId.value
          : this.linkedPrototypeId,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Stage(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('cyclesFormula: $cyclesFormula, ')
          ..write('condition1Formula: $condition1Formula, ')
          ..write('condition1Op: $condition1Op, ')
          ..write('condition1Value: $condition1Value, ')
          ..write('condition2Formula: $condition2Formula, ')
          ..write('condition2Op: $condition2Op, ')
          ..write('condition2Value: $condition2Value, ')
          ..write('logicCyclesReqs: $logicCyclesReqs, ')
          ..write('logicReqsConds: $logicReqsConds, ')
          ..write('logicCond1Cond2: $logicCond1Cond2, ')
          ..write('linkedPrototypeId: $linkedPrototypeId, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    sortOrder,
    cyclesFormula,
    condition1Formula,
    condition1Op,
    condition1Value,
    condition2Formula,
    condition2Op,
    condition2Value,
    logicCyclesReqs,
    logicReqsConds,
    logicCond1Cond2,
    linkedPrototypeId,
    color,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Stage &&
          other.id == this.id &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder &&
          other.cyclesFormula == this.cyclesFormula &&
          other.condition1Formula == this.condition1Formula &&
          other.condition1Op == this.condition1Op &&
          other.condition1Value == this.condition1Value &&
          other.condition2Formula == this.condition2Formula &&
          other.condition2Op == this.condition2Op &&
          other.condition2Value == this.condition2Value &&
          other.logicCyclesReqs == this.logicCyclesReqs &&
          other.logicReqsConds == this.logicReqsConds &&
          other.logicCond1Cond2 == this.logicCond1Cond2 &&
          other.linkedPrototypeId == this.linkedPrototypeId &&
          other.color == this.color);
}

class StagesCompanion extends UpdateCompanion<Stage> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<String> cyclesFormula;
  final Value<String> condition1Formula;
  final Value<String> condition1Op;
  final Value<double> condition1Value;
  final Value<String> condition2Formula;
  final Value<String> condition2Op;
  final Value<double> condition2Value;
  final Value<String> logicCyclesReqs;
  final Value<String> logicReqsConds;
  final Value<String> logicCond1Cond2;
  final Value<int?> linkedPrototypeId;
  final Value<int> color;
  const StagesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.cyclesFormula = const Value.absent(),
    this.condition1Formula = const Value.absent(),
    this.condition1Op = const Value.absent(),
    this.condition1Value = const Value.absent(),
    this.condition2Formula = const Value.absent(),
    this.condition2Op = const Value.absent(),
    this.condition2Value = const Value.absent(),
    this.logicCyclesReqs = const Value.absent(),
    this.logicReqsConds = const Value.absent(),
    this.logicCond1Cond2 = const Value.absent(),
    this.linkedPrototypeId = const Value.absent(),
    this.color = const Value.absent(),
  });
  StagesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.sortOrder = const Value.absent(),
    this.cyclesFormula = const Value.absent(),
    this.condition1Formula = const Value.absent(),
    this.condition1Op = const Value.absent(),
    this.condition1Value = const Value.absent(),
    this.condition2Formula = const Value.absent(),
    this.condition2Op = const Value.absent(),
    this.condition2Value = const Value.absent(),
    this.logicCyclesReqs = const Value.absent(),
    this.logicReqsConds = const Value.absent(),
    this.logicCond1Cond2 = const Value.absent(),
    this.linkedPrototypeId = const Value.absent(),
    this.color = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Stage> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<String>? cyclesFormula,
    Expression<String>? condition1Formula,
    Expression<String>? condition1Op,
    Expression<double>? condition1Value,
    Expression<String>? condition2Formula,
    Expression<String>? condition2Op,
    Expression<double>? condition2Value,
    Expression<String>? logicCyclesReqs,
    Expression<String>? logicReqsConds,
    Expression<String>? logicCond1Cond2,
    Expression<int>? linkedPrototypeId,
    Expression<int>? color,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (cyclesFormula != null) 'cycles_formula': cyclesFormula,
      if (condition1Formula != null) 'condition1_formula': condition1Formula,
      if (condition1Op != null) 'condition1_op': condition1Op,
      if (condition1Value != null) 'condition1_value': condition1Value,
      if (condition2Formula != null) 'condition2_formula': condition2Formula,
      if (condition2Op != null) 'condition2_op': condition2Op,
      if (condition2Value != null) 'condition2_value': condition2Value,
      if (logicCyclesReqs != null) 'logic_cycles_reqs': logicCyclesReqs,
      if (logicReqsConds != null) 'logic_reqs_conds': logicReqsConds,
      if (logicCond1Cond2 != null) 'logic_cond1_cond2': logicCond1Cond2,
      if (linkedPrototypeId != null) 'linked_prototype_id': linkedPrototypeId,
      if (color != null) 'color': color,
    });
  }

  StagesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? sortOrder,
    Value<String>? cyclesFormula,
    Value<String>? condition1Formula,
    Value<String>? condition1Op,
    Value<double>? condition1Value,
    Value<String>? condition2Formula,
    Value<String>? condition2Op,
    Value<double>? condition2Value,
    Value<String>? logicCyclesReqs,
    Value<String>? logicReqsConds,
    Value<String>? logicCond1Cond2,
    Value<int?>? linkedPrototypeId,
    Value<int>? color,
  }) {
    return StagesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      cyclesFormula: cyclesFormula ?? this.cyclesFormula,
      condition1Formula: condition1Formula ?? this.condition1Formula,
      condition1Op: condition1Op ?? this.condition1Op,
      condition1Value: condition1Value ?? this.condition1Value,
      condition2Formula: condition2Formula ?? this.condition2Formula,
      condition2Op: condition2Op ?? this.condition2Op,
      condition2Value: condition2Value ?? this.condition2Value,
      logicCyclesReqs: logicCyclesReqs ?? this.logicCyclesReqs,
      logicReqsConds: logicReqsConds ?? this.logicReqsConds,
      logicCond1Cond2: logicCond1Cond2 ?? this.logicCond1Cond2,
      linkedPrototypeId: linkedPrototypeId ?? this.linkedPrototypeId,
      color: color ?? this.color,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (cyclesFormula.present) {
      map['cycles_formula'] = Variable<String>(cyclesFormula.value);
    }
    if (condition1Formula.present) {
      map['condition1_formula'] = Variable<String>(condition1Formula.value);
    }
    if (condition1Op.present) {
      map['condition1_op'] = Variable<String>(condition1Op.value);
    }
    if (condition1Value.present) {
      map['condition1_value'] = Variable<double>(condition1Value.value);
    }
    if (condition2Formula.present) {
      map['condition2_formula'] = Variable<String>(condition2Formula.value);
    }
    if (condition2Op.present) {
      map['condition2_op'] = Variable<String>(condition2Op.value);
    }
    if (condition2Value.present) {
      map['condition2_value'] = Variable<double>(condition2Value.value);
    }
    if (logicCyclesReqs.present) {
      map['logic_cycles_reqs'] = Variable<String>(logicCyclesReqs.value);
    }
    if (logicReqsConds.present) {
      map['logic_reqs_conds'] = Variable<String>(logicReqsConds.value);
    }
    if (logicCond1Cond2.present) {
      map['logic_cond1_cond2'] = Variable<String>(logicCond1Cond2.value);
    }
    if (linkedPrototypeId.present) {
      map['linked_prototype_id'] = Variable<int>(linkedPrototypeId.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StagesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('cyclesFormula: $cyclesFormula, ')
          ..write('condition1Formula: $condition1Formula, ')
          ..write('condition1Op: $condition1Op, ')
          ..write('condition1Value: $condition1Value, ')
          ..write('condition2Formula: $condition2Formula, ')
          ..write('condition2Op: $condition2Op, ')
          ..write('condition2Value: $condition2Value, ')
          ..write('logicCyclesReqs: $logicCyclesReqs, ')
          ..write('logicReqsConds: $logicReqsConds, ')
          ..write('logicCond1Cond2: $logicCond1Cond2, ')
          ..write('linkedPrototypeId: $linkedPrototypeId, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }
}

class $PrototypesTable extends Prototypes
    with TableInfo<$PrototypesTable, Prototype> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrototypesTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
    'sex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _longevityFormulaMeta = const VerificationMeta(
    'longevityFormula',
  );
  @override
  late final GeneratedColumn<String> longevityFormula = GeneratedColumn<String>(
    'longevity_formula',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('1000'),
  );
  static const VerificationMeta _refractoryCombatFormulaMeta =
      const VerificationMeta('refractoryCombatFormula');
  @override
  late final GeneratedColumn<String> refractoryCombatFormula =
      GeneratedColumn<String>(
        'refractory_combat_formula',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('10'),
      );
  static const VerificationMeta _refractoryCourtshipFormulaMeta =
      const VerificationMeta('refractoryCourtshipFormula');
  @override
  late final GeneratedColumn<String> refractoryCourtshipFormula =
      GeneratedColumn<String>(
        'refractory_courtship_formula',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('10'),
      );
  static const VerificationMeta _sexRatioMalesFormulaMeta =
      const VerificationMeta('sexRatioMalesFormula');
  @override
  late final GeneratedColumn<String> sexRatioMalesFormula =
      GeneratedColumn<String>(
        'sex_ratio_males_formula',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('50'),
      );
  static const VerificationMeta _sexRatioFemalesFormulaMeta =
      const VerificationMeta('sexRatioFemalesFormula');
  @override
  late final GeneratedColumn<String> sexRatioFemalesFormula =
      GeneratedColumn<String>(
        'sex_ratio_females_formula',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('50'),
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
    id,
    name,
    sex,
    color,
    longevityFormula,
    refractoryCombatFormula,
    refractoryCourtshipFormula,
    sexRatioMalesFormula,
    sexRatioFemalesFormula,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prototypes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Prototype> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
    if (data.containsKey('sex')) {
      context.handle(
        _sexMeta,
        sex.isAcceptableOrUnknown(data['sex']!, _sexMeta),
      );
    } else if (isInserting) {
      context.missing(_sexMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('longevity_formula')) {
      context.handle(
        _longevityFormulaMeta,
        longevityFormula.isAcceptableOrUnknown(
          data['longevity_formula']!,
          _longevityFormulaMeta,
        ),
      );
    }
    if (data.containsKey('refractory_combat_formula')) {
      context.handle(
        _refractoryCombatFormulaMeta,
        refractoryCombatFormula.isAcceptableOrUnknown(
          data['refractory_combat_formula']!,
          _refractoryCombatFormulaMeta,
        ),
      );
    }
    if (data.containsKey('refractory_courtship_formula')) {
      context.handle(
        _refractoryCourtshipFormulaMeta,
        refractoryCourtshipFormula.isAcceptableOrUnknown(
          data['refractory_courtship_formula']!,
          _refractoryCourtshipFormulaMeta,
        ),
      );
    }
    if (data.containsKey('sex_ratio_males_formula')) {
      context.handle(
        _sexRatioMalesFormulaMeta,
        sexRatioMalesFormula.isAcceptableOrUnknown(
          data['sex_ratio_males_formula']!,
          _sexRatioMalesFormulaMeta,
        ),
      );
    }
    if (data.containsKey('sex_ratio_females_formula')) {
      context.handle(
        _sexRatioFemalesFormulaMeta,
        sexRatioFemalesFormula.isAcceptableOrUnknown(
          data['sex_ratio_females_formula']!,
          _sexRatioFemalesFormulaMeta,
        ),
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
  Prototype map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Prototype(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sex'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      longevityFormula: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}longevity_formula'],
      )!,
      refractoryCombatFormula: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}refractory_combat_formula'],
      )!,
      refractoryCourtshipFormula: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}refractory_courtship_formula'],
      )!,
      sexRatioMalesFormula: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sex_ratio_males_formula'],
      )!,
      sexRatioFemalesFormula: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sex_ratio_females_formula'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $PrototypesTable createAlias(String alias) {
    return $PrototypesTable(attachedDatabase, alias);
  }
}

class Prototype extends DataClass implements Insertable<Prototype> {
  final int id;
  final String name;
  final String sex;
  final int color;
  final String longevityFormula;
  final String refractoryCombatFormula;
  final String refractoryCourtshipFormula;
  final String sexRatioMalesFormula;
  final String sexRatioFemalesFormula;
  final int sortOrder;
  const Prototype({
    required this.id,
    required this.name,
    required this.sex,
    required this.color,
    required this.longevityFormula,
    required this.refractoryCombatFormula,
    required this.refractoryCourtshipFormula,
    required this.sexRatioMalesFormula,
    required this.sexRatioFemalesFormula,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['sex'] = Variable<String>(sex);
    map['color'] = Variable<int>(color);
    map['longevity_formula'] = Variable<String>(longevityFormula);
    map['refractory_combat_formula'] = Variable<String>(
      refractoryCombatFormula,
    );
    map['refractory_courtship_formula'] = Variable<String>(
      refractoryCourtshipFormula,
    );
    map['sex_ratio_males_formula'] = Variable<String>(sexRatioMalesFormula);
    map['sex_ratio_females_formula'] = Variable<String>(sexRatioFemalesFormula);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  PrototypesCompanion toCompanion(bool nullToAbsent) {
    return PrototypesCompanion(
      id: Value(id),
      name: Value(name),
      sex: Value(sex),
      color: Value(color),
      longevityFormula: Value(longevityFormula),
      refractoryCombatFormula: Value(refractoryCombatFormula),
      refractoryCourtshipFormula: Value(refractoryCourtshipFormula),
      sexRatioMalesFormula: Value(sexRatioMalesFormula),
      sexRatioFemalesFormula: Value(sexRatioFemalesFormula),
      sortOrder: Value(sortOrder),
    );
  }

  factory Prototype.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Prototype(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sex: serializer.fromJson<String>(json['sex']),
      color: serializer.fromJson<int>(json['color']),
      longevityFormula: serializer.fromJson<String>(json['longevityFormula']),
      refractoryCombatFormula: serializer.fromJson<String>(
        json['refractoryCombatFormula'],
      ),
      refractoryCourtshipFormula: serializer.fromJson<String>(
        json['refractoryCourtshipFormula'],
      ),
      sexRatioMalesFormula: serializer.fromJson<String>(
        json['sexRatioMalesFormula'],
      ),
      sexRatioFemalesFormula: serializer.fromJson<String>(
        json['sexRatioFemalesFormula'],
      ),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'sex': serializer.toJson<String>(sex),
      'color': serializer.toJson<int>(color),
      'longevityFormula': serializer.toJson<String>(longevityFormula),
      'refractoryCombatFormula': serializer.toJson<String>(
        refractoryCombatFormula,
      ),
      'refractoryCourtshipFormula': serializer.toJson<String>(
        refractoryCourtshipFormula,
      ),
      'sexRatioMalesFormula': serializer.toJson<String>(sexRatioMalesFormula),
      'sexRatioFemalesFormula': serializer.toJson<String>(
        sexRatioFemalesFormula,
      ),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Prototype copyWith({
    int? id,
    String? name,
    String? sex,
    int? color,
    String? longevityFormula,
    String? refractoryCombatFormula,
    String? refractoryCourtshipFormula,
    String? sexRatioMalesFormula,
    String? sexRatioFemalesFormula,
    int? sortOrder,
  }) => Prototype(
    id: id ?? this.id,
    name: name ?? this.name,
    sex: sex ?? this.sex,
    color: color ?? this.color,
    longevityFormula: longevityFormula ?? this.longevityFormula,
    refractoryCombatFormula:
        refractoryCombatFormula ?? this.refractoryCombatFormula,
    refractoryCourtshipFormula:
        refractoryCourtshipFormula ?? this.refractoryCourtshipFormula,
    sexRatioMalesFormula: sexRatioMalesFormula ?? this.sexRatioMalesFormula,
    sexRatioFemalesFormula:
        sexRatioFemalesFormula ?? this.sexRatioFemalesFormula,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Prototype copyWithCompanion(PrototypesCompanion data) {
    return Prototype(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sex: data.sex.present ? data.sex.value : this.sex,
      color: data.color.present ? data.color.value : this.color,
      longevityFormula: data.longevityFormula.present
          ? data.longevityFormula.value
          : this.longevityFormula,
      refractoryCombatFormula: data.refractoryCombatFormula.present
          ? data.refractoryCombatFormula.value
          : this.refractoryCombatFormula,
      refractoryCourtshipFormula: data.refractoryCourtshipFormula.present
          ? data.refractoryCourtshipFormula.value
          : this.refractoryCourtshipFormula,
      sexRatioMalesFormula: data.sexRatioMalesFormula.present
          ? data.sexRatioMalesFormula.value
          : this.sexRatioMalesFormula,
      sexRatioFemalesFormula: data.sexRatioFemalesFormula.present
          ? data.sexRatioFemalesFormula.value
          : this.sexRatioFemalesFormula,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Prototype(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sex: $sex, ')
          ..write('color: $color, ')
          ..write('longevityFormula: $longevityFormula, ')
          ..write('refractoryCombatFormula: $refractoryCombatFormula, ')
          ..write('refractoryCourtshipFormula: $refractoryCourtshipFormula, ')
          ..write('sexRatioMalesFormula: $sexRatioMalesFormula, ')
          ..write('sexRatioFemalesFormula: $sexRatioFemalesFormula, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    sex,
    color,
    longevityFormula,
    refractoryCombatFormula,
    refractoryCourtshipFormula,
    sexRatioMalesFormula,
    sexRatioFemalesFormula,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Prototype &&
          other.id == this.id &&
          other.name == this.name &&
          other.sex == this.sex &&
          other.color == this.color &&
          other.longevityFormula == this.longevityFormula &&
          other.refractoryCombatFormula == this.refractoryCombatFormula &&
          other.refractoryCourtshipFormula == this.refractoryCourtshipFormula &&
          other.sexRatioMalesFormula == this.sexRatioMalesFormula &&
          other.sexRatioFemalesFormula == this.sexRatioFemalesFormula &&
          other.sortOrder == this.sortOrder);
}

class PrototypesCompanion extends UpdateCompanion<Prototype> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> sex;
  final Value<int> color;
  final Value<String> longevityFormula;
  final Value<String> refractoryCombatFormula;
  final Value<String> refractoryCourtshipFormula;
  final Value<String> sexRatioMalesFormula;
  final Value<String> sexRatioFemalesFormula;
  final Value<int> sortOrder;
  const PrototypesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sex = const Value.absent(),
    this.color = const Value.absent(),
    this.longevityFormula = const Value.absent(),
    this.refractoryCombatFormula = const Value.absent(),
    this.refractoryCourtshipFormula = const Value.absent(),
    this.sexRatioMalesFormula = const Value.absent(),
    this.sexRatioFemalesFormula = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  PrototypesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String sex,
    this.color = const Value.absent(),
    this.longevityFormula = const Value.absent(),
    this.refractoryCombatFormula = const Value.absent(),
    this.refractoryCourtshipFormula = const Value.absent(),
    this.sexRatioMalesFormula = const Value.absent(),
    this.sexRatioFemalesFormula = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : name = Value(name),
       sex = Value(sex);
  static Insertable<Prototype> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? sex,
    Expression<int>? color,
    Expression<String>? longevityFormula,
    Expression<String>? refractoryCombatFormula,
    Expression<String>? refractoryCourtshipFormula,
    Expression<String>? sexRatioMalesFormula,
    Expression<String>? sexRatioFemalesFormula,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sex != null) 'sex': sex,
      if (color != null) 'color': color,
      if (longevityFormula != null) 'longevity_formula': longevityFormula,
      if (refractoryCombatFormula != null)
        'refractory_combat_formula': refractoryCombatFormula,
      if (refractoryCourtshipFormula != null)
        'refractory_courtship_formula': refractoryCourtshipFormula,
      if (sexRatioMalesFormula != null)
        'sex_ratio_males_formula': sexRatioMalesFormula,
      if (sexRatioFemalesFormula != null)
        'sex_ratio_females_formula': sexRatioFemalesFormula,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  PrototypesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? sex,
    Value<int>? color,
    Value<String>? longevityFormula,
    Value<String>? refractoryCombatFormula,
    Value<String>? refractoryCourtshipFormula,
    Value<String>? sexRatioMalesFormula,
    Value<String>? sexRatioFemalesFormula,
    Value<int>? sortOrder,
  }) {
    return PrototypesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sex: sex ?? this.sex,
      color: color ?? this.color,
      longevityFormula: longevityFormula ?? this.longevityFormula,
      refractoryCombatFormula:
          refractoryCombatFormula ?? this.refractoryCombatFormula,
      refractoryCourtshipFormula:
          refractoryCourtshipFormula ?? this.refractoryCourtshipFormula,
      sexRatioMalesFormula: sexRatioMalesFormula ?? this.sexRatioMalesFormula,
      sexRatioFemalesFormula:
          sexRatioFemalesFormula ?? this.sexRatioFemalesFormula,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (longevityFormula.present) {
      map['longevity_formula'] = Variable<String>(longevityFormula.value);
    }
    if (refractoryCombatFormula.present) {
      map['refractory_combat_formula'] = Variable<String>(
        refractoryCombatFormula.value,
      );
    }
    if (refractoryCourtshipFormula.present) {
      map['refractory_courtship_formula'] = Variable<String>(
        refractoryCourtshipFormula.value,
      );
    }
    if (sexRatioMalesFormula.present) {
      map['sex_ratio_males_formula'] = Variable<String>(
        sexRatioMalesFormula.value,
      );
    }
    if (sexRatioFemalesFormula.present) {
      map['sex_ratio_females_formula'] = Variable<String>(
        sexRatioFemalesFormula.value,
      );
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrototypesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sex: $sex, ')
          ..write('color: $color, ')
          ..write('longevityFormula: $longevityFormula, ')
          ..write('refractoryCombatFormula: $refractoryCombatFormula, ')
          ..write('refractoryCourtshipFormula: $refractoryCourtshipFormula, ')
          ..write('sexRatioMalesFormula: $sexRatioMalesFormula, ')
          ..write('sexRatioFemalesFormula: $sexRatioFemalesFormula, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $ResourceTypesTable extends ResourceTypes
    with TableInfo<$ResourceTypesTable, ResourceType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResourceTypesTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nutrientIdMeta = const VerificationMeta(
    'nutrientId',
  );
  @override
  late final GeneratedColumn<int> nutrientId = GeneratedColumn<int>(
    'nutrient_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES nutrients (id)',
    ),
  );
  static const VerificationMeta _isOvipositionMeta = const VerificationMeta(
    'isOviposition',
  );
  @override
  late final GeneratedColumn<bool> isOviposition = GeneratedColumn<bool>(
    'is_oviposition',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_oviposition" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    id,
    name,
    nutrientId,
    isOviposition,
    color,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'resource_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<ResourceType> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
    if (data.containsKey('nutrient_id')) {
      context.handle(
        _nutrientIdMeta,
        nutrientId.isAcceptableOrUnknown(data['nutrient_id']!, _nutrientIdMeta),
      );
    }
    if (data.containsKey('is_oviposition')) {
      context.handle(
        _isOvipositionMeta,
        isOviposition.isAcceptableOrUnknown(
          data['is_oviposition']!,
          _isOvipositionMeta,
        ),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
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
  ResourceType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResourceType(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nutrientId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}nutrient_id'],
      ),
      isOviposition: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_oviposition'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $ResourceTypesTable createAlias(String alias) {
    return $ResourceTypesTable(attachedDatabase, alias);
  }
}

class ResourceType extends DataClass implements Insertable<ResourceType> {
  final int id;
  final String name;
  final int? nutrientId;
  final bool isOviposition;
  final int color;
  final int sortOrder;
  const ResourceType({
    required this.id,
    required this.name,
    this.nutrientId,
    required this.isOviposition,
    required this.color,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || nutrientId != null) {
      map['nutrient_id'] = Variable<int>(nutrientId);
    }
    map['is_oviposition'] = Variable<bool>(isOviposition);
    map['color'] = Variable<int>(color);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  ResourceTypesCompanion toCompanion(bool nullToAbsent) {
    return ResourceTypesCompanion(
      id: Value(id),
      name: Value(name),
      nutrientId: nutrientId == null && nullToAbsent
          ? const Value.absent()
          : Value(nutrientId),
      isOviposition: Value(isOviposition),
      color: Value(color),
      sortOrder: Value(sortOrder),
    );
  }

  factory ResourceType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResourceType(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nutrientId: serializer.fromJson<int?>(json['nutrientId']),
      isOviposition: serializer.fromJson<bool>(json['isOviposition']),
      color: serializer.fromJson<int>(json['color']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'nutrientId': serializer.toJson<int?>(nutrientId),
      'isOviposition': serializer.toJson<bool>(isOviposition),
      'color': serializer.toJson<int>(color),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  ResourceType copyWith({
    int? id,
    String? name,
    Value<int?> nutrientId = const Value.absent(),
    bool? isOviposition,
    int? color,
    int? sortOrder,
  }) => ResourceType(
    id: id ?? this.id,
    name: name ?? this.name,
    nutrientId: nutrientId.present ? nutrientId.value : this.nutrientId,
    isOviposition: isOviposition ?? this.isOviposition,
    color: color ?? this.color,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  ResourceType copyWithCompanion(ResourceTypesCompanion data) {
    return ResourceType(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nutrientId: data.nutrientId.present
          ? data.nutrientId.value
          : this.nutrientId,
      isOviposition: data.isOviposition.present
          ? data.isOviposition.value
          : this.isOviposition,
      color: data.color.present ? data.color.value : this.color,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResourceType(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nutrientId: $nutrientId, ')
          ..write('isOviposition: $isOviposition, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, nutrientId, isOviposition, color, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResourceType &&
          other.id == this.id &&
          other.name == this.name &&
          other.nutrientId == this.nutrientId &&
          other.isOviposition == this.isOviposition &&
          other.color == this.color &&
          other.sortOrder == this.sortOrder);
}

class ResourceTypesCompanion extends UpdateCompanion<ResourceType> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> nutrientId;
  final Value<bool> isOviposition;
  final Value<int> color;
  final Value<int> sortOrder;
  const ResourceTypesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nutrientId = const Value.absent(),
    this.isOviposition = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  ResourceTypesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.nutrientId = const Value.absent(),
    this.isOviposition = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : name = Value(name);
  static Insertable<ResourceType> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? nutrientId,
    Expression<bool>? isOviposition,
    Expression<int>? color,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nutrientId != null) 'nutrient_id': nutrientId,
      if (isOviposition != null) 'is_oviposition': isOviposition,
      if (color != null) 'color': color,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  ResourceTypesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int?>? nutrientId,
    Value<bool>? isOviposition,
    Value<int>? color,
    Value<int>? sortOrder,
  }) {
    return ResourceTypesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nutrientId: nutrientId ?? this.nutrientId,
      isOviposition: isOviposition ?? this.isOviposition,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nutrientId.present) {
      map['nutrient_id'] = Variable<int>(nutrientId.value);
    }
    if (isOviposition.present) {
      map['is_oviposition'] = Variable<bool>(isOviposition.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResourceTypesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nutrientId: $nutrientId, ')
          ..write('isOviposition: $isOviposition, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $EnvironmentsTable extends Environments
    with TableInfo<$EnvironmentsTable, Environment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnvironmentsTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.now().toIso8601String()),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.now().toIso8601String()),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    width,
    height,
    description,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'environments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Environment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    } else if (isInserting) {
      context.missing(_widthMeta);
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    } else if (isInserting) {
      context.missing(_heightMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Environment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Environment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      )!,
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $EnvironmentsTable createAlias(String alias) {
    return $EnvironmentsTable(attachedDatabase, alias);
  }
}

class Environment extends DataClass implements Insertable<Environment> {
  final int id;
  final String name;
  final int width;
  final int height;
  final String description;
  final String createdAt;
  final String updatedAt;
  const Environment({
    required this.id,
    required this.name,
    required this.width,
    required this.height,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['width'] = Variable<int>(width);
    map['height'] = Variable<int>(height);
    map['description'] = Variable<String>(description);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  EnvironmentsCompanion toCompanion(bool nullToAbsent) {
    return EnvironmentsCompanion(
      id: Value(id),
      name: Value(name),
      width: Value(width),
      height: Value(height),
      description: Value(description),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Environment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Environment(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      width: serializer.fromJson<int>(json['width']),
      height: serializer.fromJson<int>(json['height']),
      description: serializer.fromJson<String>(json['description']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'width': serializer.toJson<int>(width),
      'height': serializer.toJson<int>(height),
      'description': serializer.toJson<String>(description),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  Environment copyWith({
    int? id,
    String? name,
    int? width,
    int? height,
    String? description,
    String? createdAt,
    String? updatedAt,
  }) => Environment(
    id: id ?? this.id,
    name: name ?? this.name,
    width: width ?? this.width,
    height: height ?? this.height,
    description: description ?? this.description,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Environment copyWithCompanion(EnvironmentsCompanion data) {
    return Environment(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Environment(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, width, height, description, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Environment &&
          other.id == this.id &&
          other.name == this.name &&
          other.width == this.width &&
          other.height == this.height &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class EnvironmentsCompanion extends UpdateCompanion<Environment> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> width;
  final Value<int> height;
  final Value<String> description;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  const EnvironmentsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  EnvironmentsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int width,
    required int height,
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name),
       width = Value(width),
       height = Value(height);
  static Insertable<Environment> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? width,
    Expression<int>? height,
    Expression<String>? description,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  EnvironmentsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? width,
    Value<int>? height,
    Value<String>? description,
    Value<String>? createdAt,
    Value<String>? updatedAt,
  }) {
    return EnvironmentsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      width: width ?? this.width,
      height: height ?? this.height,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnvironmentsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SubstrateMapRowsTable extends SubstrateMapRows
    with TableInfo<$SubstrateMapRowsTable, SubstrateMapRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubstrateMapRowsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _environmentIdMeta = const VerificationMeta(
    'environmentId',
  );
  @override
  late final GeneratedColumn<int> environmentId = GeneratedColumn<int>(
    'environment_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES environments (id)',
    ),
  );
  static const VerificationMeta _yCoordMeta = const VerificationMeta('yCoord');
  @override
  late final GeneratedColumn<int> yCoord = GeneratedColumn<int>(
    'y_coord',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mapDataMeta = const VerificationMeta(
    'mapData',
  );
  @override
  late final GeneratedColumn<String> mapData = GeneratedColumn<String>(
    'map_data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, environmentId, yCoord, mapData];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'substrate_map_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<SubstrateMapRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('environment_id')) {
      context.handle(
        _environmentIdMeta,
        environmentId.isAcceptableOrUnknown(
          data['environment_id']!,
          _environmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_environmentIdMeta);
    }
    if (data.containsKey('y_coord')) {
      context.handle(
        _yCoordMeta,
        yCoord.isAcceptableOrUnknown(data['y_coord']!, _yCoordMeta),
      );
    } else if (isInserting) {
      context.missing(_yCoordMeta);
    }
    if (data.containsKey('map_data')) {
      context.handle(
        _mapDataMeta,
        mapData.isAcceptableOrUnknown(data['map_data']!, _mapDataMeta),
      );
    } else if (isInserting) {
      context.missing(_mapDataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {environmentId, yCoord},
  ];
  @override
  SubstrateMapRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubstrateMapRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      environmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}environment_id'],
      )!,
      yCoord: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}y_coord'],
      )!,
      mapData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}map_data'],
      )!,
    );
  }

  @override
  $SubstrateMapRowsTable createAlias(String alias) {
    return $SubstrateMapRowsTable(attachedDatabase, alias);
  }
}

class SubstrateMapRow extends DataClass implements Insertable<SubstrateMapRow> {
  final int id;
  final int environmentId;
  final int yCoord;
  final String mapData;
  const SubstrateMapRow({
    required this.id,
    required this.environmentId,
    required this.yCoord,
    required this.mapData,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['environment_id'] = Variable<int>(environmentId);
    map['y_coord'] = Variable<int>(yCoord);
    map['map_data'] = Variable<String>(mapData);
    return map;
  }

  SubstrateMapRowsCompanion toCompanion(bool nullToAbsent) {
    return SubstrateMapRowsCompanion(
      id: Value(id),
      environmentId: Value(environmentId),
      yCoord: Value(yCoord),
      mapData: Value(mapData),
    );
  }

  factory SubstrateMapRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubstrateMapRow(
      id: serializer.fromJson<int>(json['id']),
      environmentId: serializer.fromJson<int>(json['environmentId']),
      yCoord: serializer.fromJson<int>(json['yCoord']),
      mapData: serializer.fromJson<String>(json['mapData']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'environmentId': serializer.toJson<int>(environmentId),
      'yCoord': serializer.toJson<int>(yCoord),
      'mapData': serializer.toJson<String>(mapData),
    };
  }

  SubstrateMapRow copyWith({
    int? id,
    int? environmentId,
    int? yCoord,
    String? mapData,
  }) => SubstrateMapRow(
    id: id ?? this.id,
    environmentId: environmentId ?? this.environmentId,
    yCoord: yCoord ?? this.yCoord,
    mapData: mapData ?? this.mapData,
  );
  SubstrateMapRow copyWithCompanion(SubstrateMapRowsCompanion data) {
    return SubstrateMapRow(
      id: data.id.present ? data.id.value : this.id,
      environmentId: data.environmentId.present
          ? data.environmentId.value
          : this.environmentId,
      yCoord: data.yCoord.present ? data.yCoord.value : this.yCoord,
      mapData: data.mapData.present ? data.mapData.value : this.mapData,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubstrateMapRow(')
          ..write('id: $id, ')
          ..write('environmentId: $environmentId, ')
          ..write('yCoord: $yCoord, ')
          ..write('mapData: $mapData')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, environmentId, yCoord, mapData);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubstrateMapRow &&
          other.id == this.id &&
          other.environmentId == this.environmentId &&
          other.yCoord == this.yCoord &&
          other.mapData == this.mapData);
}

class SubstrateMapRowsCompanion extends UpdateCompanion<SubstrateMapRow> {
  final Value<int> id;
  final Value<int> environmentId;
  final Value<int> yCoord;
  final Value<String> mapData;
  const SubstrateMapRowsCompanion({
    this.id = const Value.absent(),
    this.environmentId = const Value.absent(),
    this.yCoord = const Value.absent(),
    this.mapData = const Value.absent(),
  });
  SubstrateMapRowsCompanion.insert({
    this.id = const Value.absent(),
    required int environmentId,
    required int yCoord,
    required String mapData,
  }) : environmentId = Value(environmentId),
       yCoord = Value(yCoord),
       mapData = Value(mapData);
  static Insertable<SubstrateMapRow> custom({
    Expression<int>? id,
    Expression<int>? environmentId,
    Expression<int>? yCoord,
    Expression<String>? mapData,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (environmentId != null) 'environment_id': environmentId,
      if (yCoord != null) 'y_coord': yCoord,
      if (mapData != null) 'map_data': mapData,
    });
  }

  SubstrateMapRowsCompanion copyWith({
    Value<int>? id,
    Value<int>? environmentId,
    Value<int>? yCoord,
    Value<String>? mapData,
  }) {
    return SubstrateMapRowsCompanion(
      id: id ?? this.id,
      environmentId: environmentId ?? this.environmentId,
      yCoord: yCoord ?? this.yCoord,
      mapData: mapData ?? this.mapData,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (environmentId.present) {
      map['environment_id'] = Variable<int>(environmentId.value);
    }
    if (yCoord.present) {
      map['y_coord'] = Variable<int>(yCoord.value);
    }
    if (mapData.present) {
      map['map_data'] = Variable<String>(mapData.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubstrateMapRowsCompanion(')
          ..write('id: $id, ')
          ..write('environmentId: $environmentId, ')
          ..write('yCoord: $yCoord, ')
          ..write('mapData: $mapData')
          ..write(')'))
        .toString();
  }
}

class $EnvironmentResourcesTable extends EnvironmentResources
    with TableInfo<$EnvironmentResourcesTable, EnvironmentResource> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnvironmentResourcesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _environmentIdMeta = const VerificationMeta(
    'environmentId',
  );
  @override
  late final GeneratedColumn<int> environmentId = GeneratedColumn<int>(
    'environment_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES environments (id)',
    ),
  );
  static const VerificationMeta _resourceTypeIdMeta = const VerificationMeta(
    'resourceTypeId',
  );
  @override
  late final GeneratedColumn<int> resourceTypeId = GeneratedColumn<int>(
    'resource_type_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES resource_types (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _posXMeta = const VerificationMeta('posX');
  @override
  late final GeneratedColumn<int> posX = GeneratedColumn<int>(
    'pos_x',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _posYMeta = const VerificationMeta('posY');
  @override
  late final GeneratedColumn<int> posY = GeneratedColumn<int>(
    'pos_y',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qualityMeta = const VerificationMeta(
    'quality',
  );
  @override
  late final GeneratedColumn<int> quality = GeneratedColumn<int>(
    'quality',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(50),
  );
  static const VerificationMeta _maxLevelMeta = const VerificationMeta(
    'maxLevel',
  );
  @override
  late final GeneratedColumn<int> maxLevel = GeneratedColumn<int>(
    'max_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(100),
  );
  static const VerificationMeta _regenRateMeta = const VerificationMeta(
    'regenRate',
  );
  @override
  late final GeneratedColumn<double> regenRate = GeneratedColumn<double>(
    'regen_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    environmentId,
    resourceTypeId,
    name,
    posX,
    posY,
    quality,
    level,
    maxLevel,
    regenRate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'environment_resources';
  @override
  VerificationContext validateIntegrity(
    Insertable<EnvironmentResource> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('environment_id')) {
      context.handle(
        _environmentIdMeta,
        environmentId.isAcceptableOrUnknown(
          data['environment_id']!,
          _environmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_environmentIdMeta);
    }
    if (data.containsKey('resource_type_id')) {
      context.handle(
        _resourceTypeIdMeta,
        resourceTypeId.isAcceptableOrUnknown(
          data['resource_type_id']!,
          _resourceTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_resourceTypeIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('pos_x')) {
      context.handle(
        _posXMeta,
        posX.isAcceptableOrUnknown(data['pos_x']!, _posXMeta),
      );
    } else if (isInserting) {
      context.missing(_posXMeta);
    }
    if (data.containsKey('pos_y')) {
      context.handle(
        _posYMeta,
        posY.isAcceptableOrUnknown(data['pos_y']!, _posYMeta),
      );
    } else if (isInserting) {
      context.missing(_posYMeta);
    }
    if (data.containsKey('quality')) {
      context.handle(
        _qualityMeta,
        quality.isAcceptableOrUnknown(data['quality']!, _qualityMeta),
      );
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('max_level')) {
      context.handle(
        _maxLevelMeta,
        maxLevel.isAcceptableOrUnknown(data['max_level']!, _maxLevelMeta),
      );
    }
    if (data.containsKey('regen_rate')) {
      context.handle(
        _regenRateMeta,
        regenRate.isAcceptableOrUnknown(data['regen_rate']!, _regenRateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EnvironmentResource map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EnvironmentResource(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      environmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}environment_id'],
      )!,
      resourceTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resource_type_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      posX: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pos_x'],
      )!,
      posY: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pos_y'],
      )!,
      quality: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quality'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      maxLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_level'],
      )!,
      regenRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}regen_rate'],
      )!,
    );
  }

  @override
  $EnvironmentResourcesTable createAlias(String alias) {
    return $EnvironmentResourcesTable(attachedDatabase, alias);
  }
}

class EnvironmentResource extends DataClass
    implements Insertable<EnvironmentResource> {
  final int id;
  final int environmentId;
  final int resourceTypeId;
  final String name;
  final int posX;
  final int posY;
  final int quality;
  final int level;
  final int maxLevel;
  final double regenRate;
  const EnvironmentResource({
    required this.id,
    required this.environmentId,
    required this.resourceTypeId,
    required this.name,
    required this.posX,
    required this.posY,
    required this.quality,
    required this.level,
    required this.maxLevel,
    required this.regenRate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['environment_id'] = Variable<int>(environmentId);
    map['resource_type_id'] = Variable<int>(resourceTypeId);
    map['name'] = Variable<String>(name);
    map['pos_x'] = Variable<int>(posX);
    map['pos_y'] = Variable<int>(posY);
    map['quality'] = Variable<int>(quality);
    map['level'] = Variable<int>(level);
    map['max_level'] = Variable<int>(maxLevel);
    map['regen_rate'] = Variable<double>(regenRate);
    return map;
  }

  EnvironmentResourcesCompanion toCompanion(bool nullToAbsent) {
    return EnvironmentResourcesCompanion(
      id: Value(id),
      environmentId: Value(environmentId),
      resourceTypeId: Value(resourceTypeId),
      name: Value(name),
      posX: Value(posX),
      posY: Value(posY),
      quality: Value(quality),
      level: Value(level),
      maxLevel: Value(maxLevel),
      regenRate: Value(regenRate),
    );
  }

  factory EnvironmentResource.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EnvironmentResource(
      id: serializer.fromJson<int>(json['id']),
      environmentId: serializer.fromJson<int>(json['environmentId']),
      resourceTypeId: serializer.fromJson<int>(json['resourceTypeId']),
      name: serializer.fromJson<String>(json['name']),
      posX: serializer.fromJson<int>(json['posX']),
      posY: serializer.fromJson<int>(json['posY']),
      quality: serializer.fromJson<int>(json['quality']),
      level: serializer.fromJson<int>(json['level']),
      maxLevel: serializer.fromJson<int>(json['maxLevel']),
      regenRate: serializer.fromJson<double>(json['regenRate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'environmentId': serializer.toJson<int>(environmentId),
      'resourceTypeId': serializer.toJson<int>(resourceTypeId),
      'name': serializer.toJson<String>(name),
      'posX': serializer.toJson<int>(posX),
      'posY': serializer.toJson<int>(posY),
      'quality': serializer.toJson<int>(quality),
      'level': serializer.toJson<int>(level),
      'maxLevel': serializer.toJson<int>(maxLevel),
      'regenRate': serializer.toJson<double>(regenRate),
    };
  }

  EnvironmentResource copyWith({
    int? id,
    int? environmentId,
    int? resourceTypeId,
    String? name,
    int? posX,
    int? posY,
    int? quality,
    int? level,
    int? maxLevel,
    double? regenRate,
  }) => EnvironmentResource(
    id: id ?? this.id,
    environmentId: environmentId ?? this.environmentId,
    resourceTypeId: resourceTypeId ?? this.resourceTypeId,
    name: name ?? this.name,
    posX: posX ?? this.posX,
    posY: posY ?? this.posY,
    quality: quality ?? this.quality,
    level: level ?? this.level,
    maxLevel: maxLevel ?? this.maxLevel,
    regenRate: regenRate ?? this.regenRate,
  );
  EnvironmentResource copyWithCompanion(EnvironmentResourcesCompanion data) {
    return EnvironmentResource(
      id: data.id.present ? data.id.value : this.id,
      environmentId: data.environmentId.present
          ? data.environmentId.value
          : this.environmentId,
      resourceTypeId: data.resourceTypeId.present
          ? data.resourceTypeId.value
          : this.resourceTypeId,
      name: data.name.present ? data.name.value : this.name,
      posX: data.posX.present ? data.posX.value : this.posX,
      posY: data.posY.present ? data.posY.value : this.posY,
      quality: data.quality.present ? data.quality.value : this.quality,
      level: data.level.present ? data.level.value : this.level,
      maxLevel: data.maxLevel.present ? data.maxLevel.value : this.maxLevel,
      regenRate: data.regenRate.present ? data.regenRate.value : this.regenRate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EnvironmentResource(')
          ..write('id: $id, ')
          ..write('environmentId: $environmentId, ')
          ..write('resourceTypeId: $resourceTypeId, ')
          ..write('name: $name, ')
          ..write('posX: $posX, ')
          ..write('posY: $posY, ')
          ..write('quality: $quality, ')
          ..write('level: $level, ')
          ..write('maxLevel: $maxLevel, ')
          ..write('regenRate: $regenRate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    environmentId,
    resourceTypeId,
    name,
    posX,
    posY,
    quality,
    level,
    maxLevel,
    regenRate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EnvironmentResource &&
          other.id == this.id &&
          other.environmentId == this.environmentId &&
          other.resourceTypeId == this.resourceTypeId &&
          other.name == this.name &&
          other.posX == this.posX &&
          other.posY == this.posY &&
          other.quality == this.quality &&
          other.level == this.level &&
          other.maxLevel == this.maxLevel &&
          other.regenRate == this.regenRate);
}

class EnvironmentResourcesCompanion
    extends UpdateCompanion<EnvironmentResource> {
  final Value<int> id;
  final Value<int> environmentId;
  final Value<int> resourceTypeId;
  final Value<String> name;
  final Value<int> posX;
  final Value<int> posY;
  final Value<int> quality;
  final Value<int> level;
  final Value<int> maxLevel;
  final Value<double> regenRate;
  const EnvironmentResourcesCompanion({
    this.id = const Value.absent(),
    this.environmentId = const Value.absent(),
    this.resourceTypeId = const Value.absent(),
    this.name = const Value.absent(),
    this.posX = const Value.absent(),
    this.posY = const Value.absent(),
    this.quality = const Value.absent(),
    this.level = const Value.absent(),
    this.maxLevel = const Value.absent(),
    this.regenRate = const Value.absent(),
  });
  EnvironmentResourcesCompanion.insert({
    this.id = const Value.absent(),
    required int environmentId,
    required int resourceTypeId,
    required String name,
    required int posX,
    required int posY,
    this.quality = const Value.absent(),
    this.level = const Value.absent(),
    this.maxLevel = const Value.absent(),
    this.regenRate = const Value.absent(),
  }) : environmentId = Value(environmentId),
       resourceTypeId = Value(resourceTypeId),
       name = Value(name),
       posX = Value(posX),
       posY = Value(posY);
  static Insertable<EnvironmentResource> custom({
    Expression<int>? id,
    Expression<int>? environmentId,
    Expression<int>? resourceTypeId,
    Expression<String>? name,
    Expression<int>? posX,
    Expression<int>? posY,
    Expression<int>? quality,
    Expression<int>? level,
    Expression<int>? maxLevel,
    Expression<double>? regenRate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (environmentId != null) 'environment_id': environmentId,
      if (resourceTypeId != null) 'resource_type_id': resourceTypeId,
      if (name != null) 'name': name,
      if (posX != null) 'pos_x': posX,
      if (posY != null) 'pos_y': posY,
      if (quality != null) 'quality': quality,
      if (level != null) 'level': level,
      if (maxLevel != null) 'max_level': maxLevel,
      if (regenRate != null) 'regen_rate': regenRate,
    });
  }

  EnvironmentResourcesCompanion copyWith({
    Value<int>? id,
    Value<int>? environmentId,
    Value<int>? resourceTypeId,
    Value<String>? name,
    Value<int>? posX,
    Value<int>? posY,
    Value<int>? quality,
    Value<int>? level,
    Value<int>? maxLevel,
    Value<double>? regenRate,
  }) {
    return EnvironmentResourcesCompanion(
      id: id ?? this.id,
      environmentId: environmentId ?? this.environmentId,
      resourceTypeId: resourceTypeId ?? this.resourceTypeId,
      name: name ?? this.name,
      posX: posX ?? this.posX,
      posY: posY ?? this.posY,
      quality: quality ?? this.quality,
      level: level ?? this.level,
      maxLevel: maxLevel ?? this.maxLevel,
      regenRate: regenRate ?? this.regenRate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (environmentId.present) {
      map['environment_id'] = Variable<int>(environmentId.value);
    }
    if (resourceTypeId.present) {
      map['resource_type_id'] = Variable<int>(resourceTypeId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (posX.present) {
      map['pos_x'] = Variable<int>(posX.value);
    }
    if (posY.present) {
      map['pos_y'] = Variable<int>(posY.value);
    }
    if (quality.present) {
      map['quality'] = Variable<int>(quality.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (maxLevel.present) {
      map['max_level'] = Variable<int>(maxLevel.value);
    }
    if (regenRate.present) {
      map['regen_rate'] = Variable<double>(regenRate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnvironmentResourcesCompanion(')
          ..write('id: $id, ')
          ..write('environmentId: $environmentId, ')
          ..write('resourceTypeId: $resourceTypeId, ')
          ..write('name: $name, ')
          ..write('posX: $posX, ')
          ..write('posY: $posY, ')
          ..write('quality: $quality, ')
          ..write('level: $level, ')
          ..write('maxLevel: $maxLevel, ')
          ..write('regenRate: $regenRate')
          ..write(')'))
        .toString();
  }
}

class $EnvironmentAgentsTable extends EnvironmentAgents
    with TableInfo<$EnvironmentAgentsTable, EnvironmentAgent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnvironmentAgentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _environmentIdMeta = const VerificationMeta(
    'environmentId',
  );
  @override
  late final GeneratedColumn<int> environmentId = GeneratedColumn<int>(
    'environment_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES environments (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _posXMeta = const VerificationMeta('posX');
  @override
  late final GeneratedColumn<int> posX = GeneratedColumn<int>(
    'pos_x',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _posYMeta = const VerificationMeta('posY');
  @override
  late final GeneratedColumn<int> posY = GeneratedColumn<int>(
    'pos_y',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stageIdMeta = const VerificationMeta(
    'stageId',
  );
  @override
  late final GeneratedColumn<int> stageId = GeneratedColumn<int>(
    'stage_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES stages (id)',
    ),
  );
  static const VerificationMeta _prototypeIdMeta = const VerificationMeta(
    'prototypeId',
  );
  @override
  late final GeneratedColumn<int> prototypeId = GeneratedColumn<int>(
    'prototype_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES prototypes (id)',
    ),
  );
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
    'sex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
    'age',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    environmentId,
    name,
    posX,
    posY,
    stageId,
    prototypeId,
    sex,
    age,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'environment_agents';
  @override
  VerificationContext validateIntegrity(
    Insertable<EnvironmentAgent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('environment_id')) {
      context.handle(
        _environmentIdMeta,
        environmentId.isAcceptableOrUnknown(
          data['environment_id']!,
          _environmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_environmentIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('pos_x')) {
      context.handle(
        _posXMeta,
        posX.isAcceptableOrUnknown(data['pos_x']!, _posXMeta),
      );
    } else if (isInserting) {
      context.missing(_posXMeta);
    }
    if (data.containsKey('pos_y')) {
      context.handle(
        _posYMeta,
        posY.isAcceptableOrUnknown(data['pos_y']!, _posYMeta),
      );
    } else if (isInserting) {
      context.missing(_posYMeta);
    }
    if (data.containsKey('stage_id')) {
      context.handle(
        _stageIdMeta,
        stageId.isAcceptableOrUnknown(data['stage_id']!, _stageIdMeta),
      );
    }
    if (data.containsKey('prototype_id')) {
      context.handle(
        _prototypeIdMeta,
        prototypeId.isAcceptableOrUnknown(
          data['prototype_id']!,
          _prototypeIdMeta,
        ),
      );
    }
    if (data.containsKey('sex')) {
      context.handle(
        _sexMeta,
        sex.isAcceptableOrUnknown(data['sex']!, _sexMeta),
      );
    } else if (isInserting) {
      context.missing(_sexMeta);
    }
    if (data.containsKey('age')) {
      context.handle(
        _ageMeta,
        age.isAcceptableOrUnknown(data['age']!, _ageMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EnvironmentAgent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EnvironmentAgent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      environmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}environment_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      posX: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pos_x'],
      )!,
      posY: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pos_y'],
      )!,
      stageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stage_id'],
      ),
      prototypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}prototype_id'],
      ),
      sex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sex'],
      )!,
      age: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age'],
      )!,
    );
  }

  @override
  $EnvironmentAgentsTable createAlias(String alias) {
    return $EnvironmentAgentsTable(attachedDatabase, alias);
  }
}

class EnvironmentAgent extends DataClass
    implements Insertable<EnvironmentAgent> {
  final int id;
  final int environmentId;
  final String name;
  final int posX;
  final int posY;
  final int? stageId;
  final int? prototypeId;
  final String sex;
  final int age;
  const EnvironmentAgent({
    required this.id,
    required this.environmentId,
    required this.name,
    required this.posX,
    required this.posY,
    this.stageId,
    this.prototypeId,
    required this.sex,
    required this.age,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['environment_id'] = Variable<int>(environmentId);
    map['name'] = Variable<String>(name);
    map['pos_x'] = Variable<int>(posX);
    map['pos_y'] = Variable<int>(posY);
    if (!nullToAbsent || stageId != null) {
      map['stage_id'] = Variable<int>(stageId);
    }
    if (!nullToAbsent || prototypeId != null) {
      map['prototype_id'] = Variable<int>(prototypeId);
    }
    map['sex'] = Variable<String>(sex);
    map['age'] = Variable<int>(age);
    return map;
  }

  EnvironmentAgentsCompanion toCompanion(bool nullToAbsent) {
    return EnvironmentAgentsCompanion(
      id: Value(id),
      environmentId: Value(environmentId),
      name: Value(name),
      posX: Value(posX),
      posY: Value(posY),
      stageId: stageId == null && nullToAbsent
          ? const Value.absent()
          : Value(stageId),
      prototypeId: prototypeId == null && nullToAbsent
          ? const Value.absent()
          : Value(prototypeId),
      sex: Value(sex),
      age: Value(age),
    );
  }

  factory EnvironmentAgent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EnvironmentAgent(
      id: serializer.fromJson<int>(json['id']),
      environmentId: serializer.fromJson<int>(json['environmentId']),
      name: serializer.fromJson<String>(json['name']),
      posX: serializer.fromJson<int>(json['posX']),
      posY: serializer.fromJson<int>(json['posY']),
      stageId: serializer.fromJson<int?>(json['stageId']),
      prototypeId: serializer.fromJson<int?>(json['prototypeId']),
      sex: serializer.fromJson<String>(json['sex']),
      age: serializer.fromJson<int>(json['age']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'environmentId': serializer.toJson<int>(environmentId),
      'name': serializer.toJson<String>(name),
      'posX': serializer.toJson<int>(posX),
      'posY': serializer.toJson<int>(posY),
      'stageId': serializer.toJson<int?>(stageId),
      'prototypeId': serializer.toJson<int?>(prototypeId),
      'sex': serializer.toJson<String>(sex),
      'age': serializer.toJson<int>(age),
    };
  }

  EnvironmentAgent copyWith({
    int? id,
    int? environmentId,
    String? name,
    int? posX,
    int? posY,
    Value<int?> stageId = const Value.absent(),
    Value<int?> prototypeId = const Value.absent(),
    String? sex,
    int? age,
  }) => EnvironmentAgent(
    id: id ?? this.id,
    environmentId: environmentId ?? this.environmentId,
    name: name ?? this.name,
    posX: posX ?? this.posX,
    posY: posY ?? this.posY,
    stageId: stageId.present ? stageId.value : this.stageId,
    prototypeId: prototypeId.present ? prototypeId.value : this.prototypeId,
    sex: sex ?? this.sex,
    age: age ?? this.age,
  );
  EnvironmentAgent copyWithCompanion(EnvironmentAgentsCompanion data) {
    return EnvironmentAgent(
      id: data.id.present ? data.id.value : this.id,
      environmentId: data.environmentId.present
          ? data.environmentId.value
          : this.environmentId,
      name: data.name.present ? data.name.value : this.name,
      posX: data.posX.present ? data.posX.value : this.posX,
      posY: data.posY.present ? data.posY.value : this.posY,
      stageId: data.stageId.present ? data.stageId.value : this.stageId,
      prototypeId: data.prototypeId.present
          ? data.prototypeId.value
          : this.prototypeId,
      sex: data.sex.present ? data.sex.value : this.sex,
      age: data.age.present ? data.age.value : this.age,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EnvironmentAgent(')
          ..write('id: $id, ')
          ..write('environmentId: $environmentId, ')
          ..write('name: $name, ')
          ..write('posX: $posX, ')
          ..write('posY: $posY, ')
          ..write('stageId: $stageId, ')
          ..write('prototypeId: $prototypeId, ')
          ..write('sex: $sex, ')
          ..write('age: $age')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    environmentId,
    name,
    posX,
    posY,
    stageId,
    prototypeId,
    sex,
    age,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EnvironmentAgent &&
          other.id == this.id &&
          other.environmentId == this.environmentId &&
          other.name == this.name &&
          other.posX == this.posX &&
          other.posY == this.posY &&
          other.stageId == this.stageId &&
          other.prototypeId == this.prototypeId &&
          other.sex == this.sex &&
          other.age == this.age);
}

class EnvironmentAgentsCompanion extends UpdateCompanion<EnvironmentAgent> {
  final Value<int> id;
  final Value<int> environmentId;
  final Value<String> name;
  final Value<int> posX;
  final Value<int> posY;
  final Value<int?> stageId;
  final Value<int?> prototypeId;
  final Value<String> sex;
  final Value<int> age;
  const EnvironmentAgentsCompanion({
    this.id = const Value.absent(),
    this.environmentId = const Value.absent(),
    this.name = const Value.absent(),
    this.posX = const Value.absent(),
    this.posY = const Value.absent(),
    this.stageId = const Value.absent(),
    this.prototypeId = const Value.absent(),
    this.sex = const Value.absent(),
    this.age = const Value.absent(),
  });
  EnvironmentAgentsCompanion.insert({
    this.id = const Value.absent(),
    required int environmentId,
    required String name,
    required int posX,
    required int posY,
    this.stageId = const Value.absent(),
    this.prototypeId = const Value.absent(),
    required String sex,
    this.age = const Value.absent(),
  }) : environmentId = Value(environmentId),
       name = Value(name),
       posX = Value(posX),
       posY = Value(posY),
       sex = Value(sex);
  static Insertable<EnvironmentAgent> custom({
    Expression<int>? id,
    Expression<int>? environmentId,
    Expression<String>? name,
    Expression<int>? posX,
    Expression<int>? posY,
    Expression<int>? stageId,
    Expression<int>? prototypeId,
    Expression<String>? sex,
    Expression<int>? age,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (environmentId != null) 'environment_id': environmentId,
      if (name != null) 'name': name,
      if (posX != null) 'pos_x': posX,
      if (posY != null) 'pos_y': posY,
      if (stageId != null) 'stage_id': stageId,
      if (prototypeId != null) 'prototype_id': prototypeId,
      if (sex != null) 'sex': sex,
      if (age != null) 'age': age,
    });
  }

  EnvironmentAgentsCompanion copyWith({
    Value<int>? id,
    Value<int>? environmentId,
    Value<String>? name,
    Value<int>? posX,
    Value<int>? posY,
    Value<int?>? stageId,
    Value<int?>? prototypeId,
    Value<String>? sex,
    Value<int>? age,
  }) {
    return EnvironmentAgentsCompanion(
      id: id ?? this.id,
      environmentId: environmentId ?? this.environmentId,
      name: name ?? this.name,
      posX: posX ?? this.posX,
      posY: posY ?? this.posY,
      stageId: stageId ?? this.stageId,
      prototypeId: prototypeId ?? this.prototypeId,
      sex: sex ?? this.sex,
      age: age ?? this.age,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (environmentId.present) {
      map['environment_id'] = Variable<int>(environmentId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (posX.present) {
      map['pos_x'] = Variable<int>(posX.value);
    }
    if (posY.present) {
      map['pos_y'] = Variable<int>(posY.value);
    }
    if (stageId.present) {
      map['stage_id'] = Variable<int>(stageId.value);
    }
    if (prototypeId.present) {
      map['prototype_id'] = Variable<int>(prototypeId.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnvironmentAgentsCompanion(')
          ..write('id: $id, ')
          ..write('environmentId: $environmentId, ')
          ..write('name: $name, ')
          ..write('posX: $posX, ')
          ..write('posY: $posY, ')
          ..write('stageId: $stageId, ')
          ..write('prototypeId: $prototypeId, ')
          ..write('sex: $sex, ')
          ..write('age: $age')
          ..write(')'))
        .toString();
  }
}

class $MetabolismTable extends Metabolism
    with TableInfo<$MetabolismTable, MetabolismData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetabolismTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nutrientIdMeta = const VerificationMeta(
    'nutrientId',
  );
  @override
  late final GeneratedColumn<int> nutrientId = GeneratedColumn<int>(
    'nutrient_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES nutrients (id)',
    ),
  );
  static const VerificationMeta _minFormulaMeta = const VerificationMeta(
    'minFormula',
  );
  @override
  late final GeneratedColumn<String> minFormula = GeneratedColumn<String>(
    'min_formula',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('0'),
  );
  static const VerificationMeta _criticalFormulaMeta = const VerificationMeta(
    'criticalFormula',
  );
  @override
  late final GeneratedColumn<String> criticalFormula = GeneratedColumn<String>(
    'critical_formula',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('10'),
  );
  static const VerificationMeta _optimalFormulaMeta = const VerificationMeta(
    'optimalFormula',
  );
  @override
  late final GeneratedColumn<String> optimalFormula = GeneratedColumn<String>(
    'optimal_formula',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('50'),
  );
  static const VerificationMeta _initialFormulaMeta = const VerificationMeta(
    'initialFormula',
  );
  @override
  late final GeneratedColumn<String> initialFormula = GeneratedColumn<String>(
    'initial_formula',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('50'),
  );
  static const VerificationMeta _maxFormulaMeta = const VerificationMeta(
    'maxFormula',
  );
  @override
  late final GeneratedColumn<String> maxFormula = GeneratedColumn<String>(
    'max_formula',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('100'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nutrientId,
    minFormula,
    criticalFormula,
    optimalFormula,
    initialFormula,
    maxFormula,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'metabolism';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetabolismData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nutrient_id')) {
      context.handle(
        _nutrientIdMeta,
        nutrientId.isAcceptableOrUnknown(data['nutrient_id']!, _nutrientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_nutrientIdMeta);
    }
    if (data.containsKey('min_formula')) {
      context.handle(
        _minFormulaMeta,
        minFormula.isAcceptableOrUnknown(data['min_formula']!, _minFormulaMeta),
      );
    }
    if (data.containsKey('critical_formula')) {
      context.handle(
        _criticalFormulaMeta,
        criticalFormula.isAcceptableOrUnknown(
          data['critical_formula']!,
          _criticalFormulaMeta,
        ),
      );
    }
    if (data.containsKey('optimal_formula')) {
      context.handle(
        _optimalFormulaMeta,
        optimalFormula.isAcceptableOrUnknown(
          data['optimal_formula']!,
          _optimalFormulaMeta,
        ),
      );
    }
    if (data.containsKey('initial_formula')) {
      context.handle(
        _initialFormulaMeta,
        initialFormula.isAcceptableOrUnknown(
          data['initial_formula']!,
          _initialFormulaMeta,
        ),
      );
    }
    if (data.containsKey('max_formula')) {
      context.handle(
        _maxFormulaMeta,
        maxFormula.isAcceptableOrUnknown(data['max_formula']!, _maxFormulaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MetabolismData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetabolismData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nutrientId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}nutrient_id'],
      )!,
      minFormula: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}min_formula'],
      )!,
      criticalFormula: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}critical_formula'],
      )!,
      optimalFormula: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}optimal_formula'],
      )!,
      initialFormula: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}initial_formula'],
      )!,
      maxFormula: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}max_formula'],
      )!,
    );
  }

  @override
  $MetabolismTable createAlias(String alias) {
    return $MetabolismTable(attachedDatabase, alias);
  }
}

class MetabolismData extends DataClass implements Insertable<MetabolismData> {
  final int id;
  final int nutrientId;
  final String minFormula;
  final String criticalFormula;
  final String optimalFormula;
  final String initialFormula;
  final String maxFormula;
  const MetabolismData({
    required this.id,
    required this.nutrientId,
    required this.minFormula,
    required this.criticalFormula,
    required this.optimalFormula,
    required this.initialFormula,
    required this.maxFormula,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nutrient_id'] = Variable<int>(nutrientId);
    map['min_formula'] = Variable<String>(minFormula);
    map['critical_formula'] = Variable<String>(criticalFormula);
    map['optimal_formula'] = Variable<String>(optimalFormula);
    map['initial_formula'] = Variable<String>(initialFormula);
    map['max_formula'] = Variable<String>(maxFormula);
    return map;
  }

  MetabolismCompanion toCompanion(bool nullToAbsent) {
    return MetabolismCompanion(
      id: Value(id),
      nutrientId: Value(nutrientId),
      minFormula: Value(minFormula),
      criticalFormula: Value(criticalFormula),
      optimalFormula: Value(optimalFormula),
      initialFormula: Value(initialFormula),
      maxFormula: Value(maxFormula),
    );
  }

  factory MetabolismData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetabolismData(
      id: serializer.fromJson<int>(json['id']),
      nutrientId: serializer.fromJson<int>(json['nutrientId']),
      minFormula: serializer.fromJson<String>(json['minFormula']),
      criticalFormula: serializer.fromJson<String>(json['criticalFormula']),
      optimalFormula: serializer.fromJson<String>(json['optimalFormula']),
      initialFormula: serializer.fromJson<String>(json['initialFormula']),
      maxFormula: serializer.fromJson<String>(json['maxFormula']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nutrientId': serializer.toJson<int>(nutrientId),
      'minFormula': serializer.toJson<String>(minFormula),
      'criticalFormula': serializer.toJson<String>(criticalFormula),
      'optimalFormula': serializer.toJson<String>(optimalFormula),
      'initialFormula': serializer.toJson<String>(initialFormula),
      'maxFormula': serializer.toJson<String>(maxFormula),
    };
  }

  MetabolismData copyWith({
    int? id,
    int? nutrientId,
    String? minFormula,
    String? criticalFormula,
    String? optimalFormula,
    String? initialFormula,
    String? maxFormula,
  }) => MetabolismData(
    id: id ?? this.id,
    nutrientId: nutrientId ?? this.nutrientId,
    minFormula: minFormula ?? this.minFormula,
    criticalFormula: criticalFormula ?? this.criticalFormula,
    optimalFormula: optimalFormula ?? this.optimalFormula,
    initialFormula: initialFormula ?? this.initialFormula,
    maxFormula: maxFormula ?? this.maxFormula,
  );
  MetabolismData copyWithCompanion(MetabolismCompanion data) {
    return MetabolismData(
      id: data.id.present ? data.id.value : this.id,
      nutrientId: data.nutrientId.present
          ? data.nutrientId.value
          : this.nutrientId,
      minFormula: data.minFormula.present
          ? data.minFormula.value
          : this.minFormula,
      criticalFormula: data.criticalFormula.present
          ? data.criticalFormula.value
          : this.criticalFormula,
      optimalFormula: data.optimalFormula.present
          ? data.optimalFormula.value
          : this.optimalFormula,
      initialFormula: data.initialFormula.present
          ? data.initialFormula.value
          : this.initialFormula,
      maxFormula: data.maxFormula.present
          ? data.maxFormula.value
          : this.maxFormula,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetabolismData(')
          ..write('id: $id, ')
          ..write('nutrientId: $nutrientId, ')
          ..write('minFormula: $minFormula, ')
          ..write('criticalFormula: $criticalFormula, ')
          ..write('optimalFormula: $optimalFormula, ')
          ..write('initialFormula: $initialFormula, ')
          ..write('maxFormula: $maxFormula')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nutrientId,
    minFormula,
    criticalFormula,
    optimalFormula,
    initialFormula,
    maxFormula,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetabolismData &&
          other.id == this.id &&
          other.nutrientId == this.nutrientId &&
          other.minFormula == this.minFormula &&
          other.criticalFormula == this.criticalFormula &&
          other.optimalFormula == this.optimalFormula &&
          other.initialFormula == this.initialFormula &&
          other.maxFormula == this.maxFormula);
}

class MetabolismCompanion extends UpdateCompanion<MetabolismData> {
  final Value<int> id;
  final Value<int> nutrientId;
  final Value<String> minFormula;
  final Value<String> criticalFormula;
  final Value<String> optimalFormula;
  final Value<String> initialFormula;
  final Value<String> maxFormula;
  const MetabolismCompanion({
    this.id = const Value.absent(),
    this.nutrientId = const Value.absent(),
    this.minFormula = const Value.absent(),
    this.criticalFormula = const Value.absent(),
    this.optimalFormula = const Value.absent(),
    this.initialFormula = const Value.absent(),
    this.maxFormula = const Value.absent(),
  });
  MetabolismCompanion.insert({
    this.id = const Value.absent(),
    required int nutrientId,
    this.minFormula = const Value.absent(),
    this.criticalFormula = const Value.absent(),
    this.optimalFormula = const Value.absent(),
    this.initialFormula = const Value.absent(),
    this.maxFormula = const Value.absent(),
  }) : nutrientId = Value(nutrientId);
  static Insertable<MetabolismData> custom({
    Expression<int>? id,
    Expression<int>? nutrientId,
    Expression<String>? minFormula,
    Expression<String>? criticalFormula,
    Expression<String>? optimalFormula,
    Expression<String>? initialFormula,
    Expression<String>? maxFormula,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nutrientId != null) 'nutrient_id': nutrientId,
      if (minFormula != null) 'min_formula': minFormula,
      if (criticalFormula != null) 'critical_formula': criticalFormula,
      if (optimalFormula != null) 'optimal_formula': optimalFormula,
      if (initialFormula != null) 'initial_formula': initialFormula,
      if (maxFormula != null) 'max_formula': maxFormula,
    });
  }

  MetabolismCompanion copyWith({
    Value<int>? id,
    Value<int>? nutrientId,
    Value<String>? minFormula,
    Value<String>? criticalFormula,
    Value<String>? optimalFormula,
    Value<String>? initialFormula,
    Value<String>? maxFormula,
  }) {
    return MetabolismCompanion(
      id: id ?? this.id,
      nutrientId: nutrientId ?? this.nutrientId,
      minFormula: minFormula ?? this.minFormula,
      criticalFormula: criticalFormula ?? this.criticalFormula,
      optimalFormula: optimalFormula ?? this.optimalFormula,
      initialFormula: initialFormula ?? this.initialFormula,
      maxFormula: maxFormula ?? this.maxFormula,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nutrientId.present) {
      map['nutrient_id'] = Variable<int>(nutrientId.value);
    }
    if (minFormula.present) {
      map['min_formula'] = Variable<String>(minFormula.value);
    }
    if (criticalFormula.present) {
      map['critical_formula'] = Variable<String>(criticalFormula.value);
    }
    if (optimalFormula.present) {
      map['optimal_formula'] = Variable<String>(optimalFormula.value);
    }
    if (initialFormula.present) {
      map['initial_formula'] = Variable<String>(initialFormula.value);
    }
    if (maxFormula.present) {
      map['max_formula'] = Variable<String>(maxFormula.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetabolismCompanion(')
          ..write('id: $id, ')
          ..write('nutrientId: $nutrientId, ')
          ..write('minFormula: $minFormula, ')
          ..write('criticalFormula: $criticalFormula, ')
          ..write('optimalFormula: $optimalFormula, ')
          ..write('initialFormula: $initialFormula, ')
          ..write('maxFormula: $maxFormula')
          ..write(')'))
        .toString();
  }
}

class $ReproductionTable extends Reproduction
    with TableInfo<$ReproductionTable, ReproductionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReproductionTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxEggsFormulaMeta = const VerificationMeta(
    'maxEggsFormula',
  );
  @override
  late final GeneratedColumn<String> maxEggsFormula = GeneratedColumn<String>(
    'max_eggs_formula',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('10'),
  );
  static const VerificationMeta _maxSpermPacksFormulaMeta =
      const VerificationMeta('maxSpermPacksFormula');
  @override
  late final GeneratedColumn<String> maxSpermPacksFormula =
      GeneratedColumn<String>(
        'max_sperm_packs_formula',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('10'),
      );
  static const VerificationMeta _packsTransferredFormulaMeta =
      const VerificationMeta('packsTransferredFormula');
  @override
  late final GeneratedColumn<String> packsTransferredFormula =
      GeneratedColumn<String>(
        'packs_transferred_formula',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('1'),
      );
  static const VerificationMeta _fractionFertilizedFormulaMeta =
      const VerificationMeta('fractionFertilizedFormula');
  @override
  late final GeneratedColumn<String> fractionFertilizedFormula =
      GeneratedColumn<String>(
        'fraction_fertilized_formula',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('0.5'),
      );
  static const VerificationMeta _paternityFormulaMeta = const VerificationMeta(
    'paternityFormula',
  );
  @override
  late final GeneratedColumn<String> paternityFormula = GeneratedColumn<String>(
    'paternity_formula',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('100'),
  );
  static const VerificationMeta _maxStoredPacksFormulaMeta =
      const VerificationMeta('maxStoredPacksFormula');
  @override
  late final GeneratedColumn<String> maxStoredPacksFormula =
      GeneratedColumn<String>(
        'max_stored_packs_formula',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('5'),
      );
  static const VerificationMeta _consumptionRateFormulaMeta =
      const VerificationMeta('consumptionRateFormula');
  @override
  late final GeneratedColumn<String> consumptionRateFormula =
      GeneratedColumn<String>(
        'consumption_rate_formula',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('0.1'),
      );
  static const VerificationMeta _eggsPerCycleFormulaMeta =
      const VerificationMeta('eggsPerCycleFormula');
  @override
  late final GeneratedColumn<String> eggsPerCycleFormula =
      GeneratedColumn<String>(
        'eggs_per_cycle_formula',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('1'),
      );
  static const VerificationMeta _eggFractionFormulaMeta =
      const VerificationMeta('eggFractionFormula');
  @override
  late final GeneratedColumn<String> eggFractionFormula =
      GeneratedColumn<String>(
        'egg_fraction_formula',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('0.5'),
      );
  static const VerificationMeta _packFractionFormulaMeta =
      const VerificationMeta('packFractionFormula');
  @override
  late final GeneratedColumn<String> packFractionFormula =
      GeneratedColumn<String>(
        'pack_fraction_formula',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('0.5'),
      );
  static const VerificationMeta _spermDegradationFormulaMeta =
      const VerificationMeta('spermDegradationFormula');
  @override
  late final GeneratedColumn<String> spermDegradationFormula =
      GeneratedColumn<String>(
        'sperm_degradation_formula',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('0.05'),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    maxEggsFormula,
    maxSpermPacksFormula,
    packsTransferredFormula,
    fractionFertilizedFormula,
    paternityFormula,
    maxStoredPacksFormula,
    consumptionRateFormula,
    eggsPerCycleFormula,
    eggFractionFormula,
    packFractionFormula,
    spermDegradationFormula,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reproduction';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReproductionData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('max_eggs_formula')) {
      context.handle(
        _maxEggsFormulaMeta,
        maxEggsFormula.isAcceptableOrUnknown(
          data['max_eggs_formula']!,
          _maxEggsFormulaMeta,
        ),
      );
    }
    if (data.containsKey('max_sperm_packs_formula')) {
      context.handle(
        _maxSpermPacksFormulaMeta,
        maxSpermPacksFormula.isAcceptableOrUnknown(
          data['max_sperm_packs_formula']!,
          _maxSpermPacksFormulaMeta,
        ),
      );
    }
    if (data.containsKey('packs_transferred_formula')) {
      context.handle(
        _packsTransferredFormulaMeta,
        packsTransferredFormula.isAcceptableOrUnknown(
          data['packs_transferred_formula']!,
          _packsTransferredFormulaMeta,
        ),
      );
    }
    if (data.containsKey('fraction_fertilized_formula')) {
      context.handle(
        _fractionFertilizedFormulaMeta,
        fractionFertilizedFormula.isAcceptableOrUnknown(
          data['fraction_fertilized_formula']!,
          _fractionFertilizedFormulaMeta,
        ),
      );
    }
    if (data.containsKey('paternity_formula')) {
      context.handle(
        _paternityFormulaMeta,
        paternityFormula.isAcceptableOrUnknown(
          data['paternity_formula']!,
          _paternityFormulaMeta,
        ),
      );
    }
    if (data.containsKey('max_stored_packs_formula')) {
      context.handle(
        _maxStoredPacksFormulaMeta,
        maxStoredPacksFormula.isAcceptableOrUnknown(
          data['max_stored_packs_formula']!,
          _maxStoredPacksFormulaMeta,
        ),
      );
    }
    if (data.containsKey('consumption_rate_formula')) {
      context.handle(
        _consumptionRateFormulaMeta,
        consumptionRateFormula.isAcceptableOrUnknown(
          data['consumption_rate_formula']!,
          _consumptionRateFormulaMeta,
        ),
      );
    }
    if (data.containsKey('eggs_per_cycle_formula')) {
      context.handle(
        _eggsPerCycleFormulaMeta,
        eggsPerCycleFormula.isAcceptableOrUnknown(
          data['eggs_per_cycle_formula']!,
          _eggsPerCycleFormulaMeta,
        ),
      );
    }
    if (data.containsKey('egg_fraction_formula')) {
      context.handle(
        _eggFractionFormulaMeta,
        eggFractionFormula.isAcceptableOrUnknown(
          data['egg_fraction_formula']!,
          _eggFractionFormulaMeta,
        ),
      );
    }
    if (data.containsKey('pack_fraction_formula')) {
      context.handle(
        _packFractionFormulaMeta,
        packFractionFormula.isAcceptableOrUnknown(
          data['pack_fraction_formula']!,
          _packFractionFormulaMeta,
        ),
      );
    }
    if (data.containsKey('sperm_degradation_formula')) {
      context.handle(
        _spermDegradationFormulaMeta,
        spermDegradationFormula.isAcceptableOrUnknown(
          data['sperm_degradation_formula']!,
          _spermDegradationFormulaMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReproductionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReproductionData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      maxEggsFormula: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}max_eggs_formula'],
      )!,
      maxSpermPacksFormula: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}max_sperm_packs_formula'],
      )!,
      packsTransferredFormula: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}packs_transferred_formula'],
      )!,
      fractionFertilizedFormula: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fraction_fertilized_formula'],
      )!,
      paternityFormula: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paternity_formula'],
      )!,
      maxStoredPacksFormula: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}max_stored_packs_formula'],
      )!,
      consumptionRateFormula: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}consumption_rate_formula'],
      )!,
      eggsPerCycleFormula: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}eggs_per_cycle_formula'],
      )!,
      eggFractionFormula: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}egg_fraction_formula'],
      )!,
      packFractionFormula: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pack_fraction_formula'],
      )!,
      spermDegradationFormula: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sperm_degradation_formula'],
      )!,
    );
  }

  @override
  $ReproductionTable createAlias(String alias) {
    return $ReproductionTable(attachedDatabase, alias);
  }
}

class ReproductionData extends DataClass
    implements Insertable<ReproductionData> {
  final int id;
  final String maxEggsFormula;
  final String maxSpermPacksFormula;
  final String packsTransferredFormula;
  final String fractionFertilizedFormula;
  final String paternityFormula;
  final String maxStoredPacksFormula;
  final String consumptionRateFormula;
  final String eggsPerCycleFormula;
  final String eggFractionFormula;
  final String packFractionFormula;
  final String spermDegradationFormula;
  const ReproductionData({
    required this.id,
    required this.maxEggsFormula,
    required this.maxSpermPacksFormula,
    required this.packsTransferredFormula,
    required this.fractionFertilizedFormula,
    required this.paternityFormula,
    required this.maxStoredPacksFormula,
    required this.consumptionRateFormula,
    required this.eggsPerCycleFormula,
    required this.eggFractionFormula,
    required this.packFractionFormula,
    required this.spermDegradationFormula,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['max_eggs_formula'] = Variable<String>(maxEggsFormula);
    map['max_sperm_packs_formula'] = Variable<String>(maxSpermPacksFormula);
    map['packs_transferred_formula'] = Variable<String>(
      packsTransferredFormula,
    );
    map['fraction_fertilized_formula'] = Variable<String>(
      fractionFertilizedFormula,
    );
    map['paternity_formula'] = Variable<String>(paternityFormula);
    map['max_stored_packs_formula'] = Variable<String>(maxStoredPacksFormula);
    map['consumption_rate_formula'] = Variable<String>(consumptionRateFormula);
    map['eggs_per_cycle_formula'] = Variable<String>(eggsPerCycleFormula);
    map['egg_fraction_formula'] = Variable<String>(eggFractionFormula);
    map['pack_fraction_formula'] = Variable<String>(packFractionFormula);
    map['sperm_degradation_formula'] = Variable<String>(
      spermDegradationFormula,
    );
    return map;
  }

  ReproductionCompanion toCompanion(bool nullToAbsent) {
    return ReproductionCompanion(
      id: Value(id),
      maxEggsFormula: Value(maxEggsFormula),
      maxSpermPacksFormula: Value(maxSpermPacksFormula),
      packsTransferredFormula: Value(packsTransferredFormula),
      fractionFertilizedFormula: Value(fractionFertilizedFormula),
      paternityFormula: Value(paternityFormula),
      maxStoredPacksFormula: Value(maxStoredPacksFormula),
      consumptionRateFormula: Value(consumptionRateFormula),
      eggsPerCycleFormula: Value(eggsPerCycleFormula),
      eggFractionFormula: Value(eggFractionFormula),
      packFractionFormula: Value(packFractionFormula),
      spermDegradationFormula: Value(spermDegradationFormula),
    );
  }

  factory ReproductionData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReproductionData(
      id: serializer.fromJson<int>(json['id']),
      maxEggsFormula: serializer.fromJson<String>(json['maxEggsFormula']),
      maxSpermPacksFormula: serializer.fromJson<String>(
        json['maxSpermPacksFormula'],
      ),
      packsTransferredFormula: serializer.fromJson<String>(
        json['packsTransferredFormula'],
      ),
      fractionFertilizedFormula: serializer.fromJson<String>(
        json['fractionFertilizedFormula'],
      ),
      paternityFormula: serializer.fromJson<String>(json['paternityFormula']),
      maxStoredPacksFormula: serializer.fromJson<String>(
        json['maxStoredPacksFormula'],
      ),
      consumptionRateFormula: serializer.fromJson<String>(
        json['consumptionRateFormula'],
      ),
      eggsPerCycleFormula: serializer.fromJson<String>(
        json['eggsPerCycleFormula'],
      ),
      eggFractionFormula: serializer.fromJson<String>(
        json['eggFractionFormula'],
      ),
      packFractionFormula: serializer.fromJson<String>(
        json['packFractionFormula'],
      ),
      spermDegradationFormula: serializer.fromJson<String>(
        json['spermDegradationFormula'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'maxEggsFormula': serializer.toJson<String>(maxEggsFormula),
      'maxSpermPacksFormula': serializer.toJson<String>(maxSpermPacksFormula),
      'packsTransferredFormula': serializer.toJson<String>(
        packsTransferredFormula,
      ),
      'fractionFertilizedFormula': serializer.toJson<String>(
        fractionFertilizedFormula,
      ),
      'paternityFormula': serializer.toJson<String>(paternityFormula),
      'maxStoredPacksFormula': serializer.toJson<String>(maxStoredPacksFormula),
      'consumptionRateFormula': serializer.toJson<String>(
        consumptionRateFormula,
      ),
      'eggsPerCycleFormula': serializer.toJson<String>(eggsPerCycleFormula),
      'eggFractionFormula': serializer.toJson<String>(eggFractionFormula),
      'packFractionFormula': serializer.toJson<String>(packFractionFormula),
      'spermDegradationFormula': serializer.toJson<String>(
        spermDegradationFormula,
      ),
    };
  }

  ReproductionData copyWith({
    int? id,
    String? maxEggsFormula,
    String? maxSpermPacksFormula,
    String? packsTransferredFormula,
    String? fractionFertilizedFormula,
    String? paternityFormula,
    String? maxStoredPacksFormula,
    String? consumptionRateFormula,
    String? eggsPerCycleFormula,
    String? eggFractionFormula,
    String? packFractionFormula,
    String? spermDegradationFormula,
  }) => ReproductionData(
    id: id ?? this.id,
    maxEggsFormula: maxEggsFormula ?? this.maxEggsFormula,
    maxSpermPacksFormula: maxSpermPacksFormula ?? this.maxSpermPacksFormula,
    packsTransferredFormula:
        packsTransferredFormula ?? this.packsTransferredFormula,
    fractionFertilizedFormula:
        fractionFertilizedFormula ?? this.fractionFertilizedFormula,
    paternityFormula: paternityFormula ?? this.paternityFormula,
    maxStoredPacksFormula: maxStoredPacksFormula ?? this.maxStoredPacksFormula,
    consumptionRateFormula:
        consumptionRateFormula ?? this.consumptionRateFormula,
    eggsPerCycleFormula: eggsPerCycleFormula ?? this.eggsPerCycleFormula,
    eggFractionFormula: eggFractionFormula ?? this.eggFractionFormula,
    packFractionFormula: packFractionFormula ?? this.packFractionFormula,
    spermDegradationFormula:
        spermDegradationFormula ?? this.spermDegradationFormula,
  );
  ReproductionData copyWithCompanion(ReproductionCompanion data) {
    return ReproductionData(
      id: data.id.present ? data.id.value : this.id,
      maxEggsFormula: data.maxEggsFormula.present
          ? data.maxEggsFormula.value
          : this.maxEggsFormula,
      maxSpermPacksFormula: data.maxSpermPacksFormula.present
          ? data.maxSpermPacksFormula.value
          : this.maxSpermPacksFormula,
      packsTransferredFormula: data.packsTransferredFormula.present
          ? data.packsTransferredFormula.value
          : this.packsTransferredFormula,
      fractionFertilizedFormula: data.fractionFertilizedFormula.present
          ? data.fractionFertilizedFormula.value
          : this.fractionFertilizedFormula,
      paternityFormula: data.paternityFormula.present
          ? data.paternityFormula.value
          : this.paternityFormula,
      maxStoredPacksFormula: data.maxStoredPacksFormula.present
          ? data.maxStoredPacksFormula.value
          : this.maxStoredPacksFormula,
      consumptionRateFormula: data.consumptionRateFormula.present
          ? data.consumptionRateFormula.value
          : this.consumptionRateFormula,
      eggsPerCycleFormula: data.eggsPerCycleFormula.present
          ? data.eggsPerCycleFormula.value
          : this.eggsPerCycleFormula,
      eggFractionFormula: data.eggFractionFormula.present
          ? data.eggFractionFormula.value
          : this.eggFractionFormula,
      packFractionFormula: data.packFractionFormula.present
          ? data.packFractionFormula.value
          : this.packFractionFormula,
      spermDegradationFormula: data.spermDegradationFormula.present
          ? data.spermDegradationFormula.value
          : this.spermDegradationFormula,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReproductionData(')
          ..write('id: $id, ')
          ..write('maxEggsFormula: $maxEggsFormula, ')
          ..write('maxSpermPacksFormula: $maxSpermPacksFormula, ')
          ..write('packsTransferredFormula: $packsTransferredFormula, ')
          ..write('fractionFertilizedFormula: $fractionFertilizedFormula, ')
          ..write('paternityFormula: $paternityFormula, ')
          ..write('maxStoredPacksFormula: $maxStoredPacksFormula, ')
          ..write('consumptionRateFormula: $consumptionRateFormula, ')
          ..write('eggsPerCycleFormula: $eggsPerCycleFormula, ')
          ..write('eggFractionFormula: $eggFractionFormula, ')
          ..write('packFractionFormula: $packFractionFormula, ')
          ..write('spermDegradationFormula: $spermDegradationFormula')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    maxEggsFormula,
    maxSpermPacksFormula,
    packsTransferredFormula,
    fractionFertilizedFormula,
    paternityFormula,
    maxStoredPacksFormula,
    consumptionRateFormula,
    eggsPerCycleFormula,
    eggFractionFormula,
    packFractionFormula,
    spermDegradationFormula,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReproductionData &&
          other.id == this.id &&
          other.maxEggsFormula == this.maxEggsFormula &&
          other.maxSpermPacksFormula == this.maxSpermPacksFormula &&
          other.packsTransferredFormula == this.packsTransferredFormula &&
          other.fractionFertilizedFormula == this.fractionFertilizedFormula &&
          other.paternityFormula == this.paternityFormula &&
          other.maxStoredPacksFormula == this.maxStoredPacksFormula &&
          other.consumptionRateFormula == this.consumptionRateFormula &&
          other.eggsPerCycleFormula == this.eggsPerCycleFormula &&
          other.eggFractionFormula == this.eggFractionFormula &&
          other.packFractionFormula == this.packFractionFormula &&
          other.spermDegradationFormula == this.spermDegradationFormula);
}

class ReproductionCompanion extends UpdateCompanion<ReproductionData> {
  final Value<int> id;
  final Value<String> maxEggsFormula;
  final Value<String> maxSpermPacksFormula;
  final Value<String> packsTransferredFormula;
  final Value<String> fractionFertilizedFormula;
  final Value<String> paternityFormula;
  final Value<String> maxStoredPacksFormula;
  final Value<String> consumptionRateFormula;
  final Value<String> eggsPerCycleFormula;
  final Value<String> eggFractionFormula;
  final Value<String> packFractionFormula;
  final Value<String> spermDegradationFormula;
  const ReproductionCompanion({
    this.id = const Value.absent(),
    this.maxEggsFormula = const Value.absent(),
    this.maxSpermPacksFormula = const Value.absent(),
    this.packsTransferredFormula = const Value.absent(),
    this.fractionFertilizedFormula = const Value.absent(),
    this.paternityFormula = const Value.absent(),
    this.maxStoredPacksFormula = const Value.absent(),
    this.consumptionRateFormula = const Value.absent(),
    this.eggsPerCycleFormula = const Value.absent(),
    this.eggFractionFormula = const Value.absent(),
    this.packFractionFormula = const Value.absent(),
    this.spermDegradationFormula = const Value.absent(),
  });
  ReproductionCompanion.insert({
    this.id = const Value.absent(),
    this.maxEggsFormula = const Value.absent(),
    this.maxSpermPacksFormula = const Value.absent(),
    this.packsTransferredFormula = const Value.absent(),
    this.fractionFertilizedFormula = const Value.absent(),
    this.paternityFormula = const Value.absent(),
    this.maxStoredPacksFormula = const Value.absent(),
    this.consumptionRateFormula = const Value.absent(),
    this.eggsPerCycleFormula = const Value.absent(),
    this.eggFractionFormula = const Value.absent(),
    this.packFractionFormula = const Value.absent(),
    this.spermDegradationFormula = const Value.absent(),
  });
  static Insertable<ReproductionData> custom({
    Expression<int>? id,
    Expression<String>? maxEggsFormula,
    Expression<String>? maxSpermPacksFormula,
    Expression<String>? packsTransferredFormula,
    Expression<String>? fractionFertilizedFormula,
    Expression<String>? paternityFormula,
    Expression<String>? maxStoredPacksFormula,
    Expression<String>? consumptionRateFormula,
    Expression<String>? eggsPerCycleFormula,
    Expression<String>? eggFractionFormula,
    Expression<String>? packFractionFormula,
    Expression<String>? spermDegradationFormula,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (maxEggsFormula != null) 'max_eggs_formula': maxEggsFormula,
      if (maxSpermPacksFormula != null)
        'max_sperm_packs_formula': maxSpermPacksFormula,
      if (packsTransferredFormula != null)
        'packs_transferred_formula': packsTransferredFormula,
      if (fractionFertilizedFormula != null)
        'fraction_fertilized_formula': fractionFertilizedFormula,
      if (paternityFormula != null) 'paternity_formula': paternityFormula,
      if (maxStoredPacksFormula != null)
        'max_stored_packs_formula': maxStoredPacksFormula,
      if (consumptionRateFormula != null)
        'consumption_rate_formula': consumptionRateFormula,
      if (eggsPerCycleFormula != null)
        'eggs_per_cycle_formula': eggsPerCycleFormula,
      if (eggFractionFormula != null)
        'egg_fraction_formula': eggFractionFormula,
      if (packFractionFormula != null)
        'pack_fraction_formula': packFractionFormula,
      if (spermDegradationFormula != null)
        'sperm_degradation_formula': spermDegradationFormula,
    });
  }

  ReproductionCompanion copyWith({
    Value<int>? id,
    Value<String>? maxEggsFormula,
    Value<String>? maxSpermPacksFormula,
    Value<String>? packsTransferredFormula,
    Value<String>? fractionFertilizedFormula,
    Value<String>? paternityFormula,
    Value<String>? maxStoredPacksFormula,
    Value<String>? consumptionRateFormula,
    Value<String>? eggsPerCycleFormula,
    Value<String>? eggFractionFormula,
    Value<String>? packFractionFormula,
    Value<String>? spermDegradationFormula,
  }) {
    return ReproductionCompanion(
      id: id ?? this.id,
      maxEggsFormula: maxEggsFormula ?? this.maxEggsFormula,
      maxSpermPacksFormula: maxSpermPacksFormula ?? this.maxSpermPacksFormula,
      packsTransferredFormula:
          packsTransferredFormula ?? this.packsTransferredFormula,
      fractionFertilizedFormula:
          fractionFertilizedFormula ?? this.fractionFertilizedFormula,
      paternityFormula: paternityFormula ?? this.paternityFormula,
      maxStoredPacksFormula:
          maxStoredPacksFormula ?? this.maxStoredPacksFormula,
      consumptionRateFormula:
          consumptionRateFormula ?? this.consumptionRateFormula,
      eggsPerCycleFormula: eggsPerCycleFormula ?? this.eggsPerCycleFormula,
      eggFractionFormula: eggFractionFormula ?? this.eggFractionFormula,
      packFractionFormula: packFractionFormula ?? this.packFractionFormula,
      spermDegradationFormula:
          spermDegradationFormula ?? this.spermDegradationFormula,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (maxEggsFormula.present) {
      map['max_eggs_formula'] = Variable<String>(maxEggsFormula.value);
    }
    if (maxSpermPacksFormula.present) {
      map['max_sperm_packs_formula'] = Variable<String>(
        maxSpermPacksFormula.value,
      );
    }
    if (packsTransferredFormula.present) {
      map['packs_transferred_formula'] = Variable<String>(
        packsTransferredFormula.value,
      );
    }
    if (fractionFertilizedFormula.present) {
      map['fraction_fertilized_formula'] = Variable<String>(
        fractionFertilizedFormula.value,
      );
    }
    if (paternityFormula.present) {
      map['paternity_formula'] = Variable<String>(paternityFormula.value);
    }
    if (maxStoredPacksFormula.present) {
      map['max_stored_packs_formula'] = Variable<String>(
        maxStoredPacksFormula.value,
      );
    }
    if (consumptionRateFormula.present) {
      map['consumption_rate_formula'] = Variable<String>(
        consumptionRateFormula.value,
      );
    }
    if (eggsPerCycleFormula.present) {
      map['eggs_per_cycle_formula'] = Variable<String>(
        eggsPerCycleFormula.value,
      );
    }
    if (eggFractionFormula.present) {
      map['egg_fraction_formula'] = Variable<String>(eggFractionFormula.value);
    }
    if (packFractionFormula.present) {
      map['pack_fraction_formula'] = Variable<String>(
        packFractionFormula.value,
      );
    }
    if (spermDegradationFormula.present) {
      map['sperm_degradation_formula'] = Variable<String>(
        spermDegradationFormula.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReproductionCompanion(')
          ..write('id: $id, ')
          ..write('maxEggsFormula: $maxEggsFormula, ')
          ..write('maxSpermPacksFormula: $maxSpermPacksFormula, ')
          ..write('packsTransferredFormula: $packsTransferredFormula, ')
          ..write('fractionFertilizedFormula: $fractionFertilizedFormula, ')
          ..write('paternityFormula: $paternityFormula, ')
          ..write('maxStoredPacksFormula: $maxStoredPacksFormula, ')
          ..write('consumptionRateFormula: $consumptionRateFormula, ')
          ..write('eggsPerCycleFormula: $eggsPerCycleFormula, ')
          ..write('eggFractionFormula: $eggFractionFormula, ')
          ..write('packFractionFormula: $packFractionFormula, ')
          ..write('spermDegradationFormula: $spermDegradationFormula')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProjectInfoTable projectInfo = $ProjectInfoTable(this);
  late final $NutrientsTable nutrients = $NutrientsTable(this);
  late final $SubstratesTable substrates = $SubstratesTable(this);
  late final $SubstrateCompositionsTable substrateCompositions =
      $SubstrateCompositionsTable(this);
  late final $LociTable loci = $LociTable(this);
  late final $StagesTable stages = $StagesTable(this);
  late final $PrototypesTable prototypes = $PrototypesTable(this);
  late final $ResourceTypesTable resourceTypes = $ResourceTypesTable(this);
  late final $EnvironmentsTable environments = $EnvironmentsTable(this);
  late final $SubstrateMapRowsTable substrateMapRows = $SubstrateMapRowsTable(
    this,
  );
  late final $EnvironmentResourcesTable environmentResources =
      $EnvironmentResourcesTable(this);
  late final $EnvironmentAgentsTable environmentAgents =
      $EnvironmentAgentsTable(this);
  late final $MetabolismTable metabolism = $MetabolismTable(this);
  late final $ReproductionTable reproduction = $ReproductionTable(this);
  late final ProjectInfoDao projectInfoDao = ProjectInfoDao(
    this as AppDatabase,
  );
  late final NutrientDao nutrientDao = NutrientDao(this as AppDatabase);
  late final SubstrateDao substrateDao = SubstrateDao(this as AppDatabase);
  late final LocusDao locusDao = LocusDao(this as AppDatabase);
  late final StageDao stageDao = StageDao(this as AppDatabase);
  late final PrototypeDao prototypeDao = PrototypeDao(this as AppDatabase);
  late final ResourceTypeDao resourceTypeDao = ResourceTypeDao(
    this as AppDatabase,
  );
  late final EnvironmentDao environmentDao = EnvironmentDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    projectInfo,
    nutrients,
    substrates,
    substrateCompositions,
    loci,
    stages,
    prototypes,
    resourceTypes,
    environments,
    substrateMapRows,
    environmentResources,
    environmentAgents,
    metabolism,
    reproduction,
  ];
}

typedef $$ProjectInfoTableCreateCompanionBuilder =
    ProjectInfoCompanion Function({
      Value<int> id,
      required String name,
      Value<String> description,
      Value<String> createdAt,
      Value<String> updatedAt,
    });
typedef $$ProjectInfoTableUpdateCompanionBuilder =
    ProjectInfoCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> description,
      Value<String> createdAt,
      Value<String> updatedAt,
    });

class $$ProjectInfoTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectInfoTable> {
  $$ProjectInfoTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProjectInfoTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectInfoTable> {
  $$ProjectInfoTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProjectInfoTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectInfoTable> {
  $$ProjectInfoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProjectInfoTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectInfoTable,
          ProjectInfoData,
          $$ProjectInfoTableFilterComposer,
          $$ProjectInfoTableOrderingComposer,
          $$ProjectInfoTableAnnotationComposer,
          $$ProjectInfoTableCreateCompanionBuilder,
          $$ProjectInfoTableUpdateCompanionBuilder,
          (
            ProjectInfoData,
            BaseReferences<_$AppDatabase, $ProjectInfoTable, ProjectInfoData>,
          ),
          ProjectInfoData,
          PrefetchHooks Function()
        > {
  $$ProjectInfoTableTableManager(_$AppDatabase db, $ProjectInfoTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectInfoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectInfoTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectInfoTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
              }) => ProjectInfoCompanion(
                id: id,
                name: name,
                description: description,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> description = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
              }) => ProjectInfoCompanion.insert(
                id: id,
                name: name,
                description: description,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProjectInfoTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectInfoTable,
      ProjectInfoData,
      $$ProjectInfoTableFilterComposer,
      $$ProjectInfoTableOrderingComposer,
      $$ProjectInfoTableAnnotationComposer,
      $$ProjectInfoTableCreateCompanionBuilder,
      $$ProjectInfoTableUpdateCompanionBuilder,
      (
        ProjectInfoData,
        BaseReferences<_$AppDatabase, $ProjectInfoTable, ProjectInfoData>,
      ),
      ProjectInfoData,
      PrefetchHooks Function()
    >;
typedef $$NutrientsTableCreateCompanionBuilder =
    NutrientsCompanion Function({
      Value<int> id,
      required String name,
      Value<int> sortOrder,
    });
typedef $$NutrientsTableUpdateCompanionBuilder =
    NutrientsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> sortOrder,
    });

final class $$NutrientsTableReferences
    extends BaseReferences<_$AppDatabase, $NutrientsTable, Nutrient> {
  $$NutrientsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ResourceTypesTable, List<ResourceType>>
  _resourceTypesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.resourceTypes,
    aliasName: 'nutrients__id__resource_types__nutrient_id',
  );

  $$ResourceTypesTableProcessedTableManager get resourceTypesRefs {
    final manager = $$ResourceTypesTableTableManager(
      $_db,
      $_db.resourceTypes,
    ).filter((f) => f.nutrientId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_resourceTypesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MetabolismTable, List<MetabolismData>>
  _metabolismRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.metabolism,
    aliasName: 'nutrients__id__metabolism__nutrient_id',
  );

  $$MetabolismTableProcessedTableManager get metabolismRefs {
    final manager = $$MetabolismTableTableManager(
      $_db,
      $_db.metabolism,
    ).filter((f) => f.nutrientId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_metabolismRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$NutrientsTableFilterComposer
    extends Composer<_$AppDatabase, $NutrientsTable> {
  $$NutrientsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> resourceTypesRefs(
    Expression<bool> Function($$ResourceTypesTableFilterComposer f) f,
  ) {
    final $$ResourceTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.resourceTypes,
      getReferencedColumn: (t) => t.nutrientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourceTypesTableFilterComposer(
            $db: $db,
            $table: $db.resourceTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> metabolismRefs(
    Expression<bool> Function($$MetabolismTableFilterComposer f) f,
  ) {
    final $$MetabolismTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.metabolism,
      getReferencedColumn: (t) => t.nutrientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MetabolismTableFilterComposer(
            $db: $db,
            $table: $db.metabolism,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NutrientsTableOrderingComposer
    extends Composer<_$AppDatabase, $NutrientsTable> {
  $$NutrientsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NutrientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NutrientsTable> {
  $$NutrientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> resourceTypesRefs<T extends Object>(
    Expression<T> Function($$ResourceTypesTableAnnotationComposer a) f,
  ) {
    final $$ResourceTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.resourceTypes,
      getReferencedColumn: (t) => t.nutrientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourceTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.resourceTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> metabolismRefs<T extends Object>(
    Expression<T> Function($$MetabolismTableAnnotationComposer a) f,
  ) {
    final $$MetabolismTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.metabolism,
      getReferencedColumn: (t) => t.nutrientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MetabolismTableAnnotationComposer(
            $db: $db,
            $table: $db.metabolism,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NutrientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NutrientsTable,
          Nutrient,
          $$NutrientsTableFilterComposer,
          $$NutrientsTableOrderingComposer,
          $$NutrientsTableAnnotationComposer,
          $$NutrientsTableCreateCompanionBuilder,
          $$NutrientsTableUpdateCompanionBuilder,
          (Nutrient, $$NutrientsTableReferences),
          Nutrient,
          PrefetchHooks Function({bool resourceTypesRefs, bool metabolismRefs})
        > {
  $$NutrientsTableTableManager(_$AppDatabase db, $NutrientsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NutrientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NutrientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NutrientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) =>
                  NutrientsCompanion(id: id, name: name, sortOrder: sortOrder),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int> sortOrder = const Value.absent(),
              }) => NutrientsCompanion.insert(
                id: id,
                name: name,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NutrientsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({resourceTypesRefs = false, metabolismRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (resourceTypesRefs) db.resourceTypes,
                    if (metabolismRefs) db.metabolism,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (resourceTypesRefs)
                        await $_getPrefetchedData<
                          Nutrient,
                          $NutrientsTable,
                          ResourceType
                        >(
                          currentTable: table,
                          referencedTable: $$NutrientsTableReferences
                              ._resourceTypesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NutrientsTableReferences(
                                db,
                                table,
                                p0,
                              ).resourceTypesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.nutrientId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (metabolismRefs)
                        await $_getPrefetchedData<
                          Nutrient,
                          $NutrientsTable,
                          MetabolismData
                        >(
                          currentTable: table,
                          referencedTable: $$NutrientsTableReferences
                              ._metabolismRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NutrientsTableReferences(
                                db,
                                table,
                                p0,
                              ).metabolismRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.nutrientId == item.id,
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

typedef $$NutrientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NutrientsTable,
      Nutrient,
      $$NutrientsTableFilterComposer,
      $$NutrientsTableOrderingComposer,
      $$NutrientsTableAnnotationComposer,
      $$NutrientsTableCreateCompanionBuilder,
      $$NutrientsTableUpdateCompanionBuilder,
      (Nutrient, $$NutrientsTableReferences),
      Nutrient,
      PrefetchHooks Function({bool resourceTypesRefs, bool metabolismRefs})
    >;
typedef $$SubstratesTableCreateCompanionBuilder =
    SubstratesCompanion Function({
      Value<int> id,
      required String name,
      Value<int> color,
      Value<bool> isMixed,
      Value<int> sortOrder,
    });
typedef $$SubstratesTableUpdateCompanionBuilder =
    SubstratesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> color,
      Value<bool> isMixed,
      Value<int> sortOrder,
    });

final class $$SubstratesTableReferences
    extends BaseReferences<_$AppDatabase, $SubstratesTable, Substrate> {
  $$SubstratesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $SubstrateCompositionsTable,
    List<SubstrateComposition>
  >
  _mixedSubstrateCompositionsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.substrateCompositions,
        aliasName: 'substrates__id__substrate_compositions__mixed_substrate_id',
      );

  $$SubstrateCompositionsTableProcessedTableManager
  get mixedSubstrateCompositions {
    final manager = $$SubstrateCompositionsTableTableManager(
      $_db,
      $_db.substrateCompositions,
    ).filter((f) => f.mixedSubstrateId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _mixedSubstrateCompositionsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $SubstrateCompositionsTable,
    List<SubstrateComposition>
  >
  _simpleSubstrateCompositionsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.substrateCompositions,
        aliasName:
            'substrates__id__substrate_compositions__simple_substrate_id',
      );

  $$SubstrateCompositionsTableProcessedTableManager
  get simpleSubstrateCompositions {
    final manager = $$SubstrateCompositionsTableTableManager(
      $_db,
      $_db.substrateCompositions,
    ).filter((f) => f.simpleSubstrateId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _simpleSubstrateCompositionsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SubstratesTableFilterComposer
    extends Composer<_$AppDatabase, $SubstratesTable> {
  $$SubstratesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMixed => $composableBuilder(
    column: $table.isMixed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> mixedSubstrateCompositions(
    Expression<bool> Function($$SubstrateCompositionsTableFilterComposer f) f,
  ) {
    final $$SubstrateCompositionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.substrateCompositions,
          getReferencedColumn: (t) => t.mixedSubstrateId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SubstrateCompositionsTableFilterComposer(
                $db: $db,
                $table: $db.substrateCompositions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> simpleSubstrateCompositions(
    Expression<bool> Function($$SubstrateCompositionsTableFilterComposer f) f,
  ) {
    final $$SubstrateCompositionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.substrateCompositions,
          getReferencedColumn: (t) => t.simpleSubstrateId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SubstrateCompositionsTableFilterComposer(
                $db: $db,
                $table: $db.substrateCompositions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SubstratesTableOrderingComposer
    extends Composer<_$AppDatabase, $SubstratesTable> {
  $$SubstratesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMixed => $composableBuilder(
    column: $table.isMixed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubstratesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubstratesTable> {
  $$SubstratesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get isMixed =>
      $composableBuilder(column: $table.isMixed, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> mixedSubstrateCompositions<T extends Object>(
    Expression<T> Function($$SubstrateCompositionsTableAnnotationComposer a) f,
  ) {
    final $$SubstrateCompositionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.substrateCompositions,
          getReferencedColumn: (t) => t.mixedSubstrateId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SubstrateCompositionsTableAnnotationComposer(
                $db: $db,
                $table: $db.substrateCompositions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> simpleSubstrateCompositions<T extends Object>(
    Expression<T> Function($$SubstrateCompositionsTableAnnotationComposer a) f,
  ) {
    final $$SubstrateCompositionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.substrateCompositions,
          getReferencedColumn: (t) => t.simpleSubstrateId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SubstrateCompositionsTableAnnotationComposer(
                $db: $db,
                $table: $db.substrateCompositions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SubstratesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubstratesTable,
          Substrate,
          $$SubstratesTableFilterComposer,
          $$SubstratesTableOrderingComposer,
          $$SubstratesTableAnnotationComposer,
          $$SubstratesTableCreateCompanionBuilder,
          $$SubstratesTableUpdateCompanionBuilder,
          (Substrate, $$SubstratesTableReferences),
          Substrate,
          PrefetchHooks Function({
            bool mixedSubstrateCompositions,
            bool simpleSubstrateCompositions,
          })
        > {
  $$SubstratesTableTableManager(_$AppDatabase db, $SubstratesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubstratesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubstratesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubstratesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<bool> isMixed = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => SubstratesCompanion(
                id: id,
                name: name,
                color: color,
                isMixed: isMixed,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int> color = const Value.absent(),
                Value<bool> isMixed = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => SubstratesCompanion.insert(
                id: id,
                name: name,
                color: color,
                isMixed: isMixed,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SubstratesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                mixedSubstrateCompositions = false,
                simpleSubstrateCompositions = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (mixedSubstrateCompositions) db.substrateCompositions,
                    if (simpleSubstrateCompositions) db.substrateCompositions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (mixedSubstrateCompositions)
                        await $_getPrefetchedData<
                          Substrate,
                          $SubstratesTable,
                          SubstrateComposition
                        >(
                          currentTable: table,
                          referencedTable: $$SubstratesTableReferences
                              ._mixedSubstrateCompositionsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SubstratesTableReferences(
                                db,
                                table,
                                p0,
                              ).mixedSubstrateCompositions,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mixedSubstrateId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (simpleSubstrateCompositions)
                        await $_getPrefetchedData<
                          Substrate,
                          $SubstratesTable,
                          SubstrateComposition
                        >(
                          currentTable: table,
                          referencedTable: $$SubstratesTableReferences
                              ._simpleSubstrateCompositionsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SubstratesTableReferences(
                                db,
                                table,
                                p0,
                              ).simpleSubstrateCompositions,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.simpleSubstrateId == item.id,
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

typedef $$SubstratesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubstratesTable,
      Substrate,
      $$SubstratesTableFilterComposer,
      $$SubstratesTableOrderingComposer,
      $$SubstratesTableAnnotationComposer,
      $$SubstratesTableCreateCompanionBuilder,
      $$SubstratesTableUpdateCompanionBuilder,
      (Substrate, $$SubstratesTableReferences),
      Substrate,
      PrefetchHooks Function({
        bool mixedSubstrateCompositions,
        bool simpleSubstrateCompositions,
      })
    >;
typedef $$SubstrateCompositionsTableCreateCompanionBuilder =
    SubstrateCompositionsCompanion Function({
      Value<int> id,
      required int mixedSubstrateId,
      required int simpleSubstrateId,
      Value<int> percentage,
    });
typedef $$SubstrateCompositionsTableUpdateCompanionBuilder =
    SubstrateCompositionsCompanion Function({
      Value<int> id,
      Value<int> mixedSubstrateId,
      Value<int> simpleSubstrateId,
      Value<int> percentage,
    });

final class $$SubstrateCompositionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SubstrateCompositionsTable,
          SubstrateComposition
        > {
  $$SubstrateCompositionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SubstratesTable _mixedSubstrateIdTable(_$AppDatabase db) =>
      db.substrates.createAlias(
        'substrate_compositions__mixed_substrate_id__substrates__id',
      );

  $$SubstratesTableProcessedTableManager get mixedSubstrateId {
    final $_column = $_itemColumn<int>('mixed_substrate_id')!;

    final manager = $$SubstratesTableTableManager(
      $_db,
      $_db.substrates,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mixedSubstrateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SubstratesTable _simpleSubstrateIdTable(_$AppDatabase db) =>
      db.substrates.createAlias(
        'substrate_compositions__simple_substrate_id__substrates__id',
      );

  $$SubstratesTableProcessedTableManager get simpleSubstrateId {
    final $_column = $_itemColumn<int>('simple_substrate_id')!;

    final manager = $$SubstratesTableTableManager(
      $_db,
      $_db.substrates,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_simpleSubstrateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SubstrateCompositionsTableFilterComposer
    extends Composer<_$AppDatabase, $SubstrateCompositionsTable> {
  $$SubstrateCompositionsTableFilterComposer({
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

  ColumnFilters<int> get percentage => $composableBuilder(
    column: $table.percentage,
    builder: (column) => ColumnFilters(column),
  );

  $$SubstratesTableFilterComposer get mixedSubstrateId {
    final $$SubstratesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mixedSubstrateId,
      referencedTable: $db.substrates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubstratesTableFilterComposer(
            $db: $db,
            $table: $db.substrates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubstratesTableFilterComposer get simpleSubstrateId {
    final $$SubstratesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.simpleSubstrateId,
      referencedTable: $db.substrates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubstratesTableFilterComposer(
            $db: $db,
            $table: $db.substrates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubstrateCompositionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubstrateCompositionsTable> {
  $$SubstrateCompositionsTableOrderingComposer({
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

  ColumnOrderings<int> get percentage => $composableBuilder(
    column: $table.percentage,
    builder: (column) => ColumnOrderings(column),
  );

  $$SubstratesTableOrderingComposer get mixedSubstrateId {
    final $$SubstratesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mixedSubstrateId,
      referencedTable: $db.substrates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubstratesTableOrderingComposer(
            $db: $db,
            $table: $db.substrates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubstratesTableOrderingComposer get simpleSubstrateId {
    final $$SubstratesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.simpleSubstrateId,
      referencedTable: $db.substrates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubstratesTableOrderingComposer(
            $db: $db,
            $table: $db.substrates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubstrateCompositionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubstrateCompositionsTable> {
  $$SubstrateCompositionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get percentage => $composableBuilder(
    column: $table.percentage,
    builder: (column) => column,
  );

  $$SubstratesTableAnnotationComposer get mixedSubstrateId {
    final $$SubstratesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mixedSubstrateId,
      referencedTable: $db.substrates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubstratesTableAnnotationComposer(
            $db: $db,
            $table: $db.substrates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubstratesTableAnnotationComposer get simpleSubstrateId {
    final $$SubstratesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.simpleSubstrateId,
      referencedTable: $db.substrates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubstratesTableAnnotationComposer(
            $db: $db,
            $table: $db.substrates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubstrateCompositionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubstrateCompositionsTable,
          SubstrateComposition,
          $$SubstrateCompositionsTableFilterComposer,
          $$SubstrateCompositionsTableOrderingComposer,
          $$SubstrateCompositionsTableAnnotationComposer,
          $$SubstrateCompositionsTableCreateCompanionBuilder,
          $$SubstrateCompositionsTableUpdateCompanionBuilder,
          (SubstrateComposition, $$SubstrateCompositionsTableReferences),
          SubstrateComposition,
          PrefetchHooks Function({
            bool mixedSubstrateId,
            bool simpleSubstrateId,
          })
        > {
  $$SubstrateCompositionsTableTableManager(
    _$AppDatabase db,
    $SubstrateCompositionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubstrateCompositionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SubstrateCompositionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SubstrateCompositionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> mixedSubstrateId = const Value.absent(),
                Value<int> simpleSubstrateId = const Value.absent(),
                Value<int> percentage = const Value.absent(),
              }) => SubstrateCompositionsCompanion(
                id: id,
                mixedSubstrateId: mixedSubstrateId,
                simpleSubstrateId: simpleSubstrateId,
                percentage: percentage,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int mixedSubstrateId,
                required int simpleSubstrateId,
                Value<int> percentage = const Value.absent(),
              }) => SubstrateCompositionsCompanion.insert(
                id: id,
                mixedSubstrateId: mixedSubstrateId,
                simpleSubstrateId: simpleSubstrateId,
                percentage: percentage,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SubstrateCompositionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({mixedSubstrateId = false, simpleSubstrateId = false}) {
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
                        if (mixedSubstrateId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.mixedSubstrateId,
                                    referencedTable:
                                        $$SubstrateCompositionsTableReferences
                                            ._mixedSubstrateIdTable(db),
                                    referencedColumn:
                                        $$SubstrateCompositionsTableReferences
                                            ._mixedSubstrateIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (simpleSubstrateId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.simpleSubstrateId,
                                    referencedTable:
                                        $$SubstrateCompositionsTableReferences
                                            ._simpleSubstrateIdTable(db),
                                    referencedColumn:
                                        $$SubstrateCompositionsTableReferences
                                            ._simpleSubstrateIdTable(db)
                                            .id,
                                  )
                                  as T;
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

typedef $$SubstrateCompositionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubstrateCompositionsTable,
      SubstrateComposition,
      $$SubstrateCompositionsTableFilterComposer,
      $$SubstrateCompositionsTableOrderingComposer,
      $$SubstrateCompositionsTableAnnotationComposer,
      $$SubstrateCompositionsTableCreateCompanionBuilder,
      $$SubstrateCompositionsTableUpdateCompanionBuilder,
      (SubstrateComposition, $$SubstrateCompositionsTableReferences),
      SubstrateComposition,
      PrefetchHooks Function({bool mixedSubstrateId, bool simpleSubstrateId})
    >;
typedef $$LociTableCreateCompanionBuilder =
    LociCompanion Function({
      Value<int> id,
      required String name,
      Value<bool> isContinuous,
      Value<double> dominantValue,
      Value<double> recessiveValue,
      Value<double> mutationRateDom,
      Value<double> mutationRateRec,
      Value<double> mutationRangeDom,
      Value<double> mutationRangeRec,
      Value<String> defaultExpression,
      Value<int> sortOrder,
    });
typedef $$LociTableUpdateCompanionBuilder =
    LociCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<bool> isContinuous,
      Value<double> dominantValue,
      Value<double> recessiveValue,
      Value<double> mutationRateDom,
      Value<double> mutationRateRec,
      Value<double> mutationRangeDom,
      Value<double> mutationRangeRec,
      Value<String> defaultExpression,
      Value<int> sortOrder,
    });

class $$LociTableFilterComposer extends Composer<_$AppDatabase, $LociTable> {
  $$LociTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isContinuous => $composableBuilder(
    column: $table.isContinuous,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dominantValue => $composableBuilder(
    column: $table.dominantValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get recessiveValue => $composableBuilder(
    column: $table.recessiveValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get mutationRateDom => $composableBuilder(
    column: $table.mutationRateDom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get mutationRateRec => $composableBuilder(
    column: $table.mutationRateRec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get mutationRangeDom => $composableBuilder(
    column: $table.mutationRangeDom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get mutationRangeRec => $composableBuilder(
    column: $table.mutationRangeRec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultExpression => $composableBuilder(
    column: $table.defaultExpression,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LociTableOrderingComposer extends Composer<_$AppDatabase, $LociTable> {
  $$LociTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isContinuous => $composableBuilder(
    column: $table.isContinuous,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dominantValue => $composableBuilder(
    column: $table.dominantValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get recessiveValue => $composableBuilder(
    column: $table.recessiveValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get mutationRateDom => $composableBuilder(
    column: $table.mutationRateDom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get mutationRateRec => $composableBuilder(
    column: $table.mutationRateRec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get mutationRangeDom => $composableBuilder(
    column: $table.mutationRangeDom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get mutationRangeRec => $composableBuilder(
    column: $table.mutationRangeRec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultExpression => $composableBuilder(
    column: $table.defaultExpression,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LociTableAnnotationComposer
    extends Composer<_$AppDatabase, $LociTable> {
  $$LociTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isContinuous => $composableBuilder(
    column: $table.isContinuous,
    builder: (column) => column,
  );

  GeneratedColumn<double> get dominantValue => $composableBuilder(
    column: $table.dominantValue,
    builder: (column) => column,
  );

  GeneratedColumn<double> get recessiveValue => $composableBuilder(
    column: $table.recessiveValue,
    builder: (column) => column,
  );

  GeneratedColumn<double> get mutationRateDom => $composableBuilder(
    column: $table.mutationRateDom,
    builder: (column) => column,
  );

  GeneratedColumn<double> get mutationRateRec => $composableBuilder(
    column: $table.mutationRateRec,
    builder: (column) => column,
  );

  GeneratedColumn<double> get mutationRangeDom => $composableBuilder(
    column: $table.mutationRangeDom,
    builder: (column) => column,
  );

  GeneratedColumn<double> get mutationRangeRec => $composableBuilder(
    column: $table.mutationRangeRec,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultExpression => $composableBuilder(
    column: $table.defaultExpression,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$LociTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LociTable,
          LociData,
          $$LociTableFilterComposer,
          $$LociTableOrderingComposer,
          $$LociTableAnnotationComposer,
          $$LociTableCreateCompanionBuilder,
          $$LociTableUpdateCompanionBuilder,
          (LociData, BaseReferences<_$AppDatabase, $LociTable, LociData>),
          LociData,
          PrefetchHooks Function()
        > {
  $$LociTableTableManager(_$AppDatabase db, $LociTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LociTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LociTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LociTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isContinuous = const Value.absent(),
                Value<double> dominantValue = const Value.absent(),
                Value<double> recessiveValue = const Value.absent(),
                Value<double> mutationRateDom = const Value.absent(),
                Value<double> mutationRateRec = const Value.absent(),
                Value<double> mutationRangeDom = const Value.absent(),
                Value<double> mutationRangeRec = const Value.absent(),
                Value<String> defaultExpression = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => LociCompanion(
                id: id,
                name: name,
                isContinuous: isContinuous,
                dominantValue: dominantValue,
                recessiveValue: recessiveValue,
                mutationRateDom: mutationRateDom,
                mutationRateRec: mutationRateRec,
                mutationRangeDom: mutationRangeDom,
                mutationRangeRec: mutationRangeRec,
                defaultExpression: defaultExpression,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<bool> isContinuous = const Value.absent(),
                Value<double> dominantValue = const Value.absent(),
                Value<double> recessiveValue = const Value.absent(),
                Value<double> mutationRateDom = const Value.absent(),
                Value<double> mutationRateRec = const Value.absent(),
                Value<double> mutationRangeDom = const Value.absent(),
                Value<double> mutationRangeRec = const Value.absent(),
                Value<String> defaultExpression = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => LociCompanion.insert(
                id: id,
                name: name,
                isContinuous: isContinuous,
                dominantValue: dominantValue,
                recessiveValue: recessiveValue,
                mutationRateDom: mutationRateDom,
                mutationRateRec: mutationRateRec,
                mutationRangeDom: mutationRangeDom,
                mutationRangeRec: mutationRangeRec,
                defaultExpression: defaultExpression,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LociTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LociTable,
      LociData,
      $$LociTableFilterComposer,
      $$LociTableOrderingComposer,
      $$LociTableAnnotationComposer,
      $$LociTableCreateCompanionBuilder,
      $$LociTableUpdateCompanionBuilder,
      (LociData, BaseReferences<_$AppDatabase, $LociTable, LociData>),
      LociData,
      PrefetchHooks Function()
    >;
typedef $$StagesTableCreateCompanionBuilder =
    StagesCompanion Function({
      Value<int> id,
      required String name,
      Value<int> sortOrder,
      Value<String> cyclesFormula,
      Value<String> condition1Formula,
      Value<String> condition1Op,
      Value<double> condition1Value,
      Value<String> condition2Formula,
      Value<String> condition2Op,
      Value<double> condition2Value,
      Value<String> logicCyclesReqs,
      Value<String> logicReqsConds,
      Value<String> logicCond1Cond2,
      Value<int?> linkedPrototypeId,
      Value<int> color,
    });
typedef $$StagesTableUpdateCompanionBuilder =
    StagesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> sortOrder,
      Value<String> cyclesFormula,
      Value<String> condition1Formula,
      Value<String> condition1Op,
      Value<double> condition1Value,
      Value<String> condition2Formula,
      Value<String> condition2Op,
      Value<double> condition2Value,
      Value<String> logicCyclesReqs,
      Value<String> logicReqsConds,
      Value<String> logicCond1Cond2,
      Value<int?> linkedPrototypeId,
      Value<int> color,
    });

final class $$StagesTableReferences
    extends BaseReferences<_$AppDatabase, $StagesTable, Stage> {
  $$StagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EnvironmentAgentsTable, List<EnvironmentAgent>>
  _environmentAgentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.environmentAgents,
        aliasName: 'stages__id__environment_agents__stage_id',
      );

  $$EnvironmentAgentsTableProcessedTableManager get environmentAgentsRefs {
    final manager = $$EnvironmentAgentsTableTableManager(
      $_db,
      $_db.environmentAgents,
    ).filter((f) => f.stageId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _environmentAgentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StagesTableFilterComposer
    extends Composer<_$AppDatabase, $StagesTable> {
  $$StagesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cyclesFormula => $composableBuilder(
    column: $table.cyclesFormula,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get condition1Formula => $composableBuilder(
    column: $table.condition1Formula,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get condition1Op => $composableBuilder(
    column: $table.condition1Op,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get condition1Value => $composableBuilder(
    column: $table.condition1Value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get condition2Formula => $composableBuilder(
    column: $table.condition2Formula,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get condition2Op => $composableBuilder(
    column: $table.condition2Op,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get condition2Value => $composableBuilder(
    column: $table.condition2Value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logicCyclesReqs => $composableBuilder(
    column: $table.logicCyclesReqs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logicReqsConds => $composableBuilder(
    column: $table.logicReqsConds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logicCond1Cond2 => $composableBuilder(
    column: $table.logicCond1Cond2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get linkedPrototypeId => $composableBuilder(
    column: $table.linkedPrototypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> environmentAgentsRefs(
    Expression<bool> Function($$EnvironmentAgentsTableFilterComposer f) f,
  ) {
    final $$EnvironmentAgentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.environmentAgents,
      getReferencedColumn: (t) => t.stageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvironmentAgentsTableFilterComposer(
            $db: $db,
            $table: $db.environmentAgents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StagesTableOrderingComposer
    extends Composer<_$AppDatabase, $StagesTable> {
  $$StagesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cyclesFormula => $composableBuilder(
    column: $table.cyclesFormula,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get condition1Formula => $composableBuilder(
    column: $table.condition1Formula,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get condition1Op => $composableBuilder(
    column: $table.condition1Op,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get condition1Value => $composableBuilder(
    column: $table.condition1Value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get condition2Formula => $composableBuilder(
    column: $table.condition2Formula,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get condition2Op => $composableBuilder(
    column: $table.condition2Op,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get condition2Value => $composableBuilder(
    column: $table.condition2Value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logicCyclesReqs => $composableBuilder(
    column: $table.logicCyclesReqs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logicReqsConds => $composableBuilder(
    column: $table.logicReqsConds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logicCond1Cond2 => $composableBuilder(
    column: $table.logicCond1Cond2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get linkedPrototypeId => $composableBuilder(
    column: $table.linkedPrototypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StagesTable> {
  $$StagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get cyclesFormula => $composableBuilder(
    column: $table.cyclesFormula,
    builder: (column) => column,
  );

  GeneratedColumn<String> get condition1Formula => $composableBuilder(
    column: $table.condition1Formula,
    builder: (column) => column,
  );

  GeneratedColumn<String> get condition1Op => $composableBuilder(
    column: $table.condition1Op,
    builder: (column) => column,
  );

  GeneratedColumn<double> get condition1Value => $composableBuilder(
    column: $table.condition1Value,
    builder: (column) => column,
  );

  GeneratedColumn<String> get condition2Formula => $composableBuilder(
    column: $table.condition2Formula,
    builder: (column) => column,
  );

  GeneratedColumn<String> get condition2Op => $composableBuilder(
    column: $table.condition2Op,
    builder: (column) => column,
  );

  GeneratedColumn<double> get condition2Value => $composableBuilder(
    column: $table.condition2Value,
    builder: (column) => column,
  );

  GeneratedColumn<String> get logicCyclesReqs => $composableBuilder(
    column: $table.logicCyclesReqs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get logicReqsConds => $composableBuilder(
    column: $table.logicReqsConds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get logicCond1Cond2 => $composableBuilder(
    column: $table.logicCond1Cond2,
    builder: (column) => column,
  );

  GeneratedColumn<int> get linkedPrototypeId => $composableBuilder(
    column: $table.linkedPrototypeId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  Expression<T> environmentAgentsRefs<T extends Object>(
    Expression<T> Function($$EnvironmentAgentsTableAnnotationComposer a) f,
  ) {
    final $$EnvironmentAgentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.environmentAgents,
          getReferencedColumn: (t) => t.stageId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EnvironmentAgentsTableAnnotationComposer(
                $db: $db,
                $table: $db.environmentAgents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$StagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StagesTable,
          Stage,
          $$StagesTableFilterComposer,
          $$StagesTableOrderingComposer,
          $$StagesTableAnnotationComposer,
          $$StagesTableCreateCompanionBuilder,
          $$StagesTableUpdateCompanionBuilder,
          (Stage, $$StagesTableReferences),
          Stage,
          PrefetchHooks Function({bool environmentAgentsRefs})
        > {
  $$StagesTableTableManager(_$AppDatabase db, $StagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> cyclesFormula = const Value.absent(),
                Value<String> condition1Formula = const Value.absent(),
                Value<String> condition1Op = const Value.absent(),
                Value<double> condition1Value = const Value.absent(),
                Value<String> condition2Formula = const Value.absent(),
                Value<String> condition2Op = const Value.absent(),
                Value<double> condition2Value = const Value.absent(),
                Value<String> logicCyclesReqs = const Value.absent(),
                Value<String> logicReqsConds = const Value.absent(),
                Value<String> logicCond1Cond2 = const Value.absent(),
                Value<int?> linkedPrototypeId = const Value.absent(),
                Value<int> color = const Value.absent(),
              }) => StagesCompanion(
                id: id,
                name: name,
                sortOrder: sortOrder,
                cyclesFormula: cyclesFormula,
                condition1Formula: condition1Formula,
                condition1Op: condition1Op,
                condition1Value: condition1Value,
                condition2Formula: condition2Formula,
                condition2Op: condition2Op,
                condition2Value: condition2Value,
                logicCyclesReqs: logicCyclesReqs,
                logicReqsConds: logicReqsConds,
                logicCond1Cond2: logicCond1Cond2,
                linkedPrototypeId: linkedPrototypeId,
                color: color,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int> sortOrder = const Value.absent(),
                Value<String> cyclesFormula = const Value.absent(),
                Value<String> condition1Formula = const Value.absent(),
                Value<String> condition1Op = const Value.absent(),
                Value<double> condition1Value = const Value.absent(),
                Value<String> condition2Formula = const Value.absent(),
                Value<String> condition2Op = const Value.absent(),
                Value<double> condition2Value = const Value.absent(),
                Value<String> logicCyclesReqs = const Value.absent(),
                Value<String> logicReqsConds = const Value.absent(),
                Value<String> logicCond1Cond2 = const Value.absent(),
                Value<int?> linkedPrototypeId = const Value.absent(),
                Value<int> color = const Value.absent(),
              }) => StagesCompanion.insert(
                id: id,
                name: name,
                sortOrder: sortOrder,
                cyclesFormula: cyclesFormula,
                condition1Formula: condition1Formula,
                condition1Op: condition1Op,
                condition1Value: condition1Value,
                condition2Formula: condition2Formula,
                condition2Op: condition2Op,
                condition2Value: condition2Value,
                logicCyclesReqs: logicCyclesReqs,
                logicReqsConds: logicReqsConds,
                logicCond1Cond2: logicCond1Cond2,
                linkedPrototypeId: linkedPrototypeId,
                color: color,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$StagesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({environmentAgentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (environmentAgentsRefs) db.environmentAgents,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (environmentAgentsRefs)
                    await $_getPrefetchedData<
                      Stage,
                      $StagesTable,
                      EnvironmentAgent
                    >(
                      currentTable: table,
                      referencedTable: $$StagesTableReferences
                          ._environmentAgentsRefsTable(db),
                      managerFromTypedResult: (p0) => $$StagesTableReferences(
                        db,
                        table,
                        p0,
                      ).environmentAgentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.stageId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$StagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StagesTable,
      Stage,
      $$StagesTableFilterComposer,
      $$StagesTableOrderingComposer,
      $$StagesTableAnnotationComposer,
      $$StagesTableCreateCompanionBuilder,
      $$StagesTableUpdateCompanionBuilder,
      (Stage, $$StagesTableReferences),
      Stage,
      PrefetchHooks Function({bool environmentAgentsRefs})
    >;
typedef $$PrototypesTableCreateCompanionBuilder =
    PrototypesCompanion Function({
      Value<int> id,
      required String name,
      required String sex,
      Value<int> color,
      Value<String> longevityFormula,
      Value<String> refractoryCombatFormula,
      Value<String> refractoryCourtshipFormula,
      Value<String> sexRatioMalesFormula,
      Value<String> sexRatioFemalesFormula,
      Value<int> sortOrder,
    });
typedef $$PrototypesTableUpdateCompanionBuilder =
    PrototypesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> sex,
      Value<int> color,
      Value<String> longevityFormula,
      Value<String> refractoryCombatFormula,
      Value<String> refractoryCourtshipFormula,
      Value<String> sexRatioMalesFormula,
      Value<String> sexRatioFemalesFormula,
      Value<int> sortOrder,
    });

final class $$PrototypesTableReferences
    extends BaseReferences<_$AppDatabase, $PrototypesTable, Prototype> {
  $$PrototypesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EnvironmentAgentsTable, List<EnvironmentAgent>>
  _environmentAgentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.environmentAgents,
        aliasName: 'prototypes__id__environment_agents__prototype_id',
      );

  $$EnvironmentAgentsTableProcessedTableManager get environmentAgentsRefs {
    final manager = $$EnvironmentAgentsTableTableManager(
      $_db,
      $_db.environmentAgents,
    ).filter((f) => f.prototypeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _environmentAgentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PrototypesTableFilterComposer
    extends Composer<_$AppDatabase, $PrototypesTable> {
  $$PrototypesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get longevityFormula => $composableBuilder(
    column: $table.longevityFormula,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refractoryCombatFormula => $composableBuilder(
    column: $table.refractoryCombatFormula,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refractoryCourtshipFormula => $composableBuilder(
    column: $table.refractoryCourtshipFormula,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sexRatioMalesFormula => $composableBuilder(
    column: $table.sexRatioMalesFormula,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sexRatioFemalesFormula => $composableBuilder(
    column: $table.sexRatioFemalesFormula,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> environmentAgentsRefs(
    Expression<bool> Function($$EnvironmentAgentsTableFilterComposer f) f,
  ) {
    final $$EnvironmentAgentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.environmentAgents,
      getReferencedColumn: (t) => t.prototypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvironmentAgentsTableFilterComposer(
            $db: $db,
            $table: $db.environmentAgents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PrototypesTableOrderingComposer
    extends Composer<_$AppDatabase, $PrototypesTable> {
  $$PrototypesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get longevityFormula => $composableBuilder(
    column: $table.longevityFormula,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refractoryCombatFormula => $composableBuilder(
    column: $table.refractoryCombatFormula,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refractoryCourtshipFormula => $composableBuilder(
    column: $table.refractoryCourtshipFormula,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sexRatioMalesFormula => $composableBuilder(
    column: $table.sexRatioMalesFormula,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sexRatioFemalesFormula => $composableBuilder(
    column: $table.sexRatioFemalesFormula,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PrototypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrototypesTable> {
  $$PrototypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get longevityFormula => $composableBuilder(
    column: $table.longevityFormula,
    builder: (column) => column,
  );

  GeneratedColumn<String> get refractoryCombatFormula => $composableBuilder(
    column: $table.refractoryCombatFormula,
    builder: (column) => column,
  );

  GeneratedColumn<String> get refractoryCourtshipFormula => $composableBuilder(
    column: $table.refractoryCourtshipFormula,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sexRatioMalesFormula => $composableBuilder(
    column: $table.sexRatioMalesFormula,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sexRatioFemalesFormula => $composableBuilder(
    column: $table.sexRatioFemalesFormula,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> environmentAgentsRefs<T extends Object>(
    Expression<T> Function($$EnvironmentAgentsTableAnnotationComposer a) f,
  ) {
    final $$EnvironmentAgentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.environmentAgents,
          getReferencedColumn: (t) => t.prototypeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EnvironmentAgentsTableAnnotationComposer(
                $db: $db,
                $table: $db.environmentAgents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PrototypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrototypesTable,
          Prototype,
          $$PrototypesTableFilterComposer,
          $$PrototypesTableOrderingComposer,
          $$PrototypesTableAnnotationComposer,
          $$PrototypesTableCreateCompanionBuilder,
          $$PrototypesTableUpdateCompanionBuilder,
          (Prototype, $$PrototypesTableReferences),
          Prototype,
          PrefetchHooks Function({bool environmentAgentsRefs})
        > {
  $$PrototypesTableTableManager(_$AppDatabase db, $PrototypesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrototypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrototypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrototypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> sex = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<String> longevityFormula = const Value.absent(),
                Value<String> refractoryCombatFormula = const Value.absent(),
                Value<String> refractoryCourtshipFormula = const Value.absent(),
                Value<String> sexRatioMalesFormula = const Value.absent(),
                Value<String> sexRatioFemalesFormula = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => PrototypesCompanion(
                id: id,
                name: name,
                sex: sex,
                color: color,
                longevityFormula: longevityFormula,
                refractoryCombatFormula: refractoryCombatFormula,
                refractoryCourtshipFormula: refractoryCourtshipFormula,
                sexRatioMalesFormula: sexRatioMalesFormula,
                sexRatioFemalesFormula: sexRatioFemalesFormula,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String sex,
                Value<int> color = const Value.absent(),
                Value<String> longevityFormula = const Value.absent(),
                Value<String> refractoryCombatFormula = const Value.absent(),
                Value<String> refractoryCourtshipFormula = const Value.absent(),
                Value<String> sexRatioMalesFormula = const Value.absent(),
                Value<String> sexRatioFemalesFormula = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => PrototypesCompanion.insert(
                id: id,
                name: name,
                sex: sex,
                color: color,
                longevityFormula: longevityFormula,
                refractoryCombatFormula: refractoryCombatFormula,
                refractoryCourtshipFormula: refractoryCourtshipFormula,
                sexRatioMalesFormula: sexRatioMalesFormula,
                sexRatioFemalesFormula: sexRatioFemalesFormula,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PrototypesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({environmentAgentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (environmentAgentsRefs) db.environmentAgents,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (environmentAgentsRefs)
                    await $_getPrefetchedData<
                      Prototype,
                      $PrototypesTable,
                      EnvironmentAgent
                    >(
                      currentTable: table,
                      referencedTable: $$PrototypesTableReferences
                          ._environmentAgentsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PrototypesTableReferences(
                            db,
                            table,
                            p0,
                          ).environmentAgentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.prototypeId == item.id,
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

typedef $$PrototypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrototypesTable,
      Prototype,
      $$PrototypesTableFilterComposer,
      $$PrototypesTableOrderingComposer,
      $$PrototypesTableAnnotationComposer,
      $$PrototypesTableCreateCompanionBuilder,
      $$PrototypesTableUpdateCompanionBuilder,
      (Prototype, $$PrototypesTableReferences),
      Prototype,
      PrefetchHooks Function({bool environmentAgentsRefs})
    >;
typedef $$ResourceTypesTableCreateCompanionBuilder =
    ResourceTypesCompanion Function({
      Value<int> id,
      required String name,
      Value<int?> nutrientId,
      Value<bool> isOviposition,
      Value<int> color,
      Value<int> sortOrder,
    });
typedef $$ResourceTypesTableUpdateCompanionBuilder =
    ResourceTypesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int?> nutrientId,
      Value<bool> isOviposition,
      Value<int> color,
      Value<int> sortOrder,
    });

final class $$ResourceTypesTableReferences
    extends BaseReferences<_$AppDatabase, $ResourceTypesTable, ResourceType> {
  $$ResourceTypesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $NutrientsTable _nutrientIdTable(_$AppDatabase db) =>
      db.nutrients.createAlias('resource_types__nutrient_id__nutrients__id');

  $$NutrientsTableProcessedTableManager? get nutrientId {
    final $_column = $_itemColumn<int>('nutrient_id');
    if ($_column == null) return null;
    final manager = $$NutrientsTableTableManager(
      $_db,
      $_db.nutrients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_nutrientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $EnvironmentResourcesTable,
    List<EnvironmentResource>
  >
  _environmentResourcesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.environmentResources,
        aliasName:
            'resource_types__id__environment_resources__resource_type_id',
      );

  $$EnvironmentResourcesTableProcessedTableManager
  get environmentResourcesRefs {
    final manager = $$EnvironmentResourcesTableTableManager(
      $_db,
      $_db.environmentResources,
    ).filter((f) => f.resourceTypeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _environmentResourcesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ResourceTypesTableFilterComposer
    extends Composer<_$AppDatabase, $ResourceTypesTable> {
  $$ResourceTypesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOviposition => $composableBuilder(
    column: $table.isOviposition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$NutrientsTableFilterComposer get nutrientId {
    final $$NutrientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.nutrientId,
      referencedTable: $db.nutrients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NutrientsTableFilterComposer(
            $db: $db,
            $table: $db.nutrients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> environmentResourcesRefs(
    Expression<bool> Function($$EnvironmentResourcesTableFilterComposer f) f,
  ) {
    final $$EnvironmentResourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.environmentResources,
      getReferencedColumn: (t) => t.resourceTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvironmentResourcesTableFilterComposer(
            $db: $db,
            $table: $db.environmentResources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ResourceTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $ResourceTypesTable> {
  $$ResourceTypesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOviposition => $composableBuilder(
    column: $table.isOviposition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$NutrientsTableOrderingComposer get nutrientId {
    final $$NutrientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.nutrientId,
      referencedTable: $db.nutrients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NutrientsTableOrderingComposer(
            $db: $db,
            $table: $db.nutrients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResourceTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResourceTypesTable> {
  $$ResourceTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isOviposition => $composableBuilder(
    column: $table.isOviposition,
    builder: (column) => column,
  );

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$NutrientsTableAnnotationComposer get nutrientId {
    final $$NutrientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.nutrientId,
      referencedTable: $db.nutrients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NutrientsTableAnnotationComposer(
            $db: $db,
            $table: $db.nutrients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> environmentResourcesRefs<T extends Object>(
    Expression<T> Function($$EnvironmentResourcesTableAnnotationComposer a) f,
  ) {
    final $$EnvironmentResourcesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.environmentResources,
          getReferencedColumn: (t) => t.resourceTypeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EnvironmentResourcesTableAnnotationComposer(
                $db: $db,
                $table: $db.environmentResources,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ResourceTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ResourceTypesTable,
          ResourceType,
          $$ResourceTypesTableFilterComposer,
          $$ResourceTypesTableOrderingComposer,
          $$ResourceTypesTableAnnotationComposer,
          $$ResourceTypesTableCreateCompanionBuilder,
          $$ResourceTypesTableUpdateCompanionBuilder,
          (ResourceType, $$ResourceTypesTableReferences),
          ResourceType,
          PrefetchHooks Function({
            bool nutrientId,
            bool environmentResourcesRefs,
          })
        > {
  $$ResourceTypesTableTableManager(_$AppDatabase db, $ResourceTypesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResourceTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResourceTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResourceTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> nutrientId = const Value.absent(),
                Value<bool> isOviposition = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => ResourceTypesCompanion(
                id: id,
                name: name,
                nutrientId: nutrientId,
                isOviposition: isOviposition,
                color: color,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int?> nutrientId = const Value.absent(),
                Value<bool> isOviposition = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => ResourceTypesCompanion.insert(
                id: id,
                name: name,
                nutrientId: nutrientId,
                isOviposition: isOviposition,
                color: color,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ResourceTypesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({nutrientId = false, environmentResourcesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (environmentResourcesRefs) db.environmentResources,
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
                        if (nutrientId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.nutrientId,
                                    referencedTable:
                                        $$ResourceTypesTableReferences
                                            ._nutrientIdTable(db),
                                    referencedColumn:
                                        $$ResourceTypesTableReferences
                                            ._nutrientIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (environmentResourcesRefs)
                        await $_getPrefetchedData<
                          ResourceType,
                          $ResourceTypesTable,
                          EnvironmentResource
                        >(
                          currentTable: table,
                          referencedTable: $$ResourceTypesTableReferences
                              ._environmentResourcesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ResourceTypesTableReferences(
                                db,
                                table,
                                p0,
                              ).environmentResourcesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.resourceTypeId == item.id,
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

typedef $$ResourceTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ResourceTypesTable,
      ResourceType,
      $$ResourceTypesTableFilterComposer,
      $$ResourceTypesTableOrderingComposer,
      $$ResourceTypesTableAnnotationComposer,
      $$ResourceTypesTableCreateCompanionBuilder,
      $$ResourceTypesTableUpdateCompanionBuilder,
      (ResourceType, $$ResourceTypesTableReferences),
      ResourceType,
      PrefetchHooks Function({bool nutrientId, bool environmentResourcesRefs})
    >;
typedef $$EnvironmentsTableCreateCompanionBuilder =
    EnvironmentsCompanion Function({
      Value<int> id,
      required String name,
      required int width,
      required int height,
      Value<String> description,
      Value<String> createdAt,
      Value<String> updatedAt,
    });
typedef $$EnvironmentsTableUpdateCompanionBuilder =
    EnvironmentsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> width,
      Value<int> height,
      Value<String> description,
      Value<String> createdAt,
      Value<String> updatedAt,
    });

final class $$EnvironmentsTableReferences
    extends BaseReferences<_$AppDatabase, $EnvironmentsTable, Environment> {
  $$EnvironmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SubstrateMapRowsTable, List<SubstrateMapRow>>
  _substrateMapRowsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.substrateMapRows,
    aliasName: 'environments__id__substrate_map_rows__environment_id',
  );

  $$SubstrateMapRowsTableProcessedTableManager get substrateMapRowsRefs {
    final manager = $$SubstrateMapRowsTableTableManager(
      $_db,
      $_db.substrateMapRows,
    ).filter((f) => f.environmentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _substrateMapRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $EnvironmentResourcesTable,
    List<EnvironmentResource>
  >
  _environmentResourcesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.environmentResources,
        aliasName: 'environments__id__environment_resources__environment_id',
      );

  $$EnvironmentResourcesTableProcessedTableManager
  get environmentResourcesRefs {
    final manager = $$EnvironmentResourcesTableTableManager(
      $_db,
      $_db.environmentResources,
    ).filter((f) => f.environmentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _environmentResourcesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EnvironmentAgentsTable, List<EnvironmentAgent>>
  _environmentAgentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.environmentAgents,
        aliasName: 'environments__id__environment_agents__environment_id',
      );

  $$EnvironmentAgentsTableProcessedTableManager get environmentAgentsRefs {
    final manager = $$EnvironmentAgentsTableTableManager(
      $_db,
      $_db.environmentAgents,
    ).filter((f) => f.environmentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _environmentAgentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EnvironmentsTableFilterComposer
    extends Composer<_$AppDatabase, $EnvironmentsTable> {
  $$EnvironmentsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> substrateMapRowsRefs(
    Expression<bool> Function($$SubstrateMapRowsTableFilterComposer f) f,
  ) {
    final $$SubstrateMapRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.substrateMapRows,
      getReferencedColumn: (t) => t.environmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubstrateMapRowsTableFilterComposer(
            $db: $db,
            $table: $db.substrateMapRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> environmentResourcesRefs(
    Expression<bool> Function($$EnvironmentResourcesTableFilterComposer f) f,
  ) {
    final $$EnvironmentResourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.environmentResources,
      getReferencedColumn: (t) => t.environmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvironmentResourcesTableFilterComposer(
            $db: $db,
            $table: $db.environmentResources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> environmentAgentsRefs(
    Expression<bool> Function($$EnvironmentAgentsTableFilterComposer f) f,
  ) {
    final $$EnvironmentAgentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.environmentAgents,
      getReferencedColumn: (t) => t.environmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvironmentAgentsTableFilterComposer(
            $db: $db,
            $table: $db.environmentAgents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EnvironmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $EnvironmentsTable> {
  $$EnvironmentsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EnvironmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EnvironmentsTable> {
  $$EnvironmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> substrateMapRowsRefs<T extends Object>(
    Expression<T> Function($$SubstrateMapRowsTableAnnotationComposer a) f,
  ) {
    final $$SubstrateMapRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.substrateMapRows,
      getReferencedColumn: (t) => t.environmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubstrateMapRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.substrateMapRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> environmentResourcesRefs<T extends Object>(
    Expression<T> Function($$EnvironmentResourcesTableAnnotationComposer a) f,
  ) {
    final $$EnvironmentResourcesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.environmentResources,
          getReferencedColumn: (t) => t.environmentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EnvironmentResourcesTableAnnotationComposer(
                $db: $db,
                $table: $db.environmentResources,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> environmentAgentsRefs<T extends Object>(
    Expression<T> Function($$EnvironmentAgentsTableAnnotationComposer a) f,
  ) {
    final $$EnvironmentAgentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.environmentAgents,
          getReferencedColumn: (t) => t.environmentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EnvironmentAgentsTableAnnotationComposer(
                $db: $db,
                $table: $db.environmentAgents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$EnvironmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EnvironmentsTable,
          Environment,
          $$EnvironmentsTableFilterComposer,
          $$EnvironmentsTableOrderingComposer,
          $$EnvironmentsTableAnnotationComposer,
          $$EnvironmentsTableCreateCompanionBuilder,
          $$EnvironmentsTableUpdateCompanionBuilder,
          (Environment, $$EnvironmentsTableReferences),
          Environment,
          PrefetchHooks Function({
            bool substrateMapRowsRefs,
            bool environmentResourcesRefs,
            bool environmentAgentsRefs,
          })
        > {
  $$EnvironmentsTableTableManager(_$AppDatabase db, $EnvironmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EnvironmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EnvironmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EnvironmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> width = const Value.absent(),
                Value<int> height = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
              }) => EnvironmentsCompanion(
                id: id,
                name: name,
                width: width,
                height: height,
                description: description,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int width,
                required int height,
                Value<String> description = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
              }) => EnvironmentsCompanion.insert(
                id: id,
                name: name,
                width: width,
                height: height,
                description: description,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EnvironmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                substrateMapRowsRefs = false,
                environmentResourcesRefs = false,
                environmentAgentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (substrateMapRowsRefs) db.substrateMapRows,
                    if (environmentResourcesRefs) db.environmentResources,
                    if (environmentAgentsRefs) db.environmentAgents,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (substrateMapRowsRefs)
                        await $_getPrefetchedData<
                          Environment,
                          $EnvironmentsTable,
                          SubstrateMapRow
                        >(
                          currentTable: table,
                          referencedTable: $$EnvironmentsTableReferences
                              ._substrateMapRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EnvironmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).substrateMapRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.environmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (environmentResourcesRefs)
                        await $_getPrefetchedData<
                          Environment,
                          $EnvironmentsTable,
                          EnvironmentResource
                        >(
                          currentTable: table,
                          referencedTable: $$EnvironmentsTableReferences
                              ._environmentResourcesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EnvironmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).environmentResourcesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.environmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (environmentAgentsRefs)
                        await $_getPrefetchedData<
                          Environment,
                          $EnvironmentsTable,
                          EnvironmentAgent
                        >(
                          currentTable: table,
                          referencedTable: $$EnvironmentsTableReferences
                              ._environmentAgentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EnvironmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).environmentAgentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.environmentId == item.id,
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

typedef $$EnvironmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EnvironmentsTable,
      Environment,
      $$EnvironmentsTableFilterComposer,
      $$EnvironmentsTableOrderingComposer,
      $$EnvironmentsTableAnnotationComposer,
      $$EnvironmentsTableCreateCompanionBuilder,
      $$EnvironmentsTableUpdateCompanionBuilder,
      (Environment, $$EnvironmentsTableReferences),
      Environment,
      PrefetchHooks Function({
        bool substrateMapRowsRefs,
        bool environmentResourcesRefs,
        bool environmentAgentsRefs,
      })
    >;
typedef $$SubstrateMapRowsTableCreateCompanionBuilder =
    SubstrateMapRowsCompanion Function({
      Value<int> id,
      required int environmentId,
      required int yCoord,
      required String mapData,
    });
typedef $$SubstrateMapRowsTableUpdateCompanionBuilder =
    SubstrateMapRowsCompanion Function({
      Value<int> id,
      Value<int> environmentId,
      Value<int> yCoord,
      Value<String> mapData,
    });

final class $$SubstrateMapRowsTableReferences
    extends
        BaseReferences<_$AppDatabase, $SubstrateMapRowsTable, SubstrateMapRow> {
  $$SubstrateMapRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $EnvironmentsTable _environmentIdTable(_$AppDatabase db) => db
      .environments
      .createAlias('substrate_map_rows__environment_id__environments__id');

  $$EnvironmentsTableProcessedTableManager get environmentId {
    final $_column = $_itemColumn<int>('environment_id')!;

    final manager = $$EnvironmentsTableTableManager(
      $_db,
      $_db.environments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_environmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SubstrateMapRowsTableFilterComposer
    extends Composer<_$AppDatabase, $SubstrateMapRowsTable> {
  $$SubstrateMapRowsTableFilterComposer({
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

  ColumnFilters<int> get yCoord => $composableBuilder(
    column: $table.yCoord,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mapData => $composableBuilder(
    column: $table.mapData,
    builder: (column) => ColumnFilters(column),
  );

  $$EnvironmentsTableFilterComposer get environmentId {
    final $$EnvironmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.environmentId,
      referencedTable: $db.environments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvironmentsTableFilterComposer(
            $db: $db,
            $table: $db.environments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubstrateMapRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubstrateMapRowsTable> {
  $$SubstrateMapRowsTableOrderingComposer({
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

  ColumnOrderings<int> get yCoord => $composableBuilder(
    column: $table.yCoord,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mapData => $composableBuilder(
    column: $table.mapData,
    builder: (column) => ColumnOrderings(column),
  );

  $$EnvironmentsTableOrderingComposer get environmentId {
    final $$EnvironmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.environmentId,
      referencedTable: $db.environments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvironmentsTableOrderingComposer(
            $db: $db,
            $table: $db.environments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubstrateMapRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubstrateMapRowsTable> {
  $$SubstrateMapRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get yCoord =>
      $composableBuilder(column: $table.yCoord, builder: (column) => column);

  GeneratedColumn<String> get mapData =>
      $composableBuilder(column: $table.mapData, builder: (column) => column);

  $$EnvironmentsTableAnnotationComposer get environmentId {
    final $$EnvironmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.environmentId,
      referencedTable: $db.environments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvironmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.environments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubstrateMapRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubstrateMapRowsTable,
          SubstrateMapRow,
          $$SubstrateMapRowsTableFilterComposer,
          $$SubstrateMapRowsTableOrderingComposer,
          $$SubstrateMapRowsTableAnnotationComposer,
          $$SubstrateMapRowsTableCreateCompanionBuilder,
          $$SubstrateMapRowsTableUpdateCompanionBuilder,
          (SubstrateMapRow, $$SubstrateMapRowsTableReferences),
          SubstrateMapRow,
          PrefetchHooks Function({bool environmentId})
        > {
  $$SubstrateMapRowsTableTableManager(
    _$AppDatabase db,
    $SubstrateMapRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubstrateMapRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubstrateMapRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubstrateMapRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> environmentId = const Value.absent(),
                Value<int> yCoord = const Value.absent(),
                Value<String> mapData = const Value.absent(),
              }) => SubstrateMapRowsCompanion(
                id: id,
                environmentId: environmentId,
                yCoord: yCoord,
                mapData: mapData,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int environmentId,
                required int yCoord,
                required String mapData,
              }) => SubstrateMapRowsCompanion.insert(
                id: id,
                environmentId: environmentId,
                yCoord: yCoord,
                mapData: mapData,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SubstrateMapRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({environmentId = false}) {
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
                    if (environmentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.environmentId,
                                referencedTable:
                                    $$SubstrateMapRowsTableReferences
                                        ._environmentIdTable(db),
                                referencedColumn:
                                    $$SubstrateMapRowsTableReferences
                                        ._environmentIdTable(db)
                                        .id,
                              )
                              as T;
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

typedef $$SubstrateMapRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubstrateMapRowsTable,
      SubstrateMapRow,
      $$SubstrateMapRowsTableFilterComposer,
      $$SubstrateMapRowsTableOrderingComposer,
      $$SubstrateMapRowsTableAnnotationComposer,
      $$SubstrateMapRowsTableCreateCompanionBuilder,
      $$SubstrateMapRowsTableUpdateCompanionBuilder,
      (SubstrateMapRow, $$SubstrateMapRowsTableReferences),
      SubstrateMapRow,
      PrefetchHooks Function({bool environmentId})
    >;
typedef $$EnvironmentResourcesTableCreateCompanionBuilder =
    EnvironmentResourcesCompanion Function({
      Value<int> id,
      required int environmentId,
      required int resourceTypeId,
      required String name,
      required int posX,
      required int posY,
      Value<int> quality,
      Value<int> level,
      Value<int> maxLevel,
      Value<double> regenRate,
    });
typedef $$EnvironmentResourcesTableUpdateCompanionBuilder =
    EnvironmentResourcesCompanion Function({
      Value<int> id,
      Value<int> environmentId,
      Value<int> resourceTypeId,
      Value<String> name,
      Value<int> posX,
      Value<int> posY,
      Value<int> quality,
      Value<int> level,
      Value<int> maxLevel,
      Value<double> regenRate,
    });

final class $$EnvironmentResourcesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $EnvironmentResourcesTable,
          EnvironmentResource
        > {
  $$EnvironmentResourcesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $EnvironmentsTable _environmentIdTable(_$AppDatabase db) => db
      .environments
      .createAlias('environment_resources__environment_id__environments__id');

  $$EnvironmentsTableProcessedTableManager get environmentId {
    final $_column = $_itemColumn<int>('environment_id')!;

    final manager = $$EnvironmentsTableTableManager(
      $_db,
      $_db.environments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_environmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ResourceTypesTable _resourceTypeIdTable(_$AppDatabase db) =>
      db.resourceTypes.createAlias(
        'environment_resources__resource_type_id__resource_types__id',
      );

  $$ResourceTypesTableProcessedTableManager get resourceTypeId {
    final $_column = $_itemColumn<int>('resource_type_id')!;

    final manager = $$ResourceTypesTableTableManager(
      $_db,
      $_db.resourceTypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_resourceTypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EnvironmentResourcesTableFilterComposer
    extends Composer<_$AppDatabase, $EnvironmentResourcesTable> {
  $$EnvironmentResourcesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get posX => $composableBuilder(
    column: $table.posX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get posY => $composableBuilder(
    column: $table.posY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quality => $composableBuilder(
    column: $table.quality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxLevel => $composableBuilder(
    column: $table.maxLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get regenRate => $composableBuilder(
    column: $table.regenRate,
    builder: (column) => ColumnFilters(column),
  );

  $$EnvironmentsTableFilterComposer get environmentId {
    final $$EnvironmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.environmentId,
      referencedTable: $db.environments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvironmentsTableFilterComposer(
            $db: $db,
            $table: $db.environments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ResourceTypesTableFilterComposer get resourceTypeId {
    final $$ResourceTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.resourceTypeId,
      referencedTable: $db.resourceTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourceTypesTableFilterComposer(
            $db: $db,
            $table: $db.resourceTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EnvironmentResourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $EnvironmentResourcesTable> {
  $$EnvironmentResourcesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get posX => $composableBuilder(
    column: $table.posX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get posY => $composableBuilder(
    column: $table.posY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quality => $composableBuilder(
    column: $table.quality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxLevel => $composableBuilder(
    column: $table.maxLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get regenRate => $composableBuilder(
    column: $table.regenRate,
    builder: (column) => ColumnOrderings(column),
  );

  $$EnvironmentsTableOrderingComposer get environmentId {
    final $$EnvironmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.environmentId,
      referencedTable: $db.environments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvironmentsTableOrderingComposer(
            $db: $db,
            $table: $db.environments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ResourceTypesTableOrderingComposer get resourceTypeId {
    final $$ResourceTypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.resourceTypeId,
      referencedTable: $db.resourceTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourceTypesTableOrderingComposer(
            $db: $db,
            $table: $db.resourceTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EnvironmentResourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EnvironmentResourcesTable> {
  $$EnvironmentResourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get posX =>
      $composableBuilder(column: $table.posX, builder: (column) => column);

  GeneratedColumn<int> get posY =>
      $composableBuilder(column: $table.posY, builder: (column) => column);

  GeneratedColumn<int> get quality =>
      $composableBuilder(column: $table.quality, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get maxLevel =>
      $composableBuilder(column: $table.maxLevel, builder: (column) => column);

  GeneratedColumn<double> get regenRate =>
      $composableBuilder(column: $table.regenRate, builder: (column) => column);

  $$EnvironmentsTableAnnotationComposer get environmentId {
    final $$EnvironmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.environmentId,
      referencedTable: $db.environments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvironmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.environments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ResourceTypesTableAnnotationComposer get resourceTypeId {
    final $$ResourceTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.resourceTypeId,
      referencedTable: $db.resourceTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourceTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.resourceTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EnvironmentResourcesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EnvironmentResourcesTable,
          EnvironmentResource,
          $$EnvironmentResourcesTableFilterComposer,
          $$EnvironmentResourcesTableOrderingComposer,
          $$EnvironmentResourcesTableAnnotationComposer,
          $$EnvironmentResourcesTableCreateCompanionBuilder,
          $$EnvironmentResourcesTableUpdateCompanionBuilder,
          (EnvironmentResource, $$EnvironmentResourcesTableReferences),
          EnvironmentResource,
          PrefetchHooks Function({bool environmentId, bool resourceTypeId})
        > {
  $$EnvironmentResourcesTableTableManager(
    _$AppDatabase db,
    $EnvironmentResourcesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EnvironmentResourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EnvironmentResourcesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$EnvironmentResourcesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> environmentId = const Value.absent(),
                Value<int> resourceTypeId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> posX = const Value.absent(),
                Value<int> posY = const Value.absent(),
                Value<int> quality = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<int> maxLevel = const Value.absent(),
                Value<double> regenRate = const Value.absent(),
              }) => EnvironmentResourcesCompanion(
                id: id,
                environmentId: environmentId,
                resourceTypeId: resourceTypeId,
                name: name,
                posX: posX,
                posY: posY,
                quality: quality,
                level: level,
                maxLevel: maxLevel,
                regenRate: regenRate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int environmentId,
                required int resourceTypeId,
                required String name,
                required int posX,
                required int posY,
                Value<int> quality = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<int> maxLevel = const Value.absent(),
                Value<double> regenRate = const Value.absent(),
              }) => EnvironmentResourcesCompanion.insert(
                id: id,
                environmentId: environmentId,
                resourceTypeId: resourceTypeId,
                name: name,
                posX: posX,
                posY: posY,
                quality: quality,
                level: level,
                maxLevel: maxLevel,
                regenRate: regenRate,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EnvironmentResourcesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({environmentId = false, resourceTypeId = false}) {
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
                        if (environmentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.environmentId,
                                    referencedTable:
                                        $$EnvironmentResourcesTableReferences
                                            ._environmentIdTable(db),
                                    referencedColumn:
                                        $$EnvironmentResourcesTableReferences
                                            ._environmentIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (resourceTypeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.resourceTypeId,
                                    referencedTable:
                                        $$EnvironmentResourcesTableReferences
                                            ._resourceTypeIdTable(db),
                                    referencedColumn:
                                        $$EnvironmentResourcesTableReferences
                                            ._resourceTypeIdTable(db)
                                            .id,
                                  )
                                  as T;
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

typedef $$EnvironmentResourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EnvironmentResourcesTable,
      EnvironmentResource,
      $$EnvironmentResourcesTableFilterComposer,
      $$EnvironmentResourcesTableOrderingComposer,
      $$EnvironmentResourcesTableAnnotationComposer,
      $$EnvironmentResourcesTableCreateCompanionBuilder,
      $$EnvironmentResourcesTableUpdateCompanionBuilder,
      (EnvironmentResource, $$EnvironmentResourcesTableReferences),
      EnvironmentResource,
      PrefetchHooks Function({bool environmentId, bool resourceTypeId})
    >;
typedef $$EnvironmentAgentsTableCreateCompanionBuilder =
    EnvironmentAgentsCompanion Function({
      Value<int> id,
      required int environmentId,
      required String name,
      required int posX,
      required int posY,
      Value<int?> stageId,
      Value<int?> prototypeId,
      required String sex,
      Value<int> age,
    });
typedef $$EnvironmentAgentsTableUpdateCompanionBuilder =
    EnvironmentAgentsCompanion Function({
      Value<int> id,
      Value<int> environmentId,
      Value<String> name,
      Value<int> posX,
      Value<int> posY,
      Value<int?> stageId,
      Value<int?> prototypeId,
      Value<String> sex,
      Value<int> age,
    });

final class $$EnvironmentAgentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $EnvironmentAgentsTable,
          EnvironmentAgent
        > {
  $$EnvironmentAgentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $EnvironmentsTable _environmentIdTable(_$AppDatabase db) => db
      .environments
      .createAlias('environment_agents__environment_id__environments__id');

  $$EnvironmentsTableProcessedTableManager get environmentId {
    final $_column = $_itemColumn<int>('environment_id')!;

    final manager = $$EnvironmentsTableTableManager(
      $_db,
      $_db.environments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_environmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StagesTable _stageIdTable(_$AppDatabase db) =>
      db.stages.createAlias('environment_agents__stage_id__stages__id');

  $$StagesTableProcessedTableManager? get stageId {
    final $_column = $_itemColumn<int>('stage_id');
    if ($_column == null) return null;
    final manager = $$StagesTableTableManager(
      $_db,
      $_db.stages,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_stageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PrototypesTable _prototypeIdTable(_$AppDatabase db) => db.prototypes
      .createAlias('environment_agents__prototype_id__prototypes__id');

  $$PrototypesTableProcessedTableManager? get prototypeId {
    final $_column = $_itemColumn<int>('prototype_id');
    if ($_column == null) return null;
    final manager = $$PrototypesTableTableManager(
      $_db,
      $_db.prototypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_prototypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EnvironmentAgentsTableFilterComposer
    extends Composer<_$AppDatabase, $EnvironmentAgentsTable> {
  $$EnvironmentAgentsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get posX => $composableBuilder(
    column: $table.posX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get posY => $composableBuilder(
    column: $table.posY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnFilters(column),
  );

  $$EnvironmentsTableFilterComposer get environmentId {
    final $$EnvironmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.environmentId,
      referencedTable: $db.environments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvironmentsTableFilterComposer(
            $db: $db,
            $table: $db.environments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StagesTableFilterComposer get stageId {
    final $$StagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stageId,
      referencedTable: $db.stages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StagesTableFilterComposer(
            $db: $db,
            $table: $db.stages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PrototypesTableFilterComposer get prototypeId {
    final $$PrototypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.prototypeId,
      referencedTable: $db.prototypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrototypesTableFilterComposer(
            $db: $db,
            $table: $db.prototypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EnvironmentAgentsTableOrderingComposer
    extends Composer<_$AppDatabase, $EnvironmentAgentsTable> {
  $$EnvironmentAgentsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get posX => $composableBuilder(
    column: $table.posX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get posY => $composableBuilder(
    column: $table.posY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnOrderings(column),
  );

  $$EnvironmentsTableOrderingComposer get environmentId {
    final $$EnvironmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.environmentId,
      referencedTable: $db.environments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvironmentsTableOrderingComposer(
            $db: $db,
            $table: $db.environments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StagesTableOrderingComposer get stageId {
    final $$StagesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stageId,
      referencedTable: $db.stages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StagesTableOrderingComposer(
            $db: $db,
            $table: $db.stages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PrototypesTableOrderingComposer get prototypeId {
    final $$PrototypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.prototypeId,
      referencedTable: $db.prototypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrototypesTableOrderingComposer(
            $db: $db,
            $table: $db.prototypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EnvironmentAgentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EnvironmentAgentsTable> {
  $$EnvironmentAgentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get posX =>
      $composableBuilder(column: $table.posX, builder: (column) => column);

  GeneratedColumn<int> get posY =>
      $composableBuilder(column: $table.posY, builder: (column) => column);

  GeneratedColumn<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  $$EnvironmentsTableAnnotationComposer get environmentId {
    final $$EnvironmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.environmentId,
      referencedTable: $db.environments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvironmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.environments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StagesTableAnnotationComposer get stageId {
    final $$StagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stageId,
      referencedTable: $db.stages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StagesTableAnnotationComposer(
            $db: $db,
            $table: $db.stages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PrototypesTableAnnotationComposer get prototypeId {
    final $$PrototypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.prototypeId,
      referencedTable: $db.prototypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrototypesTableAnnotationComposer(
            $db: $db,
            $table: $db.prototypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EnvironmentAgentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EnvironmentAgentsTable,
          EnvironmentAgent,
          $$EnvironmentAgentsTableFilterComposer,
          $$EnvironmentAgentsTableOrderingComposer,
          $$EnvironmentAgentsTableAnnotationComposer,
          $$EnvironmentAgentsTableCreateCompanionBuilder,
          $$EnvironmentAgentsTableUpdateCompanionBuilder,
          (EnvironmentAgent, $$EnvironmentAgentsTableReferences),
          EnvironmentAgent,
          PrefetchHooks Function({
            bool environmentId,
            bool stageId,
            bool prototypeId,
          })
        > {
  $$EnvironmentAgentsTableTableManager(
    _$AppDatabase db,
    $EnvironmentAgentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EnvironmentAgentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EnvironmentAgentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EnvironmentAgentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> environmentId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> posX = const Value.absent(),
                Value<int> posY = const Value.absent(),
                Value<int?> stageId = const Value.absent(),
                Value<int?> prototypeId = const Value.absent(),
                Value<String> sex = const Value.absent(),
                Value<int> age = const Value.absent(),
              }) => EnvironmentAgentsCompanion(
                id: id,
                environmentId: environmentId,
                name: name,
                posX: posX,
                posY: posY,
                stageId: stageId,
                prototypeId: prototypeId,
                sex: sex,
                age: age,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int environmentId,
                required String name,
                required int posX,
                required int posY,
                Value<int?> stageId = const Value.absent(),
                Value<int?> prototypeId = const Value.absent(),
                required String sex,
                Value<int> age = const Value.absent(),
              }) => EnvironmentAgentsCompanion.insert(
                id: id,
                environmentId: environmentId,
                name: name,
                posX: posX,
                posY: posY,
                stageId: stageId,
                prototypeId: prototypeId,
                sex: sex,
                age: age,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EnvironmentAgentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({environmentId = false, stageId = false, prototypeId = false}) {
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
                        if (environmentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.environmentId,
                                    referencedTable:
                                        $$EnvironmentAgentsTableReferences
                                            ._environmentIdTable(db),
                                    referencedColumn:
                                        $$EnvironmentAgentsTableReferences
                                            ._environmentIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (stageId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.stageId,
                                    referencedTable:
                                        $$EnvironmentAgentsTableReferences
                                            ._stageIdTable(db),
                                    referencedColumn:
                                        $$EnvironmentAgentsTableReferences
                                            ._stageIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (prototypeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.prototypeId,
                                    referencedTable:
                                        $$EnvironmentAgentsTableReferences
                                            ._prototypeIdTable(db),
                                    referencedColumn:
                                        $$EnvironmentAgentsTableReferences
                                            ._prototypeIdTable(db)
                                            .id,
                                  )
                                  as T;
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

typedef $$EnvironmentAgentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EnvironmentAgentsTable,
      EnvironmentAgent,
      $$EnvironmentAgentsTableFilterComposer,
      $$EnvironmentAgentsTableOrderingComposer,
      $$EnvironmentAgentsTableAnnotationComposer,
      $$EnvironmentAgentsTableCreateCompanionBuilder,
      $$EnvironmentAgentsTableUpdateCompanionBuilder,
      (EnvironmentAgent, $$EnvironmentAgentsTableReferences),
      EnvironmentAgent,
      PrefetchHooks Function({
        bool environmentId,
        bool stageId,
        bool prototypeId,
      })
    >;
typedef $$MetabolismTableCreateCompanionBuilder =
    MetabolismCompanion Function({
      Value<int> id,
      required int nutrientId,
      Value<String> minFormula,
      Value<String> criticalFormula,
      Value<String> optimalFormula,
      Value<String> initialFormula,
      Value<String> maxFormula,
    });
typedef $$MetabolismTableUpdateCompanionBuilder =
    MetabolismCompanion Function({
      Value<int> id,
      Value<int> nutrientId,
      Value<String> minFormula,
      Value<String> criticalFormula,
      Value<String> optimalFormula,
      Value<String> initialFormula,
      Value<String> maxFormula,
    });

final class $$MetabolismTableReferences
    extends BaseReferences<_$AppDatabase, $MetabolismTable, MetabolismData> {
  $$MetabolismTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $NutrientsTable _nutrientIdTable(_$AppDatabase db) =>
      db.nutrients.createAlias('metabolism__nutrient_id__nutrients__id');

  $$NutrientsTableProcessedTableManager get nutrientId {
    final $_column = $_itemColumn<int>('nutrient_id')!;

    final manager = $$NutrientsTableTableManager(
      $_db,
      $_db.nutrients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_nutrientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MetabolismTableFilterComposer
    extends Composer<_$AppDatabase, $MetabolismTable> {
  $$MetabolismTableFilterComposer({
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

  ColumnFilters<String> get minFormula => $composableBuilder(
    column: $table.minFormula,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get criticalFormula => $composableBuilder(
    column: $table.criticalFormula,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get optimalFormula => $composableBuilder(
    column: $table.optimalFormula,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get initialFormula => $composableBuilder(
    column: $table.initialFormula,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get maxFormula => $composableBuilder(
    column: $table.maxFormula,
    builder: (column) => ColumnFilters(column),
  );

  $$NutrientsTableFilterComposer get nutrientId {
    final $$NutrientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.nutrientId,
      referencedTable: $db.nutrients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NutrientsTableFilterComposer(
            $db: $db,
            $table: $db.nutrients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MetabolismTableOrderingComposer
    extends Composer<_$AppDatabase, $MetabolismTable> {
  $$MetabolismTableOrderingComposer({
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

  ColumnOrderings<String> get minFormula => $composableBuilder(
    column: $table.minFormula,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get criticalFormula => $composableBuilder(
    column: $table.criticalFormula,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get optimalFormula => $composableBuilder(
    column: $table.optimalFormula,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get initialFormula => $composableBuilder(
    column: $table.initialFormula,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get maxFormula => $composableBuilder(
    column: $table.maxFormula,
    builder: (column) => ColumnOrderings(column),
  );

  $$NutrientsTableOrderingComposer get nutrientId {
    final $$NutrientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.nutrientId,
      referencedTable: $db.nutrients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NutrientsTableOrderingComposer(
            $db: $db,
            $table: $db.nutrients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MetabolismTableAnnotationComposer
    extends Composer<_$AppDatabase, $MetabolismTable> {
  $$MetabolismTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get minFormula => $composableBuilder(
    column: $table.minFormula,
    builder: (column) => column,
  );

  GeneratedColumn<String> get criticalFormula => $composableBuilder(
    column: $table.criticalFormula,
    builder: (column) => column,
  );

  GeneratedColumn<String> get optimalFormula => $composableBuilder(
    column: $table.optimalFormula,
    builder: (column) => column,
  );

  GeneratedColumn<String> get initialFormula => $composableBuilder(
    column: $table.initialFormula,
    builder: (column) => column,
  );

  GeneratedColumn<String> get maxFormula => $composableBuilder(
    column: $table.maxFormula,
    builder: (column) => column,
  );

  $$NutrientsTableAnnotationComposer get nutrientId {
    final $$NutrientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.nutrientId,
      referencedTable: $db.nutrients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NutrientsTableAnnotationComposer(
            $db: $db,
            $table: $db.nutrients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MetabolismTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MetabolismTable,
          MetabolismData,
          $$MetabolismTableFilterComposer,
          $$MetabolismTableOrderingComposer,
          $$MetabolismTableAnnotationComposer,
          $$MetabolismTableCreateCompanionBuilder,
          $$MetabolismTableUpdateCompanionBuilder,
          (MetabolismData, $$MetabolismTableReferences),
          MetabolismData,
          PrefetchHooks Function({bool nutrientId})
        > {
  $$MetabolismTableTableManager(_$AppDatabase db, $MetabolismTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetabolismTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetabolismTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetabolismTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> nutrientId = const Value.absent(),
                Value<String> minFormula = const Value.absent(),
                Value<String> criticalFormula = const Value.absent(),
                Value<String> optimalFormula = const Value.absent(),
                Value<String> initialFormula = const Value.absent(),
                Value<String> maxFormula = const Value.absent(),
              }) => MetabolismCompanion(
                id: id,
                nutrientId: nutrientId,
                minFormula: minFormula,
                criticalFormula: criticalFormula,
                optimalFormula: optimalFormula,
                initialFormula: initialFormula,
                maxFormula: maxFormula,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int nutrientId,
                Value<String> minFormula = const Value.absent(),
                Value<String> criticalFormula = const Value.absent(),
                Value<String> optimalFormula = const Value.absent(),
                Value<String> initialFormula = const Value.absent(),
                Value<String> maxFormula = const Value.absent(),
              }) => MetabolismCompanion.insert(
                id: id,
                nutrientId: nutrientId,
                minFormula: minFormula,
                criticalFormula: criticalFormula,
                optimalFormula: optimalFormula,
                initialFormula: initialFormula,
                maxFormula: maxFormula,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MetabolismTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({nutrientId = false}) {
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
                    if (nutrientId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.nutrientId,
                                referencedTable: $$MetabolismTableReferences
                                    ._nutrientIdTable(db),
                                referencedColumn: $$MetabolismTableReferences
                                    ._nutrientIdTable(db)
                                    .id,
                              )
                              as T;
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

typedef $$MetabolismTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MetabolismTable,
      MetabolismData,
      $$MetabolismTableFilterComposer,
      $$MetabolismTableOrderingComposer,
      $$MetabolismTableAnnotationComposer,
      $$MetabolismTableCreateCompanionBuilder,
      $$MetabolismTableUpdateCompanionBuilder,
      (MetabolismData, $$MetabolismTableReferences),
      MetabolismData,
      PrefetchHooks Function({bool nutrientId})
    >;
typedef $$ReproductionTableCreateCompanionBuilder =
    ReproductionCompanion Function({
      Value<int> id,
      Value<String> maxEggsFormula,
      Value<String> maxSpermPacksFormula,
      Value<String> packsTransferredFormula,
      Value<String> fractionFertilizedFormula,
      Value<String> paternityFormula,
      Value<String> maxStoredPacksFormula,
      Value<String> consumptionRateFormula,
      Value<String> eggsPerCycleFormula,
      Value<String> eggFractionFormula,
      Value<String> packFractionFormula,
      Value<String> spermDegradationFormula,
    });
typedef $$ReproductionTableUpdateCompanionBuilder =
    ReproductionCompanion Function({
      Value<int> id,
      Value<String> maxEggsFormula,
      Value<String> maxSpermPacksFormula,
      Value<String> packsTransferredFormula,
      Value<String> fractionFertilizedFormula,
      Value<String> paternityFormula,
      Value<String> maxStoredPacksFormula,
      Value<String> consumptionRateFormula,
      Value<String> eggsPerCycleFormula,
      Value<String> eggFractionFormula,
      Value<String> packFractionFormula,
      Value<String> spermDegradationFormula,
    });

class $$ReproductionTableFilterComposer
    extends Composer<_$AppDatabase, $ReproductionTable> {
  $$ReproductionTableFilterComposer({
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

  ColumnFilters<String> get maxEggsFormula => $composableBuilder(
    column: $table.maxEggsFormula,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get maxSpermPacksFormula => $composableBuilder(
    column: $table.maxSpermPacksFormula,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packsTransferredFormula => $composableBuilder(
    column: $table.packsTransferredFormula,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fractionFertilizedFormula => $composableBuilder(
    column: $table.fractionFertilizedFormula,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paternityFormula => $composableBuilder(
    column: $table.paternityFormula,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get maxStoredPacksFormula => $composableBuilder(
    column: $table.maxStoredPacksFormula,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get consumptionRateFormula => $composableBuilder(
    column: $table.consumptionRateFormula,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eggsPerCycleFormula => $composableBuilder(
    column: $table.eggsPerCycleFormula,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eggFractionFormula => $composableBuilder(
    column: $table.eggFractionFormula,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packFractionFormula => $composableBuilder(
    column: $table.packFractionFormula,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get spermDegradationFormula => $composableBuilder(
    column: $table.spermDegradationFormula,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReproductionTableOrderingComposer
    extends Composer<_$AppDatabase, $ReproductionTable> {
  $$ReproductionTableOrderingComposer({
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

  ColumnOrderings<String> get maxEggsFormula => $composableBuilder(
    column: $table.maxEggsFormula,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get maxSpermPacksFormula => $composableBuilder(
    column: $table.maxSpermPacksFormula,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packsTransferredFormula => $composableBuilder(
    column: $table.packsTransferredFormula,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fractionFertilizedFormula => $composableBuilder(
    column: $table.fractionFertilizedFormula,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paternityFormula => $composableBuilder(
    column: $table.paternityFormula,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get maxStoredPacksFormula => $composableBuilder(
    column: $table.maxStoredPacksFormula,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get consumptionRateFormula => $composableBuilder(
    column: $table.consumptionRateFormula,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eggsPerCycleFormula => $composableBuilder(
    column: $table.eggsPerCycleFormula,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eggFractionFormula => $composableBuilder(
    column: $table.eggFractionFormula,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packFractionFormula => $composableBuilder(
    column: $table.packFractionFormula,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spermDegradationFormula => $composableBuilder(
    column: $table.spermDegradationFormula,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReproductionTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReproductionTable> {
  $$ReproductionTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get maxEggsFormula => $composableBuilder(
    column: $table.maxEggsFormula,
    builder: (column) => column,
  );

  GeneratedColumn<String> get maxSpermPacksFormula => $composableBuilder(
    column: $table.maxSpermPacksFormula,
    builder: (column) => column,
  );

  GeneratedColumn<String> get packsTransferredFormula => $composableBuilder(
    column: $table.packsTransferredFormula,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fractionFertilizedFormula => $composableBuilder(
    column: $table.fractionFertilizedFormula,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paternityFormula => $composableBuilder(
    column: $table.paternityFormula,
    builder: (column) => column,
  );

  GeneratedColumn<String> get maxStoredPacksFormula => $composableBuilder(
    column: $table.maxStoredPacksFormula,
    builder: (column) => column,
  );

  GeneratedColumn<String> get consumptionRateFormula => $composableBuilder(
    column: $table.consumptionRateFormula,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eggsPerCycleFormula => $composableBuilder(
    column: $table.eggsPerCycleFormula,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eggFractionFormula => $composableBuilder(
    column: $table.eggFractionFormula,
    builder: (column) => column,
  );

  GeneratedColumn<String> get packFractionFormula => $composableBuilder(
    column: $table.packFractionFormula,
    builder: (column) => column,
  );

  GeneratedColumn<String> get spermDegradationFormula => $composableBuilder(
    column: $table.spermDegradationFormula,
    builder: (column) => column,
  );
}

class $$ReproductionTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReproductionTable,
          ReproductionData,
          $$ReproductionTableFilterComposer,
          $$ReproductionTableOrderingComposer,
          $$ReproductionTableAnnotationComposer,
          $$ReproductionTableCreateCompanionBuilder,
          $$ReproductionTableUpdateCompanionBuilder,
          (
            ReproductionData,
            BaseReferences<_$AppDatabase, $ReproductionTable, ReproductionData>,
          ),
          ReproductionData,
          PrefetchHooks Function()
        > {
  $$ReproductionTableTableManager(_$AppDatabase db, $ReproductionTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReproductionTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReproductionTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReproductionTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> maxEggsFormula = const Value.absent(),
                Value<String> maxSpermPacksFormula = const Value.absent(),
                Value<String> packsTransferredFormula = const Value.absent(),
                Value<String> fractionFertilizedFormula = const Value.absent(),
                Value<String> paternityFormula = const Value.absent(),
                Value<String> maxStoredPacksFormula = const Value.absent(),
                Value<String> consumptionRateFormula = const Value.absent(),
                Value<String> eggsPerCycleFormula = const Value.absent(),
                Value<String> eggFractionFormula = const Value.absent(),
                Value<String> packFractionFormula = const Value.absent(),
                Value<String> spermDegradationFormula = const Value.absent(),
              }) => ReproductionCompanion(
                id: id,
                maxEggsFormula: maxEggsFormula,
                maxSpermPacksFormula: maxSpermPacksFormula,
                packsTransferredFormula: packsTransferredFormula,
                fractionFertilizedFormula: fractionFertilizedFormula,
                paternityFormula: paternityFormula,
                maxStoredPacksFormula: maxStoredPacksFormula,
                consumptionRateFormula: consumptionRateFormula,
                eggsPerCycleFormula: eggsPerCycleFormula,
                eggFractionFormula: eggFractionFormula,
                packFractionFormula: packFractionFormula,
                spermDegradationFormula: spermDegradationFormula,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> maxEggsFormula = const Value.absent(),
                Value<String> maxSpermPacksFormula = const Value.absent(),
                Value<String> packsTransferredFormula = const Value.absent(),
                Value<String> fractionFertilizedFormula = const Value.absent(),
                Value<String> paternityFormula = const Value.absent(),
                Value<String> maxStoredPacksFormula = const Value.absent(),
                Value<String> consumptionRateFormula = const Value.absent(),
                Value<String> eggsPerCycleFormula = const Value.absent(),
                Value<String> eggFractionFormula = const Value.absent(),
                Value<String> packFractionFormula = const Value.absent(),
                Value<String> spermDegradationFormula = const Value.absent(),
              }) => ReproductionCompanion.insert(
                id: id,
                maxEggsFormula: maxEggsFormula,
                maxSpermPacksFormula: maxSpermPacksFormula,
                packsTransferredFormula: packsTransferredFormula,
                fractionFertilizedFormula: fractionFertilizedFormula,
                paternityFormula: paternityFormula,
                maxStoredPacksFormula: maxStoredPacksFormula,
                consumptionRateFormula: consumptionRateFormula,
                eggsPerCycleFormula: eggsPerCycleFormula,
                eggFractionFormula: eggFractionFormula,
                packFractionFormula: packFractionFormula,
                spermDegradationFormula: spermDegradationFormula,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReproductionTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReproductionTable,
      ReproductionData,
      $$ReproductionTableFilterComposer,
      $$ReproductionTableOrderingComposer,
      $$ReproductionTableAnnotationComposer,
      $$ReproductionTableCreateCompanionBuilder,
      $$ReproductionTableUpdateCompanionBuilder,
      (
        ReproductionData,
        BaseReferences<_$AppDatabase, $ReproductionTable, ReproductionData>,
      ),
      ReproductionData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProjectInfoTableTableManager get projectInfo =>
      $$ProjectInfoTableTableManager(_db, _db.projectInfo);
  $$NutrientsTableTableManager get nutrients =>
      $$NutrientsTableTableManager(_db, _db.nutrients);
  $$SubstratesTableTableManager get substrates =>
      $$SubstratesTableTableManager(_db, _db.substrates);
  $$SubstrateCompositionsTableTableManager get substrateCompositions =>
      $$SubstrateCompositionsTableTableManager(_db, _db.substrateCompositions);
  $$LociTableTableManager get loci => $$LociTableTableManager(_db, _db.loci);
  $$StagesTableTableManager get stages =>
      $$StagesTableTableManager(_db, _db.stages);
  $$PrototypesTableTableManager get prototypes =>
      $$PrototypesTableTableManager(_db, _db.prototypes);
  $$ResourceTypesTableTableManager get resourceTypes =>
      $$ResourceTypesTableTableManager(_db, _db.resourceTypes);
  $$EnvironmentsTableTableManager get environments =>
      $$EnvironmentsTableTableManager(_db, _db.environments);
  $$SubstrateMapRowsTableTableManager get substrateMapRows =>
      $$SubstrateMapRowsTableTableManager(_db, _db.substrateMapRows);
  $$EnvironmentResourcesTableTableManager get environmentResources =>
      $$EnvironmentResourcesTableTableManager(_db, _db.environmentResources);
  $$EnvironmentAgentsTableTableManager get environmentAgents =>
      $$EnvironmentAgentsTableTableManager(_db, _db.environmentAgents);
  $$MetabolismTableTableManager get metabolism =>
      $$MetabolismTableTableManager(_db, _db.metabolism);
  $$ReproductionTableTableManager get reproduction =>
      $$ReproductionTableTableManager(_db, _db.reproduction);
}
