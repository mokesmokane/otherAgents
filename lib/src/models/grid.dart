import '../interfaces/force.dart';
import '../models/node.dart';
import 'dart:math';

class GridForce<N extends Node> implements IForce<N> {
  GridForce({
    required this.cellSize,
    this.strength = 1.0,
  });

  final double cellSize;
  final double strength;

  @override
  List<N>? nodes;

  @override
  void call([double alpha = 1]) {
    if (nodes == null) return;

    for (final node in nodes!) {
      final targetX = (node.x / cellSize).round() * cellSize;
      final targetY = (node.y / cellSize).round() * cellSize;

      final dx = targetX - node.x;
      final dy = targetY - node.y;

      node.vx += dx * strength * alpha;
      node.vy += dy * strength * alpha;
    }
  }

  @override
  void initialize(List<N> _nodes, _) {
    nodes = _nodes;
  }
}