import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'task_model.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}
class _TaskListScreenState extends State<TaskListScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  String selectedDay = 'Monday'; 
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    _db.collection('tasks').orderBy('day').orderBy('time').snapshots().listen((snapshot) {
      setState(() {
        _tasks = snapshot.docs.map((doc) => Task.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)).toList();
      });
    });
  }

  void _showAddTaskDialog() {
  String _newTaskDay = selectedDay; 

  showDialog(
    context: context,
    builder: (BuildContext context) {
     
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Color(0xFFD9CAB3),
            title: Text('Add New Task', style: TextStyle(color: Color(0xFF2E4A2F))),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: _taskNameController,
                    decoration: InputDecoration(labelText: 'Task Name'),
                  ),
                  TextField(
                    controller: _timeController,
                    decoration: InputDecoration(labelText: 'Time (e.g., 10 AM)'),
                  ),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _newTaskDay,
                    onChanged: (String? newValue) {
                     
                      setState(() {
                        _newTaskDay = newValue!;
                      });
                    },
                    items: <String>['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  _taskNameController.clear();
                  _timeController.clear();
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Add', style: TextStyle(color: Color(0xFF2E4A2F))),
                onPressed: () {
                  if (_taskNameController.text.isNotEmpty && _timeController.text.isNotEmpty) {
                    _addTask(_taskNameController.text, _newTaskDay, _timeController.text);
                    _taskNameController.clear();
                    _timeController.clear();
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        },
      );
    },
  );
}


  void _addTask(String name, String day, String time) {
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      isCompleted: false,
      day: day,
      time: time,
    );
    _db.collection('tasks').add(newTask.toMap()).then((_) {
      setState(() {
        _tasks.add(newTask);
      });
    });
  }

    @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF2E4A2F),
          title: Text('Weekly Tasks', style: TextStyle(color: Color(0xFFD9CAB3))),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.exit_to_app, color: Color(0xFFD9CAB3)),
              onPressed: () async {
                Navigator.pushReplacementNamed(context, '/login'); 
              },
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Color(0xFFD9CAB3),
            labelColor: Color(0xFFD9CAB3),
            unselectedLabelColor: Colors.white70,
            tabs: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
                .map((day) => Tab(text: day))
                .toList(),
          ),
        ),
        body: TabBarView(
          children: [
            for (var day in ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'])
              _buildTasksForDay(day),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddTaskDialog,
          backgroundColor: Color(0xFF2E4A2F),
          child: Icon(Icons.add, color: Color(0xFFD9CAB3)),
        ),
      ),
    );
  }

  Widget _buildTasksForDay(String day) {
    List<Task> tasksForDay = _tasks.where((task) => task.day == day).toList();
    return tasksForDay.isEmpty
        ? Center(child: Text('No tasks for $day', style: TextStyle(color: Colors.white)))
        : ListView.builder(
            itemCount: tasksForDay.length,
            itemBuilder: (context, index) {
              final task = tasksForDay[index];
              return Card(
                color: Color(0xFFD9CAB3),
                child: ListTile(
                  title: Text(task.name, style: TextStyle(color: Color(0xFF2E4A2F))),
                  subtitle: Text('Time: ${task.time}', style: TextStyle(color: Color(0xFF2E4A2F).withOpacity(0.7))),
                  leading: Checkbox(
                    value: task.isCompleted,
                    onChanged: (bool? newValue) {
                      _toggleTaskCompletion(task, newValue!);
                    },
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red[400]),
                    onPressed: () => _deleteTask(task),
                  ),
                ),
              );
            },
          );
  }

  void _toggleTaskCompletion(Task task, bool isCompleted) {
    _db.collection('tasks').doc(task.id).update({'isCompleted': isCompleted});
    int index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      setState(() {
        _tasks[index].isCompleted = isCompleted;
      });
    }
  }

  void _deleteTask(Task task) {
    _db.collection('tasks').doc(task.id).delete();
    setState(() {
      _tasks.removeWhere((t) => t.id == task.id);
    });
  }
}
