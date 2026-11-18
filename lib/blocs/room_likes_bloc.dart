import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../data/room_likes_repository.dart';
import 'list_bloc.dart';

class RoomLikesBloc extends ListBloc<String> {
  RoomLikesBloc(this._repository) : super(_repository.getAll);

  final RoomLikesRepository _repository;
  static const _storage = FlutterSecureStorage();
  static const _passwordKey = 'room_likes_db_password';

  bool get isConfigured => _repository.isConfigured;

  Future<void> restoreConnection() async {
    final String? password;
    try {
      password = await _storage.read(key: _passwordKey);
    } on Exception {
      return;
    }
    if (password == null || password.isEmpty) return;
    _repository.setPassword(password);
    await refresh();
  }

  Future<bool> connect(String password) async {
    _repository.setPassword(password);
    if (!await refresh()) return false;
    await _storage.write(key: _passwordKey, value: password);
    return true;
  }

  Future<void> setLiked(String roomId, bool liked) async {
    await _repository.setLiked(roomId, liked);
    await refresh();
  }
}
