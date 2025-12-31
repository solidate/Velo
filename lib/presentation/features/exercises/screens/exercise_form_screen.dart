import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/exercise_constants.dart';
import '../../../../domain/entities/exercise.dart';
import '../providers/exercise_provider.dart';

class ExerciseFormScreen extends ConsumerStatefulWidget {
  final Exercise? exercise;

  const ExerciseFormScreen({super.key, this.exercise});

  @override
  ConsumerState<ExerciseFormScreen> createState() => _ExerciseFormScreenState();
}

class _ExerciseFormScreenState extends ConsumerState<ExerciseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _mediaUrlController;

  String _selectedBodyPart = ExerciseConstants.bodyParts.first;
  String _selectedEquipment = ExerciseConstants.equipmentTypes.first;
  ExerciseDifficulty _selectedDifficulty = ExerciseDifficulty.beginner;

  List<String> _targetMuscles = [];
  final List<TextEditingController> _instructionControllers = [];

  String? _mediaPath;
  MediaType? _mediaType;
  MediaSource? _mediaSource;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.exercise?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.exercise?.description ?? '');
    _mediaUrlController = TextEditingController();

    if (widget.exercise != null) {
      if (ExerciseConstants.bodyParts.contains(widget.exercise!.bodyPart)) {
        _selectedBodyPart = widget.exercise!.bodyPart;
      }
      if (ExerciseConstants.equipmentTypes.contains(widget.exercise!.equipmentType)) {
        _selectedEquipment = widget.exercise!.equipmentType;
      }
      _selectedDifficulty = widget.exercise!.difficulty;
      _targetMuscles = List.from(widget.exercise!.targetMuscleGroups);
      
      for (var instruction in widget.exercise!.instructions) {
        _instructionControllers.add(TextEditingController(text: instruction));
      }
      if (_instructionControllers.isEmpty) {
        _instructionControllers.add(TextEditingController());
      }

      _mediaPath = widget.exercise!.mediaPath;
      _mediaType = widget.exercise!.mediaType;
      _mediaSource = widget.exercise!.mediaSource;

      if (_mediaSource == MediaSource.online && _mediaPath != null) {
        _mediaUrlController.text = _mediaPath!;
      }
    } else {
      _instructionControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _mediaUrlController.dispose();
    for (var controller in _instructionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickMedia(ImageSource source, {bool isVideo = false}) async {
    XFile? pickedFile;
    try {
      if (isVideo) {
        pickedFile = await _picker.pickVideo(source: source);
      } else {
        pickedFile = await _picker.pickImage(source: source);
      }

      if (pickedFile != null) {
        setState(() {
          _mediaPath = pickedFile!.path;
          _mediaType = isVideo ? MediaType.video : MediaType.image;
          _mediaSource = MediaSource.local;
          _mediaUrlController.clear(); // Clear URL if local picked
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking media: $e')),
      );
    }
  }

  void _addInstruction() {
    setState(() {
      _instructionControllers.add(TextEditingController());
    });
  }

  void _removeInstruction(int index) {
    setState(() {
      final controller = _instructionControllers.removeAt(index);
      controller.dispose();
    });
  }

  void _saveExercise() {
    if (_formKey.currentState!.validate()) {
      // Prioritize URL if local path not set or URL was just entered
      if (_mediaUrlController.text.isNotEmpty) {
        _mediaPath = _mediaUrlController.text.trim();
        _mediaSource = MediaSource.online;
        // Auto-detect type
        if (_mediaPath!.toLowerCase().endsWith('.mp4') || _mediaPath!.toLowerCase().endsWith('.mov')) {
           _mediaType = MediaType.video;
        } else {
           _mediaType = MediaType.image;
        }
      }

      final instructions = _instructionControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final newExercise = Exercise(
        id: widget.exercise?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        isCustom: true,
        bodyPart: _selectedBodyPart,
        equipmentType: _selectedEquipment,
        difficulty: _selectedDifficulty,
        targetMuscleGroups: _targetMuscles,
        instructions: instructions,
        mediaPath: _mediaPath,
        mediaType: _mediaType,
        mediaSource: _mediaSource,
        commonMistakes: widget.exercise?.commonMistakes ?? [],
        formTips: widget.exercise?.formTips ?? [],
        equipmentAlternatives: widget.exercise?.equipmentAlternatives ?? [],
      );

      if (widget.exercise == null) {
        ref.read(exerciseListProvider.notifier).addExercise(newExercise);
      } else {
         ref.read(exerciseListProvider.notifier).addExercise(newExercise); 
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise == null ? 'Create Exercise' : 'Edit Exercise'),
        actions: [
          IconButton(
            onPressed: _saveExercise,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Media Section
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.image),
                        title: const Text('Pick Image'),
                        onTap: () {
                          Navigator.pop(context);
                          _pickMedia(ImageSource.gallery, isVideo: false);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.videocam),
                        title: const Text('Pick Video'),
                        onTap: () {
                          Navigator.pop(context);
                          _pickMedia(ImageSource.gallery, isVideo: true);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.camera_alt),
                        title: const Text('Take Photo'),
                        onTap: () {
                          Navigator.pop(context);
                          _pickMedia(ImageSource.camera, isVideo: false);
                        },
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  image: _mediaPath != null && _mediaType == MediaType.image && _mediaSource == MediaSource.local
                      ? DecorationImage(
                          image: FileImage(File(_mediaPath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: _mediaPath != null && _mediaSource == MediaSource.online && _mediaType == MediaType.image
                    ? CachedNetworkImage(
                        imageUrl: _mediaPath!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 48, color: Colors.red),
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      )
                    : (_mediaPath == null || _mediaType == MediaType.video)
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_mediaType == MediaType.video)
                                 const Icon(Icons.play_circle_outline, size: 64)
                              else if (_mediaPath == null) ...[
                                 const Icon(Icons.add_a_photo, size: 48, color: Colors.grey),
                                 const Text('Add Photo/Video'),
                              ]
                            ],
                          )
                        : null,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _mediaUrlController,
              decoration: const InputDecoration(
                labelText: 'Media URL (GIF/Video)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    _mediaPath = value;
                    _mediaSource = MediaSource.online;
                    // Reset type or guess
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Basic Info
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Exercise Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Dropdowns
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedBodyPart,
                    decoration: const InputDecoration(
                      labelText: 'Body Part',
                      border: OutlineInputBorder(),
                    ),
                    items: ExerciseConstants.bodyParts.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedBodyPart = newValue!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedEquipment,
                    decoration: const InputDecoration(
                      labelText: 'Equipment',
                      border: OutlineInputBorder(),
                    ),
                    items: ExerciseConstants.equipmentTypes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedEquipment = newValue!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<ExerciseDifficulty>(
              value: _selectedDifficulty,
              decoration: const InputDecoration(
                labelText: 'Difficulty',
                border: OutlineInputBorder(),
              ),
              items: ExerciseDifficulty.values.map((ExerciseDifficulty value) {
                return DropdownMenuItem<ExerciseDifficulty>(
                  value: value,
                  child: Text(value.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedDifficulty = newValue!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Instructions
            const Text('Instructions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._instructionControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: 'Step ${index + 1}',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeInstruction(index),
                    ),
                  ],
                ),
              );
            }).toList(),
            TextButton.icon(
              onPressed: _addInstruction,
              icon: const Icon(Icons.add),
              label: const Text('Add Step'),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
