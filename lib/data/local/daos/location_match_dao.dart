import 'package:drift/drift.dart';
import '../tables/location_matches_table.dart';
import '../database/app_database.dart';

part 'location_match_dao.g.dart';

/// 古今地名对照数据访问对象
@DriftAccessor(tables: [LocationMatches])
class LocationMatchDao extends DatabaseAccessor<AppDatabase> {
  LocationMatchDao(AppDatabase db) : super(db);

  // ---------------------------------------------------------------------------
  // The generated mixin will be added after running build_runner:
  //   with _$LocationMatchDaoMixin
  // ---------------------------------------------------------------------------

  /// 获取指定古代地名的所有匹配记录，按置信度降序排列
  Future<List<LocationMatch>> getByAncientLocationId(int ancientLocationId) {
    return (select(locationMatches)
          ..where((t) => t.ancientLocationId.equals(ancientLocationId))
          ..orderBy([
            (t) => OrderingTerm.desc(t.confidence),
          ]))
        .get();
  }

  /// 获取指定古代地名的最佳缓存匹配（置信度最高的已验证匹配）
  Future<LocationMatch?> getCachedMatch(int ancientLocationId) {
    return (select(locationMatches)
          ..where((t) =>
              t.ancientLocationId.equals(ancientLocationId) & t.verified.equals(true))
          ..orderBy([
            (t) => OrderingTerm.desc(t.confidence),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  /// 监听指定古代地名的匹配记录（响应式），按置信度降序
  Stream<List<LocationMatch>> watchByAncientLocationId(int ancientLocationId) {
    return (select(locationMatches)
          ..where((t) => t.ancientLocationId.equals(ancientLocationId))
          ..orderBy([
            (t) => OrderingTerm.desc(t.confidence),
          ]))
        .watch();
  }

  /// 插入单条匹配记录，返回新记录的 id
  Future<int> insert(LocationMatchesCompanion entry) {
    return into(locationMatches).insert(entry);
  }

  /// 批量插入匹配记录
  Future<void> insertAll(List<LocationMatchesCompanion> entries) {
    return batch((b) {
      b.insertAll(locationMatches, entries);
    });
  }

  /// 检查指定古代地名是否已存在匹配记录
  Future<bool> hasMatch(int ancientLocationId) async {
    final query = selectOnly(locationMatches)
      ..addColumns([locationMatches.id.count()])
      ..where(locationMatches.ancientLocationId.equals(ancientLocationId));
    final row = await query.getSingle();
    final count = row.read(locationMatches.id.count()) ?? 0;
    return count > 0;
  }
}
