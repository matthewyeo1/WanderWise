import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'aesthetics/textfield_style.dart';

class GeminiChatPage extends StatefulWidget {
  const GeminiChatPage({super.key});
  @override
  _GeminiChatPageState createState() => _GeminiChatPageState();
}

class _GeminiChatPageState extends State<GeminiChatPage> {
  final Gemini gemini = Gemini.instance; // Answer from Gemini
  List<ChatMessage> _messages = []; // List to hold chat messages
  late String userId; // Variable to hold current user ID
  TextEditingController textController = TextEditingController();
  bool isDarkMode = false;

  ChatUser geminiUser = ChatUser(
    id: '0',
    firstName: 'WanderWise',
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
              onSend: _handleSendMessage,
              currentUser: ChatUser(
                id: userId,
                firstName: userId,
              ),
              inputOptions: InputOptions(
                inputTextStyle: const TextStyle(color: Colors.black),
                cursorStyle: const CursorStyle(color: Colors.black),
                sendButtonBuilder: (sendMessage) {
                  return IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      sendMessage();
                    },
                  );
                },
                inputDecoration: TextFieldConfig.buildInputDecoration(
                  hintText: 'Type a message...',
                  prefixIcon: const Icon(
                    Icons.message,
                    color: Colors.black45,
                  ),
                ),
                textController: textController,
              ),
              messageOptions: MessageOptions(
                  currentUserContainerColor:
                      !isDarkMode ? Colors.blue : Colors.white,
                  currentUserTextColor:
                      !isDarkMode ? Colors.white : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  // Handle sending messages
  void _handleSendMessage(ChatMessage chatMessage) {
    setState(() {
      _messages = [chatMessage, ..._messages]; // Add new message to the list
    });

    try {
      String response = chatMessage.text;
      gemini.streamGenerateContent(response).listen((event) {
        ChatMessage? lastMessage = _messages.firstOrNull;
        if (lastMessage != null && lastMessage.user == geminiUser) {
          lastMessage = _messages.removeAt(0);
          String response = event.content?.parts?.fold("", (previous, current) => "$previous ${current.text}") ?? "";
          lastMessage.text += response;
          setState(() {
            _messages = [lastMessage!, ..._messages];
          });

        } else {
          String response = event.content?.parts?.fold("", (previous, current) => "$previous ${current.text}") ?? "";
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
          content: Text('An error occured: $e'),
        ),
      );
    }
  }
}
