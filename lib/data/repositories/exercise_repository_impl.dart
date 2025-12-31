import 'package:sqflite/sqflite.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../../core/services/database_service.dart';
import '../models/exercise_model.dart';

class ExerciseRepositoryImpl implements ExerciseRepository {
  final DatabaseService _databaseService;

  ExerciseRepositoryImpl(this._databaseService);

  @override
  Future<List<Exercise>> getAllExercises() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('exercises');

    return List.generate(maps.length, (i) {
      return ExerciseModel.fromMap(maps[i]);
    });
  }

  @override
  Future<Exercise?> getExerciseById(String id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'exercises',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ExerciseModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> insertExercise(Exercise exercise) async {
    final db = await _databaseService.database;
    final model = ExerciseModel(
      id: exercise.id,
      name: exercise.name,
      description: exercise.description,
      mediaPath: exercise.mediaPath,
      isCustom: exercise.isCustom,
      bodyPart: exercise.bodyPart,
      equipmentType: exercise.equipmentType,
      difficulty: exercise.difficulty,
      targetMuscleGroups: exercise.targetMuscleGroups,
      instructions: exercise.instructions,
      commonMistakes: exercise.commonMistakes,
      formTips: exercise.formTips,
      equipmentAlternatives: exercise.equipmentAlternatives,
      mediaType: exercise.mediaType,
      mediaSource: exercise.mediaSource,
    );

    await db.insert(
      'exercises',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateExercise(Exercise exercise) async {
    final db = await _databaseService.database;
    final model = ExerciseModel(
      id: exercise.id,
      name: exercise.name,
      description: exercise.description,
      mediaPath: exercise.mediaPath,
      isCustom: exercise.isCustom,
      bodyPart: exercise.bodyPart,
      equipmentType: exercise.equipmentType,
      difficulty: exercise.difficulty,
      targetMuscleGroups: exercise.targetMuscleGroups,
      instructions: exercise.instructions,
      commonMistakes: exercise.commonMistakes,
      formTips: exercise.formTips,
      equipmentAlternatives: exercise.equipmentAlternatives,
      mediaType: exercise.mediaType,
      mediaSource: exercise.mediaSource,
    );

    await db.update(
      'exercises',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [exercise.id],
    );
  }

  @override
  Future<void> deleteExercise(String id) async {
    final db = await _databaseService.database;
    await db.delete(
      'exercises',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
