import 'dart:convert';
import 'dart:math';

import 'package:d3_force_flutter/d3_force_flutter.dart';
import 'package:example/domain/ai_vertex.dart';
import 'package:example/domain/channel.dart';
import 'package:example/domain/code_vertex.dart';
import 'package:example/domain/communicatoin_protocol.dart';
import 'package:example/domain/graph.dart';
import 'package:example/domain/simulation/simulation_edge.dart';
import 'package:example/domain/simulation/simulation_node.dart';
import 'package:example/domain/start_vertex.dart';
import 'package:example/domain/tool_vertex.dart';
import 'package:example/domain/user_vertex.dart';
import 'package:example/domain/vertex.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../domain/end_vertex.dart';


final graphStateProvider = StateNotifierProvider.family<GraphStateNotifier, GraphState?, String>((ref, graphId) {
  return GraphStateNotifier(null);
});

final graphProvider = Provider.family<Graph?, String>((ref, graphId) {
  return ref.watch(graphStateProvider(graphId))?.toGraph();
});

final selectedNodeProvider = StateProvider.family<SimulationNode?, String>((ref, graphId) {
  return null;
});

class GraphState {
  final List<SimulationNode> nodes;
  final List<SimulationEdge> edges;
  final Map<String, int> edgeCounts;
  final Map<String, Set<SimulationEdge>> nodeSourceEdges;
  final Map<String, Set<SimulationEdge>> nodeTargetEdges;
  final int maxEdgeCount;
  final String id;
  final String? name;
  GraphState({
    required this.name,
    required this.id,
    required this.nodes,
    required this.edges,
    required this.edgeCounts,
    required this.nodeSourceEdges,
    required this.nodeTargetEdges,
    required this.maxEdgeCount,
  });

  GraphState.empty()
      :nodes = [],
      edges = [],
      edgeCounts = {},
      nodeSourceEdges = {},
      nodeTargetEdges = {},
      maxEdgeCount = 0,
      name = 'Untitled',
      id = Uuid().v4();
  
  static GraphState random(String id) {
    
    final nodes = List.generate(
    14,
    (index) {
      final vertexType = VertexType.values[index % VertexType.values.length];
      Vertex vertex;
      switch (vertexType) {
                case VertexType.ai:
          vertex = AIVertex(
            id: Uuid().v4(),
            label: 'AI $index',
            role: 'assistant',
            inputs: [],
            outputs: [],
          );
          break;
        case VertexType.code:
          vertex = CodeVertex(
            id: Uuid().v4(),
            label: 'Code $index',
            code: '',
            language: 'text',
          );
          break;
        case VertexType.user:
          vertex = UserVertex(
            id: Uuid().v4(),
            label: 'User $index',
            userInput: '',
          );
          break;
        case VertexType.tools:
          vertex = ToolVertex(
            id: Uuid().v4(),
            label: 'Tool $index',
            toolName: '',
            parameters: {},
          );
          break;
        case VertexType.start:
          vertex = StartVertex(
            id: Uuid().v4(),
            label: 'Start $index',
          );
          break;
        case VertexType.end:
          vertex = EndVertex(
            id: Uuid().v4(),
            label: 'End $index',
          );
          break;
      }
      return SimulationNode(vertex);
    }
  );
    final r = Random();
    final edges = <SimulationEdge>[];
    for (final n in nodes) {
      if (r.nextDouble() < 0.8) {
        int numEdges = (r.nextDouble() * 5).toInt();
        for (int i = 0; i < numEdges; i++) {
          final targetIndex = (nodes.length * r.nextDouble()).toInt();
          edges.add(
            SimulationEdge(
              Channel(
                id: Uuid().v4(),
                label: 'Channel ${i + 1}',
                sourceId: n.id,
                targetId: nodes[targetIndex].id,
                protocol: CommunicationProtocol.command,
                metadata: {}
              ),
              n,
              nodes[targetIndex],
            ),
          );
        }
      }
    }

    final edgeCounts = <String, int>{};
    final nodeSourceEdges = <String, Set<SimulationEdge>>{};
    final nodeTargetEdges = <String, Set<SimulationEdge>>{};
    for (final edge in edges) {
      nodeSourceEdges.putIfAbsent(edge.source.id, () => <SimulationEdge>{}).add(edge);
      nodeTargetEdges.putIfAbsent(edge.target.id, () => <SimulationEdge>{}).add(edge);
    }
    var maxEdgeCount = 0;

    for (int i = 0; i < edges.length; i++) {
      final edge = edges[i];
      edge.index = i;
      edgeCounts[edge.source.id] ??= 0;
      edgeCounts[edge.target.id] ??= 0;
      edgeCounts[edge.source.id] = (edgeCounts[edge.source.id] ?? 0) + 1;
      edgeCounts[edge.target.id] = (edgeCounts[edge.target.id] ?? 0) + 1;
    }

    maxEdgeCount = edgeCounts.values.reduce((a, b) => a > b ? a : b);

    return GraphState(
      id: id,
      name: null,
      nodes: nodes,
      edges: edges,
      edgeCounts: edgeCounts,
      nodeSourceEdges: nodeSourceEdges,
      nodeTargetEdges: nodeTargetEdges,
      maxEdgeCount: maxEdgeCount,
    );
  }

