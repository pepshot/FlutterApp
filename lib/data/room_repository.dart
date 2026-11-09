import 'backend_api.dart';
import 'room_dto.dart';

abstract interface class RoomRepository {
  Future<RoomDto> getById(String id);
  Future<RoomDto> create(RoomDto value);
  Future<RoomDto> update(RoomDto value);
  Future<void> delete(String id);

  Future<List<RoomDto>> search(String query);
}

class HttpRoomRepository implements RoomRepository {
  HttpRoomRepository({BackendApi? api}) : _api = api ?? BackendApi();

  final BackendApi _api;

  @override
  Future<List<RoomDto>> search(String query) async {
    final term = query.trim();
    final items = await _api.getList(
      '/api/rooms',
      query: term.isEmpty ? null : {'search': term},
    );
    final rooms = items
        .map((item) => RoomDto.fromJson(item as Map<String, dynamic>))
        .toList();
    // Текущий бэкенд игнорирует ?search=.
    return term.isEmpty
        ? rooms
        : rooms
              .where(
                (room) => room.name.toLowerCase().contains(term.toLowerCase()),
              )
              .toList();
  }

  Map<String, dynamic> _body(RoomDto value) => value.toJson()..remove('id');

  @override
  Future<RoomDto> getById(String id) async =>
      RoomDto.fromJson(await _api.get('/api/rooms/${Uri.encodeComponent(id)}'));

  @override
  Future<RoomDto> create(RoomDto value) async =>
      RoomDto.fromJson(await _api.post('/api/rooms', _body(value)));

  @override
  Future<RoomDto> update(RoomDto value) async => RoomDto.fromJson(
    await _api.put('/api/rooms/${Uri.encodeComponent(value.id)}', _body(value)),
  );

  @override
  Future<void> delete(String id) =>
      _api.delete('/api/rooms/${Uri.encodeComponent(id)}');
}
