import '../widgets/refreshable_message.dart';
import 'entity_editors.dart';
import '../widgets/entity_form.dart';

import 'package:flutter/material.dart';

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
  final _controller = TextEditingController();
  List<RoomDto> _rooms = [];
  bool _loading = false;
  String? _error;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final requestId = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rooms = await widget.repository.search(_controller.text);
      if (!mounted || requestId != _requestId) return;
      setState(() => _rooms = rooms);
    } catch (_) {
      if (!mounted || requestId != _requestId) return;
      setState(
        () => _error = 'Не удалось загрузить комнаты. Проверьте сервер.',
      );
    } finally {
      if (mounted && requestId == _requestId) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _edit([RoomDto? room]) async {
    if (await editRoom(context, widget.repository, room) && mounted) {
      await _load();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Переговорные')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _edit(),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Название комнаты',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _load(),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _load,
                child: const Text('Найти'),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
                child: _loading
                    ? const RefreshableMessage(
                        child: CircularProgressIndicator(),
                      )
                    : _error != null
                    ? RefreshableMessage(child: Text(_error!))
                    : _rooms.isEmpty
                    ? const RefreshableMessage(
                        child: Text('Комнаты не найдены'),
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _rooms.length,
                        itemBuilder: (context, index) {
                          final room = _rooms[index];
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
                                    _load,
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
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
