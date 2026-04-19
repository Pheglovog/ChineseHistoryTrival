import 'package:drift/drift.dart';

/// 朝代表 - 存储中国历代朝代信息
class Dynasties extends Table {
  /// 自增主键
  late final id = integer().autoIncrement()();

  /// 朝代名称，如"汉朝"
  late final name = text().withLength(min: 1)();

  /// 英文名称，如"Han Dynasty"
  late final nameEn = text().nullable()();

  /// 开始年份（公元前为负数），如 -202
  late final startYear = integer()();

  /// 结束年份，如 220
  late final endYear = integer()();

  /// 子时期，如"西汉/东汉"
  late final subPeriod = text().nullable()();

  /// 朝代描述
  late final description = text().nullable()();
}
