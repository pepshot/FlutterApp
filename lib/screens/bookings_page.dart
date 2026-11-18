import '../data/room_repository.dart';
import '../data/user_repository.dart';
import '../widgets/refreshable_message.dart';
import 'entity_editors.dart';
import '../widgets/entity_form.dart';

import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';

import '../blocs/list_bloc.dart';
import '../data/booking_dto.dart';
import '../data/booking_repository.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({
    super.key,
    required this.repository,
    this.rooms,
    this.users,
  });

  final BookingRepository repository;
  final RoomRepository? rooms;
  final UserRepository? users;

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  late final _bloc = ListBloc<BookingDto>(widget.repository.getAll)..refresh();

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  String _date(BuildContext context, DateTime value) {
    final localizations = MaterialLocalizations.of(context);
    final date = localizations.formatCompactDate(value);
    final time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(value),
      alwaysUse24HourFormat: true,
    );
    return '$date $time';
  }

  String _status(BuildContext context, String status) => switch (status) {
    'CONFIRMED' => context.tr('Подтверждена'),
    'CANCELLED' => context.tr('Отменена'),
    'COMPLETED' => context.tr('Завершена'),
    _ => status,
  };

  Future<void> _edit([BookingDto? value]) async {
    if (await editBooking(
          context,
          widget.repository,
          value: value,
          rooms: widget.rooms ?? HttpRoomRepository(),
          users: widget.users ?? HttpUserRepository(),
        ) &&
        mounted) {
      await _bloc.refresh();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [
        IconButton(
          tooltip: context.tr('Обновить'),
          onPressed: _bloc.refresh,
          icon: const Icon(Icons.refresh),
        ),
      ],
      title: Text(context.tr('Встречи')),
    ),
    floatingActionButton: FloatingActionButton(
      heroTag: 'addBooking',
      onPressed: () => _edit(),
      child: const Icon(Icons.add),
    ),
    body: RefreshIndicator(
      onRefresh: _bloc.refresh,
      child: StreamBuilder<ListState<BookingDto>>(
        stream: _bloc.states,
        builder: (context, snapshot) {
          final state = snapshot.data;
          if (state?.failed == true) {
            return RefreshableMessage(
              child: Text(context.tr('Не удалось загрузить встречи')),
            );
          }
          final bookings = state?.items;
          if (bookings == null) {
            return const RefreshableMessage(child: CircularProgressIndicator());
          }
          if (bookings.isEmpty) {
            return RefreshableMessage(child: Text(context.tr('Встреч нет')));
          }
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return ListTile(
                onTap: () => _edit(booking),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: context.tr('Изменить'),
                      icon: const Icon(Icons.edit),
                      onPressed: () => _edit(booking),
                    ),
                    IconButton(
                      tooltip: context.tr('Удалить'),
                      icon: const Icon(Icons.delete),
                      onPressed: () => confirmDelete(
                        context,
                        booking.purpose,
                        () => widget.repository.delete(booking.id),
                        _bloc.refresh,
                      ),
                    ),
                  ],
                ),
                title: Text(booking.purpose),
                subtitle: Text(
                  '${_date(context, booking.startTime)} · ${_status(context, booking.status)}',
                ),
              );
            },
          );
        },
      ),
    ),
  );
}
