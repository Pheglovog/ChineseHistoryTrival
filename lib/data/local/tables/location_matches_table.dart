import 'package:drift/drift.dart';

/// 古今地名对照表 - 存储古代地名与现代地名的匹配关系
class LocationMatches extends Table {
  /// 自增主键
  late final id = integer().autoIncrement()();

  /// 古代地名ID，外键引用 ancient_locations 表
  late final ancientLocationId = integer().references(AncientLocations, #id)();

  /// 现代地名ID，外键引用 modern_locations 表
  late final modernLocationId = integer().references(ModernLocations, #id)();

  /// 匹配类型："exact"/"approximate"/"regional"
  late final matchType = text().withLength(min: 1)();

  /// 匹配置信度，范围 0.0 ~ 1.0
  late final confidence = real()();

  /// 数据来源："manual"/"ai"/"geocoding"
  late final source = text().withLength(min: 1)();

  /// 备注说明
  late final notes = text().nullable()();

  /// 是否已验证，默认 false
  late final verified = boolean().withDefault(const Constant(false))();

  /// 创建时间，默认为当前时间
  late final createdAt = dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {ancientLocationId, modernLocationId},
      ];
}
