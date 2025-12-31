import '../../domain/entities/scheduled_exercise.dart';
import '../../domain/entities/exercise.dart';

class ScheduledExerciseModel extends ScheduledExercise {
  const ScheduledExerciseModel({
    required super.id,
    required super.scheduleId,
    required super.dayOfWeek,
    required super.exerciseId,
    super.exercise,
    required super.sortOrder,
    required super.targetSets,
    required super.targetReps,
    required super.restSeconds,
    super.targetTimeSeconds,
    super.notes,
  });

  factory ScheduledExerciseModel.fromMap(Map<String, dynamic> map, {Exercise? exercise}) {
    return ScheduledExerciseModel(
      id: map['id'],
      scheduleId: map['schedule_id'],
      dayOfWeek: map['day_of_week'],
      exerciseId: map['exercise_id'],
      exercise: exercise,
      sortOrder: map['sort_order'],
      targetSets: map['target_sets'],
      targetReps: map['target_reps'],
      restSeconds: map['rest_seconds'],
      targetTimeSeconds: map['target_time_seconds'],
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'schedule_id': scheduleId,
      'day_of_week': dayOfWeek,
      'exercise_id': exerciseId,
      'sort_order': sortOrder,
      'target_sets': targetSets,
      'target_reps': targetReps,
      'rest_seconds': restSeconds,
      'target_time_seconds': targetTimeSeconds,
      'notes': notes,
    };
  }
}
