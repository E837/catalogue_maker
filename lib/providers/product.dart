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
    final propertiesAsJson = json.encode(product.properties);
    final Map<String, String> productAsMap = {
      'id': product.id,
      'properties': propertiesAsJson,
      'price': product.price.toString(),
      'alterImages': json.encode(product.alterImages),
      'mainImg': product.mainImg.path,
    };
    DBHelper.insert('product', productAsMap);
    return product;
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

  void setProdInfo(Map<String, String> props) {
    _price = double.tryParse(props['price']!) ?? 0;
    final keys = _properties.keys.toList();
    for (String key in keys) {
      _properties[key] = props[key] ?? '';
    }
    notifyListeners();
    // print(props.runtimeType);
    // print(props);
    // final _json = json.encode(props);
    // print(_json.runtimeType);
    // print(_json);
    // final decoded = json.decode(_json);
    // print(decoded.runtimeType);
    // print(decoded);
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
