import 'package:example/domain/communicatoin_protocol.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';


part 'channel.g.dart';

@JsonSerializable(explicitToJson: true)
class Channel {
  final String id;
  final String sourceId;
  final String targetId;
  final String label;
  final CommunicationProtocol protocol;
  final Map<String, dynamic> metadata;

  Channel({
    String? id,
    required this.sourceId,
    required this.targetId,
    required this.label,
    required this.protocol,
    this.metadata = const {},
  }) : id = id ?? Uuid().v4();

  factory Channel.fromJson(Map<String, dynamic> json) => _$ChannelFromJson(json);
  Map<String, dynamic> toJson() => _$ChannelToJson(this);

  factory Channel.command({
    required String sourceId,
    required String targetId,
    required String command,
    Map<String, dynamic> additionalMetadata = const {},
  }) {
    return Channel(
      sourceId: sourceId,
      targetId: targetId,
      label: 'Command: $command',
      protocol: CommunicationProtocol.command,
      metadata: {'command': command, ...additionalMetadata},
    );
  }

  factory Channel.requestResponse({
    required String sourceId,
    required String targetId,
    required String request,
    Map<String, dynamic> additionalMetadata = const {},
  }) {
    return Channel(
      sourceId: sourceId,
      targetId: targetId,
      label: 'Request: $request',
      protocol: CommunicationProtocol.requestResponse,
      metadata: {'request': request, ...additionalMetadata},
    );
  }

  // ... other factory methods (message, collaboration, longRunningTask) ...
}