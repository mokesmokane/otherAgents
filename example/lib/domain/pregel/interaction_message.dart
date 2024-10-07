import 'package:example/domain/pregel/interaction_type.dart';

class InteractionMessage {
  final String interactionId;
  final InteractionType type;
  final String senderId;
  final String recipientId;
  final Map<String, dynamic> content;
  final int timestamp;

  InteractionMessage({
    required this.interactionId,
    required this.type,
    required this.senderId,
    required this.recipientId,
    required this.content,
    required this.timestamp
  });
}