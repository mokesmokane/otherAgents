import 'dart:convert';
import 'dart:developer';

import 'package:example/domain/graph.dart';
import 'package:example/providers/providers.dart';
import 'package:example/screens/simulation_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:example/screens/canvas.dart' as canvas;
import 'package:example/screens/node_details_sheet.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';


class CanvasScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<CanvasScreen> createState() => _CanvasScreenState();
  CanvasScreen({Key? key}) : super(key: key);
}

class _CanvasScreenState extends ConsumerState<CanvasScreen> {
  bool _showOverlay = false;
  String? graphId;
  
  void initState() {
    super.initState();
  }

  @override
  @override
  Widget build(BuildContext context) {
    var selectedNode = graphId != null ? ref.watch(selectedNodeProvider(graphId!)) : null;
    var graph = graphId != null ? ref.watch(graphProvider(graphId!)) : null;
    return Scaffold(
      drawer: graph != null ? SimulationDrawer(graphId: graphId!) : null,
      body: Stack(
        children: [
         if(graph == null)
      //button to start the simulation
      Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _createNewGraph(context),
                    child: Text('New'),
                  ),
                  SizedBox(height: 16),
                  Container(
                    width: 200,
                    constraints: BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: FutureBuilder<List<Graph>>(
                      future: _loadGraphList(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else {
                          return ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.all(8),
                            itemCount: snapshot.data!.length,
                            separatorBuilder: (context, index) => Divider(color: Theme.of(context).primaryColor.withOpacity(0.2)),
                            itemBuilder: (context, index) {
                              final graph = snapshot.data![index];
                              return InkWell(
                                onTap: () => _loadSelectedGraph(graph),
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                    child: Text(
                                      graph.name,
                                      style: TextStyle(color: Theme.of(context).primaryColor),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
      if(graph != null)canvas.Canvas(graphId: graphId!),
      if (selectedNode != null)
            DraggableScrollableSheet(
              initialChildSize: 0.08,
              minChildSize: 0.08,
              maxChildSize: 0.5,
              snap: true,
              builder: (context, scrollController) {
                return  NodeDetailsSheet(
                  node: selectedNode!,
                  scrollController: scrollController,
                  graphId: graphId!, // Add this line
                );
              },
            ),
        if (_showOverlay)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _showOverlay = false),
              child: Container(
                color: Colors.black54.withOpacity(0.5),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          var graph = ref.read(graphStateProvider(graphId!))?.toGraph();
                          if(graph != null) {
                          _saveGraph(graph);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('No graph to save')),
                            );
                          }
                          setState(() {
                            _showOverlay = false;
                          });
                        },
                        child: Text('Save'),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          _showGraphList(context);
                          setState(() {
                            _showOverlay = false;
                          });
                        },
                        child: Text('Load'),
                      ),SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          //ask if they want to save first
                          bool? save = await showDialog(context: context, builder: (context) {
                            return AlertDialog(
                              title: Text('Save current graph?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text('Save'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text('Discard'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancel'),
                                ),
                              ],
                            );
                          });
                          if(save == true) {
                            var graph = ref.read(graphStateProvider(graphId!))?.toGraph();
                            if(graph != null) {
                              _saveGraph(graph);
                            }
                          }
                          if(save != null) {
                            _createNewGraph(context);
                          }
                          setState(() {
                            _showOverlay = false;
                          });
                        },
                        child: Text('New'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ]),

      floatingActionButton: 
          graph != null ?FloatingActionButton(
            onPressed: () => setState(() => _showOverlay = !_showOverlay),
            child: Icon(Icons.bubble_chart),
            shape: CircleBorder(),
            backgroundColor: Theme.of(context).primaryColor,
            heroTag: 'overlay',
        ) : null
    );
  }
Future<void> _createNewGraph(BuildContext context) async {
  final name = await _showNameDialog(context);
  if (name != null) {
    graphId = Uuid().v4();
    var graph = Graph.empty(graphId!, name);
    ref.read(graphStateProvider(graphId!).notifier).set(GraphState.fromGraph(graph));
    setState(() {
      graphId = graph.id;
    });
  }
}
Future<void> _showGraphList(BuildContext context) async {
  final graphs = await _loadGraphList();
  if (graphs.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No saved graphs found')),
    );
    return;
  }

  final selectedGraph = await showDialog<Graph>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text('Select a graph'),
        children: graphs.map((graph) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, graph),
            child: Text(graph.name),
          );
        }).toList(),
      );
    },
  );

  if (selectedGraph != null) {
    _loadSelectedGraph(selectedGraph);
  }
}
  // Add this new method
  Future<List<Graph>> _loadGraphList() async {
    final box = await Hive.openBox<String>('graph');
    final graphList = box.values.map((graphJson) {
      try {
        return Graph.fromJson(json.decode(graphJson));
      } catch (e) {
        print('Error loading graph: $e');
        return null;
      }
    }).whereType<Graph>().toList();
    return graphList;
  }

void _loadSelectedGraph(Graph graph) {
    ref.read(graphStateProvider(graph.id).notifier).set(GraphState.fromGraph(graph));
    setState(() {
      graphId = graph.id;
    });
  }

Future<void> clearHiveBox() async {
  final box = await Hive.openBox('graphs');
  await box.clear();
  print('Hive box cleared');

  final box2   = await Hive.openBox('graph');
  await box2.clear();
  print('Hive box cleared');
}

Future<void> _saveGraph(Graph graph) async {
  Box<String> box;
  try {
    box = Hive.box<String>('graph');
  } catch (e) {
    // If the box is not open, open it
    box = await Hive.openBox<String>('graph');
  }
  
  final graphJson = json.encode(graph.toJson());
  log(graphJson);
  await box.put(graph.id, graphJson);
}


  Future<String?> _showNameDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String name = '';
        return AlertDialog(
          title: Text('Name your graph'),
          content: TextField(
            autofocus: true,
            onChanged: (value) => name = value,
            decoration: InputDecoration(hintText: "Enter graph name"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(name),
            ),
          ],
        );
      },
    );
  }
}