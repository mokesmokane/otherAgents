import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'vertex.g.dart';

@JsonSerializable(explicitToJson: true)
class Vertex {
  final String id;
  final String label;
  final VertexType type;
  double? x;
  double? y;

  Vertex({
    String? id,
    required this.label,
    required this.type,
    double? x, // Default x position
    double? y, 
  }) : id = id ?? Uuid().v4(),
    x = x??0,
    y = y??0;

  factory Vertex.fromJson(Map<String, dynamic> json) => _$VertexFromJson(json);
  Map<String, dynamic> toJson() => _$VertexToJson(this);

  Vertex copyWith({
    String? id,
    String? label,
    VertexType? type,
    double? x,
    double? y,
  }) {
    return Vertex(
      id: id ?? this.id,
      label: label ?? this.label,
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }
}


@JsonEnum()
enum VertexType { start, end, ai, user, code, tools }

// Add this extension to handle conversion to/from JSON
extension VertexTypeExtension on VertexType {
  String toJson() => name;
  
  static VertexType fromJson(String json) => VertexType.values.firstWhere((e) => e.name == json);
}