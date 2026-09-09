import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// Enum: возможные состояния задачи.
enum TaskStatus { pending, completed }

// Extension: добавляем подпись к состоянию.
extension TaskStatusLabel on TaskStatus {
  String get label => switch (this) {
    TaskStatus.pending => 'В процессе',
    TaskStatus.completed => 'Выполнено',
  };
}

// Класс с полями и методом изменения состояния.
class Task {
  Task(this.title, {this.status = TaskStatus.pending});

  final String title;
  TaskStatus status;

  void toggle() {
    status = status == TaskStatus.pending
        ? TaskStatus.completed
        : TaskStatus.pending;
  }
}

class TaskRepository {
  // Синхронно возвращаем типизированный список задач (Generics).
  List<Task> loadTasks() {
    return <Task>[
      Task('Изучить классы и enum'),
      Task('Попрактиковаться с циклами и List'),
      Task('Разобраться с extension'),
    ];
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Учебные задачи',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TaskRepository _repository = TaskRepository();
  late final List<Task> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = _repository.loadTasks();
  }

  int _countCompleted(List<Task> tasks) {
    int count = 0;
    // Loop: перебираем задачи и подсчитываем выполненные.
    for (final task in tasks) {
      if (task.status == TaskStatus.completed) {
        count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Князькин Александр, ПИбд-31'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Выполнено: ${_countCompleted(_tasks)} из ${_tasks.length}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              // Анонимная функция строит строку списка.
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return CheckboxListTile(
                  title: Text(task.title),
                  subtitle: Text(task.status.label),
                  value: task.status == TaskStatus.completed,
                  onChanged: (_) {
                    setState(() => task.toggle());
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
