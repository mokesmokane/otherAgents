import 'dart:math';

import '../helpers/accessor.dart';
import '../interfaces/force.dart';
import '../helpers/jiggle.dart';
import '../helpers/lcg.dart';
import 'node.dart';

class Edge<N extends Node> {
  Edge({
    required this.source,
    required this.target,
    this.index,
  });

  int? index;
  final N source, target;
}

class Edges<E extends Edge<N>, N extends Node> implements IForce<N> {
  Edges({
    this.iterations = 1,
    AccessorCallback<double, E>? onDistance,
    AccessorCallback<double, E>? onStrength,
    double distance = 30,
    List<E>? edges,
  })  : distances = [],
        strengths = [],
        count = {},
        bias = [],
        _edges = edges ?? [] {
    _strength = onStrength ??
        (E edge) =>
            1 / min(count[edge.source.id]!, count[edge.target.id]!);
    _distance = onDistance ?? (_) => distance;
  }

  @override
  List<N>? nodes;
  late List<E> _edges;

  int iterations;
  List<double> distances, strengths, bias;
  Map<String, int> count;
  LCG? random;

  late AccessorCallback<double, E> _strength, _distance;

  set strength(AccessorCallback<double, E> fn) {
    _strength = fn;
    _initialize();
  }

  set distance(AccessorCallback<double, E> fn) {
    _distance = fn;
    _initialize();
  }

  set edges(List<E> edges) {
    _edges = edges;
    this();
  }

  int get m => _edges.length;

  @override
  void call([double alpha = 1]) {
    for (int k = 0; k < iterations; k++) {
      for (int i = 0; i < m; i++) {
        final edge = _edges[i];
        final N source = edge.source;
        final N target = edge.target;

        double x = target.x + target.vx - source.x - source.vx,
            y = target.y + target.vy - source.y - source.vy;

        if (random != null) {
          x == 0 ? jiggle(random!) : x;
          y == 0 ? jiggle(random!) : y;
        }

        double l = sqrt(x * x + y * y);
        l = (l - distances[i]) / l * alpha * strengths[i];
        x *= l;
        y *= l;

        final b = bias[i];
        edge
          ..target.vx -= x * b
          ..target.vy -= y * b
          ..source.vx += x * (1 - b)
          ..source.vy += y * (1 - b);
      }
    }
  }

  void _initialize() {
    if (nodes == null) return;
    count.clear();
    for (final node in nodes!) {
      count[node.id] = 0;
    }

    for (int i = 0; i < m; i++) {
      final edge = _edges[i];
      edge.index = i;
      count[edge.source.id] = (count[edge.source.id] ?? 0) + 1;
      count[edge.target.id] = (count[edge.target.id] ?? 0) + 1;
    }

    bias = List.filled(m, 0);
    for (int i = 0; i < m; i++) {
      final edge = _edges[i];
      final totalDegree = count[edge.source.id]! + count[edge.target.id]!;
      bias[i] = count[edge.source.id]! / totalDegree;
    }

    strengths = List.filled(m, 0);
    initializeStrength();

    distances = List.filled(m, 0);
    initializeDistance();
  }

  void initializeStrength() {
    if (nodes == null) return;
    for (int i = 0; i < m; i++) strengths[i] = _strength(_edges[i]);
  }

  void initializeDistance() {
    if (nodes == null) return;
    for (int i = 0; i < m; i++) distances[i] = _distance(_edges[i]);
  }

  @override
  void initialize(List<N> _nodes, LCG? _random) {
    nodes = _nodes;
    random = _random;
    _initialize();
  }
}
