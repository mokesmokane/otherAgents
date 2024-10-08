import 'package:d3_quadtree_flutter/d3_quadtree_flutter.dart';
import 'package:quiver/core.dart';

class Node implements IPoint {
  Node(this.id,{
    this.x = double.nan,
    this.y = double.nan,
    this.vx = 0,
    this.vy = 0,
    this.fx,
    this.fy
  }) {
    if (vx.isNaN) vx = 0;
    if (vy.isNaN) vy = 0;
  }
  String id;
  double x, y, vx, vy;
  double? fx, fy;

  @override
  Node get copy => Node(id, x: x, y: y, vx: vx, vy: vy);
  @override
  bool get isNaN => x.isNaN || y.isNaN;

  @override
  bool operator ==(Object o) =>
      o is Node &&
      x == o.x &&
      y == o.y &&
      vx == o.vx &&
      vy == o.vy;
  @override
  int get hashCode => hashObjects([x, y, vx, vy]);
  @override
  String toString() {
    return {
      'position': '($x, $y)',
      'velocity': '($vx, $vy)',
    }.toString();
  }
}
