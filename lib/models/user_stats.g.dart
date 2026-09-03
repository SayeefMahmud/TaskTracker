// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_stats.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyStatsAdapter extends TypeAdapter<DailyStats> {
  @override
  final int typeId = 5;

  @override
  DailyStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyStats(
      localDate: fields[0] as String,
      completedCount: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DailyStats obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.localDate)
      ..writeByte(1)
      ..write(obj.completedCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
