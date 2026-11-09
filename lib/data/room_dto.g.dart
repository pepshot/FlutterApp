// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomDto _$RoomDtoFromJson(Map<String, dynamic> json) => RoomDto(
  id: json['id'] as String,
  name: json['name'] as String,
  capacity: (json['capacity'] as num).toInt(),
  location: json['location'] as String,
  description: json['description'] as String?,
  image: json['image'] as String?,
  floor: (json['floor'] as num?)?.toInt(),
  accent: json['accent'] as String?,
  hasProjector: json['hasProjector'] as bool? ?? false,
);

Map<String, dynamic> _$RoomDtoToJson(RoomDto instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'capacity': instance.capacity,
  'location': instance.location,
  'description': instance.description,
  'image': instance.image,
  'floor': instance.floor,
  'accent': instance.accent,
  'hasProjector': instance.hasProjector,
};
