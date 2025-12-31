import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/entities/schedule.dart';
import '../../../../domain/entities/scheduled_exercise.dart';
import '../../../../domain/repositories/schedule_repository.dart';
import '../../../../data/repositories/schedule_repository_impl.dart';
import '../../../../core/services/database_service.dart';
import '../../exercises/providers/exercise_provider.dart';

part 'schedule_provider.g.dart';

@riverpod
ScheduleRepository scheduleRepository(ScheduleRepositoryRef ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return ScheduleRepositoryImpl(dbService);
}

@riverpod
class ActiveSchedule extends _$ActiveSchedule {
  @override
  FutureOr<Schedule?> build() async {
    final repository = ref.read(scheduleRepositoryProvider);
    return repository.getActiveSchedule();
  }

  Future<void> setActiveSchedule(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(scheduleRepositoryProvider);
      await repository.setActiveSchedule(id);
      return repository.getActiveSchedule();
    });
  }
  
  Future<void> createSchedule(Schedule schedule) async {
    final repository = ref.read(scheduleRepositoryProvider);
    await repository.createSchedule(schedule);
    // If it's the first one, activate it
    final schedules = await repository.getSchedules();
    if (schedules.length == 1) {
       await setActiveSchedule(schedule.id);
    } else if (schedule.isActive) {
       await setActiveSchedule(schedule.id);
    }
    // Refresh self
    ref.invalidateSelf();
  }
}

@riverpod
class AllSchedules extends _$AllSchedules {
  @override
  FutureOr<List<Schedule>> build() async {
    final repository = ref.read(scheduleRepositoryProvider);
    return repository.getSchedules();
  }
}

@riverpod
class DailyWorkout extends _$DailyWorkout {
  @override
  FutureOr<List<ScheduledExercise>> build(int dayOfWeek) async {
    final activeScheduleAsync = ref.watch(activeScheduleProvider);
    
    // If no active schedule, return empty list
    if (activeScheduleAsync.value == null) return [];
    
    final activeSchedule = activeScheduleAsync.value!;
    final repository = ref.read(scheduleRepositoryProvider);
    return repository.getScheduledExercises(activeSchedule.id, dayOfWeek);
  }

  Future<void> addExercise(ScheduledExercise exercise) async {
    final repository = ref.read(scheduleRepositoryProvider);
    await repository.addScheduledExercise(exercise);
    ref.invalidateSelf();
  }

  Future<void> deleteExercise(String id) async {
    final repository = ref.read(scheduleRepositoryProvider);
    await repository.deleteScheduledExercise(id);
    ref.invalidateSelf();
  }

  Future<void> reorderExercises(int oldIndex, int newIndex) async {
    final currentList = state.value;
    if (currentList == null) return;

    final items = List<ScheduledExercise>.from(currentList);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    final updatedItems = <ScheduledExercise>[];
    for (int i = 0; i < items.length; i++) {
        final original = items[i];
        updatedItems.add(ScheduledExercise(
            id: original.id,
            scheduleId: original.scheduleId,
            dayOfWeek: original.dayOfWeek,
            exerciseId: original.exerciseId,
            exercise: original.exercise,
            sortOrder: i,
            targetSets: original.targetSets,
            targetReps: original.targetReps,
            restSeconds: original.restSeconds,
            targetTimeSeconds: original.targetTimeSeconds,
            notes: original.notes,
        ));
    }

    state = AsyncValue.data(updatedItems);

    final repository = ref.read(scheduleRepositoryProvider);
    await repository.updateScheduledExercisesOrder(updatedItems);
  }
}
