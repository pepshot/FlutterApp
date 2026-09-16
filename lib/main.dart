import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

enum TaskStatus { pending, completed }

extension TaskStatusLabel on TaskStatus {
  String get label => switch (this) {
    TaskStatus.pending => 'В процессе',
    TaskStatus.completed => 'Выполнено',
  };
}

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
  List<Task> loadTasks() {
    return <Task>[
      Task('Python'),
      Task('Pascal'),
      Task('Dart'),
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
