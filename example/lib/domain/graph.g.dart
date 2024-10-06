// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'graph.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Graph _$GraphFromJson(Map<String, dynamic> json) => Graph(
      id: json['id'] as String,
      name: json['name'] as String,
      vertices: (json['vertices'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, Vertex.fromJson(e as Map<String, dynamic>)),
      ),
      channels: (json['channels'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, Channel.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$GraphToJson(Graph instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'vertices': instance.vertices.map((k, e) => MapEntry(k, e.toJson())),
      'channels': instance.channels.map((k, e) => MapEntry(k, e.toJson())),
    };
