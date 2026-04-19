import 'package:drift/drift.dart';
import '../tables/modern_locations_table.dart';
import '../database/app_database.dart';

part 'modern_location_dao.g.dart';

/// 现代地名数据访问对象
@DriftAccessor(tables: [ModernLocations])
class ModernLocationDao extends DatabaseAccessor<AppDatabase> {
  ModernLocationDao(AppDatabase db) : super(db);

  // ---------------------------------------------------------------------------
  // The generated mixin will be added after running build_runner:
  //   with _$ModernLocationDaoMixin
  // ---------------------------------------------------------------------------

  /// 模糊查询：名称包含 [name] 的所有现代地名
  Future<List<ModernLocation>> getByName(String name) {
    return (select(modernLocations)
          ..where((t) => t.name.like('%$name%')))
        .get();
  }

  /// 精确查询：名称完全匹配的现代地名（可能为 null）
  Future<ModernLocation?> getByNameExact(String name) {
    return (select(modernLocations)..where((t) => t.name.equals(name)))
        .getSingleOrNull();
  }

  /// 根据经纬度范围查询现代地名
  Future<List<ModernLocation>> getByCoordinateRange(
    double minLat,
    double maxLat,
    double minLng,
    double maxLng,
  ) {
    return (select(modernLocations)
          ..where((t) =>
              t.latitude.isBiggerOrEqualValue(minLat) &
              t.latitude.isSmallerOrEqualValue(maxLat) &
              t.longitude.isBiggerOrEqualValue(minLng) &
              t.longitude.isSmallerOrEqualValue(maxLng)))
        .get();
  }

  /// 插入单条现代地名记录，返回新记录的 id
  Future<int> insert(ModernLocationsCompanion entry) {
    return into(modernLocations).insert(entry);
  }

  /// 批量插入现代地名记录
  Future<void> insertAll(List<ModernLocationsCompanion> entries) {
    return batch((b) {
      b.insertAll(modernLocations, entries);
    });
  }
}
