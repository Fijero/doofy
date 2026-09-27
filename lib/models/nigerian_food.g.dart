// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nigerian_food.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NigerianFoodAdapter extends TypeAdapter<NigerianFood> {
  @override
  final int typeId = 2;

  @override
  NigerianFood read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NigerianFood(
      foodId: fields[0] as String,
      name: fields[1] as String,
      allergens: (fields[2] as List).cast<String>(),
      commonIngredients: (fields[3] as List).cast<String>(),
      hiddenAllergenNote: fields[4] as String,
      region: fields[5] as String,
      vendorVariation: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, NigerianFood obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.foodId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.allergens)
      ..writeByte(3)
      ..write(obj.commonIngredients)
      ..writeByte(4)
      ..write(obj.hiddenAllergenNote)
      ..writeByte(5)
      ..write(obj.region)
      ..writeByte(6)
      ..write(obj.vendorVariation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NigerianFoodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
