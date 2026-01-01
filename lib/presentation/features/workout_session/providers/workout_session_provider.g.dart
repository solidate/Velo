// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$workoutSessionHash() => r'e836cc3e9bb427038c31b9b619f6eaa6e9b2982a';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$WorkoutSession
    extends BuildlessAutoDisposeNotifier<WorkoutSessionState> {
  late final List<ScheduledExercise> exercises;

  WorkoutSessionState build(
    List<ScheduledExercise> exercises,
  );
}

/// See also [WorkoutSession].
@ProviderFor(WorkoutSession)
const workoutSessionProvider = WorkoutSessionFamily();

/// See also [WorkoutSession].
class WorkoutSessionFamily extends Family<WorkoutSessionState> {
  /// See also [WorkoutSession].
  const WorkoutSessionFamily();

  /// See also [WorkoutSession].
  WorkoutSessionProvider call(
    List<ScheduledExercise> exercises,
  ) {
    return WorkoutSessionProvider(
      exercises,
    );
  }

  @override
  WorkoutSessionProvider getProviderOverride(
    covariant WorkoutSessionProvider provider,
  ) {
    return call(
      provider.exercises,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'workoutSessionProvider';
}

/// See also [WorkoutSession].
class WorkoutSessionProvider extends AutoDisposeNotifierProviderImpl<
    WorkoutSession, WorkoutSessionState> {
  /// See also [WorkoutSession].
  WorkoutSessionProvider(
    List<ScheduledExercise> exercises,
  ) : this._internal(
          () => WorkoutSession()..exercises = exercises,
          from: workoutSessionProvider,
          name: r'workoutSessionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$workoutSessionHash,
          dependencies: WorkoutSessionFamily._dependencies,
          allTransitiveDependencies:
              WorkoutSessionFamily._allTransitiveDependencies,
          exercises: exercises,
        );

  WorkoutSessionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.exercises,
  }) : super.internal();

  final List<ScheduledExercise> exercises;

  @override
  WorkoutSessionState runNotifierBuild(
    covariant WorkoutSession notifier,
  ) {
    return notifier.build(
      exercises,
    );
  }

  @override
  Override overrideWith(WorkoutSession Function() create) {
    return ProviderOverride(
      origin: this,
      override: WorkoutSessionProvider._internal(
        () => create()..exercises = exercises,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        exercises: exercises,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<WorkoutSession, WorkoutSessionState>
      createElement() {
    return _WorkoutSessionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkoutSessionProvider && other.exercises == exercises;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, exercises.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WorkoutSessionRef on AutoDisposeNotifierProviderRef<WorkoutSessionState> {
  /// The parameter `exercises` of this provider.
  List<ScheduledExercise> get exercises;
}

class _WorkoutSessionProviderElement extends AutoDisposeNotifierProviderElement<
    WorkoutSession, WorkoutSessionState> with WorkoutSessionRef {
  _WorkoutSessionProviderElement(super.provider);

  @override
  List<ScheduledExercise> get exercises =>
      (origin as WorkoutSessionProvider).exercises;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
