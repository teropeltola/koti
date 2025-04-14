// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trend_switch.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrendSwitchAdapter extends TypeAdapter<TrendSwitch> {
  @override
  final int typeId = 7;

  @override
  TrendSwitch read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrendSwitch(
      fields[0] as int,
      fields[1] as String,
      fields[2] as String,
      fields[3] as bool,
      fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TrendSwitch obj) {
    writer
      ..writeByte(5)
      ..writeByte(3)
      ..write(obj.on)
      ..writeByte(4)
      ..write(obj.initiator)
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
      other is TrendSwitchAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
