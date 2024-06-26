import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController feedbackController = TextEditingController();

  @override
  void dispose() {
    feedbackController.dispose();
    super.dispose();
  }

  Future<void> submitFeedback() async {
    final feedback = feedbackController.text;

    if (feedback.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your feedback")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('UserFeedback').add({
        'feedback': feedback,
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Thank you for your feedback!")),
      );
      feedbackController.clear();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting feedback: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
        final theme = Theme.of(context);
    final textColor =
        theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'We value your feedback. Please let us know what you think!',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              cursorColor: textColor,
              controller: feedbackController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Enter your feedback here',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitFeedback,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
