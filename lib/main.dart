
import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const GrowDayApp());
}

// TASK CLASS
class TodoTask {
  String title;
  DateTime dueDate;
  bool isCompleted;

  TodoTask({
    required this.title,
    required this.dueDate,
    this.isCompleted = false,
  });
}

// MAIN APP
class GrowDayApp extends StatelessWidget {
  const GrowDayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GrowDay',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF14251C),
        useMaterial3: true,
      ),
      home: const TodoHomePage(),
    );
  }
}

// HOME PAGE
class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  List<TodoTask> tasks = [];

  late Timer refreshTimer;

  @override
  void initState() {
    super.initState();

    // Refresh overdue status regularly
    refreshTimer = Timer.periodic(
      const Duration(minutes: 1),
      (timer) {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    refreshTimer.cancel();
    super.dispose();
  }

  // COUNT COMPLETED TASKS
  int get completedTasks {
    return tasks.where((task) => task.isCompleted).length;
  }

  // COUNT OVERDUE TASKS
  int get overdueTasks {
    return tasks.where((task) {
      return !task.isCompleted &&
          DateUtils.dateOnly(task.dueDate).isBefore(
            DateUtils.dateOnly(DateTime.now()),
          );
    }).length;
  }

  // CALCULATE PLANT HEALTH
  int get plantHealth {
    return (70 + completedTasks * 10 - overdueTasks * 25)
        .clamp(0, 100)
        .toInt();
  }

  // CHOOSE PLANT APPEARANCE
  String get plantEmoji {
    if (plantHealth <= 20) {
      return '🥀';
    } else if (plantHealth <= 40) {
      return '🪴';
    } else if (plantHealth <= 60) {
      return '🌱';
    } else if (plantHealth <= 80) {
      return '🌿';
    } else {
      return '🌳';
    }
  }

  String get plantMessage {
    if (plantHealth <= 20) {
      return 'Your plant needs some care!';
    } else if (plantHealth <= 40) {
      return 'Your plant could use attention.';
    } else if (plantHealth <= 60) {
      return 'Keep making progress!';
    } else if (plantHealth <= 80) {
      return 'Your plant is growing!';
    } else {
      return 'Your plant is thriving!';
    }
  }

  // ADD A NEW TASK
  Future<void> addTask() async {
    final controller = TextEditingController();
    DateTime selectedDate = DateUtils.dateOnly(DateTime.now());

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('New Task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'What do you need to do?',
                      prefixIcon: Icon(Icons.edit),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Due: selectedDate.month/{selectedDate.day}/${selectedDate.year}',
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: dialogContext,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );

                          if (picked != null) {
                            setDialogState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                        child: const Text('Change'),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      setState(() {
                        tasks.add(
                          TodoTask(
                            title: controller.text.trim(),
                            dueDate: selectedDate,
                          ),
                        );
                      });

                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('Add Task'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
  }

  // COMPLETE OR UNCOMPLETE TASK
  void toggleTask(TodoTask task, bool value) {
    setState(() {
      task.isCompleted = value;
    });
  }

  // DELETE TASK
  void deleteTask(TodoTask task) {
    setState(() {
      tasks.remove(task);
    });
  }

  // BUILD TASK CARD
  Widget buildTaskCard(TodoTask task) {
    bool isOverdue = !task.isCompleted &&
        DateUtils.dateOnly(task.dueDate).isBefore(
          DateUtils.dateOnly(DateTime.now()),
        );

    return Card(
      color: const Color(0xFF263C30),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          activeColor: Colors.green,
          onChanged: (value) {
            toggleTask(task, value ?? false);
          },
        ),

        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: task.isCompleted
                ? Colors.white54
                : Colors.white,
          ),
        ),

        subtitle: Text(
          task.isCompleted
              ? 'Completed!'
              : isOverdue
                  ? 'Overdue'
                  : 'Due: task.dueDate.month/{task.dueDate.day}/${task.dueDate.year}',
          style: TextStyle(
            color: task.isCompleted
                ? Colors.greenAccent
                : isOverdue
                    ? Colors.orangeAccent
                    : Colors.white70,
          ),
        ),

        trailing: IconButton(
          icon: const Icon(
            Icons.delete_outline,
            color: Colors.white70,
          ),
          onPressed: () => deleteTask(task),
        ),
      ),
    );
  }

  // BUILD APP SCREEN
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF14251C),
        title: const Text(
          'GrowDay 🌱',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: Column(
          children: [
            // PLANT DISPLAY
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF263C30),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    'YOUR LITTLE GARDEN',
                    style: TextStyle(
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    plantEmoji,
                    style: const TextStyle(fontSize: 90),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    plantMessage,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // PLANT HEALTH BAR
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Plant Health'),
                      Text('$plantHealth%'),
                    ],
                  ),

                  const SizedBox(height: 8),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: plantHealth / 100,
                      minHeight: 12,
                      backgroundColor: Colors.black26,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(
                        Colors.greenAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // TASK STATISTICS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: statCard(
                      'Total Tasks',
                      '${tasks.length}',
                      Icons.list_alt,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: statCard(
                      'Completed',
                      '$completedTasks',
                      Icons.check_circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: statCard(
                      'Overdue',
                      '$overdueTasks',
                      Icons.schedule,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // TASK LIST TITLE
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'My Tasks',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // TASK LIST
            Expanded(
              child: tasks.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '🌷',
                            style: TextStyle(fontSize: 55),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'No tasks yet!',
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            'Add a task to start growing.',
                            style: TextStyle(
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        return buildTaskCard(tasks[index]);
                      },
                    ),
            ),
          ],
        ),
      ),

      // ADD TASK BUTTON
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addTask,
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  // STATISTICS CARD
  Widget statCard(String title, String number, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF263C30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.greenAccent),
          const SizedBox(height: 6),
          Text(
            number,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }
}


