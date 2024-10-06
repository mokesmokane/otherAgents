import 'package:example/domain/vertex.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tool_vertex.g.dart';

@JsonSerializable(explicitToJson: true)
class ToolVertex extends Vertex {
  final String toolName;
  final Map<String, dynamic> parameters;

  ToolVertex({
    String? id,
    required String label,
    required this.toolName,
    required this.parameters,
  }) : super(id: id, label: label, type: VertexType.tools);

  factory ToolVertex.fromJson(Map<String, dynamic> json) => _$ToolVertexFromJson(json);
  
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = super.toJson();
    json.addAll(_$ToolVertexToJson(this));
    return json;
  }
}
