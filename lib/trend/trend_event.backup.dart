// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trend_event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrendEventAdapter extends TypeAdapter<TrendEvent> {
  @override
  final int typeId = 2;

  @override
  TrendEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrendEvent(
      fields[0] as int,
      fields[1] as String,
      fields[2] as String,
      ObservationLevel.values[fields[3]],
      fields[4] as String
    );
  }

  @override
  void write(BinaryWriter writer, TrendEvent obj) {
    writer
      ..writeByte(5)
      ..writeByte(3)
      ..write(obj.observationLevel.index)
      ..writeByte(4)
      ..write(obj.text)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.estateId)
      ..writeByte(2)
      ..write(obj.deviceId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrendEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
