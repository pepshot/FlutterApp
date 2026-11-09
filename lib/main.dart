import 'package:flutter/material.dart';
import 'package:flutter_app/data/room_repository.dart';
import 'package:flutter_app/data/booking_repository.dart';
import 'package:flutter_app/data/user_repository.dart';
import 'package:flutter_app/screens/home_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Переговорные',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF006A60)),
        useMaterial3: true,
      ),
      home: HomePage(
        rooms: HttpRoomRepository(),
        bookings: HttpBookingRepository(),
        users: HttpUserRepository(),
      ),
    );
  }
}
