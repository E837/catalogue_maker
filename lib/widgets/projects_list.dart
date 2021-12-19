import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/project.dart';
import '../widgets/project_item.dart';

class ProjectsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final projects = Provider.of<Projects>(context).projects;
    return ListView.builder(
      itemCount: projects.length,
      itemBuilder: (ctx, i) => ChangeNotifierProvider<Project>.value(
        value: projects[i],
        child: ProjectItem(),
      ),
    );
  }
}
