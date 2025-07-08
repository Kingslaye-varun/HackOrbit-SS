import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';

class GeminiNutritionChatbot extends StatefulWidget {
  const GeminiNutritionChatbot({super.key});

  @override
  State<GeminiNutritionChatbot> createState() => _GeminiNutritionChatbotState();
}

class _GeminiNutritionChatbotState extends State<GeminiNutritionChatbot> {
  final List<ChatMessage> _messages = [];
  final _textController = TextEditingController();
  bool _isTyping = false;
  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  static const _apiKey = 'AIzaSyB8pxAPqKybFqs4yk17Yakh3KbjaV9G2Wc';
  static const _sportsNutritionInstruction = """
You are SportifAI Nutritionist, an expert AI assistant specialized in sports nutrition and diet for athletes. 

IMPORTANT BEHAVIOR:
- ALWAYS provide helpful, actionable answers to sports nutrition questions
- Give general advice first, then mention you can provide more specific recommendations if needed
- Don't keep asking for details - provide useful information based on what the user asks
- Only decline to answer if the question is completely unrelated to sports, fitness, nutrition, or health
- Be conversational and helpful, not robotic

Your capabilities:
- Provide meal plans and nutrition advice for athletes
- Recommend pre/post-workout nutrition strategies  
- Advise on hydration and supplements
- Help with weight management for athletes
- Offer recovery nutrition advice
- General fitness and diet guidance

RESPONSE STYLE:
- Give direct, helpful answers
- Provide practical tips and recommendations
- Include general guidelines that work for most people
- Only ask follow-up questions if the user wants more personalized advice
- Be encouraging and supportive

Begin by greeting the user warmly and explaining you're here to help with sports nutrition.
""";

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  void _initializeModel() async {
    try {
      // Initialize the model with updated configuration
      _model = GenerativeModel(
        model: 'gemini-1.5-flash', // Using stable model name
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 1000,
          topK: 40,
          topP: 0.95,
        ),
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
        ],
      );
      
      // Start chat session
      _chatSession = _model.startChat(history: []);
      _addWelcomeMessage();
    } catch (e) {
      print('Model initialization error: $e');
      _showError('Failed to initialize AI model');
    }
  }

  void _addWelcomeMessage() async {
    setState(() => _isTyping = true);
    
    try {
      final response = await _chatSession.sendMessage(
        Content.text(_sportsNutritionInstruction),
      );
      
      final text = response.text ?? "Hello! I'm your Sports Nutrition AI Assistant. How can I help you today?";
      
      setState(() {
        _messages.insert(0, ChatMessage(
          text: text,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isTyping = false;
      });
    } catch (e) {
      print('Welcome message error: $e');
      // Add a fallback welcome message
      setState(() {
        _messages.insert(0, ChatMessage(
          text: "Hi there! I'm SportifAI Nutritionist 🏃‍♂️💪\n\nI'm here to help you with sports nutrition, diet plans, supplements, and fitness advice. Just ask me anything about nutrition for athletes, workout meals, or healthy eating - I'll give you practical, actionable advice!\n\nWhat can I help you with today?",
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isTyping = false;
      });
    }
  }

  void _handleSendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isTyping) return;

    // Add user message
    setState(() {
      _messages.insert(0, ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
      _textController.clear();
    });

    try {
      // Send message to Gemini
      final response = await _chatSession.sendMessage(
        Content.text(text),
      );

      final responseText = response.text;
      
      if (responseText != null && responseText.isNotEmpty) {
        setState(() {
          _messages.insert(0, ChatMessage(
            text: responseText,
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isTyping = false;
        });
      } else {
        throw Exception('Empty response from AI');
      }
    } catch (e) {
      print('Send message error: $e');
      
      // Fallback response
      setState(() {
        _messages.insert(0, ChatMessage(
          text: "I'm sorry, I'm having trouble processing your request right now. Please try again in a moment.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isTyping = false;
      });
      
      _showError('Failed to get response from AI: ${e.toString()}');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sports Nutrition AI'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _ChatBubble(
                        message: message.text,
                        isUser: message.isUser,
                        timestamp: message.timestamp,
                      );
                    },
                  ),
          ),
          if (_isTyping)
            Container(
              padding: const EdgeInsets.all(16.0),
              child: const Row(
                children: [
                  SizedBox(width: 16),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'SportifAI is typing...',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Ask about sports nutrition...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onSubmitted: (_) => _handleSendMessage(),
                    enabled: !_isTyping,
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _isTyping ? null : _handleSendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class _ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final DateTime timestamp;

  const _ChatBubble({
    required this.message,
    required this.isUser,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue[100],
              child: const Icon(Icons.smart_toy, size: 16, color: Colors.blue),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.blue : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    DateFormat('h:mm a').format(timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, size: 16, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
}