  GraphState copyWith({
    String? id,
    String? name,
    List<SimulationNode>? nodes,
    List<SimulationEdge>? edges,
    Map<String, int>? edgeCounts,
    Map<String, Set<SimulationEdge>>? nodeSourceEdges,
    Map<String, Set<SimulationEdge>>? nodeTargetEdges,
    int? maxEdgeCount,
  }) {
    return GraphState(
      id: id ?? this.id,
      name: name ?? this.name,
      nodes: nodes ?? this.nodes,
      edges: edges ?? this.edges,
      edgeCounts: edgeCounts ?? this.edgeCounts,
      nodeSourceEdges: nodeSourceEdges ?? this.nodeSourceEdges,
      nodeTargetEdges: nodeTargetEdges ?? this.nodeTargetEdges,
      maxEdgeCount: maxEdgeCount ?? this.maxEdgeCount,
    );
  }

  GraphState addNode(SimulationNode node) {
    final newNodes = [...nodes, node];
    var newEdgeCounts = Map<String, int>.from(edgeCounts);
    newEdgeCounts[node.id] = 0;
    
    return copyWith(
      nodes: newNodes,
      edgeCounts: newEdgeCounts,
    );
  }

  GraphState addEdge(SimulationEdge edge) {
    final newEdges = [...edges, edge];
    edge.index = newEdges.length - 1;
    
    var newEdgeCounts = Map<String, int>.from(edgeCounts);
    newEdgeCounts[edge.source.id] = (newEdgeCounts[edge.source.id] ?? 0) + 1;
    newEdgeCounts[edge.target.id] = (newEdgeCounts[edge.target.id] ?? 0) + 1;
    
    final newNodeSourceEdges = Map<String, Set<SimulationEdge>>.from(nodeSourceEdges);
    newNodeSourceEdges.putIfAbsent(edge.source.id, () => {}).add(edge);
    
    final newNodeTargetEdges = Map<String, Set<SimulationEdge>>.from(nodeTargetEdges);
    newNodeTargetEdges.putIfAbsent(edge.target.id, () => {}).add(edge);
    
    final newMaxEdgeCount = newEdgeCounts.values.reduce((a, b) => a > b ? a : b);
    
    return copyWith(
      edges: newEdges,
      edgeCounts: newEdgeCounts,
      nodeSourceEdges: newNodeSourceEdges,
      nodeTargetEdges: newNodeTargetEdges,
      maxEdgeCount: newMaxEdgeCount,
    );
  }
  
