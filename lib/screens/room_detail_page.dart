import 'package:flutter/material.dart';

import '../data/room_dto.dart';
import '../widgets/room_image.dart';

class RoomDetailPage extends StatelessWidget {
  const RoomDetailPage({super.key, required this.room});

  final RoomDto room;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(room.name)),
      body: ListView(
        children: [
          RoomImage(url: room.image, height: 240, width: double.infinity),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text('Расположение: ${room.location}'),
                Text('Вместимость: ${room.capacity} мест'),
                Text('Проектор: ${room.hasProjector ? 'есть' : 'нет'}'),
                const SizedBox(height: 16),
                Text(
                  room.description?.isNotEmpty == true
                      ? room.description!
                      : 'Описание отсутствует',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
