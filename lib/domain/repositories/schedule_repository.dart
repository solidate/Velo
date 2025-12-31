import '../entities/schedule.dart';
import '../entities/scheduled_exercise.dart';

abstract class ScheduleRepository {
  Future<List<Schedule>> getSchedules();
  Future<Schedule?> getActiveSchedule();
  Future<Schedule?> getScheduleById(String id);
  Future<void> createSchedule(Schedule schedule);
  Future<void> updateSchedule(Schedule schedule);
  Future<void> deleteSchedule(String id);
  Future<void> setActiveSchedule(String id);

  Future<List<ScheduledExercise>> getScheduledExercises(String scheduleId, int dayOfWeek);
  Future<void> addScheduledExercise(ScheduledExercise exercise);
  Future<void> updateScheduledExercise(ScheduledExercise exercise);
  Future<void> deleteScheduledExercise(String id);
  Future<void> updateScheduledExercisesOrder(List<ScheduledExercise> exercises);
}
