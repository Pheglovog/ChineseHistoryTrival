import 'package:drift/drift.dart';
import '../tables/ancient_locations_table.dart';
import '../tables/dynasties_table.dart';
import '../database/app_database.dart';

part 'ancient_location_dao.g.dart';

/// 古代地名数据访问对象
@DriftAccessor(tables: [AncientLocations])
class AncientLocationDao extends DatabaseAccessor<AppDatabase> {
  AncientLocationDao(AppDatabase db) : super(db);

  // ---------------------------------------------------------------------------
  // The generated mixin will be added after running build_runner:
  //   with _$AncientLocationDaoMixin
  // ---------------------------------------------------------------------------

  /// 监听指定朝代下的所有古代地名（响应式）
  Stream<List<AncientLocation>> watchByDynasty(int dynastyId) {
    return (select(ancientLocations)..where((t) => t.dynastyId.equals(dynastyId)))
        .watch();
  }

  /// 监听指定朝代 + 行政级别的古代地名（响应式）
  Stream<List<AncientLocation>> watchByDynastyAndLevel(
    int dynastyId,
    String adminLevel,
  ) {
    return (select(ancientLocations)
          ..where((t) =>
              t.dynastyId.equals(dynastyId) & t.adminLevel.equals(adminLevel)))
        .watch();
  }

  /// 监听指定上级地点的子地点（响应式）
  Stream<List<AncientLocation>> watchChildren(int parentLocationId) {
    return (select(ancientLocations)
          ..where((t) => t.parentLocationId.equals(parentLocationId)))
        .watch();
  }

  /// 获取指定朝代 + 行政级别的古代地名（一次性）
  Future<List<AncientLocation>> getByDynastyAndLevel(
    int dynastyId,
    String adminLevel,
  ) {
    return (select(ancientLocations)
          ..where((t) =>
              t.dynastyId.equals(dynastyId) & t.adminLevel.equals(adminLevel)))
        .get();
  }

  /// 根据 ID 获取单个古代地名
  Future<AncientLocation> getById(int id) {
    return (select(ancientLocations)..where((t) => t.id.equals(id)))
        .getSingle();
  }

  /// 插入单条古代地名记录，返回新记录的 id
  Future<int> insert(AncientLocationsCompanion entry) {
    return into(ancientLocations).insert(entry);
  }

  /// 批量插入古代地名记录
  Future<void> insertAll(List<AncientLocationsCompanion> entries) {
    return batch((b) {
      b.insertAll(ancientLocations, entries);
    });
  }

  /// 统计指定朝代下的古代地名数量
  Future<int> countByDynasty(int dynastyId) async {
    final countExpr = ancientLocations.id.count();
    final query = selectOnly(ancientLocations)
      ..addColumns([countExpr])
      ..where(ancientLocations.dynastyId.equals(dynastyId));
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }
}
