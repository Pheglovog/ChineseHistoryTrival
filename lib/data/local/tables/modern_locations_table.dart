import 'package:drift/drift.dart';

/// 现代地名表 - 存储现代地理位置信息
@TableIndex(name: 'idx_modern_locations_lat_lng', columns: {#latitude, #longitude})
class ModernLocations extends Table {
  /// 自增主键
  late final id = integer().autoIncrement()();

  /// 地名
  late final name = text().withLength(min: 1)();

  /// 省份
  late final province = text().nullable()();

  /// 城市
  late final city = text().nullable()();

  /// 区县
  late final district = text().nullable()();

  /// 纬度
  late final latitude = real()();

  /// 经度
  late final longitude = real()();

  /// 高德地图POI ID
  late final amapPoiId = text().nullable()();

  /// 数据来源："manual"/"ai"/"geocoding"
  late final source = text().withLength(min: 1)();

  /// 置信度，范围 0.0 ~ 1.0
  late final confidence = real().nullable()();

  /// 是否已验证，默认 false
  late final verified = boolean().withDefault(const Constant(false))();
}
