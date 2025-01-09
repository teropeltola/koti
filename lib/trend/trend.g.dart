// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trend.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BoxInformationAdapter extends TypeAdapter<BoxInformation> {
  @override
  final int typeId = 0;

  @override
  BoxInformation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BoxInformation(
      fields[0] as String,
      fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BoxInformation obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.typeName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoxInformationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TrendDataAdapter extends TypeAdapter<TrendData> {
  @override
  final int typeId = 1;

  @override
  TrendData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrendData(
      fields[0] as int,
      fields[1] as String,
      fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TrendData obj) {
    writer
      ..writeByte(3)
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
      other is TrendDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
