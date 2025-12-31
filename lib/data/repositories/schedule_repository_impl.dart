import 'package:sqflite/sqflite.dart';
import '../../core/services/database_service.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/entities/scheduled_exercise.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../models/exercise_model.dart';
import '../models/schedule_model.dart';
import '../models/scheduled_exercise_model.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final DatabaseService _databaseService;

  ScheduleRepositoryImpl(this._databaseService);

  @override
  Future<List<Schedule>> getSchedules() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('schedules');
    return List.generate(maps.length, (i) => ScheduleModel.fromMap(maps[i]));
  }

  @override
  Future<Schedule?> getActiveSchedule() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'schedules',
      where: 'is_active = ?',
      whereArgs: [1],
    );
    if (maps.isNotEmpty) {
      return ScheduleModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<Schedule?> getScheduleById(String id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'schedules',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return ScheduleModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> createSchedule(Schedule schedule) async {
    final db = await _databaseService.database;
    final model = ScheduleModel(
      id: schedule.id,
      name: schedule.name,
      description: schedule.description,
      isActive: schedule.isActive,
    );
    await db.insert(
      'schedules',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateSchedule(Schedule schedule) async {
    final db = await _databaseService.database;
    final model = ScheduleModel(
      id: schedule.id,
      name: schedule.name,
      description: schedule.description,
      isActive: schedule.isActive,
    );
    await db.update(
      'schedules',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [schedule.id],
    );
  }

  @override
  Future<void> deleteSchedule(String id) async {
    final db = await _databaseService.database;
    await db.delete(
      'schedules',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> setActiveSchedule(String id) async {
    final db = await _databaseService.database;
    await db.transaction((txn) async {
      // Deactivate all
      await txn.update(
        'schedules',
        {'is_active': 0},
      );
      // Activate specific
      await txn.update(
        'schedules',
        {'is_active': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  @override
  Future<List<ScheduledExercise>> getScheduledExercises(
      String scheduleId, int dayOfWeek) async {
    final db = await _databaseService.database;
    
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT 
        se.*, 
        e.name as exercise_name,
        e.description as exercise_description,
        e.media_path,
        e.is_custom,
        e.body_part,
        e.equipment_type,
        e.difficulty_level,
        e.target_muscle_groups,
        e.instructions as exercise_instructions,
        e.common_mistakes,
        e.form_tips,
        e.equipment_alternatives,
        e.media_type,
        e.media_source
      FROM scheduled_exercises se
      INNER JOIN exercises e ON se.exercise_id = e.id
      WHERE se.schedule_id = ? AND se.day_of_week = ?
      ORDER BY se.sort_order ASC
    ''', [scheduleId, dayOfWeek]);

    return List.generate(results.length, (i) {
      final row = results[i];
      
      final exerciseMap = {
        'id': row['exercise_id'], // from se.exercise_id
        'name': row['exercise_name'],
        'description': row['exercise_description'],
        'media_path': row['media_path'],
        'is_custom': row['is_custom'],
        'body_part': row['body_part'],
        'equipment_type': row['equipment_type'],
        'difficulty_level': row['difficulty_level'],
        'target_muscle_groups': row['target_muscle_groups'],
        'instructions': row['exercise_instructions'],
        'common_mistakes': row['common_mistakes'],
        'form_tips': row['form_tips'],
        'equipment_alternatives': row['equipment_alternatives'],
        'media_type': row['media_type'],
        'media_source': row['media_source'],
      };
      
      final exercise = ExerciseModel.fromMap(exerciseMap);

      return ScheduledExerciseModel.fromMap(row, exercise: exercise);
    });
  }

  @override
  Future<void> addScheduledExercise(ScheduledExercise exercise) async {
    final db = await _databaseService.database;
    final model = ScheduledExerciseModel(
      id: exercise.id,
      scheduleId: exercise.scheduleId,
      dayOfWeek: exercise.dayOfWeek,
      exerciseId: exercise.exerciseId,
      sortOrder: exercise.sortOrder,
      targetSets: exercise.targetSets,
      targetReps: exercise.targetReps,
      restSeconds: exercise.restSeconds,
      targetTimeSeconds: exercise.targetTimeSeconds,
      notes: exercise.notes,
    );
    
    await db.insert(
      'scheduled_exercises',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateScheduledExercise(ScheduledExercise exercise) async {
    final db = await _databaseService.database;
    final model = ScheduledExerciseModel(
      id: exercise.id,
      scheduleId: exercise.scheduleId,
      dayOfWeek: exercise.dayOfWeek,
      exerciseId: exercise.exerciseId,
      sortOrder: exercise.sortOrder,
      targetSets: exercise.targetSets,
      targetReps: exercise.targetReps,
      restSeconds: exercise.restSeconds,
      targetTimeSeconds: exercise.targetTimeSeconds,
      notes: exercise.notes,
    );
    
    await db.update(
      'scheduled_exercises',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [exercise.id],
    );
  }

  @override
  Future<void> deleteScheduledExercise(String id) async {
    final db = await _databaseService.database;
    await db.delete(
      'scheduled_exercises',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> updateScheduledExercisesOrder(List<ScheduledExercise> exercises) async {
    final db = await _databaseService.database;
    await db.transaction((txn) async {
      for (var exercise in exercises) {
        await txn.update(
          'scheduled_exercises',
          {'sort_order': exercise.sortOrder},
          where: 'id = ?',
          whereArgs: [exercise.id],
        );
      }
    });
  }
}
