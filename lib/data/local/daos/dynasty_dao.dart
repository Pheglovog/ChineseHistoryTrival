import 'package:drift/drift.dart';
import '../tables/dynasties_table.dart';
import '../database/app_database.dart';

part 'dynasty_dao.g.dart';

/// 朝代数据访问对象
@DriftAccessor(tables: [Dynasties])
class DynastyDao extends DatabaseAccessor<AppDatabase> {
  DynastyDao(AppDatabase db) : super(db);

  // ---------------------------------------------------------------------------
  // The generated mixin will be added after running build_runner:
  //   with _$DynastyDaoMixin
  // Until then we access tables through the attachedDatabase helper.
  // ---------------------------------------------------------------------------

  /// 获取所有朝代列表
  Future<List<Dynasty>> getAllDynasties() {
    return select(dynasties).get();
  }

  /// 监听所有朝代列表（响应式）
  Stream<List<Dynasty>> watchAllDynasties() {
    return select(dynasties).watch();
  }

  /// 根据 ID 获取单个朝代
  Future<Dynasty> getDynastyById(int id) {
    return (select(dynasties)..where((t) => t.id.equals(id))).getSingle();
  }

  /// 插入单条朝代记录，返回新记录的 id
  Future<int> insertDynasty(DynastiesCompanion dynasty) {
    return into(dynasties).insert(dynasty);
  }

  /// 批量插入朝代记录
  Future<void> insertDynasties(List<DynastiesCompanion> dynastiesList) {
    return batch((b) {
      b.insertAll(dynasties, dynastiesList);
    });
  }
}
