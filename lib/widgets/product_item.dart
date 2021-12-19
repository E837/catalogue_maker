import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/project.dart';
import '../screens/edit_product_screen.dart';

class ProductItem extends StatelessWidget {
  List<Widget> setAlterImages(Product product) {
    final List<Widget> result = [];
    for (int i = 0; i < product.alterImages.length && i < 2; i++) {
      result.add(
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              image: DecorationImage(
                image: FileImage(product.alterImages[i]),
                fit: BoxFit.cover,
              )),
          margin: const EdgeInsets.all(3),
        ),
      );
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context);
    return Card(
      child: Column(
        children: [
          Expanded(
            child: InkWell(
              child: Hero(
                tag: product.id,
                child: product.mainImg.path == ''
                    ? Image.asset(
                        'assets/images/empty.jpg',
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        product.mainImg,
                        fit: BoxFit.cover,
                      ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => ChangeNotifierProvider.value(
                      value: product,
                      child: EditProductScreen(),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            height: 40,
            color: Colors.black.withOpacity(0.3),
            child: Row(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: setAlterImages(product),
                ),
                Expanded(
                  child: IconButton(
                    onPressed: () {
                      Provider.of<Project>(context, listen: false)
                          .removeProduct(product.id);
                    },
                    icon: Icon(
                      Icons.delete,
                      color: Theme.of(context).shadowColor.withOpacity(0.5),
                      size: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
