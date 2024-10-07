import 'package:example/domain/ai_vertex.dart';
import 'package:flutter/material.dart';

class CustomAIForm extends StatefulWidget {
  final Function(AIVertex) onSubmit;

  const CustomAIForm({Key? key, required this.onSubmit}) : super(key: key);

  @override
  _CustomAIFormState createState() => _CustomAIFormState();
}

class _CustomAIFormState extends State<CustomAIForm> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _systemPrompt = '';
  String _requirements = '';
  String _outputDescription = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Custom AI'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title/Role'),
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
                onSaved: (value) => _title = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'System Prompt'),
                validator: (value) => value!.isEmpty ? 'Please enter a system prompt' : null,
                onSaved: (value) => _systemPrompt = value!,
                maxLines: 3,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Requirements/Prerequisites'),
                onSaved: (value) => _requirements = value ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Output Description'),
                validator: (value) => value!.isEmpty ? 'Please describe the output' : null,
                onSaved: (value) => _outputDescription = value!,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final customAI = AIVertex(
        label: _title,
        role: _title,
        inputs: [],
        outputs: [],
        title: _title,
        systemPrompt: _systemPrompt,
        requirements: _requirements,
        outputDescription: _outputDescription,
      );
      widget.onSubmit(customAI);
    }
  }
}
