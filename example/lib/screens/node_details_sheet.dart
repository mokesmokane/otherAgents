import 'dart:math';

import 'package:example/domain/simulation/simulation_node.dart';
import 'package:example/domain/vertex.dart';
import 'package:example/providers/providers.dart';
import 'package:example/util/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NodeDetailsSheet extends ConsumerWidget {
  final SimulationNode node;
  final ScrollController scrollController;

  final String graphId;

  NodeDetailsSheet({required this.node, required this.scrollController, required this.graphId});



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var graphState = ref.watch(graphStateProvider(graphId));
    if (graphState == null) {
      return Container();
    }
    return DefaultTextStyle(
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: ListView(
                      controller: scrollController,
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Icon(getIconForNodeType(node.type), color: Colors.white),
                          ),
                          title: Text('${node!.label}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                          
                        ),
                        Divider(color: Colors.white30),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text('Outgoing Edges', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                        ),
                        for (final edge in graphState.nodeSourceEdges[node.id] ?? {})
                          Card(
                            color: Colors.grey[700],
                            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.blue,
                                    child: Icon(getIconForNodeType(node.type), color: Colors.white, size: 16),
                                  ),
                                  Icon(Icons.arrow_forward, color: Colors.red),
                                  CircleAvatar(
                                    backgroundColor: Colors.blue,
                                    child: Icon(getIconForNodeType(edge.target.type), color: Colors.white, size: 16),
                                  ),
                                ],
                              ),
                              title: Text('${node.label} → ${edge.target.label}', style: TextStyle(color: Colors.white)),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red[300]),
                                onPressed: () {
                                    ref.read(graphStateProvider(graphId).notifier).removeEdge(edge);
                                },
                              ),
                            ),
                          ),
                        SizedBox(height: 16),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text('Incoming Edges', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.yellow)),
                        ),
                        for (final edge in graphState.nodeTargetEdges[node.id] ?? {})
                          Card(
                            color: Colors.grey[700],
                            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.blue,
                                    child: Icon(getIconForNodeType(node.type), color: Colors.white, size: 20),
                                  ),
                                  Transform(
                                    transform: Matrix4.rotationY(pi),
                                    alignment: Alignment.center,
                                    child: Icon(Icons.arrow_forward, color: Colors.yellow),
                                  ),
                                  CircleAvatar(
                                    backgroundColor: Colors.blue,
                                    child: Icon(getIconForNodeType(edge.source.type), color: Colors.white, size: 20),
                                  ),
                                ],
                              ),
                              title: Text('${edge.source.label} → ${node.label}', style: TextStyle(color: Colors.white)),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red[300]),
                                onPressed: () {
                                  ref.read(graphStateProvider(graphId).notifier).removeEdge(edge);
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
  }
  
}