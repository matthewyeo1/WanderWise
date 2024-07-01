import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'aesthetics/textfield_style.dart';
import 'utilities/utils.dart';

class GeminiChatPage extends StatefulWidget {
  const GeminiChatPage({super.key});
  @override
  GeminiChatPageState createState() => GeminiChatPageState();
}

class GeminiChatPageState extends State<GeminiChatPage> {
  final Gemini gemini = Gemini.instance; // Answer from Gemini
  List<ChatMessage> _messages = []; // List to hold chat messages
  late String userId; // Variable to hold current user ID
  TextEditingController budgetController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  bool isDarkMode = false;

  ChatUser geminiUser = ChatUser(
    id: '0',
  );

  @override
  void initState() {
    super.initState();
    _initializeUserId();
    _loadThemePreference();
  }

  Future<void> _initializeUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _loadThemePreference() async {
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    if (doc.exists && doc.data() != null) {
      setState(() {
        isDarkMode = doc['darkMode'] ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WanderWise AI'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: DashChat(
              messages: _messages,
              onSend: (ChatMessage chatMessage) {},
              currentUser: ChatUser(
                id: userId,
                firstName: userId,
              ),
              inputOptions: const InputOptions(
                  inputDisabled: true, 
                  inputDecoration: InputDecoration()
                ),
                messageOptions: MessageOptions(
                  currentUserContainerColor: !isDarkMode ? Colors.lightBlue : const Color(0xFF191970),
                  currentUserTextColor: !isDarkMode ? Colors.white : Colors.white 
                ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  style: const TextStyle(color: Colors.black),
                  cursorColor: Colors.black,
                  controller: budgetController,
                  decoration: TextFieldConfig.buildInputDecoration(
                    hintText: 'Enter budget',
                    prefixIcon: const Icon(
                      Icons.attach_money,
                      color: Colors.black45,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 5),
                TextField(
                  style: const TextStyle(color: Colors.black),
                  cursorColor: Colors.black,
                  controller: destinationController,
                  decoration: TextFieldConfig.buildInputDecoration(
                    hintText: 'Enter destination',
                    prefixIcon: const Icon(
                      Icons.location_on,
                      color: Colors.black45,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                TextField(
                  style: const TextStyle(color: Colors.black),
                  cursorColor: Colors.black,
                  controller: durationController,
                  decoration: TextFieldConfig.buildInputDecoration(
                    hintText: 'Enter duration (days)',
                    prefixIcon: const Icon(
                      Icons.calendar_today,
                      color: Colors.black45,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _handleSendMessage,
                  child: const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleSendMessage() {
    String budgetStr = budgetController.text;
    String destination = destinationController.text;
    String durationStr = durationController.text;

    if (budgetStr.isEmpty || destination.isEmpty || durationStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all the fields'),
        ),
      );
      return;
    }

    int budget;
    int duration;

    budget = int.parse(budgetStr);
    duration = int.parse(durationStr);

    if (!isValidBudget(budget)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Budget must be at least \$100"),
        ),
      );
      return;
    }

    if (!isValidDestination(destination)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid destination"),
        ),
      );
      return;
    }

    if (!isValidDuration(duration)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Your duration of stay should be between 1 to 30 days"),
        ),
      );
      return;
    }

    String prompt =
        'Create an itinerary to $destination, with a budget of \$$budget for $duration days.';

    ChatMessage chatMessage = ChatMessage(
      user: ChatUser(
        id: userId,
        firstName: userId,
      ),
      createdAt: DateTime.now(),
      text: prompt,
    );

    setState(() {
      _messages = [chatMessage, ..._messages]; 
    });

    try {
      gemini.streamGenerateContent(prompt).listen((event) {
        ChatMessage? lastMessage = _messages.firstOrNull;
        if (lastMessage != null && lastMessage.user == geminiUser) {
          lastMessage = _messages.removeAt(0);
          String response = event.content?.parts?.fold(
                  "", (previous, current) => "$previous ${current.text}") ??
              "";
          lastMessage.text += response;
          setState(() {
            _messages = [lastMessage!, ..._messages];
          });
        } else {
          String response = event.content?.parts?.fold(
                  "", (previous, current) => "$previous ${current.text}") ??
              "";
          ChatMessage message = ChatMessage(
            user: geminiUser,
            createdAt: DateTime.now(),
            text: response,
          );
          setState(() {
            _messages = [message, ..._messages];
          });
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
        ),
      );
    }
  }
}
