import 'package:flutter/material.dart';

class EntityField {
  const EntityField(
    this.key,
    this.label, {
    this.required = true,
    this.maxLength,
    this.number = false,
  });
  final String key;
  final String label;
  final bool required;
  final int? maxLength;
  final bool number;
}

Future<bool> showEntityForm(
  BuildContext context, {
  required String title,
  required List<EntityField> fields,
  required Map<String, dynamic> initial,
  required Future<void> Function(Map<String, dynamic>) save,
  Future<Map<String, Map<String, String>>> Function()? loadOptions,
  String? Function(Map<String, dynamic>)? validate,
}) async =>
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _EntityForm(
        title: title,
        fields: fields,
        initial: initial,
        save: save,
        validate: validate,
        loadOptions: loadOptions,
      ),
    ) ??
    false;

class _EntityForm extends StatefulWidget {
  const _EntityForm({
    required this.title,
    required this.fields,
    required this.initial,
    required this.save,
    this.validate,
    this.loadOptions,
  });
  final Future<Map<String, Map<String, String>>> Function()? loadOptions;
  final String title;
  final List<EntityField> fields;
  final Map<String, dynamic> initial;
  final Future<void> Function(Map<String, dynamic>) save;
  final String? Function(Map<String, dynamic>)? validate;
  @override
  State<_EntityForm> createState() => _EntityFormState();
}

class _EntityFormState extends State<_EntityForm> {
  final _form = GlobalKey<FormState>();
  late final _controllers = {
    for (final field in widget.fields)
      field.key: TextEditingController(
        text: widget.initial[field.key]?.toString() ?? '',
      ),
  };
  Map<String, Map<String, String>> _options = {};
  bool _loadingOptions = false;
  String? _optionsError;

  @override
  void initState() {
    super.initState();
    if (widget.loadOptions != null) _loadOptions();
  }

  Future<void> _loadOptions() async {
    setState(() {
      _loadingOptions = true;
      _optionsError = null;
    });
    try {
      final options = await widget.loadOptions!();
      if (!mounted) return;
      setState(() => _options = options);
    } catch (_) {
      if (mounted) {
        setState(
          () => _optionsError =
              'Не удалось загрузить пользователей и переговорные',
        );
      }
    } finally {
      if (mounted) setState(() => _loadingOptions = false);
    }
  }

  bool get _optionsReady =>
      !_loadingOptions &&
      _optionsError == null &&
      (widget.loadOptions == null ||
          (_options.isNotEmpty &&
              _options.values.every((items) => items.isNotEmpty)));

  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_optionsReady || !_form.currentState!.validate()) return;
    final data = Map<String, dynamic>.from(widget.initial);
    for (final field in widget.fields) {
      final text = _controllers[field.key]!.text.trim();
      data[field.key] = text.isEmpty
          ? null
          : field.number
          ? int.parse(text)
          : text;
    }
    final error = widget.validate?.call(data);
    setState(() => _error = error);
    if (error != null) return;
    setState(() => _saving = true);
    try {
      await widget.save(data);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = 'Не удалось сохранить: $error';
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_loadingOptions) const LinearProgressIndicator(),
                if (_optionsError != null) ...[
                  Text(_optionsError!),
                  TextButton(
                    onPressed: _loadOptions,
                    child: const Text('Повторить'),
                  ),
                ],
                if (!_loadingOptions && _optionsError == null && !_optionsReady)
                  const Text(
                    'Для создания встречи добавьте пользователя и переговорную.',
                  ),
                for (final field in widget.fields)
                  if (_options.containsKey(field.key))
                    DropdownButtonFormField<String>(
                      key: ValueKey(field.key),
                      initialValue:
                          _options[field.key]!.containsKey(
                            _controllers[field.key]!.text,
                          )
                          ? _controllers[field.key]!.text
                          : null,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: field.label),
                      items: [
                        for (final item in _options[field.key]!.entries)
                          DropdownMenuItem(
                            value: item.key,
                            child: Text(
                              item.value,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: _saving
                          ? null
                          : (value) =>
                                _controllers[field.key]!.text = value ?? '',
                      validator: (value) =>
                          value == null ? 'Выберите из списка' : null,
                    )
                  else if (widget.loadOptions == null ||
                      (field.key != 'roomId' && field.key != 'userId'))
                    TextFormField(
                      controller: _controllers[field.key],
                      enabled: !_saving,
                      decoration: InputDecoration(labelText: field.label),
                      maxLength: field.maxLength,
                      keyboardType: field.number
                          ? TextInputType.number
                          : TextInputType.text,
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) {
                          return field.required ? 'Заполните поле' : null;
                        }
                        if (field.number &&
                            (int.tryParse(text) == null ||
                                int.parse(text) < 1)) {
                          return 'Введите целое число от 1';
                        }
                        if (field.key == 'email' &&
                            !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                .hasMatch(text)) {
                          return 'Введите корректный email';
                        }
                        return null;
                      },
                    ),
                if (_error != null)
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: _saving || !_optionsReady ? null : _save,
          child: Text(_saving ? 'Сохранение…' : 'Сохранить'),
        ),
      ],
    ),
  );
}

Future<void> confirmDelete(
  BuildContext context,
  String name,
  Future<void> Function() remove,
  VoidCallback reload,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Удаление'),
      content: Text('Удалить «$name»?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Удалить'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  try {
    await remove();
    if (context.mounted) reload();
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Не удалось удалить: $error')));
    }
  }
}
