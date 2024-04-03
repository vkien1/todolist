import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:todolist/firebase_options.dart';
import 'login_screen.dart';
import 'task_list_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); 
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Define the initial route
      initialRoute: '/',
      // Map the routes with the corresponding widgets
      routes: {
        '/': (context) => LoginScreen(), 
        '/homepage': (context) => TaskListScreen(), 
        '/login': (context) => LoginScreen(),
      },
    );
  }
}
