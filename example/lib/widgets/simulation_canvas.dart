import 'dart:math';

import 'package:d3_force_flutter/d3_force_flutter.dart' hide Center;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';


// Helper class to represent a pair of nodes
class NodePair {
  final Node source;
  final Node target;

  NodePair(this.source, this.target);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NodePair &&
          runtimeType == other.runtimeType &&
          source == other.source &&
          target == other.target;

  @override
  int get hashCode => source.hashCode ^ target.hashCode;
}

class SimulationCanvas extends MultiChildRenderObjectWidget {
  SimulationCanvas({
    required List<Widget> children,
    required this.nodeColor,
    required this.edgeColor,
    required this.showArrows,
    required this.nodeRadius,
    required this.selectedNode,
    Key? key,
  }) : super(children: children, key: key);

  final Color nodeColor;
  final Color edgeColor;
  final bool showArrows;
  final double nodeRadius;
  final Node? selectedNode;


  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSimulationCanvas(
      nodeColor: nodeColor,
      edgeColor: edgeColor,
      showArrows: showArrows,
      nodeRadius: nodeRadius,
      selectedNode: selectedNode,
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderSimulationCanvas renderObject) {
    renderObject
      ..nodeColor = nodeColor
      ..edgeColor = edgeColor
      ..showArrows = showArrows
      ..nodeRadius = nodeRadius
      ..selectedNode = selectedNode;
  }
}

class SimulationCanvasParentData extends ContainerBoxParentData<RenderBox> {
  SimulationCanvasParentData({
    required this.node,
    required this.edges,
    required this.weight,
    required this.constraints,
  });

  Node? node; // Add the Node reference here
  List<Edge> edges;
  double weight;
  BoxConstraints constraints;
}

class RenderSimulationCanvas extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, SimulationCanvasParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, SimulationCanvasParentData> {
  
  RenderSimulationCanvas({
    required Color nodeColor,
    required Color edgeColor,
    required bool showArrows,
    required double nodeRadius,
    required Node? selectedNode,
  })  : _nodeColor = nodeColor,
        _edgeColor = edgeColor,
        _showArrows = showArrows,
        _nodeRadius = nodeRadius,
        _selectedNode = selectedNode;

  Color _nodeColor;
  Color get nodeColor => _nodeColor;
  set nodeColor(Color value) {
    if (_nodeColor == value) return;
    _nodeColor = value;
    markNeedsPaint();
  }

  Color _edgeColor;
  Color get edgeColor => _edgeColor;
  set edgeColor(Color value) {
    if (_edgeColor == value) return;
    _edgeColor = value;
    markNeedsPaint();
  }

  bool _showArrows;
  bool get showArrows => _showArrows;
  set showArrows(bool value) {
    if (_showArrows == value) return;
    _showArrows = value;
    markNeedsPaint();
  }

  double _nodeRadius;
  double get nodeRadius => _nodeRadius;
  set nodeRadius(double value) {
    if (_nodeRadius == value) return;
    _nodeRadius = value;
    markNeedsPaint();
  }

  Node? _selectedNode;
  Node? get selectedNode => _selectedNode;
  set selectedNode(Node? value) {
    if (_selectedNode == value) return;
    _selectedNode = value;
    markNeedsPaint();
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! SimulationCanvasParentData) {
      // You need to provide the Node associated with this child here.
      // Ensure that when you create the children, you pass the Node to the parent data.
      child.parentData = SimulationCanvasParentData(
        node: null,
        edges: [],
        weight: 0,
        constraints: BoxConstraints.tight(Size(0, 0)),
      );
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();

    if (showArrows) {
      // Step 1: Collect all nodes and their positions
      final Map<Node, Offset> nodePositions = {};
      final Map<NodePair, List<Edge>> edgeGroups = {};

      RenderBox? child = firstChild;
      while (child != null) {
        final pd = child.parentData! as SimulationCanvasParentData;
        if(pd.node != null){
          final edgeOffset = Offset(child.size.width / 2, child.size.height / 2);

          // Store node positions
          final nodePosition = pd.offset + offset + edgeOffset;
          nodePositions[pd.node!] = nodePosition;

          // Group edges between the same pair of nodes
          for (final edge in pd.edges) {
            if (edge.source != edge.target) {
              final pair = NodePair(edge.source, edge.target);
              edgeGroups.putIfAbsent(pair, () => []).add(edge);
            }
          }
        }
        child = pd.nextSibling;
      }

      // Step 2: Draw non-self-referencing edges with varying curvature
      for (final entry in edgeGroups.entries) {
        final pair = entry.key;
        final edges = entry.value;
        final numEdges = edges.length;

        final sourcePosition = nodePositions[pair.source];
        final targetPosition = nodePositions[pair.target];

        if (sourcePosition == null || targetPosition == null) continue;

        for (int i = 0; i < numEdges; i++) {
          final curvature = _computeCurvature(i, numEdges);
          //if source node is selected, make the color red
          //if target node is selected, make the color blue
          final color = _selectedNode == pair.source ? Colors.red : _selectedNode == pair.target ? Colors.lime : edgeColor;
          _drawCurvedArrow(
            canvas,
            sourcePosition,
            targetPosition,
            curvature,
            Paint()
              ..color = color.withOpacity(1.0)
              ..strokeWidth = 0.75,
          );
        }
      }
    }

    // Then, draw the nodes
    RenderBox? child = firstChild;
    while (child != null) {
      final pd = child.parentData! as SimulationCanvasParentData;
      context.paintChild(child, pd.offset + offset);
      child = pd.nextSibling;
    }

    // Finally, draw self-referencing arrows over the nodes
    child = firstChild;
    while (child != null) {
      final pd = child.parentData! as SimulationCanvasParentData;
      final edgeOffset = Offset(child.size.width / 2, child.size.height / 2);
      for (final edge in pd.edges) {
        if (edge.source == edge.target) {
          final start = pd.offset + offset + edgeOffset;
          _drawSelfReferencingArrow(
            canvas,
            start,
            child.size.width / 2,
            Paint()
              ..color = edgeColor.withOpacity(pd.weight)
              ..strokeWidth = 0.75
              ..style = PaintingStyle.stroke,
          );
        }
      }
      child = pd.nextSibling;
    }

    canvas.restore();
  }

