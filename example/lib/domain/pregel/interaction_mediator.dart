import 'package:example/domain/pregel/interaction_message.dart';
import 'package:example/domain/pregel/interaction_state.dart';
import 'package:example/domain/pregel/interaction_type.dart';

abstract class IInteractionMediator {
  void processMessages(List<InteractionMessage> messages);

  Map<String, List<InteractionMessage>> getMessagesForVertices();
}

class InteractionMediator implements IInteractionMediator {
  final Map<String, InteractionState> interactions = {};

  void processMessages(List<InteractionMessage> messages) {
    for (var message in messages) {
      // Check if interaction exists
      var interaction = interactions[message.interactionId];

      if (interaction == null) {
        // Start new interaction
        interaction = InteractionState.create(
          interactionType: message.type,
          interactionId: message.interactionId,
          initiatorId: message.senderId,
          receiverId: message.recipientId,
        );
        interactions[message.interactionId] = interaction;
      }

      // Update interaction state
      interaction.messageHistory.add(message);

      // Handle interaction logic based on type
      handleInteraction(interaction, message);
    }
  }

  final Map<String, List<InteractionMessage>> messagesForNextSuperstep = {};

  void handleInteraction(InteractionState interaction, InteractionMessage message) {
    switch (interaction.interactionType) {
      case InteractionType.requestResponse:
        // For requestResponse, ensure a response is sent back
        if (message.senderId == interaction.initiatorId) {
          // Message from initiator, forward to receiver
          enqueueMessageForNextSuperstep(message.recipientId, message);
        } else {
          // Message from receiver, send response back to initiator
          var responseMessage = InteractionMessage(
            interactionId: interaction.interactionId,
            type: interaction.interactionType,
            senderId: message.senderId,
            recipientId: interaction.initiatorId,
            content: {'data': 'Response'},
            timestamp: DateTime.now().millisecondsSinceEpoch,
          );
          enqueueMessageForNextSuperstep(responseMessage.recipientId, responseMessage);
        }
        break;

      // Handle other interaction types...
      case InteractionType.longRunning:
        // Custom logic for long-running interactions
        break;

      // Additional cases for other interaction types
      default:
        break;
    }
  }

  void enqueueMessageForNextSuperstep(String recipientId, InteractionMessage message) {
    messagesForNextSuperstep.putIfAbsent(recipientId, () => []).add(message);
  }

  Map<String, List<InteractionMessage>> getMessagesForVertices() {
    var messages = Map<String, List<InteractionMessage>>.from(messagesForNextSuperstep);
    messagesForNextSuperstep.clear();
    return messages;
  }
}
