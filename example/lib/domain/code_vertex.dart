import 'package:example/domain/vertex.dart';
import 'package:json_annotation/json_annotation.dart';

part 'code_vertex.g.dart';

@JsonSerializable(explicitToJson: true)
class CodeVertex extends Vertex {
  final String code;
  final String language;

  CodeVertex({
    String? id,
    required String label,
    required this.code,
    required this.language,
  }) : super(id: id, label: label, type: VertexType.code);

  factory CodeVertex.fromJson(Map<String, dynamic> json) => _$CodeVertexFromJson(json);
  
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = super.toJson();
    json.addAll(_$CodeVertexToJson(this));
    return json;
  }
}
