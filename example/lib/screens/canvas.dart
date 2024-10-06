import 'dart:math';

import 'package:example/domain/channel.dart';
import 'package:example/domain/communicatoin_protocol.dart';
import 'package:example/domain/simulation/simulation_edge.dart';
import 'package:example/domain/simulation/simulation_node.dart';
import 'package:example/domain/vertex.dart';
import 'package:example/providers/providers.dart';
import 'package:example/screens/grid.dart';
import 'package:example/screens/grid_painter.dart';
import 'package:example/screens/node_options_menu.dart';
import 'package:example/util/util.dart';
import 'package:example/widgets/animated_list_menu.dart';
import 'package:example/widgets/node_hit_test.dart';
import 'package:example/widgets/simulation_canvas.dart';
import 'package:example/widgets/simulation_canvas_object.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:d3_force_flutter/d3_force_flutter.dart' as f;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'dart:ui' as ui;

// Update your CanvasScreen widget to be a ConsumerStatefulWidget
class Canvas extends ConsumerStatefulWidget {
  Canvas({Key? key, required this.graphId}) : super(key: key?? ValueKey(graphId));
  final String graphId;
  @override
  ConsumerState<Canvas> createState() => _State();
}

// Update your _CanvasScreenState to be a ConsumerState
class _State extends ConsumerState<Canvas> with TickerProviderStateMixin {
  late final Ticker _ticker;
  late f.ForceSimulation simulation;
  bool _showGrid = false;
  double _gridCellSize = 100.0; // Adjust this value to change the grid size
  GridForce? _gridForce;
  int i = 0;

  f.Node? selectedNode;
  f.Node? startNode;
  f.Node? endNode;
  Offset? tapPosition;
  Offset? longPressPosition;
  final DraggableScrollableController _dragController = DraggableScrollableController();
  bool _isSelectingTargetNode = false;
  bool _isInitialized = false;
  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      setState(() {
        simulation.tick();
      });
    })..start();

    _dragController.addListener(_onDragUpdate);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addSimulationListeners();
      ref.read(nodeColorProvider(widget.graphId).notifier).state = Theme.of(context).primaryColor;
    });
  }

  void _addSimulationListeners() {
    final graphState = ref.read(graphStateProvider(widget.graphId));
    if (graphState == null) return;

  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeSimulation();
      _updateSimulation();
      _isInitialized = true;
    }
  }

