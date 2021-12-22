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
    DBHelper.delete('product', id);
    DBHelper.update('project', Projects.projectAsMap(this), _id);
  }

  File get logoImage => _logoImage;

  String get description => _description;

  Future<void> saveProjectSettings(File image, String description) async {
    _logoImage = image;
    _description = description;
    notifyListeners();
    await DBHelper.update('project', Projects.projectAsMap(this), _id);
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
    updateMethod == UpdateMethod.insert
        ? DBHelper.insert('project', projectAsMap(project))
        : DBHelper.update('project', projectAsMap(project), project.id);
  }

  static Map<String, String> projectAsMap(Project project) {
    final propertiesAsJson = json.encode(project.properties);
    final productsIdsAsList = project.products.map((e) => e.id).toList();
    final productsIdsAsJson = json.encode(productsIdsAsList);
    return {
      'id': project.id,
      'products': productsIdsAsJson,
      'properties': propertiesAsJson,
      'status': project.status.toString(),
      'creationDate': project.creationDate.toIso8601String(),
      'logoImage': project.logoImage.path,
      'description': project.description,
    };
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
        alterImages: (List<String>.from(
                json.decode(thisMapProduct['alterImages'] ?? '[]')))
            .map((e) => File(e))
            .toList(),
        mainImg: File(thisMapProduct['mainImg'] ?? ''),
      ));
    }
    // print('--------- setting products done ---------');
    return result;
  }

  void removeProject(String id) {
    // finding products of the project before deleting the project
    final _thisProject = _projects.firstWhere((element) => element.id == id);
    final _productIds =
        _thisProject.products.map((product) => product.id).toList();
    // updating the provider and the UI
    _projects.removeWhere((element) => element.id == id);
    notifyListeners();
    // deleting the products of the project from sqlite
    for (String productId in _productIds) {
      DBHelper.delete('product', productId);
    }
    // deleting the project itself from sqlite
    DBHelper.delete('project', id);
  }
}
