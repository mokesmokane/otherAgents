// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'end_vertex.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EndVertex _$EndVertexFromJson(Map<String, dynamic> json) => EndVertex(
      id: json['id'] as String?,
      label: json['label'] as String,
    )
      ..x = (json['x'] as num?)?.toDouble()
      ..y = (json['y'] as num?)?.toDouble();

Map<String, dynamic> _$EndVertexToJson(EndVertex instance) => <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'x': instance.x,
      'y': instance.y,
    };
