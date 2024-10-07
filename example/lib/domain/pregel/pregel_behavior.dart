
// New interface for Pregel behavior
import 'package:example/domain/ai_vertex.dart';
import 'package:example/domain/pregel/interaction_message.dart';
import 'package:example/domain/pregel/interaction_type.dart';
import 'package:uuid/uuid.dart';

abstract class PregelBehavior {
  void compute(List<InteractionMessage> messages);
  List<InteractionMessage> sendMessages();
}


class DefaultPregelBehavior implements PregelBehavior {
  final String id;
  final List<InteractionMessage> outgoingMessages = [];
  final Function currentTimestamp;
  DefaultPregelBehavior({required this.id, required this.currentTimestamp});

  @override
  void compute(List<InteractionMessage> messages) {
    // Default implementation
  }

  @override
  List<InteractionMessage> sendMessages() {
    // Default implementation
    return [];
  }

   void startInteraction({
    required String receiverId,
    required InteractionType type,
    required Map<String, dynamic> content,
  }) {
    var interactionId = Uuid().v4();
    // Create the first message
    var message = InteractionMessage(
      interactionId: interactionId,
      type: type,
      senderId: this.id,
      recipientId: receiverId,
      content: content,
      timestamp: currentTimestamp()
    );
    outgoingMessages.add(message);
  }
}

class AIPregelBehavior implements PregelBehavior{
  final AIVertex aiVertex;

  AIPregelBehavior({required this.aiVertex});
  

  @override
  void compute(List<InteractionMessage> messages) {
    // TODO: implement compute
  }

  @override
  List<InteractionMessage> sendMessages() {
    // TODO: implement sendMessages
    throw UnimplementedError();
  }
    
}
