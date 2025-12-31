import 'package:equatable/equatable.dart';
import '../../../../domain/entities/scheduled_exercise.dart';

enum WorkoutStatus { initial, inProgress, paused, completed }

class WorkoutSessionState extends Equatable {
  final List<ScheduledExercise> exercises;
  final int currentExerciseIndex;
  final int currentSet; // 1-based
  final bool isResting;
  final int restTimeRemaining;
  final WorkoutStatus status;
  final int totalDurationSeconds; // For session timer
  final int currentSetDurationSeconds; // Elapsed time for current set

  const WorkoutSessionState({
    required this.exercises,
    this.currentExerciseIndex = 0,
    this.currentSet = 1,
    this.isResting = false,
    this.restTimeRemaining = 0,
    this.status = WorkoutStatus.initial,
    this.totalDurationSeconds = 0,
    this.currentSetDurationSeconds = 0,
  });

  ScheduledExercise? get currentExercise => 
      exercises.isNotEmpty && currentExerciseIndex < exercises.length
          ? exercises[currentExerciseIndex]
          : null;

  bool get isLastExercise => currentExerciseIndex == exercises.length - 1;
  bool get isLastSet => currentExercise != null && currentSet == currentExercise!.targetSets;

  WorkoutSessionState copyWith({
    List<ScheduledExercise>? exercises,
    int? currentExerciseIndex,
    int? currentSet,
    bool? isResting,
    int? restTimeRemaining,
    WorkoutStatus? status,
    int? totalDurationSeconds,
    int? currentSetDurationSeconds,
  }) {
    return WorkoutSessionState(
      exercises: exercises ?? this.exercises,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      currentSet: currentSet ?? this.currentSet,
      isResting: isResting ?? this.isResting,
      restTimeRemaining: restTimeRemaining ?? this.restTimeRemaining,
      status: status ?? this.status,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      currentSetDurationSeconds: currentSetDurationSeconds ?? this.currentSetDurationSeconds,
    );
  }

  @override
  List<Object?> get props => [
        exercises,
        currentExerciseIndex,
        currentSet,
        isResting,
        restTimeRemaining,
        status,
        totalDurationSeconds,
        currentSetDurationSeconds,
      ];
}
