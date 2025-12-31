import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../domain/entities/scheduled_exercise.dart';
import '../../../../domain/entities/exercise.dart';
import '../providers/schedule_provider.dart';
import '../../exercises/screens/exercise_list_screen.dart';

class DayWorkoutScreen extends ConsumerWidget {
  final int dayOfWeek;

  const DayWorkoutScreen({super.key, required this.dayOfWeek});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyWorkoutAsync = ref.watch(dailyWorkoutProvider(dayOfWeek));
    final activeScheduleAsync = ref.watch(activeScheduleProvider);
    final activeSchedule = activeScheduleAsync.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getDayName(dayOfWeek)),
      ),
      body: dailyWorkoutAsync.when(
        data: (exercises) {
          if (exercises.isEmpty) {
            return const Center(child: Text('No exercises scheduled for this day.'));
          }
          return ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final item = exercises[index];
              return ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(item.exercise?.name ?? 'Unknown'),
                subtitle: Text('${item.targetSets} sets x ${item.targetReps} • ${item.restSeconds}s rest'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    ref.read(dailyWorkoutProvider(dayOfWeek).notifier).deleteExercise(item.id);
                  },
                ),
                onTap: () {
                   // TODO: Edit details (sets/reps)
                },
              );
            },
          );
        },
        error: (err, st) => Center(child: Text('Error: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           if (activeSchedule != null) {
              _showAddExerciseSheet(context, ref, activeSchedule.id);
           } else {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Please create a schedule first.')),
             );
           }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getDayName(int index) {
    switch (index) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }

  void _showAddExerciseSheet(BuildContext context, WidgetRef ref, String scheduleId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseListScreen(
          onExerciseSelected: (exercise) {
             _showConfigureExerciseDialog(context, ref, scheduleId, exercise);
          },
        ),
      ),
    );
  }

  void _showConfigureExerciseDialog(BuildContext context, WidgetRef ref, String scheduleId, Exercise exercise) {
    final setsController = TextEditingController(text: '3');
    final repsController = TextEditingController(text: '10');
    final restController = TextEditingController(text: '60');
    final timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Configure ${exercise.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: setsController,
              decoration: const InputDecoration(labelText: 'Sets'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: repsController,
              decoration: const InputDecoration(labelText: 'Reps (e.g. 10 or 8-12)'),
            ),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: 'Target Time (seconds, optional)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: restController,
              decoration: const InputDecoration(labelText: 'Rest (seconds)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
               final sets = int.tryParse(setsController.text) ?? 3;
               final reps = repsController.text;
               final rest = int.tryParse(restController.text) ?? 60;
               final time = int.tryParse(timeController.text);

               final newScheduledExercise = ScheduledExercise(
                 id: const Uuid().v4(),
                 scheduleId: scheduleId,
                 dayOfWeek: dayOfWeek,
                 exerciseId: exercise.id,
                 sortOrder: 0, 
                 targetSets: sets, 
                 targetReps: reps, 
                 restSeconds: rest, 
                 targetTimeSeconds: time,
                 notes: '',
               );
               
               ref.read(dailyWorkoutProvider(dayOfWeek).notifier).addExercise(newScheduledExercise);
               Navigator.pop(context); // Close Dialog
               Navigator.pop(context); // Close ExerciseListScreen
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
