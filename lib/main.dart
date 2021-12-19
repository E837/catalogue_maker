import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/projects_overview_screen.dart';
import './providers/project.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Projects>(create: (ctx) => Projects()),
      ],
      child: MaterialApp(
        title: 'Catalogue Maker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
        ),
        home: ProjectsOverviewScreen(),
      ),
    );
  }
}
