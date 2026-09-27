// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'allergen_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AllergenModelAdapter extends TypeAdapter<AllergenModel> {
  @override
  final int typeId = 1;

  @override
  AllergenModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AllergenModel(
      allergenId: fields[0] as String,
      name: fields[1] as String,
      synonyms: (fields[2] as List).cast<String>(),
      nutrientsProvided: (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, AllergenModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.allergenId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.synonyms)
      ..writeByte(3)
      ..write(obj.nutrientsProvided);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AllergenModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
