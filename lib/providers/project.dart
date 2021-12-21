import 'dart:io';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

import 'product.dart';
import '../helpers/db_helper.dart';

enum UpdateMethod {
  insert,
  update,
}

class Project with ChangeNotifier {
  final String _id;
  List<Product> _products;
  final List<String> _properties;
  double _status; // todo: use this arg
  final DateTime _creationDate;
  File _logoImage;
  String _description;

  Project({
    required String id,
    required List<Product> products,
    required List<String> properties,
    required double status,
    required DateTime creationDate,
    required File logoImage,
    required String description,
  })  : _id = id,
        _products = products,
        _properties = properties,
        _status = status,
        _creationDate = creationDate,
        _logoImage = logoImage,
        _description = description;

  String get id => _id;

  List<Product> get products => List.unmodifiable(_products);

  set products(List<Product> value) {
    _products = value;
    notifyListeners();
  }

  List<String> get properties => _properties;

  double get status => _status;

  DateTime get creationDate => _creationDate;

  void addEmptyProduct(List<String> properties) {
    final emptyProduct = Product.emptyProduct(properties);
    _products.add(emptyProduct);
    notifyListeners();
    Projects._updateSqlite(this, UpdateMethod.update);
  }

  void removeProduct(String id) {
    _products.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  File get logoImage => _logoImage;

  set logoImage(File value) {
    _logoImage = value;
    notifyListeners();
  }

  String get description => _description;

  set description(String value) {
    _description = value;
    notifyListeners();
  }

  void changeThumbs() {
    notifyListeners();
  }
}

class Projects with ChangeNotifier {
  List<Project> _projects = [];

  List<Project> get projects {
    return List.unmodifiable(_projects);
  }

  void addEmptyProject(int prodsCount, List<String> properties) {
    _projects.add(
      Project(
        id: const Uuid().v1(),
        products: List<Product>.generate(
            prodsCount, (int index) => Product.emptyProduct(properties)),
        properties: properties,
        status: 0,
        creationDate: DateTime.now(),
        logoImage: File(''),
        description: '',
      ),
    );
    notifyListeners();
    _updateSqlite(_projects.last, UpdateMethod.insert);
  }

  static void _updateSqlite(Project project, UpdateMethod updateMethod) {
    // inserting the new project into sqlite DB
    //todo: this re-writing the whole database is not efficient at all since we are doing this with every single product changing, so we should only update one item
    final propertiesAsJson = json.encode(project.properties);
    final productsIdsAsList = project.products.map((e) => e.id).toList();
    final productsIdsAsJson = json.encode(productsIdsAsList);
    final Map<String, String> projectAsMap = {
      'id': project.id,
      'products': productsIdsAsJson,
      'properties': propertiesAsJson,
      'status': project.status.toString(),
      'creationDate': project.creationDate.toIso8601String(),
      'logoImage': project.logoImage.path,
      'description': project.description,
    };
    updateMethod == UpdateMethod.insert
        ? DBHelper.insert('project', projectAsMap)
        : DBHelper.update('project', projectAsMap);
  }

  Future<void> fetchAndSetData() async {
    final dbProjectsData = await DBHelper.getData('project');
    final dbProductsData = await DBHelper.getData('product');
    _projects = [];
    for (Map<String, String> item in dbProjectsData) {
      _projects.add(Project(
        id: item['id'] ?? '',
        products: _setProducts(dbProductsData,
            List<String>.from(json.decode(item['products'] ?? ''))),
        properties: List<String>.from(json.decode(item['properties'] ?? '')),
        status: double.parse(item['status'] ?? ''),
        creationDate: DateTime.parse(item['creationDate'] ?? ''),
        logoImage: File(item['logoImage'] ?? ''),
        description: item['description'] as String,
      ));
    }
    // print('--------- fetching method done ---------');
    notifyListeners();
  }

  List<Product> _setProducts(
      List<Map<String, String>> dbData, List<String> ids) {
    List<Product> result = [];
    for (String id in ids) {
      final thisMapProduct =
          dbData.firstWhere((element) => element['id'] == id);
      result.add(Product(
        id: thisMapProduct['id'] ?? '',
        properties: Map<String, String>.from(
            json.decode(thisMapProduct['properties'] ?? '{"": ""}')),
        price: double.parse(thisMapProduct['price'] ?? '0'),
        alterImages:
            List<File>.from(json.decode(thisMapProduct['alterImages'] ?? '[]')),
        mainImg: File(thisMapProduct['mainImg'] ?? ''),
      ));
    }
    // print('--------- setting products done ---------');
    return result;
  }

  void removeProject(String id) {
    _projects.removeWhere((element) => element.id == id);
    notifyListeners();
    // deleting the project from sqlite
    DBHelper.delete('project', id);
  }
}
