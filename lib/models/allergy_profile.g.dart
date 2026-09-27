// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'allergy_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AllergyProfileAdapter extends TypeAdapter<AllergyProfile> {
  @override
  final int typeId = 0;

  @override
  AllergyProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AllergyProfile(
      selectedAllergens: (fields[0] as List).cast<String>(),
      severityMap: (fields[1] as Map).cast<String, String>(),
      cloudBackupEnabled: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AllergyProfile obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.selectedAllergens)
      ..writeByte(1)
      ..write(obj.severityMap)
      ..writeByte(2)
      ..write(obj.cloudBackupEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AllergyProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
