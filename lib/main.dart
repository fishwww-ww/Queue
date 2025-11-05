import 'package:flutter/material.dart';
import 'pages/case/index.dart';
import 'pages/todo/index.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/case',
      routes: {
        '/case': (context) => const CasePage(),
        '/todo': (context) => const TodoPage(),
      },
    );
  }
}

