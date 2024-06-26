import 'package:flutter/material.dart';

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
          const SizedBox(height: 16),
          const Text(
            'Need More Assistance?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildContactSection(),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFAQItem('How do I reset my password?', 'To reset your password, go to the settings page and click on "Change Password". Follow the instructions provided.'),
        _buildFAQItem('What type of documents can be uploaded?', 'WanderWise only allows for .pdf and .doc type documents to be uploaded under "Flights/Bookings".'),
        _buildFAQItem('Am I able to view my itineraries and documents offline?', 'Unfortunately, the current version of the app does not support offline sync. Stay tuned for future updates!'),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: [Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(answer),
      )],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const Icon(Icons.email),
          title: const Text('Email Us'),
          subtitle: const Text('support@example.com'),
          onTap: () {
            // Implement email sending functionality
          },
        ),
        ListTile(
          leading: const Icon(Icons.phone),
          title: const Text('Call Us'),
          subtitle: const Text('(123) 456-7890'),
          onTap: () {
            // Implement call functionality
          },
        ),
        ListTile(
          leading: const Icon(Icons.feedback),
          title: const Text('Send Feedback'),
          onTap: () {
            // Implement feedback form functionality
          },
        ),
      ],
    );
  }
}

