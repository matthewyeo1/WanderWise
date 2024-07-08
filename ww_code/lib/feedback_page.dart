import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  FeedbackPageState createState() => FeedbackPageState();
}

// Feedback page
class FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController feedbackController = TextEditingController();
  final FeedbackService feedbackService = FeedbackService();

  @override
  void dispose() {
    feedbackController.dispose();
    super.dispose();
  }

  Future<void> submitFeedback() async {
    final feedback = feedbackController.text;

    if (feedback.isEmpty) {
      showSnackBar("Please enter your feedback");
      return;
    }

    final success = await feedbackService.submitFeedback(feedback);

    if (success) {
      showSnackBar("Thank you for your feedback!");
      feedbackController.clear();
    } else {
      showSnackBar("Error submitting feedback");
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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

// Upload feedback to Firestore
class FeedbackService {
  Future<bool> submitFeedback(String feedback) async {
    try {
      await FirebaseFirestore.instance.collection('UserFeedback').add({
        'feedback': feedback,
        'timestamp': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (error) {
      print("Error submitting feedback: $error");
      return false;
    }
  }
}
