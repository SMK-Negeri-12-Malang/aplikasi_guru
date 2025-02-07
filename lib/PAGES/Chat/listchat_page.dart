import 'package:aplikasi_ortu/PAGES/Chat/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatListPage extends StatefulWidget {
  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  List<Map<String, String>> chats = [];
  String searchQuery = '';
  bool isSearching = false;

  void _addChat(String name, String phoneNumber) {
    setState(() {
      chats.add({
        'name': name,
        'phone': phoneNumber,
        'message': 'Hello!',
        'time': _getCurrentTime(),
      });
    });
  }

  String _getCurrentTime() {
    return DateFormat('HH:mm').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredChats = chats.where((chat) {
      return chat['name']!.toLowerCase().contains(searchQuery.toLowerCase()) ||
          chat['phone']!.contains(searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: chats.isEmpty ? _buildEmptyState() : _buildChatList(filteredChats),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(25),
        ),
        child: TextField(
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Cari kontak... ',
            prefixIcon: Icon(Icons.search, color: Colors.blue[700]),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'Belum ada percakapan',
        style: TextStyle(color: Colors.grey[600], fontSize: 18),
      ),
    );
  }

  Widget _buildChatList(List<Map<String, String>> filteredChats) {
    return ListView.builder(
      itemCount: filteredChats.length,
      itemBuilder: (context, index) {
        final chat = filteredChats[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue[700],
            child: Text(
              chat['name']![0].toUpperCase(),
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(chat['name']!, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(chat['message']!, style: TextStyle(color: Colors.black54)),
          trailing: Text(chat['time']!, style: TextStyle(color: Colors.grey[700])),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatPage(chatData: chat)),
            );
          },
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => _showAddContactSheet(context),
      backgroundColor: Colors.blue[700],
      child: Icon(Icons.chat, color: Colors.white),
    );
  }

  void _showAddContactSheet(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nama'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Nomor Telepon'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700]),
                onPressed: () {
                  if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                    _addChat(nameController.text, phoneController.text);
                    Navigator.pop(context);
                  }
                },
                child: Text('Tambah Kontak', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }
}
