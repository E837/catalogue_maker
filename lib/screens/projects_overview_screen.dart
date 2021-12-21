import 'package:flutter/material.dart';

import '../widgets/new_project.dart';
import '../widgets/projects_list.dart';

class ProjectsOverviewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects List'),
        actions: [
          IconButton(
              onPressed: () => showModalBottomSheet(
                    context: context,
                    builder: (_) => NewProject(),
                  ),
              icon: const Icon(Icons.add)),
        ],
      ),
      body: ProjectsList(),
    );
  }
}
