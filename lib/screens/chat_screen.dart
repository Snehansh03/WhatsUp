import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {

  ChatScreen({this.otherUser});

  String otherUser='';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final _firestore=Firestore.instance;
  final _auth=FirebaseAuth.instance;
  FirebaseUser loggedInUser;
  String messageText;
  final messageController=TextEditingController();


  @override
  void initState() {
    super.initState();
    getCurrentUser();
    print(widget.otherUser);
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
      }
    }
    catch(e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.remove('email');
                _auth.signOut();
                Navigator.pushNamed(context, 'welcome_screen');
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
              stream: _firestore.collection('messages').orderBy('created').snapshots(),
              builder: (context,snapshot){
                if(!snapshot.hasData){
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                  );
                }
                final messages=snapshot.data.documents.reversed;
                List<MessageBubble> messageWidgets=[];
                for (var message in messages){
                  final messageText=message.data['text'];
                  final messageSender=message.data['sender'];
                  final messageReceiver=message.data['receiver'];
                  if(messageSender==loggedInUser.email && messageReceiver==widget.otherUser || messageSender==widget.otherUser && messageReceiver==loggedInUser.email ) {
                    final messageWidget = MessageBubble(sender: messageSender,
                        text: messageText,
                        isMe: loggedInUser.email == messageSender);
                    messageWidgets.add(messageWidget);
                  }
                }
                return Expanded(
                  child: ListView(
                    reverse: true,
                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
                    children: messageWidgets,
                ),
                );
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      onChanged: (value) {
                        messageText=value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageController.clear();
                      _firestore.collection('messages').add({
                        'text':messageText,
                        'sender':loggedInUser.email,
                        'receiver':widget.otherUser,
                        'created': FieldValue.serverTimestamp()
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

class MessageBubble extends StatelessWidget {

  MessageBubble({this.sender,this.text,this.isMe});

  String text;
  String sender;
  bool isMe;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
        Text(
        sender.substring(0,sender.indexOf("@")),
        style:TextStyle(
            color: Colors.black54
        ),
      ),
      Material(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30),bottomRight: Radius.circular(30),topLeft:isMe ? Radius.circular(30) :Radius.circular(0),topRight:isMe ? Radius.circular(0) :Radius.circular(30)),
        elevation: 15,
        color:isMe ? Colors.lightBlueAccent: Colors.white70,
        child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
              child: Text(
                text,
              style: TextStyle(
                color:isMe ? Colors.white :Colors.black54,
                fontSize: 15,
              ),
              ),
            ),
        ),
      ],
      ),
    ) ;
  }
}
