// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Channel _$ChannelFromJson(Map<String, dynamic> json) => Channel(
      id: json['id'] as String?,
      sourceId: json['sourceId'] as String,
      targetId: json['targetId'] as String,
      label: json['label'] as String,
      protocol: $enumDecode(_$CommunicationProtocolEnumMap, json['protocol']),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$ChannelToJson(Channel instance) => <String, dynamic>{
      'id': instance.id,
      'sourceId': instance.sourceId,
      'targetId': instance.targetId,
      'label': instance.label,
      'protocol': _$CommunicationProtocolEnumMap[instance.protocol]!,
      'metadata': instance.metadata,
    };

const _$CommunicationProtocolEnumMap = {
  CommunicationProtocol.command: 'command',
  CommunicationProtocol.requestResponse: 'requestResponse',
  CommunicationProtocol.message: 'message',
  CommunicationProtocol.collaboration: 'collaboration',
  CommunicationProtocol.longRunningTask: 'longRunningTask',
};
