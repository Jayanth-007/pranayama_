import 'package:flutter/material.dart';

Future<Map<String, int>?> showCustomizationDialog(
    BuildContext context, {
      required int initialInhale,
      required int initialExhale,
      required int initialHold,
    }) async {
  double inhale = initialInhale.toDouble();
  double exhale = initialExhale.toDouble();
  double hold = initialHold.toDouble();

  return await showModalBottomSheet<Map<String, int>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 16),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return Column(
                        children: [
                          _buildSlider(
                            context,
                            label: 'Inhale',
                            value: inhale,
                            onChanged: (value) => setState(() => inhale = value),
                          ),
                          const SizedBox(height: 24),
                          _buildSlider(
                            context,
                            label: 'Exhale',
                            value: exhale,
                            onChanged: (value) => setState(() => exhale = value),
                          ),
                          const SizedBox(height: 24),
                          _buildSlider(
                            context,
                            label: 'Hold',
                            value: hold,
                            onChanged: (value) => setState(() => hold = value),
                          ),
                          const SizedBox(height: 32),
                          _buildSaveButton(context, inhale, exhale, hold),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }
  );
}

Widget _buildHeader(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Text(
        'Customize Breathing',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.pop(context),
      ),
    ],
  );
}

Widget _buildSlider(
    BuildContext context, {
      required String label,
      required double value,
      required ValueChanged<double> onChanged,
    }) {
  final bool isHold = label == 'Hold';
  final double minValue = isHold ? 0 : 1;
  final int divisions = isHold ? 10 : 9;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${value.toInt()} sec',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Slider(
        value: value,
        min: minValue,
        max: 10,
        divisions: divisions,
        label: value.toInt().toString(),
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
        inactiveColor: Colors.grey[300],
      ),
    ],
  );
}

Widget _buildSaveButton(BuildContext context, double inhale, double exhale, double hold) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        Navigator.pop(context, {
          'inhale': inhale.toInt(),
          'exhale': exhale.toInt(),
          'hold': hold.toInt(),
        });
      },
      child: const Text(
        'BEGIN',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
  );
}