void _updateSimulation() {
  final graphState = ref.read(graphStateProvider(widget.graphId));
  if (graphState == null) return;
  final edgeDistance = ref.read(edgeDistanceProvider(widget.graphId));
  final manyBodyStrength = ref.read(manyBodyStrengthProvider(widget.graphId));
  final collideRadius = ref.read(collideRadiusProvider(widget.graphId));

  simulation
    ..setForce('collide', f.Collide(radius: collideRadius))
    ..setForce('manyBody', f.ManyBody(strength: manyBodyStrength))
    ..setForce(
      'edges',
      f.Edges(edges: graphState.edges, distance: edgeDistance, onStrength: (SimulationEdge e) => _onStrength(e, graphState), onDistance: (SimulationEdge e) => _onDistance(e, graphState, edgeDistance))
    )
    ..setForce('grid', _gridForce!)
    ..velocityDecay = 0.1
    ..alpha = 1;  // Restart the simulation
}
    double _onDistance(f.Edge<f.Node> edge, GraphState graphState, double edgeDistance) {
    // // Get the current distance between nodes
    //   double currentDistance = sqrt(pow(edge.source.x - edge.target.x, 2) + pow(edge.source.y - edge.target.y, 2));
      
    //   // Get the number of connections for each node
    //   int sourceConnections = graphState.edgeCounts[edge.source.id] ?? 0;
    //   int targetConnections = graphState.edgeCounts[edge.target.id] ?? 0;
      
    //   // Base distance
    //   double baseDistance = 100;
      
    //   // Adjust distance based on connections
    //   double connectionFactor = (sourceConnections + targetConnections) / 10;
      
    //   // Adjust distance based on current distance (allows for more flexibility)
    //   double distanceFactor = currentDistance / baseDistance;
      
      return edgeDistance;
    }

    double _onStrength(f.Edge<f.Node> edge, GraphState graphState) {
    // // Get the current distance between nodes
    //   double currentDistance = sqrt(pow(edge.source.x - edge.target.x, 2) + pow(edge.source.y - edge.target.y, 2));
      
    //   // Base strength
    //   double baseStrength = 0.1;
      
    //   // Adjust strength based on how far the nodes are from their desired position
    //   double distanceFactor = currentDistance / 100; // Assuming 100 is the desired distance
      
    //   // Adjust strength based on node velocities
    //   double velocityFactor = (edge.source.vx.abs() + edge.source.vy.abs() + edge.target.vx.abs() + edge.target.vy.abs()) / 4;
      
    //   return baseStrength * (1 + distanceFactor) * (1 - velocityFactor);
      // return 1 / min(graphState.edgeCounts[edge.source.id]??0, graphState.edgeCounts[edge.target.id]??0);
      return 0.01;
    }

  void _initializeSimulation() {
    var size = MediaQuery.of(context).size;
    var graphState = ref.read(graphStateProvider(widget.graphId));
    if (graphState == null) return;
    var nodes = graphState.nodes;
    var edges = graphState.edges;
    
    var edgeDistance = ref.read(edgeDistanceProvider(graphState.id));
    var manyBodyStrength = ref.read(manyBodyStrengthProvider(graphState.id));
    var collideRadius = ref.read(collideRadiusProvider(graphState.id));
    _gridForce = GridForce(cellSize: _gridCellSize, strength: 20);
    simulation = f.ForceSimulation(
      phyllotaxisX: size.width / 2,
      phyllotaxisY: size.height / 2,
      phyllotaxisRadius: 20,
    )
      ..nodes = nodes
      ..setForce('collide', f.Collide(radius: collideRadius))
      ..setForce('manyBody', f.ManyBody(strength: manyBodyStrength))
      ..setForce(
        'edges',
        f.Edges(edges: edges, distance: edgeDistance, onDistance: (SimulationEdge e) => _onDistance(e, graphState, edgeDistance), onStrength: (SimulationEdge e) => _onStrength(e, graphState)),
      )
      ..setForce('x', f.XPositioning(x: size.width / 2))
      ..setForce('y', f.YPositioning(y: size.height / 2))
      ..setForce('grid', _gridForce!)
      ..alpha = 1;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _dragController.dispose();
    super.dispose();
  }

  void startTicker() => _ticker..start();

  void _onDragUpdate() {
    // If the sheet is dragged below a certain threshold, dismiss it
    if (_dragController.size < 0.1) {
        setState(() {
          selectedNode = null;
        });
    }
  }

  void _handleCanvasLongPress(Offset offset) {
    setState(() {
      longPressPosition = offset;
    });
    _showOptionsMenu(offset);
  }

  void _showOptionsMenu(Offset position) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    
    entry = OverlayEntry(
      builder: (context) => NodeOptionsMenu(graphId: widget.graphId, longPressPosition: position, vertexType: VertexType.user, addNode: (node) => _addNewNode(node, position), onDismiss: () => entry.remove())
    );
    
    overlay.insert(entry);
  }
  void _startSelectTargetNodeMode() {
      // Implement the logic for starting select target node mode
      // For example:
      setState(() {
        _isSelectingTargetNode = true;
      });
    }
    
  void _showNodeOptionsMenu(f.Node node) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    
    entry = OverlayEntry(
      builder: (context) => AnimatedOptionsList(
        options: [
          'Add Edge'
        ],
        onOptionSelected: (option) {
          if (option == 'Add Edge') {
            setState(() {
              selectedNode = node;
            });
            _startSelectTargetNodeMode();
          }
          entry.remove(); // Remove the options menu
        },
        onDismiss: () {
          entry.remove();
        },
        position: Offset(node.x, node.y),
      ),
    );
    
    overlay.insert(entry);
  }


