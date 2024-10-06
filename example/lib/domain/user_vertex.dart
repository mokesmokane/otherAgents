import 'package:example/domain/vertex.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_vertex.g.dart';

@JsonSerializable(explicitToJson: true)
class UserVertex extends Vertex {
  final String userInput;

  UserVertex({
    String? id,
    required String label,
    required this.userInput,
  }) : super(id: id, label: label, type: VertexType.user);

  factory UserVertex.fromJson(Map<String, dynamic> json) => _$UserVertexFromJson(json);
  
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = super.toJson();
    json.addAll(_$UserVertexToJson(this));
    return json;
  }
}
