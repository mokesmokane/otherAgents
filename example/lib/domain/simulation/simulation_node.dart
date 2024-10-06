import 'package:d3_force_flutter/d3_force_flutter.dart' as f;
import 'package:example/domain/vertex.dart';
class SimulationNode extends f.Node {
  final Vertex vertex;

  SimulationNode(this.vertex) : super(vertex.id, x:vertex.x??double.nan, y:vertex.y??double.nan);

  // You can add any additional properties or methods needed for the simulation here

  // Helper method to update position
  void updatePosition(double newX, double newY) {
    x = newX;
    y = newY;
  }

  // Helper method to update velocity
  void updateVelocity(double newVx, double newVy) {
    vx = newVx;
    vy = newVy;
  }

  // Override toString for easier debugging
  @override
  String toString() {
    return 'SimulationNode(id: ${vertex.id}, type: ${vertex.type}, position: ($x, $y), velocity: ($vx, $vy))';
  }

  // You might want to add methods to interact with the underlying Vertex
  String get label => vertex.label;
  VertexType get type => vertex.type;

}