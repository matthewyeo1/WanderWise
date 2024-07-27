import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'localization/locales.dart';

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
      showSnackBar(LocaleData.feedback.getString(context));
      return;
    }

    final success = await feedbackService.submitFeedback(feedback);

    if (success) {
      showSnackBar(LocaleData.thankFeedback.getString(context));
      feedbackController.clear();
    } else {
      showSnackBar(LocaleData.errorFeedback.getString(context));
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
        title: Text(LocaleData.feedbackWord.getString(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleData.feedbackSentence.getString(context),
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              cursorColor: textColor,
              controller: feedbackController,
              maxLines: 5,
              decoration:  InputDecoration(
                hintText: LocaleData.feedbackEnter.getString(context),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitFeedback,
              child: Text(LocaleData.submitButton.getString(context)),
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
