import 'package:hive/hive.dart';

part 'user_stats.g.dart';

@HiveType(typeId: 5)
class DailyStats extends HiveObject {
  @HiveField(0)
  final String localDate; // YYYY-MM-DD

  @HiveField(1)
  int completedCount;

  DailyStats({
    required this.localDate,
    this.completedCount = 0,
  });
}