_addNewNode(SimulationNode node, Offset longPressPosition) {
  node.x = longPressPosition.dx;
  node.y = longPressPosition.dy;
    
    final graphState = ref.read(graphStateProvider(widget.graphId));
    if (graphState == null) return;
    final edgeDistance = ref.read(edgeDistanceProvider(graphState.id));
    final manyBodyStrength = ref.read(manyBodyStrengthProvider(graphState.id));
    final collideRadius = ref.read(collideRadiusProvider(graphState.id));

    ref.read(graphStateProvider(widget.graphId).notifier).addNode(node);
    simulation.nodes.add(node);

    // Update simulation with preserved settings
    simulation
      ..setForce('collide', f.Collide(radius: collideRadius))
      ..setForce('manyBody', f.ManyBody(strength: manyBodyStrength))
      ..setForce(
        'edges',
        f.Edges(edges: graphState.edges, distance: edgeDistance, onDistance: (SimulationEdge e) => _onDistance(e, graphState, edgeDistance), onStrength: (SimulationEdge e) => _onStrength(e, graphState)),
      )
      ..setForce('grid', _gridForce!)
      ..alpha = 1;  // 
}

void _addNewEdge(SimulationNode source, SimulationNode target) {
  final newChannel = Channel(
    id: Uuid().v4(),
    label: 'New Channel',
    sourceId: source.vertex.id,
    targetId: target.vertex.id,
    protocol: CommunicationProtocol.command,
    metadata: {}
  );
  final newEdge = SimulationEdge(newChannel, source, target);

  var graphState = ref.read(graphStateProvider(widget.graphId));
  if (graphState == null) return;
  var edgeDistance = ref.read(edgeDistanceProvider(graphState.id));
  var manyBodyStrength = ref.read(manyBodyStrengthProvider(graphState.id));
  var collideRadius = ref.read(collideRadiusProvider(graphState.id));

  ref.read(graphStateProvider(widget.graphId).notifier).addEdge(newEdge);


    // Update simulation with preserved settings
    simulation
      ..setForce('collide', f.Collide(radius: collideRadius))
      ..setForce('manyBody', f.ManyBody(strength: manyBodyStrength))
      ..setForce(
        'edges',
        f.Edges(edges: graphState.edges, distance: edgeDistance, onDistance: (SimulationEdge e) => _onDistance(e, graphState, edgeDistance), onStrength: (SimulationEdge e) => _onStrength(e, graphState)),
      ) 
      ..setForce('grid', _gridForce!)
      ..alpha = 1;  // 
  }



  @override
  Widget build(BuildContext context) {
    final size = Size(2000, 2000);
    var selectedNode = ref.watch(selectedNodeProvider(widget.graphId)); 
    var graphState = ref.watch(graphStateProvider(widget.graphId));
    
    if (graphState == null) {
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              _initializeSimulation();
            },
            child: Text('Start'),
          )
        )
      );
    }

    // Watch the providers to trigger rebuilds when they change
    ref.watch(edgeDistanceProvider(graphState.id));
    ref.watch(manyBodyStrengthProvider(graphState.id));
    ref.watch(collideRadiusProvider(graphState.id));

    // Use ref.listen to react to changes
    ref.listen(edgeDistanceProvider(graphState.id), (_, __) => _updateSimulation());
    ref.listen(manyBodyStrengthProvider(graphState.id), (_, __) => _updateSimulation());
    ref.listen(collideRadiusProvider(graphState.id), (_, __) => _updateSimulation());
    ref.listen<GraphState?>(graphStateProvider(graphState.id), (_, __) => _updateSimulation());
    return
      Stack(
        children: [CustomPaint(
        painter: GridPainter(
          cellSize: _gridCellSize,
          showGrid: _showGrid,
        ),
          child:GestureDetector(
            onTapDown: (details) {
              if (_isSelectingTargetNode) {
                
              } else if(selectedNode != null){
                ref.read(selectedNodeProvider(widget.graphId).notifier).state = null;
              }
            },
            onLongPressStart:(d) =>_handleCanvasLongPress(d.globalPosition),
            child: Container(
              color: Colors.black.withOpacity(0.5),
              width: size.width,
              height: size.height,
              child: ConstrainedBox(
                constraints: BoxConstraints.tight(size),
                child: SimulationCanvas(
                  nodeColor: ref.read(nodeColorProvider(graphState.id)),
                  edgeColor: ref.read(edgeColorProvider(graphState.id)),
                  showArrows: ref.read(showArrowsProvider(graphState.id)),
                  nodeRadius: ref.read(nodeSizeProvider(graphState.id)) / 2,
                  selectedNode: selectedNode,
                  children: [
                    for (final node in graphState.nodes)
                      if (!node.isNaN)
                        Builder(builder: (context) {
                          final double weight = graphState.maxEdgeCount == 0
                              ? 0
                              : (graphState.edgeCounts[node.id]??0) / graphState.maxEdgeCount;
                          final bool isSourceNode = node == selectedNode;
                          return SimulationCanvasObject(
                            weight: weight,
                            constraints: BoxConstraints.tight(
                              Size(ref.read(nodeSizeProvider(graphState.id)), ref.read(nodeSizeProvider(graphState.id))),
                            ),
                            node: node,
                            edges: ref.read(showArrowsProvider(graphState.id))
                                ? [...graphState.edges.where((e) => e.source == node)]
                                : [],
                            child: NodeHitTester(
                              node,
                              onDragStart: (_) {
                                setState(() {
                                  _showGrid = true;
                                });
                              },
                              onDragUpdate: (update) {
                                node
                                  ..fx = update.globalPosition.dx
                                  ..fy = update.globalPosition.dy;
                                simulation..alphaTarget = 0.5;
                              },
                              onDragEnd: (_) {
                                setState(() {
                                  _showGrid = false;
                                });
                                node
                                  ..fx = null
                                  ..fy = null;
                                simulation.alphaTarget = 0;
                              },
                              onTap: () {
                                if (_isSelectingTargetNode) {
                                  if (node != selectedNode) {
                                    _addNewEdge(selectedNode!, node);
                                    setState(() {
                                      _isSelectingTargetNode = false;
                                    });
                                  }
                                } else {
                                  if (selectedNode != node) {
                                    ref.read(selectedNodeProvider(widget.graphId).notifier).state = node;
                                  } else {
                                    ref.read(selectedNodeProvider(widget.graphId).notifier).state = null;
                                  }
                                }
                              },
                              onLongPress: () {
                                ref.read(selectedNodeProvider(widget.graphId).notifier).state = node;
                                _showNodeOptionsMenu(node);
                              },
                              child: Container(
                                width: ref.read(nodeSizeProvider(graphState.id)),
                                height: ref.read(nodeSizeProvider(graphState.id)),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        isSourceNode ? Colors.yellow : ref.read(nodeColorProvider(graphState.id)),
                                    width: isSourceNode ? 3 : 2,
                                  ),
                                  color: isSourceNode
                                      ? Colors.yellow.withOpacity(0.5)
                                      : ref.read(nodeColorProvider(graphState.id)).withOpacity(sqrt(weight)),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    getIconForNodeType(node.type),
                                    size: ref.read(nodeSizeProvider(graphState.id)) * 0.6,
                                    color: isSourceNode
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                  ],
                ),
              ),
            ),
          )),
          if (_isSelectingTargetNode)
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Text(
                    'Select a target node to create an edge',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          // Conditionally render the DraggableScrollableSheet when selectedNode is not null
          
        ],
      );
  }

}