  static GraphState? fromGraph(Graph graph) {
    final nodes = graph.vertices.values.map((v) => SimulationNode(v)).toList();
    final edges = graph.channels.values.map((c) => SimulationEdge(c, nodes.firstWhere((n) => n.id == c.sourceId), nodes.firstWhere((n) => n.id == c.targetId))).toList();
    final edgeCounts = <String, int>{};
    final nodeSourceEdges = <String, Set<SimulationEdge>>{};
    final nodeTargetEdges = <String, Set<SimulationEdge>>{};
    for (final edge in edges) {
      nodeSourceEdges.putIfAbsent(edge.source.id, () => <SimulationEdge>{}).add(edge);
      nodeTargetEdges.putIfAbsent(edge.target.id, () => <SimulationEdge>{}).add(edge);
    }
    return GraphState(
      name: graph.name, 
      id: graph.id,
      nodes: nodes,
      edges: edges,
      edgeCounts: edgeCounts,
      nodeSourceEdges: nodeSourceEdges,
      nodeTargetEdges: nodeTargetEdges,
      maxEdgeCount: edges.length,
    );
  }
  
  toGraph() {
    return Graph(
      id: id,
      name: name,
      vertices: Map.fromEntries(nodes.map((n) => MapEntry(n.id, n.vertex.copyWith(x: n.x, y: n.y)))),
      channels: Map.fromEntries(edges.map((e) => MapEntry(e.channel.id, e.channel))),
    );
  }
}

class GraphStateNotifier extends StateNotifier<GraphState?> {
  GraphStateNotifier(Graph? graph) : super(graph != null ? GraphState.fromGraph(graph) : null);


  void addNode(SimulationNode node) {
    state = state?.addNode(node);
  }

  void addEdge(SimulationEdge edge) {
    state = state?.addEdge(edge);
  }

  void removeEdge(Edge edge) {
    if (state == null) return;

    final newEdges = state!.edges.where((e) => e != edge).toList();
    final newNodeSourceEdges = Map<String, Set<SimulationEdge>>.from(state!.nodeSourceEdges);
    final newNodeTargetEdges = Map<String, Set<SimulationEdge>>.from(state!.nodeTargetEdges);

    newNodeSourceEdges[edge.source.id]?.remove(edge);
    newNodeTargetEdges[edge.target.id]?.remove(edge);

    var newEdgeCounts = Map<String,int>.from(state!.edgeCounts);
    newEdgeCounts[edge.source.id] = (newEdgeCounts[edge.source.id] ?? 1) - 1;
    newEdgeCounts[edge.target.id] = (newEdgeCounts[edge.target.id] ?? 1) - 1;

    final newMaxEdgeCount = newEdgeCounts.values.reduce((a, b) => a > b ? a : b);

    state = state!.copyWith(
      edges: newEdges,
      edgeCounts: newEdgeCounts,
      nodeSourceEdges: newNodeSourceEdges,
      nodeTargetEdges: newNodeTargetEdges,
      maxEdgeCount: newMaxEdgeCount,
    );
  }
  void set(GraphState? graphState) {
    state = graphState;
  }

  void removeNode(SimulationNode node) {
    state = state!.copyWith(
      nodes: state!.nodes.where((n) => n != node).toList(),
      edges: state!.edges.where((e) => e.source != node && e.target != node).toList(),
    );
  }
  // Add other methods as needed
}

// Add these at the end of the file

final nodeSizeProvider = StateProvider.family<double, String>((ref, graphId) => 40);
final edgeDistanceProvider = StateProvider.family<double, String>((ref, graphId) => 160);
final manyBodyStrengthProvider = StateProvider.family<double, String>((ref, graphId) => -200);
final collideRadiusProvider = StateProvider.family<double, String>((ref, graphId) => 20);
final showArrowsProvider = StateProvider.family<bool, String>((ref, graphId) => true);
final nodeColorProvider = StateProvider.family<Color, String>((ref, graphId) => Colors.blue);
final edgeColorProvider = StateProvider.family<Color, String>((ref, graphId) => Colors.grey);

// Add these providers at the end of the file

final startNodeProvider = Provider.family<SimulationNode?, String>((ref, graphId) {
  final graphState = ref.watch(graphStateProvider(graphId));
  return graphState?.nodes.cast<SimulationNode?>().firstWhere(
    (node) => node?.type == VertexType.start,
    orElse: () => null,
  );
});

final endNodeProvider = Provider.family<SimulationNode?, String>((ref, graphId) {
  final graphState = ref.watch(graphStateProvider(graphId));
  return graphState?.nodes.cast<SimulationNode?>().firstWhere(
    (node) => node?.type == VertexType.end,
    orElse: () => null,
  );
});
