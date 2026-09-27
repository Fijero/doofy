// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DetectedAllergenAdapter extends TypeAdapter<DetectedAllergen> {
  @override
  final int typeId = 3;

  @override
  DetectedAllergen read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DetectedAllergen(
      allergenName: fields[0] as String,
      triggeredBy: fields[1] as String,
      severity: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DetectedAllergen obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.allergenName)
      ..writeByte(1)
      ..write(obj.triggeredBy)
      ..writeByte(2)
      ..write(obj.severity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetectedAllergenAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ScanResultAdapter extends TypeAdapter<ScanResult> {
  @override
  final int typeId = 4;

  @override
  ScanResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScanResult(
      ingredientText: fields[0] as String,
      detectedAllergens: (fields[1] as List).cast<DetectedAllergen>(),
      status: fields[2] as String,
      scanMethod: fields[3] as String,
      timestamp: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ScanResult obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.ingredientText)
      ..writeByte(1)
      ..write(obj.detectedAllergens)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.scanMethod)
      ..writeByte(4)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
