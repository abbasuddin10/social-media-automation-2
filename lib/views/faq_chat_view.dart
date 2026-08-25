import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class FaqChatView extends StatefulWidget {
  const FaqChatView({super.key});

  @override
  State<FaqChatView> createState() => _FaqChatViewState();
}

class _FaqChatViewState extends State<FaqChatView> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  // Gemini API ইনিশিয়ালাইজেশন
  late final GenerativeModel _model;
  late final ChatSession _chat;

  @override
  void initState() {
    super.initState();
    // ⚠️ আপনার GEMINI_API_KEY বসান
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: 'YOUR_GEMINI_API_KEY',
      systemInstruction: Content.text(
        "আপনি একটি সোশ্যাল মিডিয়া অটোমেশন অ্যাপের হেল্প ডেস্ক অ্যাসিস্ট্যান্ট। "
        "ইউজারকে অ্যাপের কাজ, সুবিধা ও সমস্যা সমাধানে সংক্ষিপ্ত এবং ফ্রেন্ডলি বাংলায় উত্তর দিন।",
      ),
    );
    _chat = _model.startChat();
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"sender": "user", "text": text});
      _isLoading = true;
    });
    _controller.clear();

    try {
      final response = await _chat.sendMessage(Content.text(text));
      setState(() {
        _messages.add({
          "sender": "ai",
          "text": response.text ?? "দুঃখিত, কোনো উত্তর পাওয়া যায়নি।",
        });
      });
    } catch (e) {
      setState(() {
        _messages.add({
          "sender": "ai",
          "text": "নেটওয়ার্ক সমস্যা হচ্ছে, আবার চেষ্টা করুন।",
        });
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FAQ & AI Support")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg["sender"] == "user";
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.deepPurple : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg["text"] ?? "",
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "আপনার প্রশ্নটি লিখুন...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepPurple),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
