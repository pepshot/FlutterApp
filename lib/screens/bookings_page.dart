import '../data/room_repository.dart';
import '../data/user_repository.dart';
import '../widgets/refreshable_message.dart';
import 'entity_editors.dart';
import '../widgets/entity_form.dart';

import 'package:flutter/material.dart';

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
  late Future<List<BookingDto>> _bookings = widget.repository.getAll();

  String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year} '
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

  Future<void> _reload() async {
    final request = widget.repository.getAll();
    setState(() {
      _bookings = request;
    });
    try {
      await request;
    } catch (_) {
      // FutureBuilder displays the error and allows another swipe to retry.
    }
  }

  Future<void> _edit([BookingDto? value]) async {
    if (await editBooking(
          context,
          widget.repository,
          value: value,
          rooms: widget.rooms ?? HttpRoomRepository(),
          users: widget.users ?? HttpUserRepository(),
        ) &&
        mounted) {
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [
        IconButton(
          tooltip: 'Обновить',
          onPressed: _reload,
          icon: const Icon(Icons.refresh),
        ),
      ],
      title: const Text('Встречи'),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => _edit(),
      child: const Icon(Icons.add),
    ),
    body: RefreshIndicator(
      onRefresh: _reload,
      child: FutureBuilder<List<BookingDto>>(
        future: _bookings,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const RefreshableMessage(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const RefreshableMessage(
              child: Text('Не удалось загрузить встречи'),
            );
          }
          final bookings = snapshot.data!;
          if (bookings.isEmpty) {
            return const RefreshableMessage(child: Text('Встреч нет'));
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
                      tooltip: 'Изменить',
                      icon: const Icon(Icons.edit),
                      onPressed: () => _edit(booking),
                    ),
                    IconButton(
                      tooltip: 'Удалить',
                      icon: const Icon(Icons.delete),
                      onPressed: () => confirmDelete(
                        context,
                        booking.purpose,
                        () => widget.repository.delete(booking.id),
                        _reload,
                      ),
                    ),
                  ],
                ),
                title: Text(booking.purpose),
                subtitle: Text(
                  '${_date(booking.startTime)} · ${booking.status}',
                ),
              );
            },
          );
        },
      ),
    ),
  );
}
