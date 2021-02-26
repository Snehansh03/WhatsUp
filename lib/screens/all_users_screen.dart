import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';

class AllUsersScreen extends StatefulWidget {

  @override
  _AllUsersScreenState createState() => _AllUsersScreenState();
}

class _AllUsersScreenState extends State<AllUsersScreen> {

  final _firestore=Firestore.instance;
  final _auth=FirebaseAuth.instance;
  FirebaseUser loggedInUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
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
        title: Text(
            'WhatsUp'
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('users').orderBy('created').snapshots(),
              builder: (context,snapshot){
                if(!snapshot.hasData){
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                  );
                }
                final users=snapshot.data.documents;
                List<UsersBubble> usersWidgets=[];
                for (var user in users){
                  final emailText=user.data['email'];
                  if(emailText != loggedInUser.email) {
                    final userWidget = UsersBubble(username: emailText);
                    usersWidgets.add(userWidget);
                  }
                }
                return Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
                    children: usersWidgets,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class UsersBubble extends StatelessWidget {

  UsersBubble({this.username});

  String username;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: (){
        Navigator.push(context,MaterialPageRoute(builder: (context){
          return ChatScreen(otherUser: username);
        },
        ),
        );
      },
      child: Container(
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 10,right: 10),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage('https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcRydqj0adQagAk1DaMTYWnQ8X2SNdt9tCfkvA&usqp=CAU'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10,right: 10),
                  child: Text(
                    username.substring(0,username.indexOf("@")),
                    style:TextStyle(
                        color: Colors.black54
                    ),
                  ),
                ),
              ],
            ),
            Divider(
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}


