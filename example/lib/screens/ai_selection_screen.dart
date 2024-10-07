import 'package:example/domain/ai_vertex.dart';
import 'package:example/screens/custom_ai_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AISelectionScreen extends ConsumerWidget {
  final Function(AIVertex) onAISelected;

  const AISelectionScreen({Key? key, required this.onAISelected}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select AI'),
      ),
      body: ListView(
        children: [
          _buildPredefinedAIList(context),
          const Divider(),
          _buildCustomAIOption(context),
        ],
      ),
    );
  }

  Widget _buildPredefinedAIList(BuildContext context) {
    // TODO: Replace with actual predefined AI list
    final predefinedAIs = [
      AIVertex(
        title: 'General Assistant',
        systemPrompt: 'You are a helpful AI assistant.',
        requirements: 'None',
        outputDescription: 'Provides general assistance and information.', label: 'General Assistant', role: 'You are a helpful AI assistant.', inputs: [], outputs: [],
      ),
      AIVertex(
        title: 'Code Helper',
        systemPrompt: 'You are an AI specialized in helping with coding tasks.',
        requirements: 'Basic programming knowledge',
        outputDescription: 'Provides code snippets, explanations, and debugging assistance.', label: 'Code Helper', role: 'You are an AI specialized in helping with coding tasks.', inputs: [], outputs: [],
      ),
      //researcher
      AIVertex(
        title: 'Researcher',
        systemPrompt: 'You are an AI specialized in helping with research tasks.',
        requirements: 'Basic research skills',
        outputDescription: 'Provides research assistance and information.', label: 'Researcher', role: 'You are an AI specialized in helping with research tasks.', inputs: [], outputs: [],
      ),
      //writer
      AIVertex(
        title: 'Writer',
        systemPrompt: 'You are an AI specialized in helping with writing tasks.',
        requirements: 'Basic writing skills',
        outputDescription: 'Provides writing assistance and information.', label: 'Writer', role: 'You are an AI specialized in helping with writing tasks.', inputs: [], outputs: [],
      ),
      //editor
      AIVertex(
        title: 'Editor',
        systemPrompt: 'You are an AI specialized in helping with editing tasks.',
        requirements: 'Basic editing skills',
        outputDescription: 'Provides editing assistance and information.', label: 'Editor', role: 'You are an AI specialized in helping with editing tasks.', inputs: [], outputs: [],
      ),
      //outline creator
      AIVertex(
        title: 'Outline Creator',
        systemPrompt: 'You are an AI specialized in helping with outlining tasks.',
        requirements: 'Basic outlining skills',
        outputDescription: 'Provides outlining assistance and information.', label: 'Outline Creator', role: 'You are an AI specialized in helping with outlining tasks.', inputs: [], outputs: [],
      )
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Predefined AIs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ...predefinedAIs.map((ai) => ListTile(
          title: Text(ai.title ?? ai.label),
          subtitle: Text(ai.systemPrompt ?? ''),
          onTap: () => onAISelected(ai),
        )),
      ],
    );
  }

  Widget _buildCustomAIOption(BuildContext context) {
    return ListTile(
      title: const Text('Create Custom AI'),
      leading: const Icon(Icons.add),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => CustomAIForm(
            onSubmit: (customAI) {
              Navigator.of(context).pop();
              onAISelected(customAI);
            },
          ),
        );
      },
    );
  }
}
