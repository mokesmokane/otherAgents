import 'package:example/domain/vertex.dart';
import 'package:json_annotation/json_annotation.dart';

part 'end_vertex.g.dart';

@JsonSerializable(explicitToJson: true)
class EndVertex extends Vertex {
  EndVertex({
    String? id,
    required String label,
  }) : super(id: id, label: label, type: VertexType.end);

  factory EndVertex.fromJson(Map<String, dynamic> json) => _$EndVertexFromJson(json);
  
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = super.toJson();
    json.addAll(_$EndVertexToJson(this));
    return json;
  }
}
