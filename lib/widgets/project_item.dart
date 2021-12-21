import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/project.dart';
import '../providers/product.dart';
import '../screens/products_overview_screen.dart';

class ProjectItem extends StatelessWidget {
  List<Widget> _setImages(Project project) {
    final List<Widget> _result = [];
    final prodCount = project.products.length;
    for (int i = 0; i < prodCount && i < 3; i++) {
      _result.add(project.products[i].mainImg.path == ''
          ? Image.asset('assets/images/empty.jpg')
          : Image.file(project.products[i].mainImg));
    }
    return _result;
  }

  @override
  Widget build(BuildContext context) {
    final project = Provider.of<Project>(context);
    // Provider.of<Product>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Dismissible(
        key: ValueKey(project.id),
        background: Card(
          color: Theme.of(context).errorColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Icon(Icons.delete),
                Icon(Icons.delete),
              ],
            ),
          ),
        ),
        onDismissed: (direction) {
          Provider.of<Projects>(context, listen: false)
              .removeProject(project.id);
        },
        child: Card(
          child: ListTile(
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: _setImages(project),
            ),
            trailing: Text(DateFormat.yMd().format(project.creationDate)),
            // here we are providing "project" again to handle provider page scoping
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => ChangeNotifierProvider<Project>.value(
                  value: project,
                  child: ProductsOverviewScreen(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
