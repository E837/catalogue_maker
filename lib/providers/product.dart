import 'dart:io';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

import '../helpers/db_helper.dart';

//todo: specify a status percent for every product so we can calculate the status of the project by this formula => sum of prods stat / prodsCount*100
class Product with ChangeNotifier {
  final String _id;
  Map<String, String> _properties;
  double _price;
  List<File> _alterImages;
  File _mainImg;

  Product({
    required String id,
    required Map<String, String> properties,
    required double price,
    required List<File> alterImages,
    required File mainImg,
  })  : _id = id,
        _properties = properties,
        _price = price,
        _alterImages = alterImages,
        _mainImg = mainImg;

  static Product emptyProduct(List<String> keys) {
    final product = Product(
      id: const Uuid().v1(),
      properties: {for (var k in keys) k: ''},
      price: 0.0,
      alterImages: [],
      mainImg: File(''),
    );
    // inserting the new product into sqlite DB
    DBHelper.insert('product', productAsMap(product));
    return product;
  }

  static Map<String, String> productAsMap(Product product) {
    final propertiesAsJson = json.encode(product.properties);
    final alterImagesPaths = product.alterImages.map((e) => e.path).toList();
    return {
      'id': product.id,
      'properties': propertiesAsJson,
      'price': product.price.toString(),
      'alterImages': json.encode(alterImagesPaths),
      'mainImg': product.mainImg.path,
    };
  }

  String get id {
    return _id;
  }

  Map<String, String> get properties {
    return Map.unmodifiable(_properties);
  }

  double get price {
    return _price;
  }

  List<File> get alterImages {
    return List.unmodifiable(_alterImages);
  }

  File get mainImg {
    return _mainImg;
  }

  Future<void> setProdInfo(Map<String, String> props) async {
    _price = double.tryParse(props['price']!) ?? 0;
    final keys = _properties.keys.toList();
    for (String key in keys) {
      _properties[key] = props[key] ?? '';
    }
    notifyListeners();
    await DBHelper.update('product', productAsMap(this), _id);
  }

  void addAlterImage(File file) {
    _alterImages.add(file);
    notifyListeners();
  }

  void removeAlterImage(int index) {
    _alterImages.removeAt(index);
    notifyListeners();
  }

  set mainImg(File value) {
    _mainImg = value;
    notifyListeners();
  }
}
