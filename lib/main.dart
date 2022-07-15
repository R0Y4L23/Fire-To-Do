// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_function_declarations_over_variables, unused_local_variable, non_constant_identifier_names, avoid_print, avoid_function_literals_in_foreach_calls, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CollectionReference TodoList = FirebaseFirestore.instance.collection('Items');

  Future<void> getData() async {
    FirebaseFirestore.instance
        .collection('Items')
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        Todos = querySnapshot.docs;
      });
    });
  }

  String nowEditing = "";

  @override
  void initState() {
    super.initState();
    getData();
  }

  TextEditingController todoController = TextEditingController();
  TextEditingController modifyTodoController = TextEditingController();

  List Todos = [];

  Future<void> addOrUpdateTodo(
      String id, String title, String date, bool done) async {
    // Call the user's CollectionReference to add a new user
    TodoList.doc(id).set({
      'id': id,
      'title': title,
      'date': date,
      'done': done,
    });
    return getData();
  }

  Future<void> deleteTodo(String id) async {
    // Call the user's CollectionReference to add a new user
    TodoList.doc(id).delete();
    return getData();
  }

  @override
  Widget build(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;
    var deviceHeight = MediaQuery.of(context).size.height;

    var getWidth = (double percent) => deviceWidth * percent / 100;
    var getHeight = (double percent) => deviceHeight * percent / 100;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 28),
                  child: Image.asset(
                    'assets/note.png',
                    width: 100,
                    height: 100,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: getHeight(2),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: getWidth(60),
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter Here...',
                    ),
                    controller: todoController,
                  ),
                ),
                SizedBox(
                  width: getWidth(20),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        String dateString = DateTime.now().toString();
                        if (todoController.text.isNotEmpty) {
                          addOrUpdateTodo(
                              todoController.text + dateString,
                              todoController.text,
                              dateString.substring(0, 10),
                              false);
                          todoController.text = '';
                        }
                      });
                    },
                    child: Icon(
                      Icons.add_circle_rounded,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: getHeight(2),
            ),
            SizedBox(
              height: getHeight(70),
              child: Todos.isNotEmpty
                  ? ListView(
                      children: Todos.map((todo) {
                        if (nowEditing != todo.id) {
                          return ListTile(
                              title: Text(todo['title']),
                              subtitle: Text("Date Added : " + todo['date']),
                              trailing: SizedBox(
                                width: getWidth(30),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        deleteTodo(todo['id']);
                                      },
                                    ),
                                    InkWell(
                                        onTap: () {
                                          addOrUpdateTodo(
                                              todo['id'],
                                              todo['title'],
                                              todo['date'],
                                              !todo['done']);
                                        },
                                        child: Icon(
                                          Icons.check_circle,
                                          color: todo['done']
                                              ? Colors.green
                                              : Colors.grey,
                                        )),
                                    SizedBox(
                                      width: getWidth(3),
                                    ),
                                    InkWell(
                                        onTap: () {
                                          if (nowEditing == "") {
                                            setState(() {
                                              nowEditing = todo['id'];
                                            });
                                          }
                                        },
                                        child: Icon(Icons.edit,
                                            color: nowEditing == ""
                                                ? Colors.blue
                                                : Colors.grey)),
                                  ],
                                ),
                              ));
                        } else {
                          modifyTodoController.text = todo['title'];
                          return ListTile(
                              title: TextField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Modify Here...',
                                ),
                                controller: modifyTodoController,
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  String dateString = DateTime.now().toString();
                                  addOrUpdateTodo(
                                      nowEditing,
                                      modifyTodoController.text,
                                      dateString.substring(0, 10),
                                      todo['done']);
                                  setState(() {
                                    nowEditing = "";
                                  });
                                },
                                icon: Icon(
                                  Icons.done,
                                  color: Colors.green,
                                ),
                              ));
                        }
                      }).toList(),
                    )
                  : Center(
                      child: Text(
                        'No Todos',
                        style: TextStyle(
                          fontSize: getHeight(5),
                        ),
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
