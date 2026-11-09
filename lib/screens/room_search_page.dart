import '../widgets/refreshable_message.dart';
import 'entity_editors.dart';
import '../widgets/entity_form.dart';

import 'package:flutter/material.dart';

import '../blocs/list_bloc.dart';
import '../data/room_dto.dart';
import '../data/room_repository.dart';
import '../widgets/room_image.dart';
import 'room_detail_page.dart';

class RoomSearchPage extends StatefulWidget {
  const RoomSearchPage({super.key, required this.repository});

  final RoomRepository repository;

  @override
  State<RoomSearchPage> createState() => _RoomSearchPageState();
}

class _RoomSearchPageState extends State<RoomSearchPage> {
  late final _bloc = ListBloc<RoomDto>.searchable(widget.repository.search)
    ..refresh();

  Future<void> _edit([RoomDto? room]) async {
    if (await editRoom(context, widget.repository, room) && mounted) {
      await _bloc.refresh();
    }
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Переговорные'),
        actions: [
          IconButton(
            tooltip: 'Обновить',
            onPressed: _bloc.refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addRoom',
        onPressed: () => _edit(),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Название комнаты',
                border: OutlineInputBorder(),
              ),
              onChanged: _bloc.searchChanged,
              onSubmitted: (_) => _bloc.refresh(),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _bloc.refresh,
                child: StreamBuilder<ListState<RoomDto>>(
                  stream: _bloc.states,
                  builder: (context, snapshot) {
                    final state = snapshot.data;
                    if (state?.failed == true) {
                      return const RefreshableMessage(
                        child: Text(
                          'Не удалось загрузить комнаты. Проверьте сервер.',
                        ),
                      );
                    }
                    final rooms = state?.items;
                    if (rooms == null) {
                      return const RefreshableMessage(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (rooms.isEmpty) {
                      return const RefreshableMessage(
                        child: Text('Комнаты не найдены'),
                      );
                    }
                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: rooms.length,
                      itemBuilder: (context, index) {
                        final room = rooms[index];
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: RoomImage(
                              url: room.image,
                              width: 64,
                              height: 56,
                            ),
                          ),
                          title: Text(room.name),
                          subtitle: Text(
                            '${room.location} · ${room.capacity} мест',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Изменить',
                                icon: const Icon(Icons.edit),
                                onPressed: () => _edit(room),
                              ),
                              IconButton(
                                tooltip: 'Удалить',
                                icon: const Icon(Icons.delete),
                                onPressed: () => confirmDelete(
                                  context,
                                  room.name,
                                  () => widget.repository.delete(room.id),
                                  _bloc.refresh,
                                ),
                              ),
                            ],
                          ),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => RoomDetailPage(room: room),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
