import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/project.dart';

class NewProject extends StatefulWidget {
  @override
  State<NewProject> createState() => _NewProjectState();
}

class _NewProjectState extends State<NewProject> {
  final _form = GlobalKey<FormState>();
  final _productsController = TextEditingController();
  int prodsCount = 0;
  int propsCount = 0;
  int step = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 10,
        ),
        child: step == 0
            ? Column(
                children: [
                  const Text('how many products you want to create?'),
                  SizedBox(
                    width: 50,
                    child: TextField(
                      controller: _productsController,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        hintText: 'count',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      prodsCount = int.parse(_productsController.text);
                      setState(() {
                        step++;
                      });
                    },
                    child: const Text('Next'),
                  ),
                ],
              )
            : step == 1
                ? Form(
                    key: _form,
                    child: Column(
                      children: [
                        const Text(
                          'how many properties do you want to enter?\n(except price, it should not be included)',
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          width: 50,
                          child: TextFormField(
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              hintText: 'count',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == '') return 'required';
                              if (int.parse(value!) > 5) return 'max is 5';
                            },
                            onSaved: (value) {
                              propsCount = int.parse(value!);
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  step--;
                                });
                              },
                              child: const Text('Prev'),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                final isValid = _form.currentState!.validate();
                                if (isValid) {
                                  _form.currentState!.save();
                                  setState(() {
                                    step++;
                                  });
                                }
                              },
                              child: const Text('Next'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : PropsForm(prodsCount, propsCount),
      ),
    );
  }
}

class PropsForm extends StatefulWidget {
  final int _prodsCount;
  final int _propsCount;

  PropsForm(this._prodsCount, this._propsCount);

  @override
  _PropsFormState createState() => _PropsFormState();
}

class _PropsFormState extends State<PropsForm> {
  final _form = GlobalKey<FormState>();
  final List<String> properties = [];

  @override
  Widget build(BuildContext context) {
    final projects = Provider.of<Projects>(context, listen: false);
    return Form(
      key: _form,
      child: Column(
        children: [
          SizedBox(
            width: 200,
            height: widget._propsCount * 50,
            child: ListView.builder(
              itemCount: widget._propsCount,
              itemBuilder: (ctx, i) => TextFormField(
                decoration: const InputDecoration(
                  hintText: 'property name',
                ),
                validator: (value) {
                  if (value == '') return 'required field';
                },
                onSaved: (value) {
                  properties.add(value!);
                },
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final isValid = _form.currentState!.validate();
              if (isValid) {
                _form.currentState!.save();
                projects.addEmptyProject(widget._prodsCount, properties);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
