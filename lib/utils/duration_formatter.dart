String? formatDuration(int? minutes) {
  if (minutes == null || minutes <= 0) return null;

  if (minutes < 60) {
    return '${minutes}m';
  }

  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;

  if (remainingMinutes == 0) {
    return '${hours}h';
  }

  return '${hours}h ${remainingMinutes}m';
}
