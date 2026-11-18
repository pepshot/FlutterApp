import 'dart:io';

import 'package:postgres/postgres.dart';

class RoomLikesRepository {
  String? _password;

  bool get isConfigured => _password != null;

  void setPassword(String password) => _password = password;

  Future<List<String>> getAll() => _withConnection((connection) async {
    final rows = await connection.execute('SELECT room_id FROM room_likes');
    return rows.map((row) => row[0] as String).toList();
  });

  Future<void> setLiked(String roomId, bool liked) => _withConnection((
    connection,
  ) async {
    final statement = liked
        ? 'INSERT INTO room_likes (room_id) VALUES (@id) ON CONFLICT DO NOTHING'
        : 'DELETE FROM room_likes WHERE room_id = @id';
    await connection.execute(Sql.named(statement), parameters: {'id': roomId});
  });

  Future<T> _withConnection<T>(Future<T> Function(Connection) action) async {
    const host = String.fromEnvironment('LIKES_DB_HOST');
    const username = String.fromEnvironment(
      'LIKES_DB_USER',
      defaultValue: 'meetspace_likes_app',
    );
    final password = _password;
    if (password == null) {
      throw StateError('Enter the PostgreSQL password in the app');
    }
    final connection = await Connection.open(
      Endpoint(
        host: host.isNotEmpty
            ? host
            : (Platform.isAndroid ? '10.0.2.2' : '127.0.0.1'),
        port: const int.fromEnvironment('LIKES_DB_PORT', defaultValue: 5432),
        database: 'meetspace_likes',
        username: username,
        password: password,
      ),
      settings: const ConnectionSettings(
        sslMode: SslMode.disable,
        connectTimeout: Duration(seconds: 5),
        queryTimeout: Duration(seconds: 5),
      ),
    );
    try {
      return await action(connection);
    } finally {
      await connection.close();
    }
  }
}
