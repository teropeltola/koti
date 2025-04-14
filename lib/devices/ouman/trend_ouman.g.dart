// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trend_ouman.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrendOumanAdapter extends TypeAdapter<TrendOuman> {
  @override
  final int typeId = 6;

  @override
  TrendOuman read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrendOuman(
      fields[0] as int,
      fields[1] as String,
      fields[2] as String,
      fields[3] as double,
      fields[4] as double,
      fields[5] as double,
      fields[6] as double,
    );
  }

  @override
  void write(BinaryWriter writer, TrendOuman obj) {
    writer
      ..writeByte(7)
      ..writeByte(3)
      ..write(obj.outsideTemperature)
      ..writeByte(4)
      ..write(obj.measuredWaterTemperature)
      ..writeByte(5)
      ..write(obj.requestedWaterTemperature)
      ..writeByte(6)
      ..write(obj.valve)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.environmentId)
      ..writeByte(2)
      ..write(obj.deviceId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrendOumanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
