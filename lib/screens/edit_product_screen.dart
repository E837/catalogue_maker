import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/product.dart';

enum SourceType {
  camera,
  gallery,
}

enum ImageType {
  main,
  alternative,
}

class EditProductScreen extends StatelessWidget {
  final _form = GlobalKey<FormState>();
  final Map<String, String> _userInput = {};

  Widget showAlterImages(BuildContext context, Product product) {
    return SizedBox(
      height: 110,
      child: product.alterImages.isNotEmpty
          ? GridView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: product.alterImages.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 150,
                childAspectRatio: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (ctx, i) => Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.circular(50),
                      image: DecorationImage(
                        image: FileImage(product.alterImages[i]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: InkWell(
                      onTap: () {
                        product.removeAlterImage(i);
                      },
                      child: Icon(
                        Icons.clear,
                        color: Theme.of(context).errorColor,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const Text('\n\nNo images yet'),
    );
  }

  Future<void> getPhoto(
      Product product, SourceType sourceType, ImageType imageType) async {
    final image = await ImagePicker().pickImage(
      source: sourceType == SourceType.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      maxWidth: 500,
      maxHeight: 500,
    );
    final imageFile = File(image?.path ?? '');
    if (imageFile.path != '') {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = basename(imageFile.path);
      final savedImage = await imageFile.copy('${appDir.path}/$fileName');
      if (imageType == ImageType.main) {
        product.mainImg = savedImage;
      } else {
        product.addAlterImage(savedImage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _product = Provider.of<Product>(context);
    final _keys = _product.properties.keys.toList();
    final _values = _product.properties.values.toList();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(Icons.arrow_back),
                elevation: 0,
              ),
            ),
            iconTheme: IconThemeData(
              color: Theme.of(context)
                  .colorScheme
                  .primary, //change your color here
            ),
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Positioned.fill(
                    child: Hero(
                      tag: _product.id,
                      child: _product.mainImg.path == ''
                          ? Image.asset(
                              'assets/images/empty.jpg',
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              _product.mainImg,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            getPhoto(
                                _product, SourceType.gallery, ImageType.main);
                          },
                          child: const Icon(Icons.collections),
                        ),
                        const SizedBox(width: 5),
                        ElevatedButton(
                          onPressed: () {
                            getPhoto(
                                _product, SourceType.camera, ImageType.main);
                          },
                          child: const Icon(Icons.photo_camera),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _form,
                  //todo: implement 'onWillPop' arg here
                  child: Column(
                    children: [
                      const Text('Properties'),
                      SizedBox(
                        height: 20 + _product.properties.length * 70,
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _product.properties.length,
                          itemBuilder: (ctx, i) => TextFormField(
                            decoration: InputDecoration(
                              labelText: _keys[i],
                            ),
                            initialValue: _values[i],
                            onSaved: (value) {
                              _userInput[_keys[i]] = value ?? '';
                            },
                          ),
                        ),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'price',
                        ),
                        initialValue: _product.price == 0
                            ? ''
                            : _product.price.toString(),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == '' || value == null) {
                            value = '0.0';
                          }
                          if (double.tryParse(value) == null) {
                            return 'should be a number or nothing';
                          }
                        },
                        onSaved: (value) {
                          _userInput['price'] = value ?? '0.0';
                        },
                      ),
                      const Divider(
                        height: 50,
                        thickness: 1,
                      ),
                      const Text('Alternative Images'),
                      const SizedBox(height: 20),
                      showAlterImages(context, _product),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            flex: 1,
                            child: OutlinedButton(
                              onPressed: () => getPhoto(_product,
                                  SourceType.camera, ImageType.alternative),
                              child: const Text('camera'),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            flex: 1,
                            child: OutlinedButton(
                              onPressed: () => getPhoto(_product,
                                  SourceType.gallery, ImageType.alternative),
                              child: const Text('gallery'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_form.currentState!.validate()) {
                                  _form.currentState!.save();
                                  _product.setProdInfo(_userInput);
                                  Navigator.of(context).pop();
                                }
                              },
                              child: const Text('Save'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
