import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/project.dart';
import '../providers/product.dart';
import '../widgets/product_item.dart';

class ProductsList extends StatelessWidget {
  final Project _project;

  ProductsList(this._project);

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      interactive: true,
      thickness: 15,
      radius: const Radius.circular(10),
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        itemCount: _project.products.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 150,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2 / 3,
        ),
        itemBuilder: (ctx, i) => ChangeNotifierProvider<Product>.value(
          value: _project.products[i],
          child: ProductItem(),
        ),
      ),
    );
  }
}
