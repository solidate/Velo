import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/entities/exercise.dart';
import '../../../../domain/repositories/exercise_repository.dart';
import '../../../../data/repositories/exercise_repository_impl.dart';
import '../../../../core/services/database_service.dart';

part 'exercise_provider.g.dart';

@riverpod
DatabaseService databaseService(DatabaseServiceRef ref) {
  return DatabaseService();
}

@riverpod
ExerciseRepository exerciseRepository(ExerciseRepositoryRef ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return ExerciseRepositoryImpl(dbService);
}

@riverpod
class ExerciseList extends _$ExerciseList {
  @override
  FutureOr<List<Exercise>> build() async {
    return _fetchExercises();
  }

  Future<List<Exercise>> _fetchExercises() async {
    final repository = ref.read(exerciseRepositoryProvider);
    return repository.getAllExercises();
  }

  Future<void> addExercise(Exercise exercise) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(exerciseRepositoryProvider);
      await repository.insertExercise(exercise);
      return _fetchExercises();
    });
  }

  Future<void> deleteExercise(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(exerciseRepositoryProvider);
      await repository.deleteExercise(id);
      return _fetchExercises();
    });
  }
}
