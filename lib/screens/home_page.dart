import 'package:flutter/material.dart';

import '../data/booking_repository.dart';
import '../data/room_repository.dart';
import '../data/user_repository.dart';
import 'bookings_page.dart';
import 'room_search_page.dart';
import 'users_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.rooms,
    required this.bookings,
    required this.users,
  });

  final RoomRepository rooms;
  final BookingRepository bookings;
  final UserRepository users;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: _selected,
      children: [
        RoomSearchPage(repository: widget.rooms),
        BookingsPage(
          repository: widget.bookings,
          rooms: widget.rooms,
          users: widget.users,
        ),
        UsersPage(repository: widget.users),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _selected,
      onDestinationSelected: (index) => setState(() => _selected = index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.meeting_room_outlined),
          label: 'Переговорные',
        ),
        NavigationDestination(
          icon: Icon(Icons.event_outlined),
          label: 'Встречи',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outline),
          label: 'Пользователи',
        ),
      ],
    ),
  );
}
