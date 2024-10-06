// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'code_vertex.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CodeVertex _$CodeVertexFromJson(Map<String, dynamic> json) => CodeVertex(
      id: json['id'] as String?,
      label: json['label'] as String,
      code: json['code'] as String,
      language: json['language'] as String,
    )
      ..x = (json['x'] as num?)?.toDouble()
      ..y = (json['y'] as num?)?.toDouble();

Map<String, dynamic> _$CodeVertexToJson(CodeVertex instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'x': instance.x,
      'y': instance.y,
      'code': instance.code,
      'language': instance.language,
    };
