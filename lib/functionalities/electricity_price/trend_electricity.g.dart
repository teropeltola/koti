// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trend_electricity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrendElectricityAdapter extends TypeAdapter<TrendElectricity> {
  @override
  final int typeId = 5;

  @override
  TrendElectricity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrendElectricity(
      fields[1] as int,
      fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, TrendElectricity obj) {
    writer
      ..writeByte(2)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.price);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrendElectricityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
