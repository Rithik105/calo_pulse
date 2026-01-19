// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calorie_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CalorieEntryAdapter extends TypeAdapter<CalorieEntry> {
  @override
  final int typeId = 1;

  @override
  CalorieEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CalorieEntry(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      calories: fields[2] as int,
      mealType: fields[3] as String?,
      note: fields[4] as String?,
      createdAt: fields[5] as dynamic,
      updatedAt: fields[6] as dynamic,
      isDeleted: fields[7] as dynamic,
      isSynced: fields[8] as dynamic,
    );
  }

  @override
  void write(BinaryWriter writer, CalorieEntry obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.calories)
      ..writeByte(3)
      ..write(obj.mealType)
      ..writeByte(4)
      ..write(obj.note)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.isDeleted)
      ..writeByte(8)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalorieEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
