import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'vertex.g.dart';

@JsonSerializable(explicitToJson: true)
class Vertex {
  final String id;
  final String label;
  final VertexType type;

  Vertex({
    String? id,
    required this.label,
    required this.type,
  }) : id = id ?? Uuid().v4();

  factory Vertex.fromJson(Map<String, dynamic> json) => _$VertexFromJson(json);
  Map<String, dynamic> toJson() => _$VertexToJson(this);
}


@JsonEnum()
enum VertexType { start, end, ai, user, code, tools }

// Add this extension to handle conversion to/from JSON
extension VertexTypeExtension on VertexType {
  String toJson() => name;
  
  static VertexType fromJson(String json) => VertexType.values.firstWhere((e) => e.name == json);
}