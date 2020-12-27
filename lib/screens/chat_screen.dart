import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ChatScreen extends StatefulWidget {
  static const String id = 'chatScreen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseUser user;
  String messageText;
  final firestore = Firestore.instance;

  Future<void> getCurrentUser() async {
    var currentUser = await firebaseAuth.currentUser();
    if (currentUser != null) {
      user = await currentUser;
      print(user.email);
    }
  }

  Future<void> getMessages() async {
    var messages = await firestore.collection('messages').getDocuments();

    for (var message in messages.documents) {
      print(message.data['text']);
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
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
            MessageStream(firestore: firestore, user: user),
            Container(
              decoration: kMessageContainerDecoration,
              // alignment: Alignment.bottomCenter,

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
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

class MessageStream extends StatelessWidget {
  const MessageStream({
    Key key,
    @required this.firestore,
    @required this.user,
  }) : super(key: key);

  final Firestore firestore;
  final FirebaseUser user;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('messages').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return ModalProgressHUD(
            inAsyncCall: true,
            child: Container(
              width: 200,
              height: 200,
            ),
          );
        }
        final messages = snapshot.data.documents;

        bool isme = false;
        List<MessageTile> messageStreams = [];
        for (var message in messages) {
          final messageSender = message.data['sender'];
          final messageText = message.data['text'];

          if (messageSender == user.email) {
            isme = true;
          }

          messageStreams.add(MessageTile(
            sender: messageSender.toString().split('@')[0],
            text: messageText,
            isme: isme,
          ));
        }
        return Expanded(
          child: ListView(
            children: messageStreams,
          ),
        );
      },
    );
  }
}

class MessageTile extends StatelessWidget {
  final text;
  final sender;
  final bool isme;

  const MessageTile({
    Key key,
    this.text,
    this.sender,
    this.isme,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
          bottomLeft: Radius.circular(25),
        ),
        elevation: 12,
        color: isme ? Colors.blueAccent : Colors.pinkAccent,
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
