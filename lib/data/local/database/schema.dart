/// Database schema constants for sqflite.
class Schema {
  static const String databaseName = 'huaxia_footprint.db';
  static const int version = 1;

  // Table names
  static const String dynasties = 'dynasties';
  static const String ancientLocations = 'ancient_locations';
  static const String modernLocations = 'modern_locations';
  static const String locationMatches = 'location_matches';

  // CREATE TABLE statements - column names must match what domain entity fromRow() expects
  static const String createDynasties = '''
    CREATE TABLE $dynasties (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      name_en TEXT,
      start_year INTEGER NOT NULL,
      end_year INTEGER NOT NULL,
      sub_period TEXT,
      description TEXT
    )
  ''';

  static const String createAncientLocations = '''
    CREATE TABLE $ancientLocations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      dynasty_id INTEGER NOT NULL,
      name TEXT NOT NULL,
      alias TEXT,
      admin_level TEXT NOT NULL,
      parent_location_id INTEGER,
      description TEXT,
      year_established INTEGER,
      year_abolished INTEGER,
      historical_significance TEXT,
      FOREIGN KEY (dynasty_id) REFERENCES $dynasties(id)
    )
  ''';

  static const String createModernLocations = '''
    CREATE TABLE $modernLocations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      province TEXT,
      city TEXT,
      district TEXT,
      latitude REAL NOT NULL,
      longitude REAL NOT NULL,
      amap_poi_id TEXT,
      source TEXT NOT NULL DEFAULT 'manual',
      confidence REAL,
      verified INTEGER NOT NULL DEFAULT 0
    )
  ''';

  static const String createLocationMatches = '''
    CREATE TABLE $locationMatches (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      ancient_location_id INTEGER NOT NULL,
      modern_location_id INTEGER NOT NULL,
      match_type TEXT NOT NULL,
      confidence REAL NOT NULL,
      source TEXT NOT NULL,
      notes TEXT,
      verified INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL DEFAULT (datetime('now')),
      FOREIGN KEY (ancient_location_id) REFERENCES $ancientLocations(id),
      FOREIGN KEY (modern_location_id) REFERENCES $modernLocations(id),
      UNIQUE (ancient_location_id, modern_location_id)
    )
  ''';

  // Indexes
  static const String createIndexDynastyAdmin = '''
    CREATE INDEX idx_ancient_locations_dynasty_admin
    ON $ancientLocations (dynasty_id, admin_level)
  ''';

  static const String createIndexLatLng = '''
    CREATE INDEX idx_modern_locations_lat_lng
    ON $modernLocations (latitude, longitude)
  ''';
}
