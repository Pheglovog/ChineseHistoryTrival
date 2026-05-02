/// Database schema constants for sqflite.
class Schema {
  static const String databaseName = 'huaxia_footprint.db';
  static const int version = 2;

  // Table names
  static const String dynasties = 'dynasties';
  static const String ancientLocations = 'ancient_locations';
  static const String modernLocations = 'modern_locations';
  static const String locationMatches = 'location_matches';
  static const String historicalFigures = 'historical_figures';
  static const String figureLocationRelations = 'figure_location_relations';
  static const String travelRoutes = 'travel_routes';
  static const String routeStops = 'route_stops';
  static const String historyCards = 'history_cards';
  static const String userFavorites = 'user_favorites';
  static const String browseHistory = 'browse_history';

  // CREATE TABLE statements
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

  static const String createHistoricalFigures = '''
    CREATE TABLE $historicalFigures (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      dynasty_id INTEGER NOT NULL,
      name TEXT NOT NULL,
      alias TEXT,
      title TEXT,
      birth_year INTEGER,
      death_year INTEGER,
      category TEXT NOT NULL DEFAULT 'other',
      description TEXT,
      biography TEXT,
      FOREIGN KEY (dynasty_id) REFERENCES $dynasties(id)
    )
  ''';

  static const String createFigureLocationRelations = '''
    CREATE TABLE $figureLocationRelations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      figure_id INTEGER NOT NULL,
      location_id INTEGER NOT NULL,
      relation_type TEXT NOT NULL,
      description TEXT,
      FOREIGN KEY (figure_id) REFERENCES $historicalFigures(id),
      FOREIGN KEY (location_id) REFERENCES $ancientLocations(id)
    )
  ''';

  static const String createTravelRoutes = '''
    CREATE TABLE $travelRoutes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      dynasty_id INTEGER NOT NULL,
      name TEXT NOT NULL,
      description TEXT,
      figure_id INTEGER,
      cover_story TEXT,
      difficulty TEXT NOT NULL DEFAULT 'medium',
      estimated_days INTEGER NOT NULL DEFAULT 1,
      is_custom INTEGER NOT NULL DEFAULT 0,
      created_at TEXT,
      FOREIGN KEY (dynasty_id) REFERENCES $dynasties(id),
      FOREIGN KEY (figure_id) REFERENCES $historicalFigures(id)
    )
  ''';

  static const String createRouteStops = '''
    CREATE TABLE $routeStops (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      route_id INTEGER NOT NULL,
      order_index INTEGER NOT NULL,
      location_id INTEGER NOT NULL,
      modern_location_id INTEGER,
      title TEXT,
      description TEXT,
      arrival_story TEXT,
      stay_duration INTEGER,
      FOREIGN KEY (route_id) REFERENCES $travelRoutes(id),
      FOREIGN KEY (location_id) REFERENCES $ancientLocations(id),
      FOREIGN KEY (modern_location_id) REFERENCES $modernLocations(id)
    )
  ''';

  static const String createHistoryCards = '''
    CREATE TABLE $historyCards (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      dynasty_id INTEGER NOT NULL,
      title TEXT NOT NULL,
      content TEXT NOT NULL,
      figure_id INTEGER,
      location_id INTEGER,
      date_hint TEXT,
      category TEXT NOT NULL DEFAULT 'event',
      FOREIGN KEY (dynasty_id) REFERENCES $dynasties(id)
    )
  ''';

  static const String createUserFavorites = '''
    CREATE TABLE $userFavorites (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      location_id INTEGER NOT NULL,
      dynasty_id INTEGER NOT NULL,
      created_at TEXT NOT NULL DEFAULT (datetime('now')),
      FOREIGN KEY (location_id) REFERENCES $ancientLocations(id),
      UNIQUE (location_id)
    )
  ''';

  static const String createBrowseHistory = '''
    CREATE TABLE $browseHistory (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      location_id INTEGER NOT NULL,
      dynasty_id INTEGER NOT NULL,
      visited_at TEXT NOT NULL DEFAULT (datetime('now')),
      FOREIGN KEY (location_id) REFERENCES $ancientLocations(id),
      UNIQUE (location_id)
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

  static const String createIndexFigureDynasty = '''
    CREATE INDEX idx_historical_figures_dynasty
    ON $historicalFigures (dynasty_id, category)
  ''';

  static const String createIndexFigureLocRelation = '''
    CREATE INDEX idx_figure_location_relations_figure
    ON $figureLocationRelations (figure_id)
  ''';

  static const String createIndexFigureLocRelationLoc = '''
    CREATE INDEX idx_figure_location_relations_location
    ON $figureLocationRelations (location_id)
  ''';

  static const String createIndexRouteDynasty = '''
    CREATE INDEX idx_travel_routes_dynasty
    ON $travelRoutes (dynasty_id)
  ''';

  static const String createIndexRouteStopRoute = '''
    CREATE INDEX idx_route_stops_route
    ON $routeStops (route_id, order_index)
  ''';

  static const String createIndexHistoryCardsDynasty = '''
    CREATE INDEX idx_history_cards_dynasty
    ON $historyCards (dynasty_id, category)
  ''';

  static const String createIndexUserFavoritesDynasty = '''
    CREATE INDEX idx_user_favorites_dynasty
    ON $userFavorites (dynasty_id)
  ''';

  static const String createIndexBrowseHistoryTime = '''
    CREATE INDEX idx_browse_history_visited
    ON $browseHistory (visited_at DESC)
  ''';

  // V2 migration: add new tables
  static const String migrationV2 = '''
    $createHistoricalFigures;
    $createFigureLocationRelations;
    $createTravelRoutes;
    $createRouteStops;
    $createHistoryCards;
    $createUserFavorites;
    $createBrowseHistory;
    $createIndexFigureDynasty;
    $createIndexFigureLocRelation;
    $createIndexFigureLocRelationLoc;
    $createIndexRouteDynasty;
    $createIndexRouteStopRoute;
    $createIndexHistoryCardsDynasty;
    $createIndexUserFavoritesDynasty;
    $createIndexBrowseHistoryTime;
  ''';
}
