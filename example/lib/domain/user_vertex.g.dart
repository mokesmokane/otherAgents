// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_vertex.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserVertex _$UserVertexFromJson(Map<String, dynamic> json) => UserVertex(
      id: json['id'] as String?,
      label: json['label'] as String,
      userInput: json['userInput'] as String,
    );

Map<String, dynamic> _$UserVertexToJson(UserVertex instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'userInput': instance.userInput,
    };
