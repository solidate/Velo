import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'velo_core.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const boolType = 'INTEGER NOT NULL';
    const integerType = 'INTEGER';

    // Exercises Table
    await db.execute('''
      CREATE TABLE exercises (
        id $idType,
        name $textType,
        description $textType,
        media_path TEXT,
        is_custom $boolType,
        body_part $textType,
        equipment_type $textType,
        difficulty_level $textType,
        target_muscle_groups TEXT,
        instructions TEXT,
        common_mistakes TEXT,
        form_tips TEXT,
        equipment_alternatives TEXT,
        media_type TEXT,
        media_source TEXT
      )
    ''');
    
    // Workouts Table
    await db.execute('''
      CREATE TABLE workouts (
        id $idType,
        name $textType,
        description $textType,
        is_template $boolType
      )
    ''');

    // Workout Exercises Table
    await db.execute('''
      CREATE TABLE workout_exercises (
        id $idType,
        workout_id TEXT NOT NULL,
        exercise_id TEXT NOT NULL,
        sort_order $integerType,
        target_sets $integerType,
        target_reps TEXT,
        rest_seconds $integerType,
        FOREIGN KEY (workout_id) REFERENCES workouts (id) ON DELETE CASCADE,
        FOREIGN KEY (exercise_id) REFERENCES exercises (id)
      )
    ''');

    // Workout Logs Table
    await db.execute('''
      CREATE TABLE workout_logs (
        id $idType,
        workout_template_id TEXT,
        start_time $integerType,
        end_time $integerType,
        notes TEXT
      )
    ''');

    // Exercise Logs Table
    await db.execute('''
      CREATE TABLE exercise_logs (
        id $idType,
        workout_log_id TEXT NOT NULL,
        exercise_id TEXT NOT NULL,
        set_number $integerType,
        weight REAL,
        reps $integerType,
        rpe $integerType,
        FOREIGN KEY (workout_log_id) REFERENCES workout_logs (id) ON DELETE CASCADE,
        FOREIGN KEY (exercise_id) REFERENCES exercises (id)
      )
    ''');

    // Schedules Table
    await db.execute('''
      CREATE TABLE schedules (
        id $idType,
        name $textType,
        is_active $boolType,
        description TEXT
      )
    ''');

    // Scheduled Exercises Table
    await db.execute('''
      CREATE TABLE scheduled_exercises (
        id $idType,
        schedule_id TEXT NOT NULL,
        day_of_week $integerType,
        exercise_id TEXT NOT NULL,
        sort_order $integerType,
        target_sets $integerType,
        target_reps TEXT,
        rest_seconds $integerType,
        target_time_seconds $integerType,
        notes TEXT,
        FOREIGN KEY (schedule_id) REFERENCES schedules (id) ON DELETE CASCADE,
        FOREIGN KEY (exercise_id) REFERENCES exercises (id)
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const boolType = 'INTEGER NOT NULL';
    const integerType = 'INTEGER';

    if (oldVersion < 2) {
      // Create new tables if they don't exist
      await db.execute('''
        CREATE TABLE IF NOT EXISTS schedules (
          id $idType,
          name $textType,
          is_active $boolType,
          description TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS scheduled_exercises (
          id $idType,
          schedule_id TEXT NOT NULL,
          day_of_week $integerType,
          exercise_id TEXT NOT NULL,
          sort_order $integerType,
          target_sets $integerType,
          target_reps TEXT,
          rest_seconds $integerType,
          notes TEXT,
          FOREIGN KEY (schedule_id) REFERENCES schedules (id) ON DELETE CASCADE,
          FOREIGN KEY (exercise_id) REFERENCES exercises (id)
        )
      ''');
      
      // Update exercises table
      var columns = await db.rawQuery('PRAGMA table_info(exercises)');
      var hasCategory = columns.any((c) => c['name'] == 'category');
      var hasBodyPart = columns.any((c) => c['name'] == 'body_part');
      
      if (hasCategory && !hasBodyPart) {
        await db.execute('ALTER TABLE exercises RENAME COLUMN category TO body_part');
      } else if (!hasBodyPart) {
        await db.execute('ALTER TABLE exercises ADD COLUMN body_part $textType DEFAULT ""');
      }

      final newColumns = [
        'equipment_type TEXT',
        'difficulty_level TEXT',
        'target_muscle_groups TEXT',
        'instructions TEXT',
        'common_mistakes TEXT',
        'form_tips TEXT',
        'equipment_alternatives TEXT',
        'media_type TEXT',
        'media_source TEXT'
      ];

      for (var col in newColumns) {
        var colName = col.split(' ')[0];
        if (!columns.any((c) => c['name'] == colName)) {
          await db.execute('ALTER TABLE exercises ADD COLUMN $col');
        }
      }
    }

    if (oldVersion < 3) {
      // Add target_time_seconds to scheduled_exercises if table exists
      try {
        await db.execute('ALTER TABLE scheduled_exercises ADD COLUMN target_time_seconds $integerType');
      } catch (e) {
        // Table might not exist if v1->v3 and v2 block created it without column? 
        // No, v2 block creates it WITHOUT column. So this block adds it.
        // If v2 block created it, it follows v2 schema.
        // If v1->v3, both blocks run. v2 creates table. v3 adds column. Correct.
      }
    }
  }
}
