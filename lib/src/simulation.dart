import 'dart:math';

import 'helpers/lcg.dart';
import 'models/node.dart';
import 'interfaces/force.dart';

class ForceSimulation<N extends Node> {
  ForceSimulation({
    List<N>? nodes,
    this.alpha = 1,
    this.alphaMin = 0.001,
    double? alphaDecay,
    this.alphaTarget = 0,
    double? velocityDecay,
    LCG? random,
    this.phyllotaxisX = 0,
    this.phyllotaxisY = 0,
    this.phyllotaxisRadius = 10,
  })  : _velocityDecay = velocityDecay ?? 0.6,
        _forces = {},
        _random = random ?? LCG(),
        _nodes = nodes ?? [] {
    this.alphaDecay = alphaDecay ?? (1 - pow(alphaMin, 1 / 300).toDouble());
    _initializeNodes();
  }

  final double phyllotaxisRadius;
  static final _initialAngle = pi * (3 - sqrt(5));
  final double phyllotaxisX, phyllotaxisY;

  late double alphaDecay;
  double alpha, alphaMin, alphaTarget;

  final Map<String, IForce> _forces;
  List<N> _nodes;
  List<N> get nodes => _nodes;
  set nodes(List<N> nodes) {
    _nodes = nodes;
    _initializeNodes();
    _forces.values.forEach(_initializeForce);
  }

  LCG _random;
  set random(LCG random) {
    _random = random;
    _forces.values.forEach(_initializeForce);
  }

  double _velocityDecay;
  double get velocityDecay => 1 - _velocityDecay;
  set velocityDecay(double vd) {
    _velocityDecay = 1 - vd;
  }

  void _initializeNodes() {
    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      if (node.fx != null) node.x = node.fx!;
      if (node.fy != null) node.y = node.fy!;
      if (node.x.isNaN || node.y.isNaN) {
        final radius = phyllotaxisRadius * sqrt(0.5 + i),
            angle = i * _initialAngle;
        node
          ..x = phyllotaxisX + radius * cos(angle)
          ..y = phyllotaxisY + radius * sin(angle);
      }
      if (node.vx.isNaN || node.vy.isNaN) {
        node.vx = node.vy = 0;
      }
    }
  }

  void _initializeForce(IForce force) {
    force.initialize(_nodes, _random);
  }

  void setForce(String name, [IForce? force]) {
    if (force == null) {
      _forces.remove(name);
      return;
    }
    _forces[name] = force;
    _initializeForce(force);
  }

  IForce? getForce(String name) => _forces[name];

  void tick([int iterations = 1]) {
    for (var k = 0; k < iterations; ++k) {
      alpha += (alphaTarget - alpha) * alphaDecay;

      // If alpha falls below alphaMin, set it to 0
      if (alpha < alphaMin) {
        alpha = 0;
      }
      
      _forces.values.forEach((force) => force(alpha));

      // Verlet integration
      for (final node in nodes) {
        if (node.fx == null){
          var x = node.x;
          var vx = node.vx;

          node.x += node.vx *= velocityDecay;
          if (node.x.isNaN) {
            print('node.x is NaN x:${x} vx:${vx} velocityDecay:${velocityDecay}');
            node.x = x.isNaN ? 0 : x;
            node.vx = vx.isNaN ? 0 : vx;
          }
        }
        else {
          if (node.fx?.isNaN ?? true) {
            print('node.fx is NaN');
          }
          node
            ..x = node.fx!
            ..vx = 0;
        }
        if (node.fy == null){
          node.y += node.vy *= velocityDecay;
          if (node.y.isNaN) {
            print('node.y is NaN');
            node.y = node.vy.isNaN ? 0 : node.vy;
            node.vy = node.vy.isNaN ? 0 : node.vy;
          }
        }
        else {
          if (node.fy!.isNaN) {
            print('node.fy is NaN');
          }
          node
            ..y = node.fy!
            ..vy = 0;
        }
      }
    }
  }

  N? find(double x, double y, [double radius = double.infinity]) {
    late double dx, dy, d2;
    N? closest;

    if (radius.isFinite) radius *= radius;
    for (final node in nodes) {
      dx = x - node.x;
      dy = y - node.y;
      d2 = dx * dx + dy * dy;
      if (d2 < radius) {
        closest = node;
        radius = d2;
      }
    }

    return closest;
  }
}
