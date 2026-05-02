import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/historical_figure.dart';
import '../../domain/entities/figure_location_relation.dart';
import '../../domain/enums/figure_category.dart';
import 'database_provider.dart';
import 'current_dynasty_provider.dart';

final figuresByDynastyProvider =
    FutureProvider<List<HistoricalFigure>>((ref) async {
  final db = ref.watch(databaseProvider);
  final dynastyId = ref.watch(currentDynastyIdProvider);
  final dao = await db.historicalFigureDao;
  return dao.getByDynasty(dynastyId);
});

final figuresByDynastyAndCategoryProvider =
    FutureProvider.family<List<HistoricalFigure>, FigureCategory>(
        (ref, category) async {
  final db = ref.watch(databaseProvider);
  final dynastyId = ref.watch(currentDynastyIdProvider);
  final dao = await db.historicalFigureDao;
  return dao.getByDynastyAndCategory(dynastyId, category.name);
});

final figureDetailProvider =
    FutureProvider.family<HistoricalFigure, int>((ref, figureId) async {
  final db = ref.watch(databaseProvider);
  final dao = await db.historicalFigureDao;
  return dao.getById(figureId);
});

final figuresByLocationProvider =
    FutureProvider.family<List<HistoricalFigure>, int>((ref, locationId) async {
  final db = ref.watch(databaseProvider);
  final dao = await db.historicalFigureDao;
  return dao.getByLocationId(locationId);
});

final figureRelationsProvider =
    FutureProvider.family<List<FigureLocationRelation>, int>(
        (ref, figureId) async {
  final db = ref.watch(databaseProvider);
  final dao = await db.figureLocationRelationDao;
  return dao.getByFigureId(figureId);
});
