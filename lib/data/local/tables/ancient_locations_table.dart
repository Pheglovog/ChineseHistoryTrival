import 'package:drift/drift.dart';

/// 古代地名表 - 存储历代行政区划及地名信息
@TableIndex(name: 'idx_ancient_locations_dynasty_admin', columns: {#dynastyId, #adminLevel})
class AncientLocations extends Table {
  /// 自增主键
  late final id = integer().autoIncrement()();

  /// 所属朝代ID，外键引用 dynasties 表
  late final dynastyId = integer().references(Dynasties, #id)();

  /// 地名
  late final name = text().withLength(min: 1)();

  /// 别名
  late final alias = text().nullable()();

  /// 行政级别："zhou"/"jun"/"xian"
  late final adminLevel = text().withLength(min: 1)();

  /// 上级地点ID（自引用外键）
  late final parentLocationId = integer().nullable()();

  /// 描述
  late final description = text().nullable()();

  /// 设立年份
  late final yearEstablished = integer().nullable()();

  /// 废除年份
  late final yearAbolished = integer().nullable()();

  /// 历史意义
  late final historicalSignificance = text().nullable()();
}
