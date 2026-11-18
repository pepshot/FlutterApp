import 'package:flutter/material.dart';

import '../data/booking_repository.dart';
import '../data/room_repository.dart';
import '../data/user_repository.dart';
import '../l10n/app_strings.dart';
import 'bookings_page.dart';
import 'room_search_page.dart';
import 'users_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.rooms,
    required this.bookings,
    required this.users,
    required this.onLocaleChanged,
  });

  final RoomRepository rooms;
  final BookingRepository bookings;
  final UserRepository users;
  final ValueChanged<Locale> onLocaleChanged;

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
        Scaffold(
          appBar: AppBar(title: Text(context.tr('Настройки'))),
          body: ListTile(
            title: Text(context.tr('Язык приложения')),
            trailing: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'ru', label: Text('RU')),
                ButtonSegment(value: 'en', label: Text('EN')),
              ],
              selected: {Localizations.localeOf(context).languageCode},
              onSelectionChanged: (selection) =>
                  widget.onLocaleChanged(Locale(selection.single)),
            ),
          ),
        ),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _selected,
      onDestinationSelected: (index) => setState(() => _selected = index),
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.meeting_room_outlined),
          label: context.tr('Переговорные'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.event_outlined),
          label: context.tr('Встречи'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.people_outline),
          label: context.tr('Пользователи'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.settings_outlined),
          label: context.tr('Настройки'),
        ),
      ],
    ),
  );
}
