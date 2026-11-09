import 'backend_api.dart';
import 'user_dto.dart';

abstract interface class UserRepository {
  Future<UserDto> getById(String id);
  Future<UserDto> create(UserDto value);
  Future<UserDto> update(UserDto value);
  Future<void> delete(String id);

  Future<List<UserDto>> getAll();
}

class HttpUserRepository implements UserRepository {
  HttpUserRepository({BackendApi? api}) : _api = api ?? BackendApi();

  final BackendApi _api;

  @override
  Future<List<UserDto>> getAll() async =>
      (await _api.getList('/api/users'))
          .map((item) => UserDto.fromJson(item as Map<String, dynamic>))
          .toList();

  Map<String, dynamic> _body(UserDto value) => value.toJson()..remove('id');

  @override
  Future<UserDto> getById(String id) async =>
      UserDto.fromJson(await _api.get('/api/users/${Uri.encodeComponent(id)}'));

  @override
  Future<UserDto> create(UserDto value) async =>
      UserDto.fromJson(await _api.post('/api/users', _body(value)));

  @override
  Future<UserDto> update(UserDto value) async => UserDto.fromJson(
    await _api.put('/api/users/${Uri.encodeComponent(value.id)}', _body(value)),
  );

  @override
  Future<void> delete(String id) =>
      _api.delete('/api/users/${Uri.encodeComponent(id)}');
}
