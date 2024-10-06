import 'package:d3_force_flutter/d3_force_flutter.dart' as f;
import 'package:example/domain/channel.dart';
import 'simulation_node.dart';

class SimulationEdge extends f.Edge {
  final Channel channel;

  SimulationEdge(this.channel, SimulationNode source, SimulationNode target)
      : super(source: source, target: target);
}