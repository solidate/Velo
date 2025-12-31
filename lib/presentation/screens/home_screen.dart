import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/schedule/providers/schedule_provider.dart';
import '../features/workout_session/screens/workout_session_screen.dart';
import '../../core/providers/theme_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeScheduleAsync = ref.watch(activeScheduleProvider);
    final today = DateTime.now().weekday; // 1 = Monday, 7 = Sunday
    final dailyWorkoutAsync = ref.watch(dailyWorkoutProvider(today));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Workout'),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark 
                  ? Icons.light_mode 
                  : Icons.dark_mode
            ),
            onPressed: () {
              ref.read(themeModeNotifierProvider.notifier).toggle();
            },
          ),
        ],
      ),
      body: dailyWorkoutAsync.when(
        data: (exercises) {
          if (exercises.isEmpty) {
             // Check if there is an active schedule
             if (activeScheduleAsync.value == null) {
               return Center(
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Text('No active schedule.', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                     const SizedBox(height: 16),
                     FilledButton.tonal(
                       onPressed: () {
                         // Navigate to Schedule Tab via BottomNav (by changing index)
                         // But for now, we can just say "Go to Schedule Tab"
                       },
                       child: const Text('Create a Schedule in Schedule Tab'),
                     ),
                   ],
                 ),
               );
             }
             return Center(child: Text('Rest Day! No exercises scheduled.', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 18)));
          }
          
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: exercises.length,
            separatorBuilder: (c, i) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = exercises[index];
              final exercise = item.exercise;
              return Card(
                elevation: 0,
                color: colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
                    child: Text('${index + 1}')
                  ),
                  title: Text(
                    exercise?.name ?? 'Unknown Exercise',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${item.targetSets} sets x ${item.targetReps}${item.targetTimeSeconds != null ? ' • ${item.targetTimeSeconds}s' : ''}',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.play_circle, color: colorScheme.primary, size: 32),
                    onPressed: () {
                      // TODO: Start specific exercise or workout
                    },
                  ),
                ),
              );
            },
          );
        },
        error: (err, st) => Center(child: Text('Error: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
           dailyWorkoutAsync.whenData((exercises) {
             if (exercises.isNotEmpty) {
               Navigator.push(
                 context,
                 MaterialPageRoute(
                   builder: (context) => WorkoutSessionScreen(exercises: exercises),
                 ),
               );
             } else {
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('No exercises to start.')),
               );
             }
           });
        },
        label: const Text('Start Workout'),
        icon: const Icon(Icons.play_arrow),
      ),
    );
  }
}
