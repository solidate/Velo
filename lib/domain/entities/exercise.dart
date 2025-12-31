import 'package:equatable/equatable.dart';

enum ExerciseDifficulty { beginner, intermediate, advanced }
enum MediaType { video, gif, image }
enum MediaSource { asset, local, online }

class Exercise extends Equatable {
  final String id;
  final String name;
  final String description;
  final String? mediaPath;
  final bool isCustom;
  final String bodyPart; // Was category
  final String equipmentType;
  final ExerciseDifficulty difficulty;
  final List<String> targetMuscleGroups;
  final List<String> instructions;
  final List<String> commonMistakes;
  final List<String> formTips;
  final List<String> equipmentAlternatives;
  final MediaType? mediaType;
  final MediaSource? mediaSource;

  const Exercise({
    required this.id,
    required this.name,
    required this.description,
    this.mediaPath,
    required this.isCustom,
    required this.bodyPart,
    required this.equipmentType,
    required this.difficulty,
    required this.targetMuscleGroups,
    required this.instructions,
    this.commonMistakes = const [],
    this.formTips = const [],
    this.equipmentAlternatives = const [],
    this.mediaType,
    this.mediaSource,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        mediaPath,
        isCustom,
        bodyPart,
        equipmentType,
        difficulty,
        targetMuscleGroups,
        instructions,
        commonMistakes,
        formTips,
        equipmentAlternatives,
        mediaType,
        mediaSource,
      ];
}
