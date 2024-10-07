import 'package:example/domain/pregel/interaction_artefact.dart';
import 'package:example/domain/pregel/interaction_message.dart';
import 'package:example/domain/pregel/interaction_type.dart';

abstract class InteractionState {
  final InteractionType interactionType;
  final String interactionId;
  final String initiatorId;
  final String receiverId;
  final List<InteractionMessage> messageHistory;
  final List<InteractionMessage> pendingMessages;
  final List<InteractionArtefact> artefacts;

  InteractionState({
    required this.interactionType,
    required this.interactionId,
    required this.initiatorId,
    required this.receiverId,
    required this.messageHistory,
    required this.pendingMessages,
    required this.artefacts,
  });


  static InteractionState create({required InteractionType interactionType, required String interactionId, required String initiatorId, required String receiverId}) {
    switch (interactionType) {
      case InteractionType.requestResponse:
        return RequestResponseInteractionState(
          interactionType: interactionType,
          interactionId: interactionId,
          initiatorId: initiatorId,
          receiverId: receiverId,
          messageHistory: []
        );
      case InteractionType.longRunning:
        return LongRunningInteractionState(
          interactionType: interactionType,
          interactionId: interactionId,
          initiatorId: initiatorId,
          receiverId: receiverId,
          messageHistory: []
        );
      case InteractionType.command:
        return CommandInteractionState(
          interactionType: interactionType,
          interactionId: interactionId,
          initiatorId: initiatorId,
          receiverId: receiverId,
        );
      default:
        return InformationMessageInteractionState(
          interactionType: interactionType,
          interactionId: interactionId,
          initiatorId: initiatorId,
          receiverId: receiverId,
          messageHistory: []
        );
    }
  }
}

class RequestResponseInteractionState extends InteractionState {
  RequestResponseInteractionState({
    required InteractionType interactionType,
    required String interactionId,
    required String initiatorId,
    required String receiverId,
    List<InteractionMessage> messageHistory = const [],
    List<InteractionMessage> pendingMessages = const [],
    List<InteractionArtefact> artefacts = const [],
  }) : super(
    interactionType: interactionType,
    interactionId: interactionId,
    initiatorId: initiatorId,
    receiverId: receiverId,
    messageHistory: messageHistory,
    pendingMessages: pendingMessages,
    artefacts: artefacts.toList(),
  );
}

class LongRunningInteractionState extends InteractionState {

  LongRunningInteractionState({
    required InteractionType interactionType,
    required String interactionId,
    required String initiatorId,
    required String receiverId,
    List<InteractionMessage> messageHistory = const [],
    List<InteractionMessage> pendingMessages = const [],
    List<InteractionArtefact> artefacts = const [],
  }) : super(
    interactionType: interactionType,
    interactionId: interactionId,
    initiatorId: initiatorId,
    receiverId: receiverId,
    messageHistory: messageHistory,
    pendingMessages: pendingMessages,
    artefacts: artefacts.toList(),
  );
}


class CommandInteractionState extends InteractionState {

  CommandInteractionState({
    required InteractionType interactionType,
    required String interactionId,
    required String initiatorId,
    required String receiverId,
    List<InteractionMessage> messageHistory = const [],
    List<InteractionMessage> pendingMessages = const [],
    List<InteractionArtefact> artefacts = const [],
  }) : super(
    interactionType: interactionType,
    interactionId: interactionId,
    initiatorId: initiatorId,
    receiverId: receiverId,
    messageHistory: messageHistory,
    pendingMessages: pendingMessages,
    artefacts: artefacts.toList(),
  );
} 

class InformationMessageInteractionState extends InteractionState {

  InformationMessageInteractionState({
    required InteractionType interactionType,
    required String interactionId,
    required String initiatorId,
    required String receiverId,
    List<InteractionMessage> messageHistory = const [],
    List<InteractionMessage> pendingMessages = const [],
    List<InteractionArtefact> artefacts = const [],
  }) : super(
    interactionType: interactionType,
    interactionId: interactionId,
    initiatorId: initiatorId,
    receiverId: receiverId,
    messageHistory: messageHistory,
    pendingMessages: pendingMessages,
    artefacts: artefacts.toList(),
    );  
  }

