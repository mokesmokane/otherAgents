import 'package:example/domain/start_vertex.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'vertex.dart';
import 'channel.dart';

part 'graph.g.dart';

@JsonSerializable(explicitToJson: true)
class Graph {
  final String id;
  final String? name;
  final Map<String, Vertex> vertices;
  final Map<String, Channel> channels;

  Graph({
    required this.id,
    this.name,
    required this.vertices,
    required this.channels,
  });

  factory Graph.empty(String id, {String? name}) =>
    Graph(id: id, name: name, vertices: {'start': StartVertex.empty(Uuid().v4())}, channels: {});
  

  factory Graph.fromJson(Map<String, dynamic> json) => _$GraphFromJson(json);
  Map<String, dynamic> toJson() => _$GraphToJson(this);

  Vertex? getVertexById(String id) {
    return vertices[id];
  }

  List<Channel> getChannelsForVertex(String vertexId) {
    return channels.values.where((c) => c.sourceId == vertexId || c.targetId == vertexId).toList();
  }

  void addVertex(Vertex vertex) {
    vertices[vertex.id] = vertex;
  }

  void addChannel(Channel channel) {
    channels[channel.id] = channel;
  }

  void removeVertex(String id) {
    vertices.remove(id);
  }

  void removeChannel(String id) {
    channels.remove(id);
  }

}

