import 'package:json_annotation/json_annotation.dart';

part 'room_dto.g.dart';

@JsonSerializable()
class RoomDto {
  const RoomDto({
    required this.id,
    required this.name,
    required this.capacity,
    required this.location,
    this.description,
    this.image,
    this.floor,
    this.accent,
    this.hasProjector = false,
  });

  final String id;
  final String name;
  final int capacity;
  final String location;
  final String? description;
  final String? image;
  final int? floor;
  final String? accent;
  final bool hasProjector;

  factory RoomDto.fromJson(Map<String, dynamic> json) =>
      _$RoomDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RoomDtoToJson(this);
}
