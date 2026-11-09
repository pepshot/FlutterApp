import '../widgets/refreshable_message.dart';
import 'entity_editors.dart';
import '../widgets/entity_form.dart';

import 'package:flutter/material.dart';

import '../data/user_dto.dart';
import '../data/user_repository.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key, required this.repository});

  final UserRepository repository;

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  late Future<List<UserDto>> _users = widget.repository.getAll();

  Future<void> _reload() async {
    final request = widget.repository.getAll();
    setState(() {
      _users = request;
    });
    try {
      await request;
    } catch (_) {
      // FutureBuilder displays the error and allows another swipe to retry.
    }
  }

  Future<void> _edit([UserDto? value]) async {
    if (await editUser(context, widget.repository, value) && mounted) _reload();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [
        IconButton(
          tooltip: 'Обновить',
          onPressed: _reload,
          icon: const Icon(Icons.refresh),
        ),
      ],
      title: const Text('Пользователи'),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => _edit(),
      child: const Icon(Icons.add),
    ),
    body: RefreshIndicator(
      onRefresh: _reload,
      child: FutureBuilder<List<UserDto>>(
        future: _users,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const RefreshableMessage(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const RefreshableMessage(
              child: Text('Не удалось загрузить пользователей'),
            );
          }
          final users = snapshot.data!;
          if (users.isEmpty) {
            return const RefreshableMessage(child: Text('Пользователей нет'));
          }
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                onTap: () => _edit(user),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Изменить',
                      icon: const Icon(Icons.edit),
                      onPressed: () => _edit(user),
                    ),
                    IconButton(
                      tooltip: 'Удалить',
                      icon: const Icon(Icons.delete),
                      onPressed: () => confirmDelete(
                        context,
                        user.fullName,
                        () => widget.repository.delete(user.id),
                        _reload,
                      ),
                    ),
                  ],
                ),
                title: Text(user.fullName),
                subtitle: Text(
                  user.department?.isNotEmpty == true
                      ? '${user.email} · ${user.department}'
                      : user.email,
                ),
              );
            },
          );
        },
      ),
    ),
  );
}
