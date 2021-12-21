import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/project.dart';
import '../widgets/project_item.dart';

class ProjectsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<Projects>(context, listen: false).fetchAndSetData(),
      builder: (ctx, snapshot) => snapshot.connectionState ==
              ConnectionState.done
          ? Consumer<Projects>(
              builder: (ctx, projectsData, child) => ListView.builder(
                itemCount: projectsData.projects.length,
                itemBuilder: (ctx, i) => ChangeNotifierProvider<Project>.value(
                  value: projectsData.projects[i],
                  child: ProjectItem(),
                ),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
