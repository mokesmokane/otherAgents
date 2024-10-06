// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start_vertex.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StartVertex _$StartVertexFromJson(Map<String, dynamic> json) => StartVertex(
      id: json['id'] as String?,
      label: json['label'] as String,
    )
      ..x = (json['x'] as num?)?.toDouble()
      ..y = (json['y'] as num?)?.toDouble();

Map<String, dynamic> _$StartVertexToJson(StartVertex instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'x': instance.x,
      'y': instance.y,
    };
