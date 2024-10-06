// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_vertex.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AIVertex _$AIVertexFromJson(Map<String, dynamic> json) => AIVertex(
      id: json['id'] as String?,
      label: json['label'] as String,
      role: json['role'] as String,
      inputs:
          (json['inputs'] as List<dynamic>).map((e) => e as String).toList(),
      outputs:
          (json['outputs'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$AIVertexToJson(AIVertex instance) => <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'role': instance.role,
      'inputs': instance.inputs,
      'outputs': instance.outputs,
    };
