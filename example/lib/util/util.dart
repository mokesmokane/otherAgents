import 'package:example/domain/vertex.dart';
import 'package:flutter/material.dart';

IconData getIconForNodeType(VertexType type) {
    switch (type) {
      case VertexType.start:
        return Icons.play_arrow;
      case VertexType.end:
        return Icons.stop;
      case VertexType.ai:
        return Icons.smart_toy;
      case VertexType.user:
        return Icons.person;
      case VertexType.code:
        return Icons.code;
      case VertexType.tools:
        return Icons.build;
    }
  }