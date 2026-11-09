import 'package:json_annotation/json_annotation.dart';

part 'booking_dto.g.dart';

@JsonSerializable()
class BookingDto {
  const BookingDto({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.purpose,
    required this.status,
    this.participantsCount,
  });

  final String id;
  final String roomId;
  final String userId;
  final DateTime startTime;
  final DateTime endTime;
  final String purpose;
  final String status;
  final int? participantsCount;

  factory BookingDto.fromJson(Map<String, dynamic> json) =>
      _$BookingDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BookingDtoToJson(this);
}
