import 'dart:ui';

import 'package:example/domain/ai_vertex.dart';
import 'package:example/domain/code_vertex.dart';
import 'package:example/domain/end_vertex.dart';
import 'package:example/domain/simulation/simulation_node.dart';
import 'package:example/domain/start_vertex.dart';
import 'package:example/domain/tool_vertex.dart';
import 'package:example/domain/user_vertex.dart';
import 'package:example/domain/vertex.dart';
import 'package:example/providers/providers.dart';
import 'package:example/widgets/animated_list_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NodeOptionsMenu extends ConsumerWidget {
  final String graphId;
  final Offset longPressPosition;
  final VertexType vertexType;
  final SimulationNode? startNode;
  final SimulationNode? endNode;
  final Function onDismiss;
  final Function(SimulationNode) addNode;

  NodeOptionsMenu({required this.graphId, required this.longPressPosition, required this.vertexType, this.startNode, this.endNode, required this.onDismiss, required this.addNode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return  Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () => onDismiss(),
            child: Container(color: Colors.transparent),
          ),
        ),AnimatedOptionsList(
        options: [
          if(startNode == null)'Add Start Node', 
          if(endNode == null)'Add End Node',
          'Add AI Node',
          'Add Code Node',
          'Add Tools Node',  
          ],
        onOptionSelected: (option) {
          if (option == 'Add User Node') {
            _addNewNode(VertexType.user, ref);
          } else if (option == 'Add Start Node') {
            _addNewNode(VertexType.start, ref);
          } else if (option == 'Add End Node') {
            _addNewNode(VertexType.end, ref);
          } else if (option == 'Add AI Node') {
            _addNewNode(VertexType.ai, ref);
          } else if (option == 'Add Code Node') {
              _addNewNode(VertexType.code, ref);
          } else if (option == 'Add Tools Node') {
            _addNewNode(VertexType.tools, ref);
          } 
        },
        onDismiss: () => onDismiss(),
        position: longPressPosition,
      ),
      ],
    );
  }


void _addNewNode(VertexType vt, ref) {
  if (longPressPosition != null) {
    Vertex newVertex;
    switch (vt) {
      case VertexType.start:
        newVertex = StartVertex(
          label: 'New Start',
        );
        break;
      case VertexType.end:
        newVertex = EndVertex(
          label: 'New End',
        );
        break;
      case VertexType.ai:
        newVertex = AIVertex(
          label: 'New AI',
          role: 'assistant',
          inputs: [],
          outputs: [],
        );
        break;
      case VertexType.user:
        newVertex = UserVertex(
          label: 'New User',
          userInput: '',
        );
        break;
      case VertexType.code:
        newVertex = CodeVertex(
          label: 'New Code',
          code: '',
          language: 'text',
        );
        break;
      case VertexType.tools:
        newVertex = ToolVertex(
          label: 'New Tool',
          toolName: '',
          parameters: {},
        );
        break;
    }
    
    final newNode = SimulationNode(newVertex);
    addNode(newNode);
  }
}
}