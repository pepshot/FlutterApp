import '../widgets/refreshable_message.dart';
import 'entity_editors.dart';
import '../widgets/entity_form.dart';

import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';

import '../blocs/list_bloc.dart';
import '../data/user_dto.dart';
import '../data/user_repository.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key, required this.repository});

  final UserRepository repository;

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  late final _bloc = ListBloc<UserDto>(widget.repository.getAll)..refresh();

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  Future<void> _edit([UserDto? value]) async {
    if (await editUser(context, widget.repository, value) && mounted) {
      await _bloc.refresh();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [
        IconButton(
          tooltip: context.tr('Обновить'),
          onPressed: _bloc.refresh,
          icon: const Icon(Icons.refresh),
        ),
      ],
      title: Text(context.tr('Пользователи')),
    ),
    floatingActionButton: FloatingActionButton(
      heroTag: 'addUser',
      onPressed: () => _edit(),
      child: const Icon(Icons.add),
    ),
    body: RefreshIndicator(
      onRefresh: _bloc.refresh,
      child: StreamBuilder<ListState<UserDto>>(
        stream: _bloc.states,
        builder: (context, snapshot) {
          final state = snapshot.data;
          if (state?.failed == true) {
            return RefreshableMessage(
              child: Text(context.tr('Не удалось загрузить пользователей')),
            );
          }
          final users = state?.items;
          if (users == null) {
            return const RefreshableMessage(child: CircularProgressIndicator());
          }
          if (users.isEmpty) {
            return RefreshableMessage(
              child: Text(context.tr('Пользователей нет')),
            );
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
                      tooltip: context.tr('Изменить'),
                      icon: const Icon(Icons.edit),
                      onPressed: () => _edit(user),
                    ),
                    IconButton(
                      tooltip: context.tr('Удалить'),
                      icon: const Icon(Icons.delete),
                      onPressed: () => confirmDelete(
                        context,
                        user.fullName,
                        () => widget.repository.delete(user.id),
                        _bloc.refresh,
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
