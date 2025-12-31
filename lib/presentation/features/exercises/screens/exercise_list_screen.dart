import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/exercise_constants.dart';
import '../../../../domain/entities/exercise.dart';
import '../providers/exercise_provider.dart';
import 'exercise_form_screen.dart';

import '../../../../domain/entities/exercise.dart';

class ExerciseListScreen extends ConsumerStatefulWidget {
  final Function(Exercise)? onExerciseSelected;
  
  const ExerciseListScreen({super.key, this.onExerciseSelected});

  @override
  ConsumerState<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends ConsumerState<ExerciseListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Filters
  String? _selectedBodyPart;
  ExerciseDifficulty? _selectedDifficulty;
  bool? _isCustomFilter; // null = all, true = custom, false = pre-loaded

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exerciseListAsync = ref.watch(exerciseListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercises'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFilterSheet,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
        ),
      ),
      body: exerciseListAsync.when(
        data: (exercises) {
          // Filter Logic
          final filteredExercises = exercises.where((exercise) {
            final matchesSearch = exercise.name.toLowerCase().contains(_searchQuery);
            final matchesBodyPart = _selectedBodyPart == null || exercise.bodyPart == _selectedBodyPart;
            final matchesDifficulty = _selectedDifficulty == null || exercise.difficulty == _selectedDifficulty;
            final matchesCustom = _isCustomFilter == null || exercise.isCustom == _isCustomFilter;

            return matchesSearch && matchesBodyPart && matchesDifficulty && matchesCustom;
          }).toList();

          if (filteredExercises.isEmpty) {
            return const Center(child: Text('No exercises found.'));
          }

          return ListView.builder(
            itemCount: filteredExercises.length,
            itemBuilder: (context, index) {
              final exercise = filteredExercises[index];
              return Dismissible(
                key: Key(exercise.id),
                direction: exercise.isCustom ? DismissDirection.endToStart : DismissDirection.none,
                background: Container(
                  color: Theme.of(context).colorScheme.error,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Exercise'),
                      content: const Text('Are you sure you want to delete this exercise?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) {
                  ref.read(exerciseListProvider.notifier).deleteExercise(exercise.id);
                },
                child: Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                      child: Text(exercise.name.substring(0, 1).toUpperCase()),
                    ),
                    title: Text(
                      exercise.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      '${exercise.bodyPart} • ${exercise.difficulty.name.toUpperCase()}',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    onTap: () {
                       if (widget.onExerciseSelected != null) {
                         widget.onExerciseSelected!(exercise);
                         return;
                       }

                       if (exercise.isCustom) {
                         Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExerciseFormScreen(exercise: exercise),
                          ),
                        );
                       }
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (exercise.mediaPath != null && 
                           (exercise.mediaSource == MediaSource.local || exercise.mediaSource == MediaSource.asset))
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Icon(Icons.offline_pin, size: 16, color: Theme.of(context).colorScheme.primary),
                          ),
                        if (exercise.isCustom)
                          IconButton(
                            icon: Icon(Icons.edit_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ExerciseFormScreen(exercise: exercise),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        error: (error, stack) => Center(child: Text('Error: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ExerciseFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Filter Exercises', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // Body Part Filter
                  const Text('Body Part', style: TextStyle(fontWeight: FontWeight.bold)),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: _selectedBodyPart == null,
                          onSelected: (selected) {
                            setModalState(() => _selectedBodyPart = null);
                            setState(() {});
                          },
                        ),
                        ...ExerciseConstants.bodyParts.map((part) => Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: FilterChip(
                            label: Text(part),
                            selected: _selectedBodyPart == part,
                            onSelected: (selected) {
                              setModalState(() => _selectedBodyPart = selected ? part : null);
                              setState(() {});
                            },
                          ),
                        )).toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Difficulty Filter
                  const Text('Difficulty', style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _selectedDifficulty == null,
                        onSelected: (selected) {
                          setModalState(() => _selectedDifficulty = null);
                          setState(() {});
                        },
                      ),
                      ...ExerciseDifficulty.values.map((diff) => Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: FilterChip(
                          label: Text(diff.name.toUpperCase()),
                          selected: _selectedDifficulty == diff,
                          onSelected: (selected) {
                            setModalState(() => _selectedDifficulty = selected ? diff : null);
                            setState(() {});
                          },
                        ),
                      )).toList(),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Type Filter
                  const Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _isCustomFilter == null,
                        onSelected: (selected) {
                          setModalState(() => _isCustomFilter = null);
                          setState(() {});
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Custom'),
                        selected: _isCustomFilter == true,
                        onSelected: (selected) {
                          setModalState(() => _isCustomFilter = selected ? true : null);
                          setState(() {});
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Pre-loaded'),
                        selected: _isCustomFilter == false,
                        onSelected: (selected) {
                          setModalState(() => _isCustomFilter = selected ? false : null);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }
}
