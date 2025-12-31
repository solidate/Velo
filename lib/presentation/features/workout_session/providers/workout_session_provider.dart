import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/entities/scheduled_exercise.dart';
import 'workout_session_state.dart';

part 'workout_session_provider.g.dart';

@riverpod
class WorkoutSession extends _$WorkoutSession {
  Timer? _restTimer;
  Timer? _sessionTimer;

  @override
  WorkoutSessionState build(List<ScheduledExercise> exercises) {
    ref.onDispose(() {
      _restTimer?.cancel();
      _sessionTimer?.cancel();
    });
    
    // Start session timer immediately or on start? 
    // Requirement says "Active Workout Session".
    // I'll start monitoring but only increment if status is inProgress.
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.status == WorkoutStatus.inProgress) {
        int newSetDuration = state.currentSetDurationSeconds;
        if (!state.isResting) {
          newSetDuration++;
        }
        state = state.copyWith(
          totalDurationSeconds: state.totalDurationSeconds + 1,
          currentSetDurationSeconds: newSetDuration,
        );
      }
    });

    return WorkoutSessionState(exercises: exercises);
  }

  void startWorkout() {
    state = state.copyWith(status: WorkoutStatus.inProgress);
  }

  void pauseWorkout() {
    state = state.copyWith(status: WorkoutStatus.paused);
  }

  void resumeWorkout() {
    state = state.copyWith(status: WorkoutStatus.inProgress);
  }

  void endWorkout() {
    _restTimer?.cancel();
    _sessionTimer?.cancel();
    state = state.copyWith(status: WorkoutStatus.completed);
  }

  void completeSet() {
    if (state.status != WorkoutStatus.inProgress) return;

    if (state.isLastExercise && state.isLastSet) {
      endWorkout();
      return;
    }

    // Start rest
    state = state.copyWith(
      isResting: true,
      restTimeRemaining: state.currentExercise?.restSeconds ?? 60,
    );
    _startRestTimer();
  }

  void skipRest() {
    _restTimer?.cancel();
    _advanceToNextSetOrExercise();
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.restTimeRemaining > 0) {
        state = state.copyWith(restTimeRemaining: state.restTimeRemaining - 1);
      } else {
        timer.cancel();
        _advanceToNextSetOrExercise();
      }
    });
  }

  void _advanceToNextSetOrExercise() {
    final currentEx = state.currentExercise;
    if (currentEx == null) return;

    if (state.currentSet < currentEx.targetSets) {
      // Next Set
      state = state.copyWith(
        isResting: false,
        currentSet: state.currentSet + 1,
        currentSetDurationSeconds: 0,
      );
    } else {
      // Next Exercise
      if (state.isLastExercise) {
        endWorkout();
      } else {
        state = state.copyWith(
          isResting: false,
          currentExerciseIndex: state.currentExerciseIndex + 1,
          currentSet: 1,
          currentSetDurationSeconds: 0,
        );
      }
    }
  }
}
