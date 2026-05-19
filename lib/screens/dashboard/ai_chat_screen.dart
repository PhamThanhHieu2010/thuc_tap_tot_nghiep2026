import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';

import '../../config/theme.dart';
import '../../providers/app_provider.dart';
import '../../services/ai_service.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Service AI
  final AIService _aiService = AIService();
  
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add({
      'role': 'bot',
      'text': 'Chào bạn! Tôi là Smart Manager AI. Tôi có thể giúp bạn phân tích chi tiêu hoặc tư vấn tài chính (Hỗ trợ cả Online & Offline).'
    });
  }

  void _sendMessage() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    
    // 1. Hiện tin nhắn user
    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isLoading = true;
      _ctrl.clear();
    });
    _scrollToBottom();

    // 2. Lấy dữ liệu ví từ Provider
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final txs = appProvider.transactions;

    // 3. Gọi AI (Tự động chuyển Online/Offline)
    final response = await _aiService.chatWithData(text, txs);

    // 4. Hiện phản hồi
    if (mounted) {
      setState(() {
        _messages.add({'role': 'bot', 'text': response});
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppTheme.background, 
      appBar: AppBar(
        title: const Text("Trợ lý Tài chính", style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.background,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // KHUNG CHAT
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.withOpacity(0.3), width: 2),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))
                ]
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: _messages.length,
                  itemBuilder: (ctx, i) {
                    final msg = _messages[i];
                    final isUser = msg['role'] == 'user';
                    
                    return FadeInUp(
                      duration: const Duration(milliseconds: 300),
                      child: Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                          decoration: BoxDecoration(
                            color: isUser ? AppTheme.iosBlue : const Color(0xFFF2F4F7),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
                              bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isUser) 
                                 Padding(
                                   padding: const EdgeInsets.only(bottom: 4),
                                   child: Row(
                                     children: const [
                                       Icon(Icons.smart_toy_rounded, size: 14, color: AppTheme.iosPurple),
                                       SizedBox(width: 4),
                                       Text("Smart Bot", style: TextStyle(fontSize: 10, color: AppTheme.iosPurple, fontWeight: FontWeight.bold)),
                                     ],
                                   ),
                                 ),
                              Text(
                                msg['text']!,
                                style: TextStyle(
                                  color: isUser ? Colors.white : AppTheme.textDark, 
                                  height: 1.5,
                                  fontSize: 15
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // KHUNG NHẬP LIỆU
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(color: AppTheme.background),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isLoading)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.textGrey)),
                        SizedBox(width: 8),
                        Text("AI đang suy nghĩ...", style: TextStyle(fontStyle: FontStyle.italic, color: AppTheme.textGrey, fontSize: 12)),
                      ],
                    ),
                  ),
                
                Container(
                  decoration: BoxDecoration(
                     color: Colors.white,
                     borderRadius: BorderRadius.circular(30),
                     boxShadow: [
                       BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                     ]
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ctrl,
                          style: const TextStyle(color: AppTheme.textDark),
                          decoration: const InputDecoration(
                            hintText: "Hỏi về tiền, tiết kiệm, đầu tư...",
                            hintStyle: TextStyle(color: AppTheme.textGrey),
                            filled: false, 
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      GestureDetector(
                        onTap: _isLoading ? null : _sendMessage,
                        child: Container(
                          margin: const EdgeInsets.only(right: 5),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isLoading ? Colors.grey : AppTheme.iosBlue,
                          ),
                          child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: bottomInset > 0 ? 10 : 90),
              ],
            ),
          )
        ],
      ),
    );
  }
}