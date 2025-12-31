import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../domain/entities/scheduled_exercise.dart';
import '../../../../domain/entities/exercise.dart';
import '../providers/workout_session_provider.dart';
import '../providers/workout_session_state.dart';

class WorkoutSessionScreen extends ConsumerWidget {
  final List<ScheduledExercise> exercises;

  const WorkoutSessionScreen({super.key, required this.exercises});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(workoutSessionProvider(exercises));
    final notifier = ref.read(workoutSessionProvider(exercises).notifier);
    final colorScheme = Theme.of(context).colorScheme;

    // Initial Start
    if (sessionState.status == WorkoutStatus.initial) {
       Future.microtask(() => notifier.startWorkout());
    }

    if (sessionState.status == WorkoutStatus.completed) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Workout Completed!', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Finish'),
              ),
            ],
          ),
        ),
      );
    }

    final currentExercise = sessionState.currentExercise;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Session'),
        actions: [
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: () => notifier.endWorkout(),
          ),
        ],
      ),
      body: currentExercise == null
          ? const Center(child: Text('No exercise'))
          : Column(
              children: [
                // Media / Visual (Always visible to avoid layout jump)
                Container(
                  height: 250,
                  color: Colors.black, // Keep black for media content usually
                  child: Center(
                    child: _MediaDisplay(
                      mediaPath: currentExercise.exercise?.mediaPath,
                      mediaType: currentExercise.exercise?.mediaType,
                      mediaSource: currentExercise.exercise?.mediaSource,
                    ),
                  ),
                ),
                
                // Info & Timer
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Exercise Info
                        Column(
                          children: [
                            Text(
                              currentExercise.exercise?.name ?? 'Unknown',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            if (sessionState.isResting)
                              Text('Resting...', style: TextStyle(fontSize: 18, color: colorScheme.tertiary))
                            else
                              Text(
                                'Set ${sessionState.currentSet} of ${currentExercise.targetSets}',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),

                        // Timer (Swaps inplace)
                        if (sessionState.isResting)
                          CircularTimer(
                            value: sessionState.restTimeRemaining,
                            maxValue: currentExercise.restSeconds > 0 ? currentExercise.restSeconds : 60,
                            label: 'REST',
                            color: colorScheme.tertiary, // Use theme tertiary (often warm color) or keep Orange
                            // Let's stick to Orange for distinctiveness, or custom color
                            // color: Colors.orange, 
                            // Better for Material You:
                            customColor: Colors.orange,
                            isCountDown: true,
                          )
                        else
                          CircularTimer(
                            value: (currentExercise.targetTimeSeconds != null && currentExercise.targetTimeSeconds! > 0)
                                ? (currentExercise.targetTimeSeconds! - sessionState.currentSetDurationSeconds).clamp(0, 9999)
                                : sessionState.currentSetDurationSeconds,
                            maxValue: currentExercise.targetTimeSeconds,
                            label: 'ACTIVE',
                            color: colorScheme.primary, // Use primary color
                            // customColor: Colors.green, // Or Green
                            customColor: Colors.green,
                            isCountDown: currentExercise.targetTimeSeconds != null && currentExercise.targetTimeSeconds! > 0,
                          ),

                        // Additional Info (Target / Instructions)
                        if (!sessionState.isResting)
                          Text(
                            'Target: ${currentExercise.targetReps} reps${currentExercise.targetTimeSeconds != null ? ' • ${currentExercise.targetTimeSeconds}s' : ''}',
                            style: TextStyle(fontSize: 18, color: colorScheme.onSurfaceVariant),
                          )
                        else
                          const SizedBox(height: 24), // Spacer for consistency
                      ],
                    ),
                  ),
                ),
                
                // Bottom Button (Swaps inplace)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: sessionState.isResting
                        ? FilledButton.tonal(
                            onPressed: notifier.skipRest,
                            style: FilledButton.styleFrom(
                              backgroundColor: colorScheme.tertiaryContainer,
                              foregroundColor: colorScheme.onTertiaryContainer,
                            ),
                            child: const Text('Skip Rest', style: TextStyle(fontSize: 20)),
                          )
                        : FilledButton(
                            onPressed: notifier.completeSet,
                            child: Text(
                              sessionState.isLastSet && sessionState.isLastExercise 
                                  ? 'Finish Workout' 
                                  : 'Complete Set',
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class CircularTimer extends StatelessWidget {
  final int value;
  final int? maxValue;
  final String label;
  final Color? color; // From theme
  final Color? customColor; // Explicit override
  final bool isCountDown;

  const CircularTimer({
    super.key,
    required this.value,
    this.maxValue,
    required this.label,
    this.color,
    this.customColor,
    this.isCountDown = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = customColor ?? color ?? Theme.of(context).colorScheme.primary;
    final trackColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    final textColor = Theme.of(context).colorScheme.onSurface;

    double progress = 1.0;
    if (maxValue != null && maxValue! > 0) {
      if (isCountDown) {
        progress = value / maxValue!;
      } else {
        progress = 1.0;
      }
    }

    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 15,
            valueColor: AlwaysStoppedAnimation<Color>(trackColor),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: progress),
            duration: const Duration(seconds: 1),
            builder: (context, value, child) {
              return CircularProgressIndicator(
                value: value,
                strokeWidth: 15,
                valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
                backgroundColor: Colors.transparent,
              );
            },
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: effectiveColor),
                ),
                Text(
                  isCountDown ? '$value' : _formatTime(value),
                  style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: textColor),
                ),
                if (isCountDown && maxValue != null)
                   Text('of ${maxValue}s', style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.outline)),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class _MediaDisplay extends StatelessWidget {
  final String? mediaPath;
  final MediaType? mediaType;
  final MediaSource? mediaSource;

  const _MediaDisplay({this.mediaPath, this.mediaType, this.mediaSource});

  @override
  Widget build(BuildContext context) {
    if (mediaPath == null) {
      return const Icon(Icons.fitness_center, size: 64, color: Colors.white);
    }
    
    // Logic for displaying media
    if (mediaSource == MediaSource.online || mediaPath!.startsWith('http')) {
        if (mediaType == MediaType.video) {
           return const Icon(Icons.play_circle_outline, size: 64, color: Colors.white);
        } else {
           return CachedNetworkImage(
             imageUrl: mediaPath!,
             fit: BoxFit.contain,
             errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 64, color: Colors.red),
             placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
           );
        }
    }
    
    if (mediaSource == MediaSource.local) {
        if (mediaType == MediaType.video) {
           return const Icon(Icons.play_circle_filled, size: 64, color: Colors.white);
        }
        return Image.file(File(mediaPath!), fit: BoxFit.contain);
    }

    return const Icon(Icons.image, size: 64, color: Colors.white); 
  }
}
