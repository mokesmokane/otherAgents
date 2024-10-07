import 'package:example/domain/pregel/interaction_message.dart';
import 'package:example/domain/pregel/interaction_state.dart';
import 'package:example/domain/pregel/interaction_type.dart';
import 'package:example/domain/pregel/pregel_behavior.dart';
import 'package:example/domain/vertex.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'ai_vertex.g.dart';

@JsonSerializable(explicitToJson: true)
class AIVertex extends Vertex implements PregelBehavior {
  final String role;
  final List<String> inputs;
  final List<String> outputs;
  final String? title;
  final String? systemPrompt;
  final String? requirements;
  final String? outputDescription;
  // New properties for Pregel
  @JsonKey(ignore: true)
  dynamic state;
  @JsonKey(ignore: true)
  PregelBehavior? pregelStrategy;

  AIVertex({
    String? id,
    required String label,
    required this.role,
    required this.inputs,
    required this.outputs,
    this.title,
    this.systemPrompt,
    this.requirements,
    this.outputDescription,
    this.pregelStrategy,
  }) : super(id: id, label: label, type: VertexType.ai);

  factory AIVertex.fromJson(Map<String, dynamic> json) => _$AIVertexFromJson(json);
  
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = super.toJson();
    json.addAll(_$AIVertexToJson(this));
    return json;
  }

  // Implement PregelBehavior methods
  @override
  void compute(List<InteractionMessage> messages) {
    if (pregelStrategy != null) {
      pregelStrategy?.compute(messages as List<InteractionMessage>);
    }
    else{
      _defaultCompute(messages);
    }
  }

  @override
  List<InteractionMessage> sendMessages() {
    if (pregelStrategy != null) {
      return pregelStrategy!.sendMessages();
    }
    return _defaultSendMessages();
  }

  // Default implementations
  void _defaultCompute(List<InteractionMessage> messages) {
    // Default computation logic
  }

  List<InteractionMessage> _defaultSendMessages() {
    // Default message sending logic
    return [];
  }

  // Method to set Pregel strategy
  void setPregelStrategy(PregelBehavior strategy) {
    pregelStrategy = strategy;
  }


  bool shouldStartInteraction() {
    // Logic to decide whether to start an interaction
    return true; // Placeholder
  }
  
  int currentTimestamp() {
    return DateTime.now().millisecondsSinceEpoch;
  }
}