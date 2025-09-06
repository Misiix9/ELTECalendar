// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExportOptionsAdapter extends TypeAdapter<ExportOptions> {
  @override
  final int typeId = 7;

  @override
  ExportOptions read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExportOptions(
      semesterIds: (fields[0] as List).cast<String>(),
      courseTypes: (fields[1] as List).cast<CourseType>(),
      startDate: fields[2] as DateTime?,
      endDate: fields[3] as DateTime?,
      includeInstructors: fields[4] as bool,
      includeLocation: fields[5] as bool,
      includeDescription: fields[6] as bool,
      includeCredits: fields[7] as bool,
      title: fields[8] as String?,
      layoutType: fields[9] as ExportLayoutType,
      includeWeekends: fields[10] as bool,
      dayStartTime: fields[11] as TimeOfDay?,
      dayEndTime: fields[12] as TimeOfDay?,
    );
  }

  @override
  void write(BinaryWriter writer, ExportOptions obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.semesterIds)
      ..writeByte(1)
      ..write(obj.courseTypes)
      ..writeByte(2)
      ..write(obj.startDate)
      ..writeByte(3)
      ..write(obj.endDate)
      ..writeByte(4)
      ..write(obj.includeInstructors)
      ..writeByte(5)
      ..write(obj.includeLocation)
      ..writeByte(6)
      ..write(obj.includeDescription)
      ..writeByte(7)
      ..write(obj.includeCredits)
      ..writeByte(8)
      ..write(obj.title)
      ..writeByte(9)
      ..write(obj.layoutType)
      ..writeByte(10)
      ..write(obj.includeWeekends)
      ..writeByte(11)
      ..write(obj.dayStartTime)
      ..writeByte(12)
      ..write(obj.dayEndTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExportOptionsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExportHistoryItemAdapter extends TypeAdapter<ExportHistoryItem> {
  @override
  final int typeId = 9;

  @override
  ExportHistoryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExportHistoryItem(
      id: fields[0] as String,
      exportType: fields[1] as ExportType,
      fileName: fields[2] as String,
      timestamp: fields[3] as DateTime,
      itemCount: fields[4] as int,
      fileSize: fields[5] as int,
      success: fields[6] as bool,
      error: fields[7] as String?,
      options: (fields[8] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ExportHistoryItem obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.exportType)
      ..writeByte(2)
      ..write(obj.fileName)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.itemCount)
      ..writeByte(5)
      ..write(obj.fileSize)
      ..writeByte(6)
      ..write(obj.success)
      ..writeByte(7)
      ..write(obj.error)
      ..writeByte(8)
      ..write(obj.options);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExportHistoryItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExportTypeAdapter extends TypeAdapter<ExportType> {
  @override
  final int typeId = 6;

  @override
  ExportType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExportType.ics;
      case 1:
        return ExportType.pdf;
      case 2:
        return ExportType.excel;
      default:
        return ExportType.ics;
    }
  }

  @override
  void write(BinaryWriter writer, ExportType obj) {
    switch (obj) {
      case ExportType.ics:
        writer.writeByte(0);
        break;
      case ExportType.pdf:
        writer.writeByte(1);
        break;
      case ExportType.excel:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExportTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CourseTypeAdapter extends TypeAdapter<CourseType> {
  @override
  final int typeId = 8;

  @override
  CourseType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CourseType.lecture;
      case 1:
        return CourseType.practice;
      case 2:
        return CourseType.laboratory;
      case 3:
        return CourseType.seminar;
      case 4:
        return CourseType.consultation;
      default:
        return CourseType.lecture;
    }
  }

  @override
  void write(BinaryWriter writer, CourseType obj) {
    switch (obj) {
      case CourseType.lecture:
        writer.writeByte(0);
        break;
      case CourseType.practice:
        writer.writeByte(1);
        break;
      case CourseType.laboratory:
        writer.writeByte(2);
        break;
      case CourseType.seminar:
        writer.writeByte(3);
        break;
      case CourseType.consultation:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExportLayoutTypeAdapter extends TypeAdapter<ExportLayoutType> {
  @override
  final int typeId = 9;

  @override
  ExportLayoutType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExportLayoutType.daily;
      case 1:
        return ExportLayoutType.weekly;
      case 2:
        return ExportLayoutType.monthly;
      case 3:
        return ExportLayoutType.list;
      default:
        return ExportLayoutType.daily;
    }
  }

  @override
  void write(BinaryWriter writer, ExportLayoutType obj) {
    switch (obj) {
      case ExportLayoutType.daily:
        writer.writeByte(0);
        break;
      case ExportLayoutType.weekly:
        writer.writeByte(1);
        break;
      case ExportLayoutType.monthly:
        writer.writeByte(2);
        break;
      case ExportLayoutType.list:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExportLayoutTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
