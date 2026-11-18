import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';

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
  title: value == null
      ? context.tr('Новый пользователь')
      : context.tr('Изменить пользователя'),
  initial: value?.toJson() ?? {'id': ''},
  fields: [
    EntityField('fullName', context.tr('ФИО'), maxLength: 255),
    const EntityField('email', 'Email', maxLength: 254),
    EntityField(
      'department',
      context.tr('Отдел'),
      required: false,
      maxLength: 100,
    ),
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
  title: value == null
      ? context.tr('Новая переговорная')
      : context.tr('Изменить переговорную'),
  initial: value?.toJson() ?? {'id': ''},
  fields: [
    EntityField('name', context.tr('Название'), maxLength: 100),
    EntityField('capacity', context.tr('Количество мест'), number: true),
    EntityField('location', context.tr('Расположение'), maxLength: 255),
    EntityField('floor', context.tr('Этаж'), required: false, number: true),
    EntityField(
      'description',
      context.tr('Описание'),
      required: false,
      maxLength: 2000,
    ),
    EntityField(
      'image',
      context.tr('Адрес изображения'),
      required: false,
      maxLength: 2048,
    ),
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
  title: value == null
      ? context.tr('Новая встреча')
      : context.tr('Изменить встречу'),
  initial: value?.toJson() ?? {'id': '', 'status': 'CONFIRMED'},
  loadOptions: () async {
    final result = await Future.wait<Object>([
      rooms.search(''),
      users.getAll(),
    ]);
    return {
      'roomId': {
        if (context.mounted)
          for (final room in result[0] as List<RoomDto>)
            room.id:
                '${room.name} · ${room.location} (${context.tr('{count} мест', {'count': room.capacity})})',
      },
      'userId': {
        for (final user in result[1] as List<UserDto>)
          user.id: '${user.fullName} · ${user.email}',
      },
    };
  },
  fields: [
    EntityField('roomId', context.tr('Переговорная')),
    EntityField('userId', context.tr('Пользователь')),
    EntityField('startTime', context.tr('Начало (2026-10-28T10:00)')),
    EntityField('endTime', context.tr('Конец (2026-10-28T11:00)')),
    EntityField('purpose', context.tr('Цель встречи'), maxLength: 500),
    EntityField(
      'participantsCount',
      context.tr('Участников'),
      required: false,
      number: true,
    ),
  ],
  validate: (data) {
    final start = DateTime.tryParse(data['startTime'] as String);
    final end = DateTime.tryParse(data['endTime'] as String);
    if (start == null || end == null || !end.isAfter(start)) {
      return context.tr('Укажите даты; конец должен быть позже начала');
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
