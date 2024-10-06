import 'package:example/domain/vertex.dart';
import 'package:json_annotation/json_annotation.dart';

part 'start_vertex.g.dart';

@JsonSerializable(explicitToJson: true)
class StartVertex extends Vertex {
  StartVertex({
    String? id,
    required String label,
  }) : super(id: id, label: label, type: VertexType.start);

  factory StartVertex.fromJson(Map<String, dynamic> json) => _$StartVertexFromJson(json);
  
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = super.toJson();
    json.addAll(_$StartVertexToJson(this));
    return json;
  }

  factory StartVertex.empty(String id){
    return StartVertex(id: id, label: 'Start');
  }
}