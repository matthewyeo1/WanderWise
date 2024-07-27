import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:ww_code/feedback_page.dart';
import 'localization/locales.dart';

// Contains FAQ, email and contact no. widgets and feedback section 
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleData.help.getString(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            LocaleData.faq.getString(context),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildFAQSection(context),
          const SizedBox(height: 32), 
          Text(
            LocaleData.moreAssistance.getString(context),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildContactSection(context),
          const SizedBox(height: 32), 
          Text(
            LocaleData.sendFeedback.getString(context),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildFeedbackSection(context),
        ],
      ),
    );
  }

  Widget _buildFAQSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFAQItem(LocaleData.q1.getString(context),
            LocaleData.a1.getString(context)),
        _buildFAQItem(LocaleData.q2.getString(context),
            LocaleData.a2.getString(context)),
        _buildFAQItem(LocaleData.q3.getString(context),
            LocaleData.a3.getString(context)),
        _buildFAQItem(LocaleData.q4.getString(context),
            LocaleData.a4.getString(context)),
      
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleData.emailUs.getString(context),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'support@example.com',
          
        ),
        const SizedBox(height: 16),
        Text(
          LocaleData.callUs.getString(context),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          '(123) 456-7890',
          
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFeedbackSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleData.feedbackQuestion.getString(context),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.feedback),
          title: Text(LocaleData.sendFeedback.getString(context)),
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
