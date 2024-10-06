// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vertex.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vertex _$VertexFromJson(Map<String, dynamic> json) => Vertex(
      id: json['id'] as String?,
      label: json['label'] as String,
      type: $enumDecode(_$VertexTypeEnumMap, json['type']),
      x: (json['x'] as num?)?.toDouble(),
      y: (json['y'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$VertexToJson(Vertex instance) => <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'type': _$VertexTypeEnumMap[instance.type]!,
      'x': instance.x,
      'y': instance.y,
    };

const _$VertexTypeEnumMap = {
  VertexType.start: 'start',
  VertexType.end: 'end',
  VertexType.ai: 'ai',
  VertexType.user: 'user',
  VertexType.code: 'code',
  VertexType.tools: 'tools',
};
