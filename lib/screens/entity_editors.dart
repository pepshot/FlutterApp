import 'package:flutter/material.dart';

import '../data/user_dto.dart';
import '../data/user_repository.dart';
import '../data/room_dto.dart';
import '../data/room_repository.dart';
import '../data/booking_dto.dart';
import '../data/booking_repository.dart';
import '../widgets/entity_form.dart';

Future<bool> editUser(
  BuildContext context,
  UserRepository repository, [
  UserDto? value,
]) => showEntityForm(
  context,
  title: value == null ? 'Новый пользователь' : 'Изменить пользователя',
  initial: value?.toJson() ?? {'id': ''},
  fields: const [
    EntityField('fullName', 'ФИО', maxLength: 255),
    EntityField('email', 'Email', maxLength: 254),
    EntityField('department', 'Отдел', required: false, maxLength: 100),
  ],
  save: (data) async {
    final dto = UserDto.fromJson(data);
    if (value == null) {
      await repository.create(dto);
    } else {
      await repository.update(dto);
    }
  },
);

Future<bool> editRoom(
  BuildContext context,
  RoomRepository repository, [
  RoomDto? value,
]) => showEntityForm(
  context,
  title: value == null ? 'Новая переговорная' : 'Изменить переговорную',
  initial: value?.toJson() ?? {'id': ''},
  fields: const [
    EntityField('name', 'Название', maxLength: 100),
    EntityField('capacity', 'Количество мест', number: true),
    EntityField('location', 'Расположение', maxLength: 255),
    EntityField('floor', 'Этаж', required: false, number: true),
    EntityField('description', 'Описание', required: false, maxLength: 2000),
    EntityField('image', 'Адрес изображения', required: false, maxLength: 2048),
  ],
  save: (data) async {
    final dto = RoomDto.fromJson(data);
    if (value == null) {
      await repository.create(dto);
    } else {
      await repository.update(dto);
    }
  },
);

Future<bool> editBooking(
  BuildContext context,
  BookingRepository repository, {
  required RoomRepository rooms,
  required UserRepository users,
  BookingDto? value,
}) => showEntityForm(
  context,
  title: value == null ? 'Новая встреча' : 'Изменить встречу',
  initial: value?.toJson() ?? {'id': '', 'status': 'CONFIRMED'},
  loadOptions: () async {
    final result = await Future.wait<Object>([
      rooms.search(''),
      users.getAll(),
    ]);
    return {
      'roomId': {
        for (final room in result[0] as List<RoomDto>)
          room.id: '${room.name} · ${room.location} (${room.capacity} мест)',
      },
      'userId': {
        for (final user in result[1] as List<UserDto>)
          user.id: '${user.fullName} · ${user.email}',
      },
    };
  },
  fields: const [
    EntityField('roomId', 'Переговорная'),
    EntityField('userId', 'Пользователь'),
    EntityField('startTime', 'Начало (2026-10-28T10:00)'),
    EntityField('endTime', 'Конец (2026-10-28T11:00)'),
    EntityField('purpose', 'Цель встречи', maxLength: 500),
    EntityField(
      'participantsCount',
      'Участников',
      required: false,
      number: true,
    ),
  ],
  validate: (data) {
    final start = DateTime.tryParse(data['startTime'] as String);
    final end = DateTime.tryParse(data['endTime'] as String);
    if (start == null || end == null || !end.isAfter(start)) {
      return 'Укажите даты; конец должен быть позже начала';
    }
    return null;
  },
  save: (data) async {
    final dto = BookingDto.fromJson(data);
    if (value == null) {
      await repository.create(dto);
    } else {
      await repository.update(dto);
    }
  },
);
