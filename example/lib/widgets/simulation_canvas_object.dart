import 'package:example/widgets/simulation_canvas.dart';
import 'package:flutter/material.dart';
import 'package:d3_force_flutter/d3_force_flutter.dart';

class SimulationCanvasObject
    extends ParentDataWidget<SimulationCanvasParentData> {
  const SimulationCanvasObject({
    required Widget child,
    required this.node,
    required this.edges,
    required this.constraints,
    required this.weight,
    Key? key,
  }) : super(child: child, key: key);

  final Node node;
  final List<Edge> edges;
  final BoxConstraints constraints;
  final double weight;

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData as SimulationCanvasParentData;

    if (parentData.offset != Offset(node.x, node.y)) {
      parentData.offset = Offset(node.x, node.y);
    }

    if (parentData.edges != edges) {
      parentData.edges = edges;
    }

    if (parentData.node != node) {
      parentData.node = node;
    }

    if (parentData.constraints != constraints) {
      parentData.constraints = constraints;
    }

    if (parentData.weight != weight) {
      parentData.weight = weight;
    }

    final targetObject = renderObject.parent;
    if (targetObject is RenderObject) {
      targetObject.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => SimulationCanvas;
}
