// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$scheduleRepositoryHash() =>
    r'163e95fd227cef4b91e8e7497faf15490205e777';

/// See also [scheduleRepository].
@ProviderFor(scheduleRepository)
final scheduleRepositoryProvider =
    AutoDisposeProvider<ScheduleRepository>.internal(
  scheduleRepository,
  name: r'scheduleRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$scheduleRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ScheduleRepositoryRef = AutoDisposeProviderRef<ScheduleRepository>;
String _$activeScheduleHash() => r'6df15927acca9e3610256aa95432c62be3dd5e32';

/// See also [ActiveSchedule].
@ProviderFor(ActiveSchedule)
final activeScheduleProvider =
    AutoDisposeAsyncNotifierProvider<ActiveSchedule, Schedule?>.internal(
  ActiveSchedule.new,
  name: r'activeScheduleProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeScheduleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ActiveSchedule = AutoDisposeAsyncNotifier<Schedule?>;
String _$allSchedulesHash() => r'75572ba7fd398d6bbd26d47ec03149de8f04a40f';

/// See also [AllSchedules].
@ProviderFor(AllSchedules)
final allSchedulesProvider =
    AutoDisposeAsyncNotifierProvider<AllSchedules, List<Schedule>>.internal(
  AllSchedules.new,
  name: r'allSchedulesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allSchedulesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AllSchedules = AutoDisposeAsyncNotifier<List<Schedule>>;
String _$dailyWorkoutHash() => r'cfc4dd1891f94effa24fe33560e25c630b165045';

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

abstract class _$DailyWorkout
    extends BuildlessAutoDisposeAsyncNotifier<List<ScheduledExercise>> {
  late final int dayOfWeek;

  FutureOr<List<ScheduledExercise>> build(
    int dayOfWeek,
  );
}

/// See also [DailyWorkout].
@ProviderFor(DailyWorkout)
const dailyWorkoutProvider = DailyWorkoutFamily();

/// See also [DailyWorkout].
class DailyWorkoutFamily extends Family<AsyncValue<List<ScheduledExercise>>> {
  /// See also [DailyWorkout].
  const DailyWorkoutFamily();

  /// See also [DailyWorkout].
  DailyWorkoutProvider call(
    int dayOfWeek,
  ) {
    return DailyWorkoutProvider(
      dayOfWeek,
    );
  }

  @override
  DailyWorkoutProvider getProviderOverride(
    covariant DailyWorkoutProvider provider,
  ) {
    return call(
      provider.dayOfWeek,
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
  String? get name => r'dailyWorkoutProvider';
}

/// See also [DailyWorkout].
class DailyWorkoutProvider extends AutoDisposeAsyncNotifierProviderImpl<
    DailyWorkout, List<ScheduledExercise>> {
  /// See also [DailyWorkout].
  DailyWorkoutProvider(
    int dayOfWeek,
  ) : this._internal(
          () => DailyWorkout()..dayOfWeek = dayOfWeek,
          from: dailyWorkoutProvider,
          name: r'dailyWorkoutProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$dailyWorkoutHash,
          dependencies: DailyWorkoutFamily._dependencies,
          allTransitiveDependencies:
              DailyWorkoutFamily._allTransitiveDependencies,
          dayOfWeek: dayOfWeek,
        );

  DailyWorkoutProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.dayOfWeek,
  }) : super.internal();

  final int dayOfWeek;

  @override
  FutureOr<List<ScheduledExercise>> runNotifierBuild(
    covariant DailyWorkout notifier,
  ) {
    return notifier.build(
      dayOfWeek,
    );
  }

  @override
  Override overrideWith(DailyWorkout Function() create) {
    return ProviderOverride(
      origin: this,
      override: DailyWorkoutProvider._internal(
        () => create()..dayOfWeek = dayOfWeek,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        dayOfWeek: dayOfWeek,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<DailyWorkout, List<ScheduledExercise>>
      createElement() {
    return _DailyWorkoutProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DailyWorkoutProvider && other.dayOfWeek == dayOfWeek;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, dayOfWeek.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DailyWorkoutRef
    on AutoDisposeAsyncNotifierProviderRef<List<ScheduledExercise>> {
  /// The parameter `dayOfWeek` of this provider.
  int get dayOfWeek;
}

class _DailyWorkoutProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<DailyWorkout,
        List<ScheduledExercise>> with DailyWorkoutRef {
  _DailyWorkoutProviderElement(super.provider);

  @override
  int get dayOfWeek => (origin as DailyWorkoutProvider).dayOfWeek;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
