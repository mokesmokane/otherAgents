import 'package:example/domain/graph.dart';
import 'package:example/domain/pregel/interaction_mediator.dart';
import 'package:example/domain/pregel/interaction_message.dart';
import 'package:example/domain/pregel/pregel_behavior.dart';

class GraphRunner {
  final Graph graph;
  final IInteractionMediator mediator;
  final ISupersetRunner supersetRunner;

  GraphRunner(this.graph, this.mediator, this.supersetRunner);

  void run() {

    // Run the graph
  }

}

abstract class ISupersetRunner {
  
}


class SupersetRunner implements ISupersetRunner {
  final Graph graph;
  final IInteractionMediator interactionMediator;
  
  num MAX_STEPS = 10;

  SupersetRunner(this.graph, this.interactionMediator);

  void run() {
    bool converged = false;
    int step = 0;
    Map<String, List<InteractionMessage>> vertexMessages = {};

    // Initialize vertex messages
    for (var vertex in graph.vertices.values) {
      vertexMessages[vertex.id] = [];
    }

    while (!converged) {
      step++;

      // Step 1: Each vertex performs compute
      for (var vertex in graph.vertices.values) {
        var messages = vertexMessages[vertex.id] ?? [];
        if (vertex is PregelBehavior) {
          (vertex as PregelBehavior).compute(messages);
        }
      }

      // Step 2: Collect messages from vertices
      List<InteractionMessage> allMessages = [];
      for (var vertex in graph.vertices.values) {
        if (vertex is PregelBehavior) {
          var messages = (vertex as PregelBehavior).sendMessages();
          allMessages.addAll(messages);
        }
      }

      // Step 3: Pass messages to InteractionMediator
      interactionMediator.processMessages(allMessages);

      // Step 4: Get messages for next superstep
      vertexMessages = interactionMediator.getMessagesForVertices();

      // Step 5: Check for convergence condition
      converged = checkConvergenceCondition(vertexMessages);

      // Optional: Implement max superstep limit to prevent infinite loops
      if (step >= MAX_STEPS) {
        break;
      }
    }
  }

  bool checkConvergenceCondition(Map<String, List<InteractionMessage>> vertexMessages) {
    // For simplicity, assume convergence when no messages are to be delivered
    for (var messages in vertexMessages.values) {
      if (messages.isNotEmpty) {
        return false;
      }
    }
    return true;
  }
}

