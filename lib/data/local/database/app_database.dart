import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import 'schema.dart';
import '../daos/dynasty_dao.dart';
import '../daos/ancient_location_dao.dart';
import '../daos/modern_location_dao.dart';
import '../daos/location_match_dao.dart';

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
        await db.execute(Schema.createIndexDynastyAdmin);
        await db.execute(Schema.createIndexLatLng);
      },
    );
  }

  // Lazy DAO singletons
  DynastyDao? _dynastyDao;
  AncientLocationDao? _ancientLocationDao;
  ModernLocationDao? _modernLocationDao;
  LocationMatchDao? _locationMatchDao;

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
}
