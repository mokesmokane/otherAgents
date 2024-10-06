
import 'dart:math';

import 'package:d3_force_flutter/d3_force_flutter.dart';

class GridForce<N extends Node> implements IForce<N> {
  GridForce({
    required this.cellSize,
    this.strength = 0.1,
  });

  final double cellSize;
  final double strength;

  @override
  List<N>? nodes;

  @override
  void call([double alpha = 1]) {
    if (nodes == null) return;

    for (final node in nodes!) {
      final cellX = (node.x / cellSize).floor() * cellSize + cellSize / 2;
      final cellY = (node.y / cellSize).floor() * cellSize + cellSize / 2;

      final dx = cellX - node.x;
      final dy = cellY - node.y;
      final distance = sqrt(dx * dx + dy * dy);

      if (distance > 0) {
        final factor = alpha * strength / distance;
        node.vx += dx * factor;
        node.vy += dy * factor;
      }
    }
  }

  @override
  void initialize(List<N> _nodes, _) {
    nodes = _nodes;
  }
}