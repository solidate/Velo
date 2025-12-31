import 'package:equatable/equatable.dart';
import 'exercise.dart';

class ScheduledExercise extends Equatable {
  final String id;
  final String scheduleId;
  final int dayOfWeek; // 1-7
  final String exerciseId;
  final Exercise? exercise; // Loaded exercise details
  final int sortOrder;
  final int targetSets;
  final String targetReps;
  final int restSeconds;
  final int? targetTimeSeconds; // Optional time for set
  final String? notes;

  const ScheduledExercise({
    required this.id,
    required this.scheduleId,
    required this.dayOfWeek,
    required this.exerciseId,
    this.exercise,
    required this.sortOrder,
    required this.targetSets,
    required this.targetReps,
    required this.restSeconds,
    this.targetTimeSeconds,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        scheduleId,
        dayOfWeek,
        exerciseId,
        exercise,
        sortOrder,
        targetSets,
        targetReps,
        restSeconds,
        targetTimeSeconds,
        notes,
      ];
}