  // Compute curvature based on the index and total number of edges
  double _computeCurvature(int index, int totalEdges) {
    if (totalEdges == 1) return 0.0;
    final maxCurvature = 50.0; // Adjust as needed
    final step = (2 * maxCurvature) / (totalEdges - 1);
    return -maxCurvature + index * step;
  }

  void _drawCurvedArrow(
  Canvas canvas,
  Offset start,
  Offset end,
  double curvature,
  Paint paint,
) {
  // Calculate control point for the quadratic Bezier curve
  final midPoint = Offset.lerp(start, end, 0.5)!;
  final dx = end.dx - start.dx;
  final dy = end.dy - start.dy;

  // Calculate the normal vector
  Offset normal = Offset(-dy, dx);

  // Normalize the normal vector
  final length = sqrt(normal.dx * normal.dx + normal.dy * normal.dy);
  if (length != 0) {
    normal = Offset(normal.dx / length, normal.dy / length);
  }

  // Adjust the normal vector based on curvature
  final controlPoint = midPoint + normal * curvature;

  // Calculate the derivative at t=1 for the quadratic Bezier curve
  // The derivative is 2*(end - controlPoint)
  Offset tangent = (end - controlPoint) * 2;

  // Normalize the tangent vector
  final tangentLength = sqrt(tangent.dx * tangent.dx + tangent.dy * tangent.dy);
  if (tangentLength != 0) {
    tangent = Offset(tangent.dx / tangentLength, tangent.dy / tangentLength);
  }

  // Adjust the end point to be at the edge of the target node
  final adjustedEnd = end - tangent * nodeRadius;

  // Create the path up to the adjusted end point
  final path = Path()
    ..moveTo(start.dx, start.dy)
    ..quadraticBezierTo(
      controlPoint.dx,
      controlPoint.dy,
      adjustedEnd.dx,
      adjustedEnd.dy,
    );

  // Draw the path
  canvas.drawPath(path, paint..style = PaintingStyle.stroke);

  // Draw the arrowhead at the adjusted end point
  _drawArrowhead(canvas, adjustedEnd, tangent, paint);
}


