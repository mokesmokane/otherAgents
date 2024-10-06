import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:example/providers/providers.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SimulationDrawer extends ConsumerWidget {
  final String graphId;

  const SimulationDrawer({Key? key, required this.graphId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nodeSize = ref.watch(nodeSizeProvider(graphId));
    final edgeDistance = ref.watch(edgeDistanceProvider(graphId));
    final manyBodyStrength = ref.watch(manyBodyStrengthProvider(graphId));
    final collideRadius = ref.watch(collideRadiusProvider(graphId));
    final showArrows = ref.watch(showArrowsProvider(graphId));
    final nodeColor = ref.watch(nodeColorProvider(graphId));
    final edgeColor = ref.watch(edgeColorProvider(graphId));
    final graph = ref.watch(graphStateProvider(graphId));
    return Drawer(
      child: Container(
        color: Colors.grey[900],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue[800],
              ),
              child: Text(
                graph?.name ?? 'Options',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildSliderListTile('Node Size', nodeSize, 10, 50, 40, (value) => ref.read(nodeSizeProvider(graphId).notifier).state = value),
            _buildSliderListTile('Edge Distance', edgeDistance, 30, 300, 170, (value) => ref.read(edgeDistanceProvider(graphId).notifier).state = value),
            _buildSliderListTile('Many-Body Strength', manyBodyStrength, -500, 100, 600, (value) => ref.read(manyBodyStrengthProvider(graphId).notifier).state = value),
            _buildSliderListTile('Collide Radius', collideRadius, 5, 50, 45, (value) => ref.read(collideRadiusProvider(graphId).notifier).state = value),
            SwitchListTile(
              title: Text('Show Arrows', style: TextStyle(color: Colors.white)),
              value: showArrows,
              onChanged: (value) => ref.read(showArrowsProvider(graphId).notifier).state = value,
            ),
            _buildColorListTile('Node Color', nodeColor, () => _showColorPicker(context, ref, nodeColorProvider(graphId))),
            _buildColorListTile('Edge Color', edgeColor, () => _showColorPicker(context, ref, edgeColorProvider(graphId))),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderListTile(String title, double value, double min, double max, int divisions, Function(double) onChanged) {
    return ListTile(
      title: Text(title, style: TextStyle(color: Colors.white)),
      subtitle: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        label: value.round().toString(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildColorListTile(String title, Color color, VoidCallback onTap) {
    return ListTile(
      title: Text(title, style: TextStyle(color: Colors.white)),
      trailing: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.white, width: 1),
        ),
      ),
      onTap: onTap,
    );
  }

  void _showColorPicker(BuildContext context, WidgetRef ref, StateProvider<Color> colorProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData.dark(),
          child: AlertDialog(
            title: const Text('Pick a color'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: ref.read(colorProvider),
                onColorChanged: (Color color) {
                  ref.read(colorProvider.notifier).state = color;
                },
                showLabel: true,
                pickerAreaHeightPercent: 0.8,
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Done'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

}