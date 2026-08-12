// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: flutter pub run build_runner build --delete-conflicting-outputs

part of 'models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MemberAdapter extends TypeAdapter<Member> {
  @override
  final int typeId = 0;

  @override
  Member read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Member(
      id: fields[0] as String,
      name: fields[1] as String,
      upiId: fields[2] as String?,
      upiName: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Member obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.upiId)
      ..writeByte(3)
      ..write(obj.upiName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemberAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ItemShareAdapter extends TypeAdapter<ItemShare> {
  @override
  final int typeId = 1;

  @override
  ItemShare read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemShare(
      memberId: fields[0] as String,
      amount: fields[1] as double,
      locked: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ItemShare obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.memberId)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.locked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemShareAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SplitItemAdapter extends TypeAdapter<SplitItem> {
  @override
  final int typeId = 2;

  @override
  SplitItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SplitItem(
      id: fields[0] as String,
      name: fields[1] as String,
      price: fields[2] as double,
      includedMemberIds: (fields[3] as List).cast<String>(),
      shares: (fields[4] as List).cast<ItemShare>(),
    );
  }

  @override
  void write(BinaryWriter writer, SplitItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.includedMemberIds)
      ..writeByte(4)
      ..write(obj.shares);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplitItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SplitSessionAdapter extends TypeAdapter<SplitSession> {
  @override
  final int typeId = 3;

  @override
  SplitSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SplitSession(
      id: fields[0] as String,
      name: fields[1] as String,
      createdBy: fields[2] as String,
      createdByName: fields[3] as String,
      createdAt: fields[4] as int,
      payeeId: fields[5] as String,
      items: (fields[6] as List).cast<SplitItem>(),
      status: fields[7] as String,
      paidMemberIds: (fields[8] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, SplitSession obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.createdBy)
      ..writeByte(3)
      ..write(obj.createdByName)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.payeeId)
      ..writeByte(6)
      ..write(obj.items)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.paidMemberIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplitSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GroupAdapter extends TypeAdapter<Group> {
  @override
  final int typeId = 4;

  @override
  Group read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Group(
      id: fields[0] as String,
      name: fields[1] as String,
      payeeId: fields[2] as String,
      currency: fields[3] as String,
      members: (fields[4] as List).cast<Member>(),
      items: (fields[5] as List).cast<SplitItem>(),
      createdAt: fields[6] as int,
      ownerId: fields[7] as String,
      splits: (fields[8] as List).cast<SplitSession>(),
    );
  }

  @override
  void write(BinaryWriter writer, Group obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.payeeId)
      ..writeByte(3)
      ..write(obj.currency)
      ..writeByte(4)
      ..write(obj.members)
      ..writeByte(5)
      ..write(obj.items)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.ownerId)
      ..writeByte(8)
      ..write(obj.splits);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