  void _drawArrowhead(
  Canvas canvas,
  Offset tip,
  Offset tangent,
  Paint paint,
) {
  final angle = atan2(tangent.dy, tangent.dx);
  final double arrowLength = 10.0; // Adjust as needed
  final double arrowAngle = pi / 6; // 30 degrees

  // Calculate the two base points of the arrowhead
  final arrowPoint1 = tip - Offset(
    arrowLength * cos(angle - arrowAngle),
    arrowLength * sin(angle - arrowAngle),
  );

  final arrowPoint2 = tip - Offset(
    arrowLength * cos(angle + arrowAngle),
    arrowLength * sin(angle + arrowAngle),
  );

  // Create the arrowhead path
  final arrowPath = Path()
    ..moveTo(tip.dx, tip.dy)
    ..lineTo(arrowPoint1.dx, arrowPoint1.dy)
    ..lineTo(arrowPoint2.dx, arrowPoint2.dy)
    ..close();

  // Draw the arrowhead
  canvas.drawPath(arrowPath, paint..style = PaintingStyle.fill);
}


void _drawSelfReferencingArrow(Canvas canvas, Offset center, double nodeRadius, Paint paint) {
  paint.color = edgeColor.withOpacity(paint.color.opacity);
  final loopRadius = nodeRadius * 10.0;  // Adjust the multiplier to change loop size
  final arrowSize = nodeRadius * 0.5;   // Adjust arrow size as needed

  // Start and end angles for the loop
  final startAngle = -pi / 2; // Starting from the top
  final endAngle = startAngle - 2 * pi + 0.001; // Full circle minus a small value

  // Calculate start and end points on the node's circumference
  final startPoint = center + Offset(nodeRadius * cos(startAngle), nodeRadius * sin(startAngle));
  final endPoint = startPoint; // For a full loop, start and end points are the same

  // Create the path for the arc
  final path = Path()
    ..moveTo(startPoint.dx, startPoint.dy)
    ..arcToPoint(
      endPoint,
      radius: Radius.circular(loopRadius),
      largeArc: true,
      clockwise: false, // Change to true if you want the opposite direction
    );

  // Draw the arc
  canvas.drawPath(path, paint);

  // Calculate the angle for the arrowhead
  final angle = startAngle - pi;

  // Position the arrow tip at the edge of the node
  final arrowTip = center + Offset(nodeRadius * cos(angle), nodeRadius * sin(angle));

  // Draw the arrowhead
  final arrowPoint1 = arrowTip + Offset.fromDirection(angle + pi / 6, arrowSize);
  final arrowPoint2 = arrowTip + Offset.fromDirection(angle - pi / 6, arrowSize);

  final arrowPath = Path()
    ..moveTo(arrowTip.dx, arrowTip.dy)
    ..lineTo(arrowPoint1.dx, arrowPoint1.dy)
    ..lineTo(arrowPoint2.dx, arrowPoint2.dy)
    ..close();

  // Ensure the arrowhead is filled
  final arrowPaint = Paint()
    ..color = paint.color
    ..style = PaintingStyle.fill;

  canvas.drawPath(arrowPath, arrowPaint);
}



  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
  final nodeRadius = 20.0;  // Adjust this to match your node size
  final arrowSize = 10.0;   // Adjust as needed for arrow head size

  // Calculate the angle and length of the line
  final dx = end.dx - start.dx;
  final dy = end.dy - start.dy;
  final angle = atan2(dy, dx);
  final length = sqrt(dx * dx + dy * dy);

  // Calculate the end point of the line (where the arrow head starts)
  final shortenedLength = length - nodeRadius - arrowSize;
  final endX = start.dx + shortenedLength * cos(angle);
  final endY = start.dy + shortenedLength * sin(angle);
  final lineEnd = Offset(endX, endY);

  // Draw the line
  canvas.drawLine(start, lineEnd, paint);

  // Calculate arrow head points
  final tipX = start.dx + (length - nodeRadius) * cos(angle);
  final tipY = start.dy + (length - nodeRadius) * sin(angle);
  final tip = Offset(tipX, tipY);

  final arrowPoint1 = tip + Offset.fromDirection(angle + pi - pi/6, arrowSize);
  final arrowPoint2 = tip + Offset.fromDirection(angle + pi + pi/6, arrowSize);

  // Draw the arrow head
  final arrowPath = Path()
    ..moveTo(tip.dx, tip.dy)
    ..lineTo(arrowPoint1.dx, arrowPoint1.dy)
    ..lineTo(arrowPoint2.dx, arrowPoint2.dy)
    ..close();

  canvas.drawPath(arrowPath, paint..style = PaintingStyle.fill);
}

  @override
  void performLayout() {
    size = _computeLayoutSize(constraints: constraints, dry: false);
  }

  Size _computeLayoutSize({
    required BoxConstraints constraints,
    required bool dry,
  }) {
    RenderBox? child = firstChild;

    while (child != null) {
      final childParentData = child.parentData! as SimulationCanvasParentData;

      if (!dry) {
        child.layout(
          childParentData.constraints,
          parentUsesSize: true,
        );
      } else {
        child.getDryLayout(childParentData.constraints);
      }

      child = childParentData.nextSibling;
    }

    return constraints.biggest;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    double height = 0;

    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as SimulationCanvasParentData;
      height += child.getMinIntrinsicHeight(width);

      child = childParentData.nextSibling;
    }

    return height;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    double width = 0;

    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as SimulationCanvasParentData;
      width = max(width, child.getMaxIntrinsicWidth(height));

      child = childParentData.nextSibling;
    }

    return width;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    double width = 0;

    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as SimulationCanvasParentData;
      width = max(width, child.getMinIntrinsicWidth(height));

      child = childParentData.nextSibling;
    }

    return width;
  }

  /// Baseline
  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToFirstActualBaseline(baseline);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
