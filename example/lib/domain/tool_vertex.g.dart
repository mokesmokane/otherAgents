// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tool_vertex.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ToolVertex _$ToolVertexFromJson(Map<String, dynamic> json) => ToolVertex(
      id: json['id'] as String?,
      label: json['label'] as String,
      toolName: json['toolName'] as String,
      parameters: json['parameters'] as Map<String, dynamic>,
    )
      ..x = (json['x'] as num?)?.toDouble()
      ..y = (json['y'] as num?)?.toDouble();

Map<String, dynamic> _$ToolVertexToJson(ToolVertex instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'x': instance.x,
      'y': instance.y,
      'toolName': instance.toolName,
      'parameters': instance.parameters,
    };
