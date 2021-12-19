import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/project.dart';

class ProjectSettingsScreen extends StatefulWidget {
  const ProjectSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ProjectSettingsScreen> createState() => _ProjectSettingsScreenState();
}

class _ProjectSettingsScreenState extends State<ProjectSettingsScreen> {
  String imagePath = '';
  final _descriptionController = TextEditingController();

  void saveData(Project project) {
    project.description = _descriptionController.text;
    project.logoImage = File(imagePath);
  }

  @override
  void initState() {
    final project = Provider.of<Project>(context, listen: false);
    imagePath = project.logoImage.path;
    _descriptionController.text = project.description;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final project = Provider.of<Project>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project settings'),
        leading: IconButton(
          onPressed: () {
            saveData(project);
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                maxLines: 4,
                controller: _descriptionController,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: imagePath == ''
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('no image yet'),
                            )
                          : ClipRRect(
                              child: Image.file(File(imagePath)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final image = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 500,
                          maxHeight: 500,
                        );
                        setState(() {
                          // this syntax is written this way because...
                          // the 'image' and '.path' both can be null
                          imagePath = image?.path ?? '';
                        });
                      },
                      child: const Text('Choose a logo'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Theme.of(context).errorColor),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text('Discard changes'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
