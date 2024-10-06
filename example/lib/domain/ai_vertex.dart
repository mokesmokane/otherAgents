import 'package:example/domain/vertex.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ai_vertex.g.dart';

@JsonSerializable(explicitToJson: true)
class AIVertex extends Vertex {
  final String role;
  final List<String> inputs;
  final List<String> outputs;

  AIVertex({
    String? id,
    required String label,
    required this.role,
    required this.inputs,
    required this.outputs,
  }) : super(id: id, label: label, type: VertexType.ai);

  factory AIVertex.fromJson(Map<String, dynamic> json) => _$AIVertexFromJson(json);
  
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = super.toJson();
    json.addAll(_$AIVertexToJson(this));
    return json;
  }
}