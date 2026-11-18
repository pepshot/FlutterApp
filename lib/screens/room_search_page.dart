import '../widgets/refreshable_message.dart';
import 'entity_editors.dart';
import '../widgets/entity_form.dart';

import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';

import '../blocs/list_bloc.dart';
import '../blocs/room_likes_bloc.dart';
import '../data/room_dto.dart';
import '../data/room_likes_repository.dart';
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

  final _likes = RoomLikesBloc(RoomLikesRepository());
  bool _connectingLikes = true;
  bool _savingLike = false;

  @override
  void initState() {
    super.initState();
    _restoreLikes();
  }

  Future<void> _restoreLikes() async {
    try {
      await _likes.restoreConnection();
    } finally {
      if (mounted) setState(() => _connectingLikes = false);
    }
  }

  Future<void> _refresh() async {
    await Future.wait([
      _bloc.refresh(),
      if (_likes.isConfigured && !_connectingLikes) _likes.refresh(),
    ]);
  }

  Future<void> _connectLikes() async {
    var entered = '';
    final password = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('Подключить PostgreSQL')),
        content: TextField(
          autofocus: true,
          obscureText: true,
          decoration: InputDecoration(
            labelText: context.tr('Пароль PostgreSQL'),
          ),
          onChanged: (value) => entered = value,
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('Отмена')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, entered),
            child: Text(context.tr('Подключить')),
          ),
        ],
      ),
    );
    if (!mounted || password == null || password.isEmpty) return;
    setState(() => _connectingLikes = true);
    try {
      if (!await _likes.connect(password) && mounted) {
        _showLikesError('Не удалось подключиться к PostgreSQL');
      }
    } on Exception {
      if (mounted) _showLikesError('Не удалось сохранить пароль PostgreSQL');
    } finally {
      if (mounted) setState(() => _connectingLikes = false);
    }
  }

  void _showLikesError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.tr(message))));
  }

  Future<void> _setLiked(String roomId, bool liked) async {
    if (_savingLike) return;
    setState(() => _savingLike = true);
    try {
      await _likes.setLiked(roomId, liked);
    } catch (_) {
      if (mounted) _showLikesError('Не удалось сохранить лайк');
    } finally {
      if (mounted) setState(() => _savingLike = false);
    }
  }

  Future<void> _edit([RoomDto? room]) async {
    if (await editRoom(context, widget.repository, room) && mounted) {
      await _bloc.refresh();
    }
  }

  @override
  void dispose() {
    _bloc.dispose();
    _likes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Переговорные')),
        actions: [
          IconButton(
            tooltip: context.tr('Обновить'),
            onPressed: _refresh,
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
              decoration: InputDecoration(
                labelText: context.tr('Название комнаты'),
                border: const OutlineInputBorder(),
              ),
              onChanged: _bloc.searchChanged,
              onSubmitted: (_) => _bloc.refresh(),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: StreamBuilder<ListState<String>>(
                  stream: _likes.states,
                  builder: (context, snapshot) {
                    final likes = snapshot.data;
                    final likedIds = likes?.items?.toSet();
                    final canConnect =
                        !_connectingLikes &&
                        (!_likes.isConfigured || likes?.failed == true);
                    return StreamBuilder<ListState<RoomDto>>(
                      stream: _bloc.states,
                      builder: (context, snapshot) {
                        final state = snapshot.data;
                        if (state?.failed == true) {
                          return RefreshableMessage(
                            child: Text(
                              context.tr(
                                'Не удалось загрузить комнаты. Проверьте сервер.',
                              ),
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
                          return RefreshableMessage(
                            child: Text(context.tr('Комнаты не найдены')),
                          );
                        }
                        return ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: rooms.length,
                          itemBuilder: (context, index) {
                            final room = rooms[index];
                            final liked = likedIds?.contains(room.id) ?? false;
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
                                '${room.location} · ${context.tr('{count} мест', {'count': room.capacity})}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: context.tr(
                                      canConnect
                                          ? 'Подключить PostgreSQL'
                                          : likedIds == null
                                          ? 'Загрузка лайков…'
                                          : liked
                                          ? 'Убрать из избранного'
                                          : 'Добавить в избранное',
                                    ),
                                    icon: Icon(
                                      liked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                    ),
                                    onPressed: _connectingLikes || _savingLike
                                        ? null
                                        : canConnect
                                        ? _connectLikes
                                        : likedIds == null
                                        ? null
                                        : () => _setLiked(room.id, !liked),
                                  ),
                                  IconButton(
                                    tooltip: context.tr('Изменить'),
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _edit(room),
                                  ),
                                  IconButton(
                                    tooltip: context.tr('Удалить'),
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
