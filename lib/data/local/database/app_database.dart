import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import 'schema.dart';
import '../daos/dynasty_dao.dart';
import '../daos/ancient_location_dao.dart';
import '../daos/modern_location_dao.dart';
import '../daos/location_match_dao.dart';
import '../daos/historical_figure_dao.dart';
import '../daos/figure_location_relation_dao.dart';
import '../daos/travel_route_dao.dart';
import '../daos/history_card_dao.dart';
import '../daos/user_favorite_dao.dart';
import '../daos/browse_history_dao.dart';

class AppDatabase {
  static Database? _database;

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, Schema.databaseName);

    return openDatabase(
      path,
      version: Schema.version,
      onCreate: (db, version) async {
        await db.execute(Schema.createDynasties);
        await db.execute(Schema.createAncientLocations);
        await db.execute(Schema.createModernLocations);
        await db.execute(Schema.createLocationMatches);
        await db.execute(Schema.createHistoricalFigures);
        await db.execute(Schema.createFigureLocationRelations);
        await db.execute(Schema.createTravelRoutes);
        await db.execute(Schema.createRouteStops);
        await db.execute(Schema.createHistoryCards);
        await db.execute(Schema.createUserFavorites);
        await db.execute(Schema.createBrowseHistory);
        await db.execute(Schema.createIndexDynastyAdmin);
        await db.execute(Schema.createIndexLatLng);
        await db.execute(Schema.createIndexFigureDynasty);
        await db.execute(Schema.createIndexFigureLocRelation);
        await db.execute(Schema.createIndexFigureLocRelationLoc);
        await db.execute(Schema.createIndexRouteDynasty);
        await db.execute(Schema.createIndexRouteStopRoute);
        await db.execute(Schema.createIndexHistoryCardsDynasty);
        await db.execute(Schema.createIndexUserFavoritesDynasty);
        await db.execute(Schema.createIndexBrowseHistoryTime);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // V2: add new tables for figures, routes, cards, favorites, history
          await db.execute(Schema.createHistoricalFigures);
          await db.execute(Schema.createFigureLocationRelations);
          await db.execute(Schema.createTravelRoutes);
          await db.execute(Schema.createRouteStops);
          await db.execute(Schema.createHistoryCards);
          await db.execute(Schema.createUserFavorites);
          await db.execute(Schema.createBrowseHistory);
          await db.execute(Schema.createIndexFigureDynasty);
          await db.execute(Schema.createIndexFigureLocRelation);
          await db.execute(Schema.createIndexFigureLocRelationLoc);
          await db.execute(Schema.createIndexRouteDynasty);
          await db.execute(Schema.createIndexRouteStopRoute);
          await db.execute(Schema.createIndexHistoryCardsDynasty);
          await db.execute(Schema.createIndexUserFavoritesDynasty);
          await db.execute(Schema.createIndexBrowseHistoryTime);
        }
      },
    );
  }

  // Lazy DAO singletons
  DynastyDao? _dynastyDao;
  AncientLocationDao? _ancientLocationDao;
  ModernLocationDao? _modernLocationDao;
  LocationMatchDao? _locationMatchDao;
  HistoricalFigureDao? _historicalFigureDao;
  FigureLocationRelationDao? _figureLocationRelationDao;
  TravelRouteDao? _travelRouteDao;
  HistoryCardDao? _historyCardDao;
  UserFavoriteDao? _userFavoriteDao;
  BrowseHistoryDao? _browseHistoryDao;

  Future<DynastyDao> get dynastyDao async {
    _dynastyDao ??= DynastyDao(await database);
    return _dynastyDao!;
  }

  Future<AncientLocationDao> get ancientLocationDao async {
    _ancientLocationDao ??= AncientLocationDao(await database);
    return _ancientLocationDao!;
  }

  Future<ModernLocationDao> get modernLocationDao async {
    _modernLocationDao ??= ModernLocationDao(await database);
    return _modernLocationDao!;
  }

  Future<LocationMatchDao> get locationMatchDao async {
    _locationMatchDao ??= LocationMatchDao(await database);
    return _locationMatchDao!;
  }

  Future<HistoricalFigureDao> get historicalFigureDao async {
    _historicalFigureDao ??= HistoricalFigureDao(await database);
    return _historicalFigureDao!;
  }

  Future<FigureLocationRelationDao> get figureLocationRelationDao async {
    _figureLocationRelationDao ??= FigureLocationRelationDao(await database);
    return _figureLocationRelationDao!;
  }

  Future<TravelRouteDao> get travelRouteDao async {
    _travelRouteDao ??= TravelRouteDao(await database);
    return _travelRouteDao!;
  }

  Future<HistoryCardDao> get historyCardDao async {
    _historyCardDao ??= HistoryCardDao(await database);
    return _historyCardDao!;
  }

  Future<UserFavoriteDao> get userFavoriteDao async {
    _userFavoriteDao ??= UserFavoriteDao(await database);
    return _userFavoriteDao!;
  }

  Future<BrowseHistoryDao> get browseHistoryDao async {
    _browseHistoryDao ??= BrowseHistoryDao(await database);
    return _browseHistoryDao!;
  }
}
