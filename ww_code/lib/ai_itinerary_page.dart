import 'aesthetics/textfield_style.dart';
import 'package:flutter/material.dart';

class AIItineraryPage extends StatefulWidget {
  const AIItineraryPage({super.key});

  @override
  AIItineraryPageState createState() => AIItineraryPageState();
}

class AIItineraryPageState extends State<AIItineraryPage> {
  final TextEditingController budgetController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController durationController = TextEditingController();

  Future<void> _generateItinerary() async {
    final String budget = budgetController.text;
    final String destination = destinationController.text;
    final String duration = durationController.text;

    if (budget.isEmpty || destination.isEmpty || duration.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    // TODO: Add AI generation logic here

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Itinerary generated successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate AI Itinerary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: budgetController,
              decoration: TextFieldConfig.buildInputDecoration(
                hintText: 'Budget',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: destinationController,
              decoration: TextFieldConfig.buildInputDecoration(
                hintText: 'Destination',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: durationController,
              decoration: TextFieldConfig.buildInputDecoration(
                hintText: 'Duration of Stay',
              ),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _generateItinerary,
              child: const Text('Generate Itinerary'),
            ),
          ],
        ),
      ),
    );
  }
}
