import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_app/data/room_repository.dart';
import 'package:flutter_app/data/booking_repository.dart';
import 'package:flutter_app/data/user_repository.dart';
import 'package:flutter_app/screens/home_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('ru');
  final _rooms = HttpRoomRepository();
  final _bookings = HttpBookingRepository();
  final _users = HttpUserRepository();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MeetSpace',
      locale: _locale,
      supportedLocales: const [Locale('ru'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF006A60)),
        useMaterial3: true,
      ),
      home: HomePage(
        rooms: _rooms,
        bookings: _bookings,
        users: _users,
        onLocaleChanged: (locale) => setState(() => _locale = locale),
      ),
    );
  }
}
