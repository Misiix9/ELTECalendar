// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'semester_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SemesterAdapter extends TypeAdapter<Semester> {
  @override
  final int typeId = 3;

  @override
  Semester read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Semester(
      id: fields[0] as String,
      academicYearStart: fields[1] as int,
      academicYearEnd: fields[2] as int,
      semesterNumber: fields[3] as int,
      isCurrent: fields[4] as bool,
      startDate: fields[5] as DateTime,
      endDate: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Semester obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.academicYearStart)
      ..writeByte(2)
      ..write(obj.academicYearEnd)
      ..writeByte(3)
      ..write(obj.semesterNumber)
      ..writeByte(4)
      ..write(obj.isCurrent)
      ..writeByte(5)
      ..write(obj.startDate)
      ..writeByte(6)
      ..write(obj.endDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemesterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
