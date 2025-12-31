import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../domain/entities/schedule.dart';
import '../../../../domain/entities/exercise.dart';
import '../../../../domain/entities/scheduled_exercise.dart';
import '../providers/schedule_provider.dart';
import '../../exercises/screens/exercise_list_screen.dart';
import '../../workout_session/screens/workout_session_screen.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  int _selectedDay = DateTime.now().weekday; // Default to today

  @override
  Widget build(BuildContext context) {
    final activeScheduleAsync = ref.watch(activeScheduleProvider);
    final dailyWorkoutAsync = ref.watch(dailyWorkoutProvider(_selectedDay));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Schedule'),
      ),
      body: activeScheduleAsync.when(
        data: (schedule) {
          if (schedule == null) {
            return Center(
              child: FilledButton(
                onPressed: () => _createDefaultSchedule(),
                child: const Text('Create New Schedule'),
              ),
            );
          }
          
          return Column(
            children: [
              _buildWeekSelector(colorScheme),
              const SizedBox(height: 16),
              if (dailyWorkoutAsync.hasValue && dailyWorkoutAsync.value!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WorkoutSessionScreen(exercises: dailyWorkoutAsync.value!),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: Text('Start ${_getDayName(_selectedDay)}\'s Workout'),
                    ),
                  ),
                ),
              Expanded(
                child: dailyWorkoutAsync.when(
                  data: (exercises) {
                    if (exercises.isEmpty) {
                      return Center(
                        child: Text(
                          'No exercises for ${_getDayName(_selectedDay)}',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      );
                    }
                    return ReorderableListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: exercises.length,
                      onReorder: (oldIndex, newIndex) {
                        ref.read(dailyWorkoutProvider(_selectedDay).notifier).reorderExercises(oldIndex, newIndex);
                      },
                      itemBuilder: (context, index) {
                        final item = exercises[index];
                        return _buildExerciseCard(item, colorScheme);
                      },
                    );
                  },
                  error: (e, s) => Center(child: Text('Error: $e')),
                  loading: () => const Center(child: CircularProgressIndicator()),
                ),
              ),
            ],
          );
        },
        error: (err, st) => Center(child: Text('Error: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
           final schedule = activeScheduleAsync.value;
           if (schedule != null) {
             _showAddExerciseSheet(schedule.id);
           }
        },
        label: const Text('Add Exercise'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWeekSelector(ColorScheme colorScheme) {
    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (context, index) {
          final dayIndex = index + 1;
          final isSelected = dayIndex == _selectedDay;
          final dayName = _getDayShortName(dayIndex);
          
          return GestureDetector(
            onTap: () => setState(() => _selectedDay = dayIndex),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              width: 50,
              decoration: BoxDecoration(
                color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  dayName,
                  style: TextStyle(
                    color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExerciseCard(ScheduledExercise item, ColorScheme colorScheme) {
    return Container(
      key: ValueKey(item.id),
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        color: colorScheme.surfaceContainerLow, // Material 3 surface
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Icon(Icons.fitness_center, color: colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.exercise?.name ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildTag('${item.targetSets} Sets', colorScheme),
                        _buildTag('${item.targetReps} Reps', colorScheme),
                        if (item.targetTimeSeconds != null)
                          _buildTag('${item.targetTimeSeconds}s', colorScheme),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: colorScheme.error),
                onPressed: () {
                  ref.read(dailyWorkoutProvider(_selectedDay).notifier).deleteExercise(item.id);
                },
              ),
              Icon(Icons.drag_handle, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Text(text, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
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

  String _getDayShortName(int index) {
    return _getDayName(index).substring(0, 3);
  }

  void _createDefaultSchedule() {
    final newSchedule = Schedule(
      id: const Uuid().v4(),
      name: 'My Weekly Plan',
      isActive: true,
      description: 'Default schedule',
    );
    ref.read(activeScheduleProvider.notifier).createSchedule(newSchedule);
  }

  void _showAddExerciseSheet(String scheduleId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseListScreen(
          onExerciseSelected: (exercise) {
             _showConfigureExerciseDialog(scheduleId, exercise);
          },
        ),
      ),
    );
  }

  void _showConfigureExerciseDialog(String scheduleId, Exercise exercise) {
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
              decoration: const InputDecoration(labelText: 'Sets', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: repsController,
              decoration: const InputDecoration(labelText: 'Reps', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: 'Time (s) Optional', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: restController,
              decoration: const InputDecoration(labelText: 'Rest (s)', border: OutlineInputBorder()),
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
                 dayOfWeek: _selectedDay,
                 exerciseId: exercise.id,
                 sortOrder: 0, 
                 targetSets: sets, 
                 targetReps: reps, 
                 restSeconds: rest, 
                 targetTimeSeconds: time,
                 notes: '',
               );
               
               ref.read(dailyWorkoutProvider(_selectedDay).notifier).addExercise(newScheduledExercise);
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
