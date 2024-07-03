import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:ww_code/aesthetics/themes.dart';
import 'aesthetics/textfield_style.dart';
import 'utilities/utils.dart';
import 'storage/itinerary_service.dart';

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
  bool isLoading = true;
  bool isGenerating = false;
  final ItineraryService _itineraryService = ItineraryService();

  // Gemini identity on Firestore
  ChatUser geminiUser = ChatUser(
    id: '0',
    profileImage:
        "https://external-preview.redd.it/google-gemini-pro-api-available-through-ai-studio-v0-FJfyR710n5wu1VMO6EJEBezHIFtvYiTfMm5tsyjNQBg.jpg?auto=webp&s=66ffb8c51c3a5dd7bc1b5747deca4696f25b8092",
  );

  @override
  void initState() {
    super.initState();
    _initializeUserId();
    _loadThemePreference();
    _loadMessages();
  }

  Future<void> _initializeUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
      _loadMessages();
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

  Future<void> _loadMessages() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('AI_Generated_Itineraries')
        .orderBy('createdAt', descending: true)
        .get();

    setState(() {
      _messages = snapshot.docs
          .map(
              (doc) => ChatMessage.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      isLoading = false;
    });
  }

  Future<void> _saveMessage(ChatMessage message) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('AI_Generated_Itineraries')
        .doc(message.createdAt.toIso8601String())
        .set(message.toJson());
  }

  Future<void> _saveToItineraryPage(ChatMessage message) async {
    Map<String, dynamic> newItem = {
      'title': '*** Generated Itinerary ***',
      'startDate': '-',
      'endDate': '-',
      'description': message.text,
      'id': message.createdAt.toIso8601String(),
    };
    await _itineraryService.saveItinerary(userId, newItem);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Saved to trips page!'),
    ));
  }

  Future<void> _clearMessages() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('AI_Generated_Itineraries')
        .get();

    for (DocumentSnapshot doc in snapshot.docs) {
      await doc.reference.delete();
    }

    setState(() {
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Create Itineraries with Gemini'), actions: [
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: _clearMessages,
        ),
      ]),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).brightness == Brightness.light
                    ? Theme.of(context)
                        .customColors
                        .circularProgressIndicatorLight
                    : Theme.of(context)
                        .customColors
                        .circularProgressIndicatorDark,
              ),
            ))
          : Column(
              children: <Widget>[
                Expanded(
                  child: _messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'images/ai_itinerary.png',
                                width: 200,
                                height: 200,
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'Generate itineraries with Gemini AI!',
                                style: TextStyle(fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                              const Text(
                                'Enter your desired budget, destination \n and duration of stay below. Save generated \n itineraries by clicking on the text generated!',
                                style: TextStyle(fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : DashChat(
                          messages: _messages,
                          onSend: (ChatMessage chatMessage) {},
                          currentUser: ChatUser(
                            id: userId,
                            firstName: userId,
                          ),
                          inputOptions: InputOptions(
                            inputDisabled: true,
                            inputDecoration: InputDecoration(
                              border: InputBorder.none,
                              suffixIcon: isGenerating
                                  ? Center(
                                      child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? Theme.of(context)
                                                  .customColors
                                                  .circularProgressIndicatorLight
                                              : Theme.of(context)
                                                  .customColors
                                                  .circularProgressIndicatorDark,
                                        ),
                                      ),
                                    ))
                                  : null,
                            ),
                          ),
                          messageOptions: MessageOptions(
                              currentUserContainerColor: !isDarkMode
                                  ? Colors.lightBlue
                                  : const Color(0xFF191970),
                              currentUserTextColor:
                                  !isDarkMode ? Colors.white : Colors.white,
                              onPressMessage: (ChatMessage message) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.white,
                                      title: const Text('Save to Trips Page',
                                          style:
                                              TextStyle(color: Colors.black)),
                                      content: const Text('Save to Trips page?',
                                          style:
                                              TextStyle(color: Colors.black)),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('Cancel',
                                              style: TextStyle(
                                                  color: Colors.lightBlue)),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: const Text('Save',
                                              style: TextStyle(
                                                  color: Colors.lightBlue)),
                                          onPressed: () {
                                            _saveToItineraryPage(message);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }),
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
                        child: const Text('Generate Itinerary'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // Algorithm to generate answer when given prompt by the user
  void _handleSendMessage() {
    String budgetStr = budgetController.text;
    String destination = destinationController.text;
    String durationStr = durationController.text;

    if (budgetStr.isEmpty || destination.isEmpty || durationStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please enter your desired budget, destination and duration of stay'),
        ),
      );
      return;
    }

    // Convert string to int for validity checks
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

    // Fixed prompt statement
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
      isGenerating = true;
    });

    _saveMessage(chatMessage);

    // To concatenate all portions of the response
    StringBuffer completeResponse = StringBuffer();
    ChatMessage? partialMessage;

    try {
      gemini.streamGenerateContent(prompt).listen((event) {
        String response = event.content?.parts?.fold(
                "", (previous, current) => "$previous ${current.text}") ??
            "";
        completeResponse.write(response);

        setState(() {
          if (_messages.isNotEmpty &&
              _messages.first.user.id == geminiUser.id) {
            // Create a new ChatMessage object with the updated response
            partialMessage = ChatMessage(
              user: geminiUser,
              createdAt: _messages.first.createdAt,
              text: completeResponse.toString(),
            );
            // Replace the existing message with the updated one
            _messages[0] = partialMessage!;
          } else {
            // Create a new message if there's no existing message from AI
            partialMessage = ChatMessage(
              user: geminiUser,
              createdAt: DateTime.now(),
              text: completeResponse.toString(),
            );
            _messages = [partialMessage!, ..._messages];
          }
        });
      }, onDone: () {
        if (partialMessage != null) {
          _saveMessage(partialMessage!);
        }
        setState(() {
          isGenerating = false;
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
        ),
      );
      setState(() {
        isGenerating = false;
      });
    }
  }
}
