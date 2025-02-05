import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final Map<String, String> chatData;
  ChatPage({required this.chatData});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late TextEditingController messageController;
  List<Map<String, String>> messages = [];

  @override
  void initState() {
    super.initState();
    messageController = TextEditingController();
    messages.add({
      'sender': widget.chatData['name']!,
      'message': 'Hello, welcome!',
      'time': _getCurrentTime(),
    });
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  }

  void _sendMessage(String message) {
    if (message.isNotEmpty) {
      setState(() {
        messages.add({
          'sender': 'You',
          'message': message,
          'time': _getCurrentTime(),
        });
      });

      if (message.toLowerCase().contains('khansa')) {
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            messages.add({
              'sender': 'Bot',
              'message': 'Kamu sangat cantik',
              'time': _getCurrentTime(),
            });
          });
        });
      }
      messageController.clear(); // Bersihkan input setelah mengirim pesan
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Text(
                widget.chatData['name']![0], // Ambil inisial nama
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(width: 10),
            Text(widget.chatData['name']!),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.call),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.video_call),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                bool isSentByUser = messages[index]['sender'] == 'You';
                return Align(
                  alignment:
                      isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSentByUser ? Colors.blueAccent : Colors.grey[300],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                        bottomLeft: isSentByUser ? Radius.circular(15) : Radius.zero,
                        bottomRight: isSentByUser ? Radius.zero : Radius.circular(15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          spreadRadius: 1,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          messages[index]['message']!,
                          style: TextStyle(
                            color: isSentByUser ? Colors.white : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 5),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            messages[index]['time']!,
                            style: TextStyle(
                              color: isSentByUser ? Colors.white70 : Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.emoji_emotions, color: Colors.blueAccent),
                  onPressed: () {},
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (value) => _sendMessage(value),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _sendMessage(messageController.text),
                  child: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.send, color: Colors.white),
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
