import 'package:equatable/equatable.dart';

class Schedule extends Equatable {
  final String id;
  final String name;
  final String? description;
  final bool isActive;

  const Schedule({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, name, description, isActive];
}
