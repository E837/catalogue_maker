import 'dart:io';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

import 'product.dart';
import '../helpers/db_helper.dart';

class Project with ChangeNotifier {
  final String _id;
  final List<Product> _products;
  final List<String> _properties;
  double _status; // todo: use this arg
  final DateTime _creationDate;
  File _logoImage;
  String _description;

  Project({
    required String id,
    required int productsCount,
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
  final List<Project> _projects = [];

  List<Project> get projects {
    return List.unmodifiable(_projects);
  }

  void addEmptyProject(int prodsCount, List<String> properties) {
    _projects.add(
      Project(
        id: const Uuid().v1(),
        productsCount: prodsCount,
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
  }

  void removeProject() {
    //todo: implement remove functionality for a project
  }
}
