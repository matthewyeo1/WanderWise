import 'package:flutter/material.dart';
import 'package:ww_code/feedback_page.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildFAQSection(),
          const SizedBox(height: 32), 
          const Text(
            'Need More Assistance?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildContactSection(context),
          const SizedBox(height: 32), 
          const Text(
            'Send Feedback',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildFeedbackSection(context),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFAQItem('How do I reset my password?',
            'To reset your password, go to the settings page and click on "Change Password". Follow the instructions provided.'),
        _buildFAQItem('What type of documents can be uploaded?',
            'WanderWise only allows for .pdf and .doc type documents to be uploaded under "Flights/Bookings".'),
        _buildFAQItem('Am I able to view my itineraries and documents offline?',
            'Unfortunately, the current version of the app does not support offline sync. Stay tuned for future updates!'),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title:
          Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(answer),
        )
      ],
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Us',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'support@example.com',
          style: TextStyle(color: Colors.grey),
        ),
        SizedBox(height: 16),
        Text(
          'Call Us',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          '(123) 456-7890',
          style: TextStyle(color: Colors.grey),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFeedbackSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Have feedback or suggestions?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.feedback),
          title: const Text('Send Feedback'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FeedbackPage()),
            );
          },
        ),
      ],
    );
  }
}
