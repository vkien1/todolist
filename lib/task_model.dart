class Task {
  String id;
  String name;
  bool isCompleted;
  String day; 
  String time; 

  Task({
    required this.id,
    required this.name,
    this.isCompleted = false,
    required this.day, 
    required this.time, 
  });

  factory Task.fromFirestore(Map<String, dynamic> firestore, String id) {
    return Task(
      id: id,
      name: firestore['name'] as String,
      isCompleted: firestore['isCompleted'] as bool? ?? false,
      day: firestore['day'] as String, 
      time: firestore['time'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isCompleted': isCompleted,
      'day': day, 
      'time': time, 
    };
  }
}
