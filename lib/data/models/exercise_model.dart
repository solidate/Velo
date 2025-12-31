import 'dart:convert';
import '../../domain/entities/exercise.dart';

class ExerciseModel extends Exercise {
  const ExerciseModel({
    required super.id,
    required super.name,
    required super.description,
    super.mediaPath,
    required super.isCustom,
    required super.bodyPart,
    required super.equipmentType,
    required super.difficulty,
    required super.targetMuscleGroups,
    required super.instructions,
    super.commonMistakes,
    super.formTips,
    super.equipmentAlternatives,
    super.mediaType,
    super.mediaSource,
  });

  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      mediaPath: map['media_path'],
      isCustom: (map['is_custom'] as int) == 1,
      bodyPart: map['body_part'] ?? map['category'] ?? '', // Handle migration/legacy
      equipmentType: map['equipment_type'] ?? 'Bodyweight',
      difficulty: _parseDifficulty(map['difficulty_level']),
      targetMuscleGroups: _parseList(map['target_muscle_groups']),
      instructions: _parseList(map['instructions']),
      commonMistakes: _parseList(map['common_mistakes']),
      formTips: _parseList(map['form_tips']),
      equipmentAlternatives: _parseList(map['equipment_alternatives']),
      mediaType: _parseMediaType(map['media_type']),
      mediaSource: _parseMediaSource(map['media_source']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'media_path': mediaPath,
      'is_custom': isCustom ? 1 : 0,
      'body_part': bodyPart,
      'equipment_type': equipmentType,
      'difficulty_level': difficulty.name,
      'target_muscle_groups': jsonEncode(targetMuscleGroups),
      'instructions': jsonEncode(instructions),
      'common_mistakes': jsonEncode(commonMistakes),
      'form_tips': jsonEncode(formTips),
      'equipment_alternatives': jsonEncode(equipmentAlternatives),
      'media_type': mediaType?.name,
      'media_source': mediaSource?.name,
    };
  }

  static List<String> _parseList(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  static ExerciseDifficulty _parseDifficulty(String? value) {
    return ExerciseDifficulty.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ExerciseDifficulty.beginner,
    );
  }

  static MediaType? _parseMediaType(String? value) {
    if (value == null) return null;
    try {
      return MediaType.values.firstWhere((e) => e.name == value);
    } catch (_) {
      return null;
    }
  }

  static MediaSource? _parseMediaSource(String? value) {
    if (value == null) return null;
    try {
      return MediaSource.values.firstWhere((e) => e.name == value);
    } catch (_) {
      return null;
    }
  }
}
