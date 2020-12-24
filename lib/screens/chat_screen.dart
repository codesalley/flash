import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';

class ChatScreen extends StatefulWidget {
  static const String id = 'chatScreen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseUser user;
  String messageText;
  final firestore = Firestore.instance;

  Future<void> getCurrentUser() async {
    var currentUser = await firebaseAuth.currentUser();
    if (currentUser != null) {
      user = currentUser;
      print(user.email);
    }
  }

  void getMessages() async {
    var messages = await firestore.collection('messages').getDocuments();

    for (var message in messages.documents) {
      print(message.data['text']);
    }
  }

  @override
  void initState() {
    getCurrentUser();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                getMessages();
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('messages').snapshots(),
              builder: (context, snapshot) {
                final messages = snapshot.data.documents;
                List<MessageTile> messageStreams = [];
                for (var message in messages) {
                  final messageSender = message.data['sender'];
                  final messageText = message.data['text'];

                  if (messageSender == user.email) {}

                  messageStreams.add(MessageTile(
                    sender: messageSender.toString().split('@')[0],
                    text: messageText,
                  ));
                }
                return Expanded(
                  child: ListView(
                    children: messageStreams,
                  ),
                );
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              // alignment: Alignment.bottomCenter,

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      firestore.collection('messages').add({
                        'sender': user.email,
                        'text': messageText,
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final text;
  final sender;

  const MessageTile({Key key, this.text, this.sender}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
        elevation: 12,
        color: Colors.blueAccent,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              Text(
                sender,
                style: TextStyle(
                  color: Colors.black87,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
